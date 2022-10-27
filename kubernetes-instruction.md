0. Optional set project config && authenticate

```shell
gcloud init 
gcloud auth login
```

1. Create cluster

```shell
gcloud beta container --project "django-natours-app" clusters create "natours-cluster" --zone "europe-west1-b" --no-enable-basic-auth --cluster-version "1.21.10-gke.2000" --release-channel "regular" --machine-type "e2-micro" --image-type "COS_CONTAINERD" --disk-type "pd-standard" --disk-size "100" --metadata disable-legacy-endpoints=true --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" --max-pods-per-node "110" --num-nodes "3" --logging=SYSTEM,WORKLOAD --monitoring=SYSTEM --enable-ip-alias --network "projects/django-natours-app/global/networks/default" --subnetwork "projects/django-natours-app/regions/europe-west1/subnetworks/default" --no-enable-intra-node-visibility --default-max-pods-per-node "110" --no-enable-master-authorized-networks --addons HorizontalPodAutoscaling,HttpLoadBalancing,GcePersistentDiskCsiDriver --enable-autoupgrade --enable-autorepair --max-surge-upgrade 1 --max-unavailable-upgrade 0 --enable-shielded-nodes --node-locations "europe-west1-b"
```

2. Create nfs for media and static files

```shell
gcloud compute disks create --size=10Gi --zone=europe-west1-b gce-media-nfs
gcloud compute disks create --size=10Gi --zone=europe-west1-b gce-static-nfs
```

3. Create static ip for ingress

```shell
gcloud compute addresses create natours-static-ip --global
```

4. Set kubernetes config file `.kube`

```shell
gcloud container clusters get-credentials natours-cluster --zone=europe-west1-b
```

5. Clone project

```shell
git clone git@github.com:Pavel418890/natours-backend.git
```

6. Jump to kubernetes definitions

```shell
cd natours-backend/kubernetes
```

7. Deploy app

```shell
kubectl apply -f . -R 
```
