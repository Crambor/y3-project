package main

import (
	"bytes"
	"fmt"
	"io/ioutil"
	"net/http"
	"strings"
	"sync"
)

type Node struct {
	URL     string
	Channel chan *QueuedRequest
}

// golang esque attempt at queueing http requests using channels
type QueuedRequest struct {
	Request  *http.Request
	Response chan *ProcessedResponse
}

type ProcessedResponse struct {
	Body       []byte
	StatusCode int
	Header     http.Header
	Error      error
}

type LoadBalancer struct {
	nodes []*Node
	queue chan *QueuedRequest
	lock  sync.Mutex
}

func NewLoadBalancer(nodeURLs []string) *LoadBalancer {
	lb := &LoadBalancer{
		nodes: make([]*Node, len(nodeURLs)),
		queue: make(chan *QueuedRequest, 100),
	}
	for i, url := range nodeURLs {
		if !strings.HasPrefix(url, "http://") {
			url = "http://" + url // attempted fix to default to http if no schema defined
		}
		lb.nodes[i] = &Node{
			URL:     url,
			Channel: make(chan *QueuedRequest, 10),
		}
		go lb.nodes[i].processRequests()
	}
	go lb.distributeRequests()
	return lb
}

func (node *Node) processRequests() {
	client := &http.Client{}
	for queuedReq := range node.Channel {
		body, err := ioutil.ReadAll(queuedReq.Request.Body)
		if err != nil {
			fmt.Printf("Error reading body from request: %v\n", err)
			queuedReq.Response <- &ProcessedResponse{Error: err}
			continue
		}
		queuedReq.Request.Body.Close()

		req, err := http.NewRequest(queuedReq.Request.Method, node.URL+queuedReq.Request.URL.Path, bytes.NewReader(body))
		if err != nil {
			fmt.Printf("Error creating forwarded request: %v\n", err)
			queuedReq.Response <- &ProcessedResponse{Error: err}
			continue
		}

		req.Header = copyHeader(queuedReq.Request.Header)

		resp, err := client.Do(req)
		if err != nil {
			fmt.Printf("Error forwarding request: %v\n", err)
			queuedReq.Response <- &ProcessedResponse{Error: err}
			continue
		}
		defer resp.Body.Close()

		responseBody, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			fmt.Printf("Error reading response body: %v\n", err)
			queuedReq.Response <- &ProcessedResponse{Error: err}
			continue
		}

		queuedReq.Response <- &ProcessedResponse{
			Body:       responseBody,
			StatusCode: resp.StatusCode,
			Header:     resp.Header,
		}
	}
}

// header deep copying as attempted fix
func copyHeader(src http.Header) http.Header {
	dst := make(http.Header)
	for k, vv := range src {
		vv2 := make([]string, len(vv))
		copy(vv2, vv)
		dst[k] = vv2
	}
	return dst
}

func (lb *LoadBalancer) distributeRequests() {
	for req := range lb.queue {
		for _, node := range lb.nodes {
			node.Channel <- req
			break
		}
	}
}

func (lb *LoadBalancer) handleRequest(w http.ResponseWriter, r *http.Request) {
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Failed to read request body: "+err.Error(), http.StatusInternalServerError)
		fmt.Printf("\nheree1\n\n")
		return
	}
	defer r.Body.Close()

	clonedReq, err := http.NewRequest(r.Method, r.URL.String(), bytes.NewReader(body))
	if err != nil {
		http.Error(w, "Failed to clone request: "+err.Error(), http.StatusInternalServerError)
		fmt.Printf("\nheree2\n\n")
		return
	}
	clonedReq.Header = r.Header

	responseChan := make(chan *ProcessedResponse)
	lb.queue <- &QueuedRequest{Request: clonedReq, Response: responseChan}
	processedResp := <-responseChan

	if processedResp.Error != nil {
		http.Error(w, processedResp.Error.Error(), http.StatusInternalServerError)
		return
	}

	// manual content type attempted fix
	w.Header().Set("Content-Type", "application/json")

	// propagate all headers
	for key, values := range processedResp.Header {
		for _, value := range values {
			w.Header().Add(key, value)
		}
	}
	w.WriteHeader(processedResp.StatusCode)
	w.Write(processedResp.Body)
}

func main() {
	// manual input for now
	// TODO: dynamic allocation for this NodeList
	lb := NewLoadBalancer([]string{"http://cn01:4243", "http://cn02:4243"})

	http.HandleFunc("/", lb.handleRequest)
	fmt.Println("Load balancer starting on port 4242...")
	if err := http.ListenAndServe(":4242", nil); err != nil {
		fmt.Println("Error starting server:", err)
	}
}
