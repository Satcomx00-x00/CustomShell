# Dockerfile for Kubernetes Tools Environment
# Based on Debian with essential Kubernetes CLI tools

FROM debian:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV KUBECONFIG=/root/.kube/config

# Install base packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    vim \
    nano \
    jq \
    yq \
    bash-completion \
    ca-certificates \
    gnupg \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Install talosctl
RUN curl -sL https://talos.dev/install | sh

# Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh && \
    rm get_helm.sh

# Install k9s (Terminal UI for Kubernetes)
RUN curl -sL https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz | tar xz && \
    install -o root -g root -m 0755 k9s /usr/local/bin/k9s && \
    rm k9s

# Install kubectx and kubens
RUN git clone https://github.com/ahmetb/kubectx.git /tmp/kubectx && \
    install -o root -g root -m 0755 /tmp/kubectx/kubectx /usr/local/bin/kubectx && \
    install -o root -g root -m 0755 /tmp/kubectx/kubens /usr/local/bin/kubens && \
    rm -rf /tmp/kubectx

# Install stern (Multi pod log tailing)
RUN curl -sL https://github.com/stern/stern/releases/latest/download/stern_$(curl -s https://api.github.com/repos/stern/stern/releases/latest | jq -r '.tag_name' | sed 's/v//')_linux_amd64.tar.gz | tar xz && \
    install -o root -g root -m 0755 stern /usr/local/bin/stern && \
    rm stern

# Install kustomize
RUN curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash && \
    install -o root -g root -m 0755 kustomize /usr/local/bin/kustomize && \
    rm kustomize

# Install Flux CLI
RUN curl -s https://fluxcd.io/install.sh | bash

# Install ArgoCD CLI
RUN curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 && \
    install -o root -g root -m 0755 argocd-linux-amd64 /usr/local/bin/argocd && \
    rm argocd-linux-amd64

# Install Velero CLI
RUN curl -sL https://github.com/vmware-tanzu/velero/releases/latest/download/velero-$(curl -s https://api.github.com/repos/vmware-tanzu/velero/releases/latest | jq -r '.tag_name')-linux-amd64.tar.gz | tar xz && \
    install -o root -g root -m 0755 velero-*-linux-amd64/velero /usr/local/bin/velero && \
    rm -rf velero-*-linux-amd64

# Install kubeconform (Kubernetes manifest validation)
RUN curl -sL https://github.com/yannh/kubeconform/releases/latest/download/kubeconform-linux-amd64.tar.gz | tar xz && \
    install -o root -g root -m 0755 kubeconform /usr/local/bin/kubeconform && \
    rm kubeconform

# Install kubeseal (Sealed Secrets CLI)
RUN curl -sL https://github.com/bitnami-labs/sealed-secrets/releases/latest/download/kubeseal-$(curl -s https://api.github.com/repos/bitnami-labs/sealed-secrets/releases/latest | jq -r '.tag_name')-linux-amd64.tar.gz | tar xz && \
    install -o root -g root -m 0755 kubeseal /usr/local/bin/kubeseal && \
    rm kubeseal

# Install krew (kubectl plugin manager)
RUN curl -fsSL https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-linux_amd64.tar.gz | tar xz && \
    ./krew-linux_amd64 install krew && \
    rm krew-linux_amd64

# Add krew to PATH
ENV PATH="${PATH}:/root/.krew/bin"

# Install useful kubectl plugins via krew
RUN kubectl krew install ctx && \
    kubectl krew install ns && \
    kubectl krew install view-secret && \
    kubectl krew install get-all && \
    kubectl krew install tree

# Create workspace directory
RUN mkdir -p /workspace
WORKDIR /workspace

# Set up bash completion
RUN echo 'source <(kubectl completion bash)' >> ~/.bashrc && \
    echo 'source <(talosctl completion bash)' >> ~/.bashrc && \
    echo 'source <(helm completion bash)' >> ~/.bashrc && \
    echo 'complete -F __start_kubectl k' >> ~/.bashrc

# Create .kube directory for kubeconfig
RUN mkdir -p /root/.kube

# Add aliases for common commands
RUN echo "alias k='kubectl'" >> ~/.bashrc && \
    echo "alias kg='kubectl get'" >> ~/.bashrc && \
    echo "alias kgp='kubectl get pods'" >> ~/.bashrc && \
    echo "alias kgn='kubectl get nodes'" >> ~/.bashrc && \
    echo "alias kgs='kubectl get svc'" >> ~/.bashrc && \
    echo "alias kga='kubectl get all'" >> ~/.bashrc && \
    echo "alias kd='kubectl describe'" >> ~/.bashrc && \
    echo "alias kl='kubectl logs'" >> ~/.bashrc && \
    echo "alias ke='kubectl exec -it'" >> ~/.bashrc

# Set default command
CMD ["/bin/bash"]