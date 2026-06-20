#!/bin/bash
# bootstrap/setup.sh

set -e # Exit immediately if a command fails

# Use your specific driver to ensure consistency!
echo "🚀 Starting Minikube with Docker driver..."
minikube start --driver=docker

echo "📦 Creating argocd namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo "⚙️ Applying ArgoCD manifests using Server-Side Apply..."
# The --server-side flag is the key to preventing "Too long" errors
kubectl apply -n argocd --server-side -f bootstrap/argocd-install.yaml

echo "⏳ Waiting for ArgoCD to become ready..."
kubectl rollout status deployment/argocd-server -n argocd --timeout=300s

echo "--------------------------------------------------------"
echo "Bootstrap complete!"
echo "ArgoCD is now running in the 'argocd' namespace."
echo "Use the following command to retrieve the initial password:"
echo "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo"
echo "--------------------------------------------------------"