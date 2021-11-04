This is the first draft of deploying Jambonz on Kubernetes (K8S). The K8S manifests are built based on the Docker compose file in the same repository.

# Manual steps

- Setup MySQL databases and tables
- Setup public DNS for `webapp` and `api-server`. It looks like that `webapp` connects to `api-server` in the front-end, so public DNS for `api-server` is needed.

# Deployment

The current deployment uses Kustomize:

```bash
kubectl apply -k .
```

# TODO

- Use Secret to store MySQL password
- Setup MySQL databases and tables using sidecar