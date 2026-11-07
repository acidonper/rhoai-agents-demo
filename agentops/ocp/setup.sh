#!/bin/bash

# Install ArgoCD Operator
oc create ns openshift-gitops-operator
oc create ns rhoai-agents-project
oc label namespace openshift-gitops-operator argocd.argoproj.io/managed-by=openshift-gitops
oc label namespace rhoai-agents-project opendatahub.io/dashboard-enabled=true
oc apply -f 00-GitOps-Operator.yaml
sleep 60

# Install ArgoCD Application
oc apply -f 01-application-project.yaml

# Label the namespaces
oc label namespace rhoai-model-registries argocd.argoproj.io/managed-by=openshift-gitops
oc label namespace rhoai-agents-project argocd.argoproj.io/managed-by=openshift-gitops
oc create clusterrolebinding openshift-gitops-argocd-application-controller-cluster-admin \
  --clusterrole=cluster-admin \
  --serviceaccount=openshift-gitops:openshift-gitops-argocd-application-controller