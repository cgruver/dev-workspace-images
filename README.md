# dev-workspace-images
Custom images for OpenShift Dev Spaces

```bash
podman build -t quay.io/cgruver0/che/workspace-base:latest ./base

cekit --descriptor images/quarkus-angular-node20-java21.yaml build podman --tag image-registry.openshift-image-registry.svc:5000/devspaces-images/quarkus-angular:latest

cekit --descriptor images/quarkus-angular-node20-java21.yaml build podman --tag quay.io/cgruver0/che/quarkus-angular-node20-java21:latest

cekit --descriptor images/quarkus-super-heroes.yaml build podman --tag quay.io/cgruver0/che/dev-workspace-quarkus-super-heroes:latest

cekit --descriptor images/quarkus-angular-node18-java17.yaml build podman --tag quay.io/cgruver0/che/quarkus-angular-node18-java17:latest

cekit --descriptor images/node20.yaml build podman --tag quay.io/cgruver0/che/node20-dev-tools:latest

cekit --descriptor images/cajun-navy.yaml build podman --tag quay.io/cgruver0/che/cajun-navy:latest

cekit --descriptor images/cassandra.yaml build podman --tag quay.io/cgruver0/che/cassandra-5:latest
```

## Local Nexus

```bash
cekit --descriptor images/cajun-navy.yaml build podman --tag nexus.clg.lab:5002/dev-spaces/cajun-navy:latest
podman push --cert-dir /public-certs nexus.clg.lab:5002/dev-spaces/cajun-navy:latest
```
