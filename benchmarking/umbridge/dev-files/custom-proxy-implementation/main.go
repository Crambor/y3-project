package main

import (
	"bytes"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"sync"
)

type Node struct {
	URL string
}

type LoadBalancer struct {
	nodes      []*Node
	currentIdx int
	lock       sync.Mutex
}

func NewLoadBalancer(nodeURLs []string) *LoadBalancer {
	nodes := make([]*Node, len(nodeURLs))
	for i, url := range nodeURLs {
		nodes[i] = &Node{URL: url}
	}
	return &LoadBalancer{nodes: nodes, currentIdx: 0}
}

// returns the next node to handle a request using round-robin scheduling
func (lb *LoadBalancer) getNextNode() *Node {
	lb.lock.Lock()
	defer lb.lock.Unlock()
	node := lb.nodes[lb.currentIdx]
	lb.currentIdx = (lb.currentIdx + 1) % len(lb.nodes)
	return node
}

func (lb *LoadBalancer) handleRequest(w http.ResponseWriter, r *http.Request) {
	node := lb.getNextNode()

	// fmt.Printf("Forwarding request for %s to node %s\n", r.URL.Path, node.URL)

	// read req. body for forwarding
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		http.Error(w, "Failed to read request body: "+err.Error(), http.StatusInternalServerError)
		return
	}
	defer r.Body.Close()

	// wrap a new request to proxy back to a node
	req, err := http.NewRequest(r.Method, node.URL+r.URL.Path, bytes.NewReader(body))
	if err != nil {
		http.Error(w, "Failed to create request: "+err.Error(), http.StatusInternalServerError)
		return
	}
	req.Header = r.Header

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		http.Error(w, "Failed to forward request: "+err.Error(), http.StatusInternalServerError)
		return
	}
	defer resp.Body.Close()

	// copy response headers and status code back to the original client
	for key, value := range resp.Header {
		w.Header()[key] = value
	}
	w.WriteHeader(resp.StatusCode)

	// send the response body back to the original client
	if _, err := io.Copy(w, resp.Body); err != nil {
		http.Error(w, "Failed to send response: "+err.Error(), http.StatusInternalServerError)
	}
}

func main() {
	// manual input for now
	// TODO: dynamic allocation for this NodeList
	lb := NewLoadBalancer([]string{"http://cn01:4243", "http://cn02:4243", "http://cn03:4243", "http://cn04:4243"})

	http.HandleFunc("/", lb.handleRequest)
	fmt.Println("Load balancer starting on port 4242...")
	if err := http.ListenAndServe(":4242", nil); err != nil {
		fmt.Println("Error starting server:", err)
	}
}
