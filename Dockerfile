FROM archlinux:base-devel

ARG TERM

RUN useradd -m user \
    && usermod -L user \
    && echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER user

RUN sudo pacman -Syy && sudo pacman -Syu --noconfirm \
    # Get essential packages
    && curl -s https://raw.githubusercontent.com/adwinying/dotfiles/master/packages/essentials.txt https://raw.githubusercontent.com/adwinying/dotfiles/master/packages/cli.txt | sudo pacman -S --needed --noconfirm - \
    # Setup dotfiles
    && mkdir -p ~/.config \
    && git clone https://github.com/adwinying/dotfiles ~/.dotfiles && cd ~/.dotfiles && stow -v zsh git vim neovim tmux \
    && ln -s ~/.dotfiles/lazygit/Library/Application\ Support/lazygit ~/.config/lazygit \
    # Install tmux plugins
    && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm \
    && TMUX_PLUGIN_MANAGER_PATH="~/.tmux/plugins" ~/.tmux/plugins/tpm/bin/install_plugins \
    # Install zsh plugins
    && TERM=${TERM:-screen-256color} zsh -isc "source ~/.zshrc" \
    # Change default shell to zsh
    && sudo usermod --shell /bin/zsh user \
    # Install AUR helper
    && git clone https://aur.archlinux.org/paru-bin.git ~/.paru && cd ~/.paru && makepkg -si --noconfirm

CMD [ "sleep", "infinity" ]