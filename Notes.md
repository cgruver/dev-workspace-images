# Testing Nested Containers

Create SCC

```bash
cat << EOF | oc apply -f -
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: test-user-namespaces-scc
priority: null
allowPrivilegeEscalation: true
allowedCapabilities:
- SETUID
- SETGID
fsGroup:
  type: MustRunAs
  ranges:
  - min: 1234
    max: 65534
runAsUser:
  type: MustRunAs
  uid: 1234
seLinuxContext:
  type: MustRunAs
  seLinuxOptions:
    type: container_engine_t
supplementalGroups:
  type: MustRunAs
  ranges:
  - min: 1234
    max: 65534
userNamespaceLevel: RequirePodLevel
EOF
```

```bash
oc adm policy add-scc-to-user test-user-namespaces-scc <non-admin-user>
```

```bash
oc new-project podman-demo

cat << EOF | oc apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nested-podman
  namespace: podman-demo
  annotations:
    io.kubernetes.cri-o.Devices: "/dev/fuse,/dev/net/tun"
    openshift.io/scc: test-user-namespaces-scc
spec:
  # hostUsers: false
  securityContext:
    hostUsers: false
  containers:
  - name: nested-podman
    image: quay.io/cgruver0/che/workspace-base:latest
    securityContext:
      hostUsers: false
      allowPrivilegeEscalation: true
      procMount: Unmasked
      capabilities:
        add:
        - "SETUID"
        - "SETGID"
EOF

oc rsh nested-podman

podman run -d --rm --name webserver -p 8080:80 quay.io/libpod/banner

curl http://localhost:8080
```

```bash
cat << EOF | oc apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nested-podman
  namespace: podman-demo
  annotations:
    io.kubernetes.cri-o.Devices: "/dev/fuse,/dev/net/tun"
    openshift.io/scc: test-user-namespaces-scc
spec:
  hostUsers: true
  containers:
  - name: nested-podman
    image: quay.io/cgruver0/che/workspace-base:latest
    securityContext:
      allowPrivilegeEscalation: true
      capabilities:
        add:
        - "SETUID"
        - "SETGID"
EOF
```


cat << EOF | oc apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nested-podman
  annotations:
    io.kubernetes.cri-o.Devices: "/dev/fuse,/dev/net/tun"
spec:
  containers:
  - name: nested-podman
    image: quay.io/cgruver0/che/workspace-base:latest
EOF

cat << EOF | oc apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: nested-podman
  annotations:
    io.kubernetes.cri-o.Devices: "/dev/fuse,/dev/net/tun"
    openshift.io/scc: test-user-namespaces-scc
spec:
  hostUsers: false
  containers:
  - name: nested-podman
    image: quay.io/cgruver0/che/workspace-base:latest
    securityContext:
      allowPrivilegeEscalation: true
      procMount: Unmasked
      capabilities:
        add:
        - "SETUID"
        - "SETGID"
EOF

## Sharing ssh keys across all workspaces in a namespace

```bash
SSH_KEY_DIR="$(mktemp -d)" 
ssh-keygen -t ecdsa -b 521 -N "" -f ${SSH_KEY_DIR}/my_ecdsa
oc create secret generic ssh-keys --from-file=${SSH_KEY_DIR}/my_ecdsa --from-file=${SSH_KEY_DIR}/my_ecdsa.pub      
rm -rf ${SSH_KEY_DIR}
oc annotate secret ssh-keys --overwrite controller.devfile.io/mount-path=${HOME}/.ssh
oc label secret ssh-keys controller.devfile.io/mount-to-devworkspace=true controller.devfile.io/watch-secret=true
```