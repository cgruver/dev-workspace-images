# Installing the editor for Local VS Code integration with Dev Spaces

## Use MS tunnel

```
wget https://raw.githubusercontent.com/eclipse-che/che-operator/refs/heads/main/editors-definitions/che-code-server-latest.yaml
oc login <cluster uri>
oc project <namespace where you deployed the CheCluster>
oc create configmap che-code-server --from-file=che-code-server-latest.yaml
oc label configmap che-code-server app.kubernetes.io/part-of=che.eclipse.org app.kubernetes.io/component=editor-definition
```

## Use SSH

```
wget https://raw.githubusercontent.com/eclipse-che/che-operator/038fcd54827d13f3e37effec2544da8837af8e0e/editors-definitions/che-code-sshd-latest.yaml
oc login <cluster uri>
oc project <namespace where you deployed the CheCluster>
oc create configmap che-code-sshd --from-file=che-code-sshd-latest.yaml
oc label configmap che-code-sshd app.kubernetes.io/part-of=che.eclipse.org app.kubernetes.io/component=editor-definition
```
