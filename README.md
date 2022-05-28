Following tutorial: https://fluxcd.io/docs/get-started/

Bootstrap this repo:
Had to use a different owner name since I've changed my username in github which changes the slug for the repos but not the internal name for git.
Also made the repo public.

```
flux bootstrap github \
  --owner=cirano-eusebi \
  --repository=fleet-infra \
  --branch=main \
  --path=./clusters/my-cluster \
  --private=false \
  --personal
```


Flux needs to have a source and a kustomization to determine `what` and `where and when` respectively.
Add a samlple app source with
```
flux create source git podinfo \
  --url=https://github.com/stefanprodan/podinfo \
  --branch=master \
  --interval=30s \
  --export > ./clusters/sandbox/podinfo-source.yaml
```
Commit and push (does it need to happen in different steps?)

Then add the kustomization sync:
The path depends on where the kustomization.yaml is on the source repo
The source is the name of the flux source used to find the `what`
The target-namespace needs to exist (at least for GitRepo sources)
```
flux create kustomization podinfo \
  --target-namespace=podinfo \
  --source=podinfo \
  --path="./kustomize" \
  --prune=true \
  --interval=5m \
  --export > ./clusters/sandbox/podinfo-kustomization.yaml
```
---

I've done some experimentation with the structure of the repo. I find more usefull for all apps to have it's own `flux kustomization` definition in order to keep first-class citzenship (being able to configure sync schedules and dependencies)
This means that instead of having one `flux kustomization` in the cluster folder + a `k8s kustomization` with all the apps listed outside, I don't use `k8s kustomizations` to group apps/infra. `k8s kustomization` is only used for overlays/ grouping of functionality specific for 1 application.  
This decision can be troublesome if we wanted to provide cluster wide policies like overriding the container registry for all services or adding labels/annotations globally.
