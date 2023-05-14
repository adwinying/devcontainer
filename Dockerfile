FROM nixos/nix

ARG TERM
ARG FLAKE_PATH="github:adwinying/dotfiles?dir=nix-config"
ENV NIX_CONFIG="experimental-features = nix-command flakes"

RUN mkdir -p /nix/var/nix/gcroots/per-user/root \
  # Remove conflicting packages
  && nix-env -e git man-db \
  # Bootstrap user environment
  && nix-shell -p home-manager --command "home-manager switch --flake \"${FLAKE_PATH}#docker-$(uname -m)\"" \
  # Change default shell to zsh
  && nix-shell -p util-linux --command "chsh -s /root/.nix-profile/bin/zsh root" \
  # Install zsh plugins
  && TERM=${TERM:-screen-256color} zsh -isc "source ~/.zshrc" \
  # Install tmux plugins
  && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm \
  && TMUX_PLUGIN_MANAGER_PATH="~/.tmux/plugins" ~/.tmux/plugins/tpm/bin/install_plugins

WORKDIR /root

ENTRYPOINT [ "zsh" ]

CMD [ "sleep", "infinity" ]
