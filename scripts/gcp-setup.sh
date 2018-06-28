gcloud config set project $PROJECT_ID;
gcloud config set compute/zone $COMPUTE_ZONE;

gcloud container clusters create $CLUSTER_NAME --num-nodes=3;
gcloud container clusters get-credentials $CLUSTER_NAME;

kubectl create namespace $NAMESPACE;

kubectl --namespace=$NAMESPACE apply -f k8s/app-ingress-production.yml
kubectl --namespace=$NAMESPACE apply -f k8s/app-ingress-canary.yml