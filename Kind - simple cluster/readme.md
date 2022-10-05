# Overview

When working with Kubernetes, we often lack a tool that helps in local development — a way run local Kubernetes cluster.  
In a few moments you will dicover a way to do that with kind.  

[Kind](https://kind.sigs.k8s.io/) is a testing tool for Kubernetes, but can be handy for local development.

## Prerequisites

Below full list of prerequisites with installation guides:
- [Linux](https://images-wixmp-ed30a86b8c4ca887773594c2.wixmp.com/f/63ca2442-fb2d-4227-8155-0935dd7feb4b/d67fzf-8895380b-f580-4ec9-b95b-016e17fdd126.png/v1/fill/w_1024,h_768,q_75,strp/linux_forever_by_mixa87.png?token=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJ1cm46YXBwOjdlMGQxODg5ODIyNjQzNzNhNWYwZDQxNWVhMGQyNmUwIiwic3ViIjoidXJuOmFwcDo3ZTBkMTg4OTgyMjY0MzczYTVmMGQ0MTVlYTBkMjZlMCIsImF1ZCI6WyJ1cm46c2VydmljZTppbWFnZS5vcGVyYXRpb25zIl0sIm9iaiI6W1t7InBhdGgiOiIvZi82M2NhMjQ0Mi1mYjJkLTQyMjctODE1NS0wOTM1ZGQ3ZmViNGIvZDY3ZnpmLTg4OTUzODBiLWY1ODAtNGVjOS1iOTViLTAxNmUxN2ZkZDEyNi5wbmciLCJ3aWR0aCI6Ijw9MTAyNCIsImhlaWdodCI6Ijw9NzY4In1dXX0.GLrSgSMRgEvy-NSJ_eYFZpo9Q4UPOWMHzBBIn5WaPyo)
- [Golang](https://go.dev/doc/install)
- [Docker](https://docs.docker.com/desktop/install/linux-install/)
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

# Kicking the Tires

## Cluster setup

Let's create a local Kubernetes cluster with the YAML config file.  
```
kind create cluster --config clusterDeployment.yaml
```  

Next, check the created cluster by quering some general informations.
- `kind get clusters`  
- `kubectl cluster-info --context kind-kind`  
- `docker ps`  
- `kubectl get nodes`  

If you want to try with default configuration, then go [here.](https://kind.sigs.k8s.io/#installation-and-usage)

## Ingress 

Kubernetes without Ingress is like a car without doors, noone can access it, so let's add one.  
Why we need an ingress controller? Because we want to establish a connection between our local environment and the Kubernetes cluster.

Let's try the [Contour ingress](https://projectcontour.io/resources/philosophy/).  
You may ask why not something else, but this particular project is under heavy development still so this seems to be the only way how you can satisfy your curiosity.  
But no pressure, you can use everything you want!  

```
kubectl apply -f https://projectcontour.io/quickstart/contour.yaml
kubectl patch daemonsets -n projectcontour envoy --patch-file ingressPatch.yaml
```
As you can see we applied a [kind specific patch](https://kind.sigs.k8s.io/docs/user/ingress/#contour) to allow Envoy pods to run on our single master node for our lab.

Also we [created cluster](https://kind.sigs.k8s.io/docs/user/ingress/#create-cluster) with letting know kind that we will require Ingress in the future.

## Fun finally

Now is the proper time to deploy our application. We will use a simple, easy to use web server from Hashicorp - [HTTP-echo](https://github.com/hashicorp/http-echo).   
```
kubectl apply -f appDeployment.yaml
```

Let's try it!  
- `curl localhost/hello`  
- `curl localhost/ping`

## Under the hood

Verify resources we've created using `kubectl get` command:
- `kubectl get services`
- `kubectl get pods`
- `kubectl get ingress`

You can try also `kubectl describe \ logs` for moe information.

## After fun

Delete the cluster and grab a beer!  
Good job today!    
```
kind delete cluster --name kind
```

# Conclusion

First, we created a Kubernetes local cluster using command line, docker, kubectl and kind.  
Last, we integrated the ingress controller and deployed a privately accessible service on the Kubernetes cluster.