# GKE NodeJS App

This project illustrates how to build and deploy a simple app to the Google Kubernetes Engine and with support for canary deployments.

## Getting started

### 1. Setup GCP and Kubernetes

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

### 2. Build and push image

Setup environment variables:

```sh
export PROJECT_ID=$(gcloud info --format='value(config.project)');
export VERSION_NUMBER=1.0.0;
```

Build the image:

```sh
docker build -t gcr.io/$PROJECT_ID/app:$VERSION_NUMBER .;
gcloud docker -- push gcr.io/$PROJECT_ID/app:$VERSION_NUMBER;
```

### 3. Deploy production

Set values from environment in manifest:

```sh
sed -i.bak "s/PROJECT_ID/$PROJECT_ID/; s/VERSION_NUMBER/$VERSION_NUMBER/;" k8s/app-production.yml;
```

Create deployment:

```sh
kubectl --namespace=production apply -f app-production.yml
```

For troubleshooting:

```sh
kubectl --namespace=production rollout status deployment/kubeapp-production
```

Create the ingress:

```sh
kubectl --namespace=production apply -f app-ingress-production.yml
kubectl --namespace=production describe ingress
export SERVICE_IP=$(kubectl --namespace=production get ingress/app-ingress --output=json | jq -r '.status.loadBalancer.ingress[0].ip')
curl http://$SERVICE_IP/
```

### 4. Deploy canary

Set values from environment in manifest:

```sh
sed -i.bak "s/PROJECT_ID/$PROJECT_ID/; s/VERSION_NUMBER/$VERSION_NUMBER/;" k8s/app-canary.yml;
```

Create deployment:

```sh
kubectl --namespace=production apply -f app-canary.yml
```

For troubleshooting:

```sh
kubectl --namespace=production rollout status deployment/kubeapp-canary
```

Create the ingress:

```sh
kubectl --namespace=production apply -f app-ingress-canary.yml
kubectl --namespace=production describe ingress
```

Set resolver to point to Ingress resource IP:

```sh
export INGRESS_IP=$(kubectl --namespace=production get ing/app-ingress --output=json | jq -r '.status.loadBalancer.ingress[0].ip')
echo "$INGRESS_IP foo.bar canary.foo.bar" | sudo tee -a /etc/hosts
```

Test HTTP access:

```sh
curl http://foo.bar/version
curl http://canary.foo.bar/version
```

### 5. Troubleshooting

```sh
kubectl --namespace=production get services;
kubectl --namespace=production get pods -o wide;
kubectl --namespace=production get events -w;
```

## Cleanup

Delete the service:

```sh
kubectl delete service app
```

Wait for the Load Balancer provisioned for the app service to be deleted:

```sh
gcloud compute forwarding-rules list
```

Delete the container cluster:

```sh
gcloud container clusters delete $CLUSTER_NAME
```