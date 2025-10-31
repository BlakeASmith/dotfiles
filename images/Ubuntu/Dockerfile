FROM ubuntu:latest

# Set build arguments
ARG USE_LOCAL_FILES=false
ARG DOTFILES_REPO_URL=https://github.com/BlakeASmith/dotfiles.git
ARG DOTFILES_BRANCH=main

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"
ENV SHELL=/usr/bin/zsh

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    file \
    git \
    locales \
    python3 \
    python3-pip \
    sudo \
    zsh \
    && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Install Linuxbrew
RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || true
RUN echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /root/.bashrc
RUN echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /root/.zshrc || true
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Create a non-root user (optional, but good practice)
RUN useradd -m -s /usr/bin/zsh -G sudo ubuntu || true
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up zsh as default shell for root
RUN chsh -s /usr/bin/zsh root

# Install fencing Python library
RUN pip3 install --break-system-packages setuptools wheel

# Copy dotfiles to temporary location (will be used if USE_LOCAL_FILES=true)
COPY . /tmp/dotfiles-local

# Copy dotfiles or clone from git
WORKDIR /root

# If USE_LOCAL_FILES is true, use local files; otherwise, clone from git
RUN if [ "$USE_LOCAL_FILES" = "true" ]; then \
        echo "Using local dotfiles from build context"; \
        cp -r /tmp/dotfiles-local /opt/dotfiles; \
        rm -rf /tmp/dotfiles-local; \
    else \
        echo "Cloning dotfiles from ${DOTFILES_REPO_URL}"; \
        git clone -b ${DOTFILES_BRANCH} ${DOTFILES_REPO_URL} /opt/dotfiles || \
        git clone ${DOTFILES_REPO_URL} /opt/dotfiles; \
        rm -rf /tmp/dotfiles-local; \
    fi

# Install fencing library
WORKDIR /opt/dotfiles/python/fencing
RUN pip3 install --break-system-packages -e .

# Set up dotfiles for root user
WORKDIR /opt/dotfiles
RUN python3 install.py zsh all --edit-rc --replace && \
    python3 install.py nvim all

# Install brew packages
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
    bash /opt/dotfiles/brew/base-utils.sh || true

# Install rust for root user
WORKDIR /opt/dotfiles/rust
RUN chmod +x install.sh crates.sh && \
    chmod +x /opt/dotfiles/bin/install-fence && \
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
    bash install.sh || true

# Install bob for root user
WORKDIR /opt/dotfiles/bob
RUN chmod +x install.py && \
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
    export PATH="$HOME/.cargo/bin:$PATH" && \
    [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env" || true && \
    python3 install.py || true

# Set up zsh for the ubuntu user as well
RUN chsh -s /usr/bin/zsh ubuntu
RUN echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/ubuntu/.bashrc
RUN echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/ubuntu/.zshrc || true

# Install dotfiles for ubuntu user
USER ubuntu
WORKDIR /home/ubuntu
RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
    if [ -d /opt/dotfiles ]; then \
        python3 /opt/dotfiles/install.py zsh all --edit-rc --replace && \
        python3 /opt/dotfiles/install.py nvim all; \
    fi

# Install rust for ubuntu user
WORKDIR /opt/dotfiles/rust
RUN chmod +x install.sh crates.sh && \
    chmod +x /opt/dotfiles/bin/install-fence && \
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
    bash install.sh || true

# Install bob for ubuntu user
WORKDIR /opt/dotfiles/bob
RUN chmod +x install.py && \
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && \
    export PATH="$HOME/.cargo/bin:$PATH" && \
    [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env" || true && \
    python3 install.py || true

# Switch back to root for default
USER root
WORKDIR /root

# Default command
CMD ["/usr/bin/zsh"]
