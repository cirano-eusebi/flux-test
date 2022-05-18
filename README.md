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
