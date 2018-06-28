VERSION_NUMBER=$1;

docker build -t gcr.io/$PROJECT_ID/app:$VERSION_NUMBER .;
gcloud docker -- push gcr.io/$PROJECT_ID/app:$VERSION_NUMBER;