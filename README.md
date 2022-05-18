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
