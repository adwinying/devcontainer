FROM archlinux:base-devel

ARG TERM

RUN useradd -m user \
    && usermod -L user \
    && echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER user

RUN sudo pacman -Syy && sudo pacman -Syu --noconfirm \
    # Get essential packages
    && sudo pacman -S --needed --noconfirm $(curl -s https://raw.githubusercontent.com/adwinying/dotfiles/master/packages/essentials.txt | xargs) \
    # Setup dotfiles
    && git clone https://github.com/adwinying/dotfiles ~/.dotfiles && cd ~/.dotfiles && stow -v zsh git vim neovim tmux lazygit paru ranger \
    # Install AUR helper
    && git clone https://aur.archlinux.org/paru-bin.git ~/.paru && cd ~/.paru && makepkg -si --noconfirm \
    # Get cli packages
    && paru -S --needed --noconfirm $(cat ~/.dotfiles/packages/cli.txt | xargs) \
    # Install tmux plugins
    && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm \
    && TMUX_PLUGIN_MANAGER_PATH="~/.tmux/plugins" ~/.tmux/plugins/tpm/bin/install_plugins \
    # Install zsh plugins
    && TERM=${TERM:-screen-256color} zsh -isc "source ~/.zshrc" \
    # Change default shell to zsh
    && sudo usermod --shell /bin/zsh user

CMD [ "sleep", "infinity" ]
