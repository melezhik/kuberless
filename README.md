POC
===

See https://github.com/melezhik/Sparrow6/blob/master/posts/Application%20Less%20Containers.md

Quick start
===========

```
minikube image build . -t kuberless:0.0.1
kubectl create deployment test126 --image=kuberless:0.0.1
```


Links
=====

Also - https://stackoverflow.com/questions/51026174/running-a-command-on-all-kubernetes-pods-of-a-service
