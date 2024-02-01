#!/bin/bash

kubectl delete -f https://raw.githubusercontent.com/21Kdev/imagepullsecret-patcher/master/deploy-example/kubernetes-manifest/2_deployment.yaml
kubectl delete -f https://raw.githubusercontent.com/21Kdev/imagepullsecret-patcher/master/deploy-example/kubernetes-manifest/1_rbac.yaml
kubectl delete -f https://raw.githubusercontent.com/21Kdev/imagepullsecret-patcher/master/deploy-example/kubernetes-manifest/0_namespace.yaml
