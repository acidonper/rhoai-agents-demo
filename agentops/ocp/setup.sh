#!/bin/bash

# Install ArgoCD Operator
oc create ns openshift-gitops-operator
oc create ns rhoai-agents-project
oc label namespace openshift-gitops-operator argocd.argoproj.io/managed-by=openshift-gitops
oc label namespace rhoai-agents-project opendatahub.io/dashboard-enabled=true
oc apply -f 00-GitOps-Operator.yaml

# Wait for ArgoCD Operator to be ready
while [ "$(oc get pod -n openshift-gitops-operator | grep -c "Running")" -ne 1 ]; do
  sleep 10
done

# Install ArgoCD Application
oc apply -f 01-application-project.yaml