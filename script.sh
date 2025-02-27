#/bin/bash
if [[ "$1" != "link" ]]; then
    wget https://github.com/StarAssassin64/dotfiles/archive/refs/heads/main.zip -O .dotfiles.zip
    mkdir -p ~/.dotfiles
    unzip .dotfiles.zip -d ~/.dotfiles
fi

rm -rf ~/.config/lvim && ln -s ~/.dotfiles/lvim ~/.config/lvim
rm -rf ~/.config/paru && ln -s ~/.dotfiles/paru ~/.config/paru
rm -rf ~/.config/lazygit && ln -s ~/.dotfiles/lazygit ~/.config/lazygit
rm -f ~/.zshrc && ln -s ~/.dotfiles/.zshrc_omz ~/.zshrc
