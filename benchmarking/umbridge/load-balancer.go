package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"strings"
	"sync"
	"syscall"
	"text/template"
	"time"
)

var nodes []string
var mutex sync.Mutex
var populated_nodes = make(chan bool)

type CaddyConfig struct {
	Nodes string
	Port  int
}

type JobScriptConfig struct {
	ServerPath         string
	LoadBalancerIPPort string
}

const jobScriptTemplate = `#! /bin/bash

#HQ --cpus=1
#HQ --time-request=10m
#HQ --time-limit=60m
#HQ --stdout none
#HQ --stderr none

# Launch model server, send back server URL
# and wait to ensure that HQ won't schedule any more jobs to this allocation.

function get_available_port {
    # Define the range of ports to select from
    MIN_PORT=1024
    MAX_PORT=65535

    # Generate a random port number
    port=$(shuf -i $MIN_PORT-$MAX_PORT -n 1)

    # Check if the port is in use
    while lsof -Pi :$port -sTCP:LISTEN -t >/dev/null; do
        # If the port is in use, generate a new random port number
        port=$(shuf -i $MIN_PORT-$MAX_PORT -n 1)
    done

    echo $port
}

port=$(get_available_port)
export PORT=$port

# Assume that server sets the port according to the environment variable 'PORT'.
{{.ServerPath}} &

host=$(hostname -I | awk '{print $1}')

echo "Waiting for model server to respond at $host:$port..."
while ! curl -s "http://$host:$port/Info" > /dev/null; do
    sleep 1
done
echo "Model server responded"

IP=$(hostname -I | cut -d' ' -f1)
curl -X POST http://{{.LoadBalancerIPPort}}/register -d "ip=$IP&port=$PORT"

sleep infinity # keep the job occupied
`

const usage = `Spawns a HTTP load balancer using Caddy, with HyperQueue integration for model server distribution.

Flags:
	-s, --server 		[path]	Filepath to model server bash script
	-n, --num-replicas 	[int] 	Number of parallel model servers to run
	-h, --help 			Prints help information 

Usage: ./load-balancer [flags]
`

const caddyTemplate = `:{{.Port}} {
    	reverse_proxy {
        		to {{.Nodes}}
        		lb_policy least_conn
				lb_retries 2
				health_uri /Info
				health_interval 5s
				health_timeout 2s
				health_status 2xx
    	}
}`


func getLocalIP() (string, error) {
	conn, err := net.Dial("udp", "8.8.8.8:80")
	if err != nil {
		return "", err
	}
	defer conn.Close()

	localAddr := conn.LocalAddr().(*net.UDPAddr)
	return localAddr.IP.String(), nil
}

func getAbsolutePath(serverPath string) (string, error) {
	absolutePath, err := filepath.Abs(serverPath)
	if err != nil {
		return "", err
	}
	return absolutePath, nil
}

func generateJobScript(serverPath string, localIP string) {
	absPath, err := getAbsolutePath(serverPath)
	if err != nil {
		log.Fatalf("Failed to get absolute path: %v", err)
	}

	config := JobScriptConfig{
		ServerPath:         absPath,
		LoadBalancerIPPort: localIP + ":8080",
	}

	t, err := template.New("bashScript").Parse(jobScriptTemplate)
	if err != nil {
		panic(err)
	}

	file, err := os.Create("hq_scripts/job.sh")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	if err := t.Execute(file, config); err != nil {
		panic(err)
	}

	println("Job script generated successfully")
}

func spawnHyperqueueWorkers(numReplicas int) {
	cmd := exec.Command("./hq", "server", "start")
	if err := cmd.Start(); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}

	// Sleep for 1 second
	time.Sleep(1 * time.Second)

	// Run initial script after server start
	if err := exec.Command("./hq_scripts/allocation_queue.sh").Run(); err != nil {
		log.Fatalf("Failed to run allocation queue script: %v", err)
	}

	// Loop to submit jobs based on numReplicas
	for i := 0; i < numReplicas; i++ {
		if err := exec.Command("./hq", "submit", "--output-mode=quiet", "./hq_scripts/job.sh").Run(); err != nil {
			log.Printf("Failed to submit job %d: %v", i+1, err)
		} else {
			log.Printf("Successfully submitted job %d", i+1)
		}
	}
}

