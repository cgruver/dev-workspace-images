### CronJob to clean up old workspaces

```bash
current_time=$(date +%s)
for namespace in $(oc get namespaces -l app.kubernetes.io/component=workspaces-namespace -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' )
do
  for workspace in $(oc get devworkspaces -n ${namespace} -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
  do
    last_start=$(date -d$(oc get devworkspace ${workspace} -n ${namespace} -o go-template='{{range .status.conditions}}{{if eq .type "Started"}}{{.lastTransitionTime}}{{end}}{{end}}') +%s)
    workspace_age=$(( ${current_time} - ${last_start} ))
    if [[ ${workspace_age} -gt  ${RETAIN_TIME} ]]
    then
      echo "Removing workspace: ${workspace}"
    fi
  done
done

current_time=$(date +%s); for namespace in $(oc get namespaces -l app.kubernetes.io/component=workspaces-namespace -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep ".-devspaces"); do for workspace in $(oc get devworkspaces -n ${namespace} -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'); do last_start=$(date -d$(oc get devworkspace ${workspace} -n ${namespace} -o go-template='{{range .status.conditions}}{{if eq .type "Started"}}{{.lastTransitionTime}}{{end}}{{end}}') +%s); workspace_age=$(( ${current_time} - ${last_start} )); if [[ ${workspace_age} -gt  ${RETAIN_TIME} ]]; then echo "Removing workspace: ${workspace}"; fi; done; done

```

```bash
cat << EOF | oc apply -f -
apiVersion: batch/v1
kind: CronJob
metadata:
  name: devworkspace-pruner
  namespace: openshift-operators
spec:
  schedule: "* * * * *"
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 3
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          volumes: 
          - name: script
            configMap:
              name: devworkspace-pruner
              defaultMode: 555
              items:
              - key: devworkspace-pruner
                path: devworkspace-pruner.sh
          restartPolicy: OnFailure
          serviceAccount: devworkspace-controller-serviceaccount
          containers:
          - name: openshift-cli
            image: image-registry.openshift-image-registry.svc:5000/openshift/cli:latest
            env:
            - name: RETAIN_TIME
              value: "2592000"
            command:
            - /devworkspace-pruner.sh
            resources:
              requests:
                cpu: 100m
                memory: 64Mi
              limits:
                cpu: 100m
                memory: 64Mi
            volumeMounts:
            - mountPath: /
              name: script
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: devworkspace-pruner
  namespace: openshift-operators
data:
  devworkspace-pruner: |
    current_time=$(date +%s)
    for namespace in $(oc get namespaces -l app.kubernetes.io/component=workspaces-namespace -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
    do
      for workspace in $(oc get devworkspaces -n ${namespace} -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}')
      do
        last_start=$(date -d$(oc get devworkspace ${workspace} -n ${namespace} -o go-template='{{range .status.conditions}}{{if eq .type "Started"}}{{.lastTransitionTime}}{{end}}{{end}}') +%s)
        workspace_age=$(( ${current_time} - ${last_start} ))
        if [[ ${workspace_age} -gt  ${RETAIN_TIME} ]]
        then
          echo "Removing workspace: ${workspace}"
        fi
      done
    done
EOF
---

apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: tekton-app-pipelinerun-pruner
spec:
  schedule: '0 0 * * *'
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 3
  concurrencyPolicy: Forbid
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          serviceAccount: pipeline
          containers:
            - name: openshift-cli
              image: image-registry.openshift-image-registry.svc:5000/openshift/cli:latest
              env:
                - name: SELECT_LABEL
                  value: "app-name"
                - name: RETAIN_LAST
                  value: "2"
              command:
                - /bin/bash
              args:
                - -c
                - "CURRENT_TIME=$(date +%s); for PIPELINE_RUN in $(oc get pipelinerun -o jsonpath='{.items[*].metadata.name}'); do CREATE_TIME=$(date -d$(oc get pipelinerun ${PIPELINE_RUN} -o jsonpath='{.metadata.creationTimestamp}') +%s); TIME_DELTA=$(( ${CURRENT_TIME} - ${CREATE_TIME} )); if [[ ${TIME_DELTA} -gt  ${RETAIN_TIME} ]]; then echo \"Removing PipelineRun: ${PIPELINE_RUN}\"; oc delete pipelinerun ${PIPELINE_RUN}; fi; done"
              resources:
                requests:
                  cpu: 100m
                  memory: 64Mi
                limits:
                  cpu: 100m
                  memory: 64Mi
```

```
#!/usr/bin/env bash

for namespace in $(oc get namespaces -l app.kubernetes.io/component=workspaces-namespace -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}' | grep ".-devspaces")
do
    let ws_count=$(oc get devworkspace --no-headers -n ${namespace} | wc -l)
    if [[ ${ws_count} -eq 0 ]]
    then
      oc delete projects ${namespace}
    fi
done
```
