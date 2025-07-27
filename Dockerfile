FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color

# Install system dependencies
RUN apt-get update && apt-get install -y \
    zsh \
    git \
    curl \
    wget \
    vim \
    nano \
    sudo \
    locales \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create a non-root user
RUN useradd -m -s /bin/zsh -G sudo developer && \
    echo 'developer:developer' | chpasswd && \
    echo 'developer ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Switch to the new user
USER developer
WORKDIR /home/developer

# Copy installation files
COPY --chown=developer:developer install.sh .
COPY --chown=developer:developer .zshrc .

# Make install script executable and run it
RUN chmod +x install.sh && ./install.sh

# Set zsh as default shell
SHELL ["/bin/zsh", "-c"]

# Create a startup script
RUN echo '#!/bin/zsh\n\
if [ "$1" = "bash" ] || [ "$1" = "sh" ]; then\n\
    exec "$@"\n\
else\n\
    exec zsh "$@"\n\
fi' > /home/developer/entrypoint.sh && \
    chmod +x /home/developer/entrypoint.sh

ENTRYPOINT ["/home/developer/entrypoint.sh"]
CMD ["zsh"]
