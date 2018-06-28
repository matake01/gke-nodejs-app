kubectl --namespace=$NAMESPACE delete service kubeapp-canary-service
kubectl --namespace=$NAMESPACE delete service kubeapp-production-service
gcloud container clusters delete $CLUSTER_NAME