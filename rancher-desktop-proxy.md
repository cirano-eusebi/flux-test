When using rancher desktop without the traefik proxy there are a lot of things that should happen under the hood that stop happening:

- No ingress controller is deployed to the cluster
    - This is what we want most of the time, we disable it to allow for a different ingress controller to be installed
- No forwarding of ports Host -> VM -> Cluster is setup
    - This one is the issue

Rancher desktop configures `kubectl` and your container client of choice (`docker` or `containerd`) to point to a VM:
    - Lima (for MacOs and Linux)
    - WSL (for windows)
These VMs then setup the networking of the `k3d` cluster with flannel.  
The node created will have the IP of the VM

We are able to connect from the host machine to the VM IP (and that extends to all services defined as `NodePort`)
We are able to connect from the VM to the flannel network (and that extends to all services defined as `ClusterIP`)
We can't connect from the host machine directly to the flannel network (services defined as `ClusterIP` are not accessible from the host)

What we need to do then is define our ingress controller with a NodePort in order to give us access to the services that define ingresses.  
These ports MUST BE above 30000 which is not very user friendly for Http

Still, that only gives us access from the host to the ingress which is a private IP.  
We can leverage services like `nip.io` in order to define ingress rules like `demo.<node-ip>.nip.io`  
We won't be able to provide ACME signed certificates until the services can be reached from the internet.

For windows in particular, what we need to do is to forward all requests comming from the internet to the VM (and then it would go to the Ingress Controller)  
The way to do this is leveraging the `netsh` command that lets us configure windows networking and firewals.  
Here I'm using the `sudo` command that it's available for windows

First we setup the IPv4 proxy for all adresses to the VM ip in the ports configured in the ingress controller `NodePort` service (connectaddress and connectport)
```shell
sudo netsh interface portproxy add v4tov4 listenport=80 listenaddress=0.0.0.0 connectaddress=172.22.115.182 connectport=30080
sudo netsh interface portproxy add v4tov4 listenport=443 listenaddress=0.0.0.0 connectaddress=172.22.115.182 connectport=30443
```

Then we make sure we allow connections in the firewall (what we put on listenport)
```shell
sudo netsh advfirewall firewall add rule name="Open Http" dir=in action=allow protocol=TCP localport=80
sudo netsh advfirewall firewall add rule name="Open Https" dir=in action=allow protocol=TCP localport=443
```

These commands show if our rules were defined correctly
```shell
netsh interface portproxy show all
netsh advfirewall firewall show rule name="Open Http"
netsh advfirewall firewall show rule name="Open Https"
```

What we just did is basically the same as a port forward but `kubectl port-forward` doesn't allow connections from `0.0.0.0` (I checked the sourcecode), also this should be permanent.  
Now we can do `curl https://localhost` and it should hit the ingress controller.

And then the last step is to get some sort of DNS pointing to our public IP, either by using `nip.io` or a dynamic DNS service (I'm using https://www.dynu.com/ because it provides wildcard DNSs)
