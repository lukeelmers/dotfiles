#!/bin/sh

# ==============================================================================
# dotfiles setup - github.com/lukeelmers/dotfiles
# ==============================================================================

# Assumes you're running Mac OSX with Xcode installed.
# After cloning the dotfiles repo, cd into the repo directory and run this script.

# Script does the following:
#  1) Copies the specified dotfiles from your home directory to a backup directory.
#  2) Symlinks specified dotfiles in the home directory to the repo dotfiles.
#  3) Performs basic git configuration (name/email/editor preferences).
#  4) Generates SSH keys if they don't exist yet.
#  5) Installs Homebrew & everything included in Brewfile.

set -e

# settings
dir=~/dotfiles                       # dotfiles directory
olddir=~/dotfiles_backup             # old dotfiles backup directory
# list of files/folders to symlink in home directory
files=".bash_profile .bashrc .gitignore_global .psqlrc .shell_prompt.sh .tmux.conf .vim .vimrc .zshrc"

if ! type "git" > /dev/null; then
  echo "ERROR: git must be installed before running."
  exit 1
fi

# create directory in order to install nvm via homebrew
mkdir -p ~/.nvm

# create directory for todo.sh addons
mkdir -p ~/.todo.actions.d

# create Developer directory
mkdir -p ~/Developer

# create backup directory
echo -n "Creating $olddir to backup existing dotfiles in ~ ..."
mkdir -p $olddir

cd $dir

# move any existing dotfiles in ~ to backup directory, then create symlinks from ~ to any files in $dir that are listed above
for file in $files; do
    echo "Moving $file from ~ to $olddir"
    mv ~/$file $olddir
    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file ~/$file
done
# symlink for hyper config
ln -s $dir/hyper-config.json ~/Library/Application\ Support/Hyper/config.json
echo "Symlinks created."

echo ""
echo "Configuring git..."
# set global ignore file
git config --global core.excludesfile ~/.gitignore_global
# show info about submodules when running 'git status' from parent directory
git config --global status.submoduleSummary true
echo "What is your name?"
read input_name
git config --global user.name "${input_name}"
echo "What is your email address?"
read input_email
git config --global user.email ${input_email}
echo "What is your preferred editor? (eg. vim, nvim, subl --wait, atom --wait)"
read input_editor
git config --global core.editor ${input_editor}

# from https://github.com/paulmillr/dotfiles/blob/master/bootstrap-new-system.sh
pub=$HOME/.ssh/id_rsa.pub
echo 'Checking for SSH key, generating one if it does not exist...'
  [[ -f $pub ]] || ssh-keygen -t rsa

echo 'Copying public key to clipboard. Paste it into your Github & Heroku accounts...'
  [[ -f $pub ]] && cat $pub | pbcopy
  open 'https://github.com/account/ssh'
  open 'https://dashboard.heroku.com/account'

which -s brew
if [[ $? != 0 ]]; then
echo 'Installing Homebrew...'
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew update
fi

echo 'Installing Homebrew...'
cd $dir
brew tap homebrew/bundle
brew bundle

# Set zsh as default shell (requires sudo)
echo "$(which zsh)" | sudo tee -a /etc/shells
chsh -s $(which zsh)

# Configure gpg signing with git
git config --global url."ssh://git@github.com:".insteadOf "https://github.com/"
git config --global commit.gpgsign true
git config --global gpg.program gpg

brew doctor

# Install Xcode command line tools
xcode-select --install

echo ''
echo 'Installing global npm modules...'
echo ''
npm install -g brunch caniuse-cmd clinic git-open instant-markdown-d ndb npm tldr yarn

echo 'Installing SDKMAN & Java...'
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java

