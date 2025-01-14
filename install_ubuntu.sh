#!/bin/bash

# Dotfiles Installer Script

# Define variables
DOTFILES_DIR="."
VIM_CONFIG="$DOTFILES_DIR/vim"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

###############################################################################
# Installing curl
###############################################################################
install_curl() {
    if ! command_exists curl; then
        echo "Installing curl..."
        sudo apt-get update
        sudo apt-get install -y curl
    else
        echo "Curl is already installed."
    fi
}

###############################################################################
# Installing Zsh + Oh My Zsh
###############################################################################
install_zsh() {
    if ! command_exists zsh; then
        echo "Installing Zsh..."
        sudo apt-get install -y zsh
        chsh -s "$(which zsh)"
    else
        echo "Zsh is already installed."
    fi
}

install_oh_my_zsh() {
    if [ -d ~/.oh-my-zsh ]; then
        echo "OhMyZSH! already installed!"
    else
        echo "Installing Oh-My-ZSH!"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
        git clone --depth=1 \
          https://github.com/romkatv/powerlevel10k.git \
          "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
        cp "$DOTFILES_DIR/.zshrc" ~/.zshrc
    fi
}

###############################################################################
# Installing Nerd Fonts
###############################################################################
install_nerd_fonts() {
    if fc-list | grep -q JetBrainsMono; then
        echo "Font already installed."
    else
        echo "Installing Nerd Font..."
        mkdir -p ~/.fonts
        curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz
        tar -xvf JetBrainsMono.tar.xz -C ~/.fonts
        rm JetBrainsMono.tar.xz
    fi
}

###############################################################################
# Installing Node.js using NVM
###############################################################################
install_node() {
    if ! command_exists node; then
        echo "Installing Node.js using NVM..."
        
        # Install NVM if not already installed
        if ! command_exists nvm; then
            echo "Installing NVM..."
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

            if ! grep -q "NVM_DIR" ~/.zshrc; then
                echo -e '\n# Add NVM and NPM exports\nexport NVM_DIR="$HOME/.nvm"\n[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"\n[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"\n' >> ~/.zshrc
            fi
        else
            echo "NVM is already installed."
        fi

        nvm install --lts
    else
        echo "Node.js is already installed."
    fi
}

###############################################################################
# Installing Neovim
###############################################################################
install_neovim() {
    if ! command_exists nvim; then
        echo "Installing Neovim..."
        sudo snap install --beta nvim --classic

        echo "Setting up Vim configurations..."
        cp "$VIM_CONFIG/.vimrc" ~/
    else
        echo "Neovim is already installed."
    fi
}

###############################################################################
# Installing lazygit
###############################################################################
install_lazygit() {
    if ! command_exists lazygit; then
        echo "Installing lazygit"
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
          | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz \
          "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit.tar.gz
        rm lazygit
    else
        echo "Lazygit is already installed."
    fi
}

###############################################################################
# Installing Rust (needed for Zellij)
###############################################################################
install_rust() {
    if ! command_exists rustup; then
        echo "Installing Rust..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        # Activate cargo in the current shell
        source "$HOME/.cargo/env"
    else
        echo "Rust is already installed."
    fi
}

###############################################################################
# Installing Zellij (replacing Tmux)
###############################################################################
install_zellij() {
    if ! command_exists zellij; then
        echo "Installing Zellij..."
        cargo install zellij
    else
        echo "Zellij is already installed."
    fi
}

###############################################################################
# Installing Kitty (replacing Alacritty/Ghostty)
###############################################################################
install_kitty() {
    if ! command_exists kitty; then
        echo "Installing Kitty terminal..."
        sudo apt-get update
        sudo apt-get install -y kitty
    else
        echo "Kitty is already installed."
    fi
}

###############################################################################
# Installing Java environment
###############################################################################
install_java() {
    if ! command_exists java; then
        echo "Installing OpenJDK (Java)..."
        # Adjust version as needed. We'll use OpenJDK 17 for this example.
        sudo apt-get update
        sudo apt-get install -y openjdk-17-jdk
    else
        echo "Java is already installed."
    fi
}

###############################################################################
# Installing LunarVim
###############################################################################
install_lunarvim() {
    if ! command_exists lvim; then
        echo "Installing LunarVim..."
        sudo apt-get install -y python3-pip
        LV_BRANCH='release-1.3/neovim-0.9' \
          bash <(curl -s https://raw.githubusercontent.com/LunarVim/LunarVim/release-1.3/neovim-0.9/utils/installer/install.sh)
    else
        echo "LunarVim is already installed."
    fi
}

###############################################################################
# MAIN
###############################################################################
main() {
    install_curl
    install_zsh
    install_nerd_fonts
    install_oh_my_zsh
    install_node
    install_neovim
    install_lazygit
    
    install_rust
    install_zellij

    # Use kitty as our terminal
    install_kitty

    # Remove Go installation, add Java
    install_java
    install_lunarvim
}

# Execute main function
main

