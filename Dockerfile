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

# Install kubectx and kubens for context/namespace switching
RUN wget -O /usr/local/bin/kubectx https://github.com/ahmetb/kubectx/releases/latest/download/kubectx && \
    wget -O /usr/local/bin/kubens https://github.com/ahmetb/kubectx/releases/latest/download/kubens && \
    chmod +x /usr/local/bin/kubectx /usr/local/bin/kubens

# Install stern for multi-pod log tailing
# Install stern for multi-pod log tailing
RUN wget -O stern.tar.gz https://github.com/stern/stern/releases/download/v1.33.0/stern_1.33.0_linux_amd64.tar.gz && \
    tar xzf stern.tar.gz && \
    install -o root -g root -m 0755 stern /usr/local/bin/stern && \
    rm stern.tar.gz stern

# Install kube-ps1 for shell prompt
RUN curl -sL https://github.com/jonmosco/kube-ps1/archive/v0.8.0.tar.gz | tar xz && \
    mv kube-ps1-0.8.0/kube-ps1.sh /usr/local/bin/kube-ps1.sh && \
    chmod +x /usr/local/bin/kube-ps1.sh && \
    rm -rf kube-ps1-0.8.0



# Create workspace directory
RUN mkdir -p /workspace
WORKDIR /workspace

# Set up bash completion
RUN echo 'source <(kubectl completion bash)' >> ~/.bashrc && \
    echo 'source <(talosctl completion bash)' >> ~/.bashrc && \
    echo 'source <(helm completion bash)' >> ~/.bashrc && \
    echo 'source /usr/local/bin/kube-ps1.sh' >> ~/.bashrc && \
    echo 'PS1='\''$(kube_ps1)'\''$PS1' >> ~/.bashrc && \
    echo 'complete -F __start_kubectl k' >> ~/.bashrc

# Create .kube directory for kubeconfig
RUN mkdir -p /root/.kube

# Create .talos directory for talos config
RUN mkdir -p /root/.talos

# Define volumes for persistent config
VOLUME ["/root/.kube", "/root/.talos"]

# Add aliases for common commands
RUN echo "alias k='kubectl'" >> ~/.bashrc && \
    echo "alias kg='kubectl get'" >> ~/.bashrc && \
    echo "alias kgp='kubectl get pods'" >> ~/.bashrc && \
    echo "alias kgn='kubectl get nodes'" >> ~/.bashrc && \
    echo "alias kgs='kubectl get svc'" >> ~/.bashrc && \
    echo "alias kga='kubectl get all'" >> ~/.bashrc && \
    echo "alias kd='kubectl describe'" >> ~/.bashrc && \
    echo "alias kl='kubectl logs'" >> ~/.bashrc && \
    echo "alias ke='kubectl exec -it'" >> ~/.bashrc && \
    echo "alias kx='kubectx'" >> ~/.bashrc && \
    echo "alias kn='kubens'" >> ~/.bashrc && \
    echo "alias ks='stern'" >> ~/.bashrc

# Set default command
CMD ["/bin/bash"]