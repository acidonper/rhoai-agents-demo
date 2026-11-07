#!/bin/bash

# Install ArgoCD Operator
oc create ns openshift-gitops-operator
oc create ns rhoai-agents-project
oc label namespace rhoai-agents-project opendatahub.io/dashboard-enabled=true
oc apply -f 00-GitOps-Operator.yaml

while [ "$(oc get pod -n openshift-gitops-operator | grep -c "Running")" -ne 1 ]; do
  sleep 10
done

while [ "$(oc get pod -n rhoai-agents-project | grep -c "Running")" -ne 1 ]; do
  sleep 10
done

# Obtain Argocd route and cluster secret to admin user access
ROUTE=$(oc get route argocd-server -n rhoai-agents-project -o jsonpath='{.spec.host}')
SECRET=$(oc get secret argocd-cluster -n rhoai-agents-project -o jsonpath='{.data.admin\.password}' | base64 -d)
echo "ArgoCD route: $ROUTE"
echo "ArgoCD admin password: $SECRET"

# Install ArgoCD Application
oc apply -f 01-application-project.yaml

# The controller ServiceAccount is <argocd-name>-argocd-application-controller.
oc create clusterrolebinding rhoai-agents-project-cluster-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=rhoai-agents-project:argocd-argocd-application-controller \
  --dry-run=client -o yaml | oc apply -f -