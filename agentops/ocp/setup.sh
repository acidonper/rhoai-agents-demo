#!/bin/bash

# Install ArgoCD Operator
oc create ns openshift-gitops-operator
oc create ns rhoai-agents-project
oc label namespace openshift-gitops-operator argocd.argoproj.io/managed-by=openshift-gitops
oc label namespace rhoai-agents-project opendatahub.io/dashboard-enabled=true
oc apply -f 00-GitOps-Operator.yaml

while [ "$(oc get pod -n openshift-gitops-operator | grep -c "Running")" -ne 1 ]; do
  sleep 10
done

while [ "$(oc get pod -n rhoai-agents-project | grep -c "Running")" -ne 1 ]; do
  sleep 10
done

# Install ArgoCD Application
oc apply -f 01-application-project.yaml

# Label the namespaces
oc create clusterrolebinding rhoai-agents-project-argocd-application-controller-cluster-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=rhoai-agents-project:rhoai-agents-project-argocd-application-controller