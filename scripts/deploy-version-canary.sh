VERSION_NUMBER=$1;

sed -i.bak "s/PROJECT_ID/$PROJECT_ID/; s/VERSION_NUMBER/$VERSION_NUMBER/;" ../k8s/app-canary.yml;

kubectl --namespace=$NAMESPACE apply -f ../k8s/app-canary.yml
kubectl --namespace=$NAMESPACE rollout status deployment/kubeapp-canary
