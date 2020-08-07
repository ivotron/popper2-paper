# Running on a Single node

Reproducible workflow for image classification using MNIST on a single machine or your local machine
in both CUDA and Non-CUDA versions.

## Instructions

### To run in local machine
```bash
$ cd local/
$ popper run
```

### To run in kubernetes

**NOTE:** The instructions given below assume that a NFS filesystem or any shared FS is not available. 

1. Update the `config_k8s.yml` file your registry username and the node you want the pods to run.

2. Login to Docker hub if not already logged in
```bash
$ docker login
```

3. Create the local persistent voluem
```bash
$ cat<<EOF > pv.yaml 
kind: PersistentVolume
apiVersion: v1
metadata:
  name: pv-hostpath
  labels:
    type: host
spec:
  persistentVolumeReclaimPolicy: Recycle
  storageClassName: manual
  capacity:
    storage: 1Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/tmp"
EOF

$ kubectl apply -f pv.yaml
```
4. Run the workflow with the k8s runner
```bash
$ cd local/
$ popper run -c config_k8s.yml
```
