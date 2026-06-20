#!/bin/bash
# bootstrap/access.sh

echo "🌐 Forwarding ArgoCD to http://localhost:8080"
kubectl port-forward svc/argocd-server -n argocd 8080:443