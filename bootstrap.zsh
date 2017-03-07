#!/usr/bin/env zsh

echo "Installing oh-my-zsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

echo "Installing x-code CLI tools"
xcode-select --install

echo "Installing Homebrew"
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

echo "Installing Vim-Plug"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo "Linking files"
mkdir -p  ~/.dotfiles_backup
for f in "aliases" "exports" "functions" "vimrc" "zshrc"
do
  echo "Linking \"$f\"" 
  if [ -f ~/.$f ]; then
    echo "Original file exists, backing it up"
    mv ~/.$f ~/.dotfiles_backup/$f
  fi
  ln -s $f ~/.$f
  echo "Linked \"$f\""
done

# Install vim plugins
echo "Configuring VIM"
vim +PlugInstall +qall

echo "Done configuring the system, please reboot :D"
