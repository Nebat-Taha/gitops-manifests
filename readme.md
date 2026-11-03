# GitOps Manifests and Argo CD

The GitOps manifests repository defines the desired Kubernetes state for the GitOps Python application. It uses Kustomize to manage the application's image version in the Kubernetes manifests, while Argo CD continuously reconciles the declared configuration with the live Kubernetes cluster. 

This repository works with the [application repository](https://github.com/Nebat-Taha/gitops-python-app). GitHub Actions builds and publishes the application image, then updates the image tag in this repository. Argo CD observes that Git change and reconciles the application in the cluster.

## Architecture

The deployment platform follows a pull-based GitOps model:

- **Git as the source of truth:** Kubernetes deployment configuration and the desired application image version are stored in this repository.
- **Argo CD observes Git:** Argo CD monitors the configured repository path and compares the declared state with the live cluster.
- **Kubernetes maintains the desired state:** The Deployment declares two application replicas, and Kubernetes works to maintain that replica count.
- **Decoupled CI and CD:** GitHub Actions updates the image reference in Git; Argo CD performs the deployment. The CI workflow does not require direct Kubernetes deployment credentials.

The application source and deployment configuration are kept in separate repositories to establish a clear boundary between building the application and defining how it runs.

## Key Capabilities

- **Declarative workload management:** Kubernetes Deployment and Service resources describe the application workload and its network exposure.
- **Kustomize-based image management:** The desired image tag is maintained in `kustomization.yaml`, allowing the CI workflow to update the version without rewriting the Deployment manifest.
- **Automated synchronization:** Argo CD can automatically apply changes detected in the configured Git revision.
- **Self-healing:** With self-heal enabled in the Argo CD Application, live changes that diverge from the declared Git state can be reconciled.
- **Replica management:** The Deployment declares two replicas, allowing Kubernetes to replace a Pod when one is removed or becomes unavailable.
- **Repeatable local environment setup:** Bootstrap scripts start Minikube and install Argo CD to prepare the environment for the demonstration.

## Deployment Workflow

1. A developer pushes an application change to the `main` branch of `gitops-python-app`.
2. GitHub Actions builds a container image tagged with the source commit SHA.
3. Following the configured publication approval, the workflow pushes the image to Docker Hub.
4. The workflow updates the image tag in `base/kustomization.yaml` and commits the change to this repository.
5. Argo CD detects the new Git revision and compares the updated manifests with the live cluster.
6. Argo CD synchronizes the desired state, and Kubernetes performs the rollout using the updated image.
7. Kubernetes continues to maintain the replica count declared by the Deployment.

No direct deployment command from the CI workflow is needed. The change to the manifests repository is the hand-off that triggers the GitOps deployment process.

## Design Decisions

### Separate application and manifests repositories

Application source and Kubernetes configuration have different responsibilities and change patterns. Keeping them separate makes the desired deployment state independently visible and version-controlled, while allowing the application pipeline to update that state through a controlled repository change.

### Commit-SHA image tags

The image tag identifies the source commit used to build the image. This avoids relying on a mutable `latest` tag and makes it easier to associate a running application version with its source revision.

### Pull-based deployment with Argo CD

Argo CD monitors the Git repository and applies the desired configuration to Kubernetes. This keeps cluster deployment responsibility with the GitOps controller rather than placing Kubernetes credentials and direct deployment commands in the CI workflow.

### Kustomize for image updates

Kustomize provides a declarative location for the image reference. The CI workflow updates the image tag in the Kustomize configuration while leaving the workload definition focused on the application's Kubernetes settings.

### Local bootstrap automation

The bootstrap scripts make the Minikube and Argo CD environment repeatable. The setup script starts Minikube, creates the Argo CD namespace, applies the Argo CD installation manifest using server-side apply, and waits for the Argo CD server deployment to become ready. A separate helper script provides local port forwarding to the Argo CD interface.

## Repository Structure

```text
gitops-manifests/
├── base/
│   ├── deployment.yaml       # Application Deployment and replica definition
│   ├── service.yaml          # Service exposing the application
│   └── kustomization.yaml    # Resources and versioned image reference
├── bootstrap/
│   ├── access.sh             # Port-forward helper for the Argo CD interface
│   ├── argocd-install.yaml   # Argo CD installation resources
│   └── setup.sh              # Minikube and Argo CD bootstrap
└── README.md
```

## Technology Stack

| Technology | Role |
|---|---|
| Kubernetes | Declarative application workload and replica management |
| Minikube | Local Kubernetes environment |
| Argo CD | GitOps reconciliation, automated sync, and self-healing |
| Kustomize | Kubernetes manifest composition and image version management |
| Docker | Container runtime support for the local cluster |
| Bash | Environment bootstrap and access automation |
| GitHub Actions | Updates the desired image version in this repository |

## Related Repository

[FastAPI application and CI pipeline — `gitops-python-app`](https://github.com/Nebat-Taha/gitops-python-app)

## Demo

[Watch the project walkthrough on YouTube]([YOUR_YOUTUBE_DEMO_LINK](https://youtu.be/zAM_jwJR8T0))
