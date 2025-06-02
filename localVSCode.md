


```
wget https://raw.githubusercontent.com/eclipse-che/che-operator/refs/heads/main/editors-definitions/che-code-server-latest.yaml
oc login <cluster uri>
oc project <namespace where you deployed the CheCluster>
oc create configmap che-code-server --from-file=che-code-server-latest.yaml
oc label configmap che-code-server app.kubernetes.io/part-of=che.eclipse.org app.kubernetes.io/component=editor-definition
```