# https://godoc.org/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta2#InitConfiguration
apiVersion: kubeadm.k8s.io/v1beta2
kind: InitConfiguration
nodeRegistration:
  kubeletExtraArgs:
    cloud-provider: ${KUBELET_CLOUD_PROVIDER}
    network-plugin: ${KUBELET_NETWORK_PLUGIN}
    volume-plugin-dir: /var/lib/kubelet/volumeplugins
---
# https://godoc.org/k8s.io/kubernetes/cmd/kubeadm/app/apis/kubeadm/v1beta2#ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
clusterName: ${CLUSTER_NAME}
kubernetesVersion: v1.18.3
controlPlaneEndpoint: ${KUBE_CONTROL_PLANE_ENDPOINT}
certificatesDir: /etc/kubernetes/pki
networking:
  serviceSubnet: 10.96.0.0/12
  podSubnet: 10.244.0.0/16
  dnsDomain: cluster.local
etcd:
  external:
    endpoints:
    %{~ for endpoint in KUBE_ETCD_ENDPOINTS ~}
      - ${endpoint}
    %{~ endfor ~}
    caFile: /etc/kubernetes/pki/etcd/ca.crt
    certFile: /etc/kubernetes/pki/apiserver-etcd-client.crt
    keyFile: /etc/kubernetes/pki/apiserver-etcd-client.key
apiServer:
  extraArgs: {}
controllerManager:
  extraArgs:
    allocate-node-cidrs: "true"
    cluster-signing-cert-file: /etc/kubernetes/pki/ca.crt
    cluster-signing-key-file: /etc/kubernetes/pki/ca.key
    flex-volume-plugin-dir: /var/lib/kubelet/volumeplugins
scheduler:
  extraArgs: {}

---
# https://godoc.org/k8s.io/kubelet/config/v1beta1#KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
clusterDNS:
  - 10.96.0.10

---
apiVersion: kubeadm.k8s.io/v1beta2
kind: JoinConfiguration
controlPlane:
  localAPIEndpoint:
    advertiseAddress: 0.0.0.0
    bindPort: 6443
discovery:
  file:
    kubeConfigPath: ${KUBECONFIG}
nodeRegistration:
  kubeletExtraArgs:
    cloud-provider: ${KUBELET_CLOUD_PROVIDER}
    network-plugin: ${KUBELET_NETWORK_PLUGIN}
    volume-plugin-dir: /var/lib/kubelet/volumeplugins