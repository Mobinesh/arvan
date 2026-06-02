#!/bin/bash
set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TF_DIR="$REPO_ROOT/terraform/kvm"
KUBESPRAY_DIR="$REPO_ROOT/kubespray"
INVENTORY_DIR="$KUBESPRAY_DIR/inventory/mycluster"
SSH_KEY="${SSH_KEY:-$HOME/.ssh/id_rsa}"
K8S_BINS_DIR="${K8S_BINS_DIR:-/tmp/k8s-bins}"

echo "========================================"
echo " Step 1: Terraform Apply"
echo "========================================"
cd "$TF_DIR"
terraform init
terraform apply -auto-approve

echo "========================================"
echo " Step 2: Generate Inventory"
echo "========================================"
MASTER_IPS=$(terraform output -json masters | jq -r \
  'to_entries[] | "\(.key) ansible_host=\(.value) ip=\(.value) ansible_python_interpreter=/usr/bin/python3"')
WORKER_IPS=$(terraform output -json workers | jq -r \
  'to_entries[] | "\(.key) ansible_host=\(.value) ip=\(.value) ansible_python_interpreter=/usr/bin/python3"')

mkdir -p "$INVENTORY_DIR/group_vars/all"

cat > "$INVENTORY_DIR/inventory.ini" << EOF
[all]
${MASTER_IPS}
${WORKER_IPS}

[kube_control_plane]
$(terraform output -json masters | jq -r 'keys[]')

[etcd]
$(terraform output -json masters | jq -r 'keys[]')

[kube_node]
$(terraform output -json workers | jq -r 'keys[]')

[k8s_cluster:children]
kube_control_plane
kube_node
EOF

echo "Inventory generated:"
cat "$INVENTORY_DIR/inventory.ini"

echo "========================================"
echo " Step 3: Wait for VMs"
echo "========================================"
ALL_IPS=$(terraform output -json node_ips | jq -r 'values[]')
for ip in $ALL_IPS; do
  echo -n "Waiting for $ip..."
  until ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 \
    -i "$SSH_KEY" ubuntu@$ip "echo ok" 2>/dev/null; do
    echo -n "."
    sleep 5
  done
  echo " ready!"
done

echo "========================================"
echo " Step 4: Copy k8s binaries to VMs"
echo "========================================"
if [ ! -f "$K8S_BINS_DIR/kubeadm" ]; then
  echo "Downloading k8s binaries via proxy..."
  mkdir -p "$K8S_BINS_DIR"
  K8S_VERSION="1.36.1"
  for bin in kubeadm kubelet kubectl; do
    curl -L --proxy socks5://127.0.0.1:1077 \
      "https://dl.k8s.io/release/v${K8S_VERSION}/bin/linux/amd64/${bin}" \
      -o "$K8S_BINS_DIR/${bin}"
    chmod +x "$K8S_BINS_DIR/${bin}"
  done
fi

for ip in $ALL_IPS; do
  echo "Copying binaries to $ip..."
  scp -o StrictHostKeyChecking=no -i "$SSH_KEY" \
    "$K8S_BINS_DIR/kubeadm" \
    "$K8S_BINS_DIR/kubelet" \
    "$K8S_BINS_DIR/kubectl" \
    ubuntu@$ip:/tmp/
done

echo "========================================"
echo " Step 5: Run Kubespray"
echo "========================================"
cd "$KUBESPRAY_DIR"
ansible-playbook -i inventory/mycluster/inventory.ini \
  --user ubuntu \
  --private-key "$SSH_KEY" \
  cluster.yml \
  --become --become-user=root

echo "========================================"
echo " Step 6: Get kubeconfig"
echo "========================================"
MASTER_IP=$(terraform -chdir="$TF_DIR" output -json masters | jq -r 'values[0]')
mkdir -p ~/.kube
ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" ubuntu@$MASTER_IP \
  "sudo cat /etc/kubernetes/admin.conf" > ~/.kube/config
sed -i "s/127.0.0.1/$MASTER_IP/g" ~/.kube/config

echo "========================================"
echo " Cluster is ready!"
echo "========================================"
kubectl get nodes
