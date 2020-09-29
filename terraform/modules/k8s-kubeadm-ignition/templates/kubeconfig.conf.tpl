apiVersion: v1
clusters:
  - cluster:
      certificate-authority-data: ${KUBE_CA_DATA}
      server: https://${KUBE_CONTROL_PLANE_ENDPOINT}
    name: ${CLUSTER_NAME}
contexts:
  - name: ${CLUSTER_NAME}
    context:
      cluster: ${CLUSTER_NAME}
      user: kubernetes
users:
  - name: kubernetes
    user:
      client-certificate-data: ${KUBE_CLIENT_CERT_DATA}
      client-key-data: ${KUBE_CLIENT_KEY_DATA}
current-context: ${CLUSTER_NAME}
preferences: {}