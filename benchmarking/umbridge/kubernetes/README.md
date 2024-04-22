# Benchmarking - umbridge Kubernetes


This is the UM-Bridge kubernetes benchmarking code. I need to pad this out.


Bare-metal kubernetes does not provide an IP without metallb. you can bypass by using the controller local IP and NodePort, obtained from the following:
`kubectl describe service kubernetes-ingress --namespace=haproxy-controller | grep -A2 "80/TCP" | awk '/NodePort/ {print $3}'`

this will provide you the node IP that exposes the load balancer HTTP, allowing you to use it effectively.

