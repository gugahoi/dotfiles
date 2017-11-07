#!/usr/bin/env bash

if [[ $SHELL != *"zsh"* ]]; 
then
  echo "Installing oh-my-zsh"
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi

if ! xcode-select -p > /dev/null; then
  echo "Installing xcode CLI tools"
  xcode-select --install
fi

if ! command -v brew > /dev/null; then
  echo "Installing Homebrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
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
software_list=( bash tig icdiff vim zsh-syntax-highlighting \
  zsh-autosuggestions python3 )
for item in "${software_list[@]}"; do
  if ! brew list | grep -q "$item"; then
    echo "Installing fresh $item"
    brew install "$item"
    # add comment and 'source' cmd only if it was not already in zshrc file
    if [ "$item" == "zsh-autosuggestions" ] && ! grep -q "# adding zsh-autosuggestions.zsh" "zshrc" ; then
      echo "Also adding source to zshrc file..."
      printf "\
        \n\n# adding zsh-autosuggestions.zsh \
        \nsource /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh" >> zshrc
    fi
    # add comment and 'source' cmd only if it was not already in zshrc file
    if [ "$item" == "zsh-syntax-highlighting" ] && ! grep -q "# adding zsh-syntax-highlighting.zsh" "zshrc" ; then
      echo "Also adding syntax-highlighting source to zshrc file..."
      printf "\
        \n\n# adding zsh-syntax-highlighting.zsh \
        \nsource /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> zshrc
    fi
  else
    echo "upgrading $item"
    brew upgrade "$item" 2>/dev/null
  fi
done

if [ ! -f ~/.vim/autoload/plug.vim ];
then
  echo "Installing Vim-Plug"
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

echo "Configuring VIM"
vim +PlugInstall +qall

echo "Installing ZSH Pure Theme"
git clone https://github.com/sindresorhus/pure ~/.zsh-pure-theme/
ln -s ~/.zsh-pure-theme/pure.zsh /usr/local/share/zsh/site-functions/prompt_pure_setup
ln -s ~/.zsh-pure-theme/async.zsh /usr/local/share/zsh/site-functions/async

echo "Done configuring the system, please reboot :D"
