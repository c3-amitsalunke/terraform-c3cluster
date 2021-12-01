
## TODOs

### Project
1. move kms to separate submodule
2. move gcs to separate submodule
3. remove downstream dependency of outputs

### IAM & Service Accounts
1. automate postgres service identity
```
gcloud beta services identity create --service=sqladmin.googleapis.com --project=env-pod
```

### Network
1. remove downstream dependency of outputs
2. remove c3 ips

### GKE
1. Enable CSI for [filestore](https://cloud.google.com/kubernetes-engine/docs/how-to/persistent-volumes/filestore-csi-driver) if gcs is not available
2. Parameterize node pool configuration

### Postgres


## References
[GKE cluster hardening](https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster)