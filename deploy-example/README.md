# deploy-example

Here is an example deployment to a kubernetes cluster.

Remember to change the Secret is specified in [2_deployment.yaml](kubernetes-manifest/2_deployment.yaml#L8). It's a base64-encoded json string which has credentials to the private registries.

To manually create such secret can follow https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/#create-a-secret-by-providing-credentials-on-the-command-line.

```shell
kubectl create secret docker-registry image-pull-secret-src \
  -n imagepullsecret-patcher \
  --docker-server=<your-registry-server> \
  --docker-username=<your-name> \
  --docker-password=<your-pword> \
  --docker-email=<your-email>
```
## how to install
```
curl -o /tmp/install_image_patcher.sh https://raw.githubusercontent.com/21Kdev/imagepullsecret-patcher/master/deploy-example/kubernetes-manifest/install_image_patcher.sh && sh /tmp/install_image_patcher.sh ; rm -f /tmp/install_image_patcher.sh
```

## how to delete
```
curl -o /tmp/delete_image_patcher.sh https://raw.githubusercontent.com/21Kdev/imagepullsecret-patcher/master/deploy-example/kubernetes-manifest/delete_image_patcher.sh && sh /tmp/delete_image_patcher.sh ; rm -f /tmp/delete_image_patcher.sh
```
