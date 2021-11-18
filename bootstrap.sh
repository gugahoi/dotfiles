#!/usr/bin/env bash

if ! xcode-select -p > /dev/null; then
  echo "Installing xcode CLI tools"
  xcode-select --install
fi

if ! command -v brew > /dev/null; then
  echo "Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

echo "Linking files"
mkdir -p  ~/.dotfiles_backup
for f in "aliases" "exports" "functions" "vimrc" "zshrc"
do
  echo "Linking \"$f\""
  if [ -f ~/.$f ]; then
    echo "Original file exists, backing it up"
    mv ~/.$f ~/.dotfiles_backup/$f
  fi
  ln -s ~/.dotfiles/$f ~/.$f
  echo "Linked \"$f\""
done

# brew installs
brew bundle install

if [ ! -f ~/.vim/autoload/plug.vim ];
then
  echo "Installing Vim-Plug"
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo "Configuring VIM"
vim +PlugInstall +qall

echo "Done configuring the system, please reboot :D"
