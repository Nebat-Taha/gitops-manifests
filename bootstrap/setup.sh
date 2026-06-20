#!/bin/bash
# bootstrap/setup.sh

set -e # Exit immediately if a command fails

echo "🚀 Starting Minikube..."
minikube start

echo "📦 Creating argocd namespace..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

echo "⚙️ Applying ArgoCD manifests..."
kubectl apply -n argocd -f bootstrap/argocd-install.yaml

echo "⏳ Waiting for ArgoCD to become ready (this may take a minute)..."
kubectl rollout status deployment/argocd-server -n argocd --timeout=300s

echo "--------------------------------------------------------"
echo "Bootstrap complete!"
echo "ArgoCD is now running in the 'argocd' namespace."
echo "Use the following command to retrieve the initial password:"
echo "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo"
echo "--------------------------------------------------------"