func startServer(numReplicas int) {
	http.HandleFunc("/register", func(w http.ResponseWriter, r *http.Request) {
		ip := r.FormValue("ip")
		port := r.FormValue("port")
		node := ip + ":" + port

		mutex.Lock()
		// Ensure the node is not already registered to handle potential duplicates
		if !contains(nodes, node) {
			nodes = append(nodes, node)
			fmt.Fprintf(w, "Registered node %s\n", node)
		}

		// If we have reached the required number of unique nodes, signal completion
		if len(nodes) >= numReplicas {
			populated_nodes <- true
		}
		mutex.Unlock()
	})

	log.Fatal(http.ListenAndServe(":8080", nil))
}

// Helper function to check if a node is already in the list
func contains(slice []string, val string) bool {
	for _, item := range slice {
		if item == val {
			return true
		}
	}
	return false
}

func waitForNodes() {
	<-populated_nodes // waits until this channel is populated with true bool from startServer
	fmt.Println("All nodes have registered.")
}

func generateCaddyfile(nodes []string) {
	// Join all nodes with a space to fit the 'to' directive in Caddyfile
	nodesStr := strings.Join(nodes, " ")

	// Create an instance of CaddyConfig with the list of nodes and port
	config := CaddyConfig{
		Nodes: nodesStr,
		Port:  4242,
	}

	// Parse the template
	t, err := template.New("caddyfile").Parse(caddyTemplate)
	if err != nil {
		panic(err)
	}

	file, err := os.Create("Caddyfile")
	if err != nil {
		panic(err)
	}
	defer file.Close()

	if err := t.Execute(file, config); err != nil {
		panic(err)
	}

	fmt.Println("Caddyfile generated successfully.")
}

func runCaddy() {
	cmd := exec.Command("./caddy", "run", "--config", "Caddyfile")
	cmd.Stdout = nil // Suppress stdout
	cmd.Stderr = nil // Suppress stderr

	// Start the Caddy server without waiting for it to complete
	if err := cmd.Start(); err != nil {
		fmt.Println("Error starting Caddy:", err)
		return
	}

	// Optionally, you can handle cmd.Wait() in a goroutine if you need to capture when Caddy exits
	go func() {
		if err := cmd.Wait(); err != nil {
			fmt.Println("Caddy exited with error:", err)
		} else {
			fmt.Println("Caddy exited successfully.")
		}
	}()
}

func main() {
	var serverPath string
	var numReplicas int

	flag.StringVar(&serverPath, "s", "", "Path to the server bash script")
	flag.StringVar(&serverPath, "server", "", "Path to the server bash script")
	flag.IntVar(&numReplicas, "n", 1, "Number of parallel model servers to run")
	flag.IntVar(&numReplicas, "num-replicas", 1, "Number of parallel model servers to run")
	flag.Usage = func() { fmt.Print(usage) }
	flag.Parse()

	if serverPath == "" {
		fmt.Println("Error: You must specify a server script path.\nType ./load-balancer --help for further information.")
		os.Exit(1)
	}

	go startServer(numReplicas)

	localIP, err := getLocalIP()
	if err != nil {
		log.Fatalf("Failed to get local IP: %v", err)
	}

	fmt.Printf("Spawning model servers (%d replicas)\n", numReplicas)
	generateJobScript(serverPath, localIP)
	spawnHyperqueueWorkers(numReplicas)

	fmt.Println("Waiting for nodes to register...")
	waitForNodes()

	// Generate Caddyfile
	generateCaddyfile(nodes)

	// Run Caddy
	fmt.Println("Starting Caddy server...")
	runCaddy()

	fmt.Printf("Load balancer ready! Available at %s:4242\n", localIP)

	// Set up a channel to listen for interrupt signal (Ctrl-C)
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt, syscall.SIGTERM)

	// Block until a signal is received.
	s := <-sigChan
	fmt.Println("Received signal:", s)
	fmt.Println("Exiting now.")
	os.Exit(0)
}
