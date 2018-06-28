export CLUSTER_NAME='app-cluster';
export COMPUTE_ZONE='europe-north1-a';
export NAMESPACE='app';
export PROJECT_ID=$(gcloud info --format='value(config.project)');
export VERSION_NUMBER=1.0.0;