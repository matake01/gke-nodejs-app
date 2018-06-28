# GKE NodeJS App

This project illustrates how to build and deploy a simple app to the Google Kubernetes Engine and with support for canary deployments.


## Quickstart

### Setup the environment

Open the file `./scripts/set-env.sh` and set the correct values for your environment.

```sh
./scripts/set-env.sh;
```

```sh
./scripts/gke-setup.sh;
```

```sh
./scripts/build-and-push-image.sh;
./scripts/deploy-version-production.sh;
```

```sh
export VERSION_NUMBER=2.0
./scripts/build-and-push-image.sh;
./scripts/deploy-version-canary.sh;
```

```sh
./scripts/gke-cleanup.sh;
```

## The hard way

### 1. Setup GCP/Kubernetes

Setup the project:

```sh
gcloud config set project <PROJECT_ID>;
gcloud config set compute/zone <ZONE_ID>;
```

Create the cluster:

```sh
export CLUSTER_NAME=<CLUSTER_NAME>;
gcloud container clusters create $CLUSTER_NAME --num-nodes=3;
gcloud container clusters get-credentials $CLUSTER_NAME;
```

Create namespace:
```sh
kubectl create namespace production
```

### 2. Build and deploy production

Set version number:

```sh
export VERSION_NUMBER=1.0;
```

Build and push images to GCP:

```sh
export PROJECT_ID=$(gcloud info --format='value(config.project)');
docker build -t gcr.io/$PROJECT_ID/app:$VERSION_NUMBER .;
gcloud docker -- push gcr.io/$PROJECT_ID/app:$VERSION_NUMBER;
```

Deploy to GKE:

```sh
sed -i.bak "s/PROJECT_ID/$PROJECT_ID/; s/VERSION_NUMBER/$VERSION_NUMBER/;" k8s/app-production.yml;
kubectl --namespace=production apply -f k8s/app-production.yml
kubectl --namespace=production rollout status deployment/kubeapp-production
```

Make externally accessible:

```sh
kubectl --namespace=production apply -f k8s/app-ingress-production.yml
kubectl --namespace=production describe ingress
export SERVICE_IP=$(kubectl --namespace=production get ingress/app-ingress --output=json | jq -r '.status.loadBalancer.ingress[0].ip')
curl http://$SERVICE_IP/
```

### 4. Build and deploy canary

Set version number:

```sh
export VERSION_NUMBER=2.0;
```

Build and push images to GCP:

```sh
export PROJECT_ID=$(gcloud info --format='value(config.project)');
docker build -t gcr.io/$PROJECT_ID/app:$VERSION_NUMBER .;
gcloud docker -- push gcr.io/$PROJECT_ID/app:$VERSION_NUMBER;
```

Deploy to GKE:

```sh
sed -i.bak "s/PROJECT_ID/$PROJECT_ID/; s/VERSION_NUMBER/$VERSION_NUMBER/;" k8s/app-canary.yml;
kubectl --namespace=production apply -f k8s/app-canary.yml
kubectl --namespace=production rollout status deployment/kubeapp-canary
```

Create the ingress:

```sh
kubectl --namespace=production apply -f k8s/app-ingress-canary.yml
kubectl --namespace=production describe ingress
export INGRESS_IP=$(kubectl --namespace=production get ing/app-ingress --output=json | jq -r '.status.loadBalancer.ingress[0].ip')
echo "$INGRESS_IP foo.bar canary.foo.bar" | sudo tee -a /etc/hosts
```


### 5. Test HTTP Access

```sh
curl http://foo.bar/version
curl http://canary.foo.bar/version
```

### 6. Troubleshooting

```sh
kubectl --namespace=... get services;
kubectl --namespace=... get pods -o wide;
kubectl --namespace=... get events -w;
```

### 7. Cleanup

Delete the service:

```sh
kubectl --namespace=production delete service kubeapp-production-service
kubectl --namespace=production delete service kubeapp-canary-service
```

Wait for the Load Balancer provisioned for the app service to be deleted:

```sh
gcloud compute forwarding-rules list
```

Delete the container cluster:

```sh
gcloud container clusters delete $CLUSTER_NAME
```