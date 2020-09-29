apiVersion: kubeadm.k8s.io/v1beta2
kind: JoinConfiguration
discovery:
  file:
    kubeConfigPath: ${KUBECONFIG}
nodeRegistration:
  kubeletExtraArgs:
    cloud-provider: ${KUBELET_CLOUD_PROVIDER}
    network-plugin: ${KUBELET_NETWORK_PLUGIN}
    volume-plugin-dir: /var/lib/kubelet/volumeplugins