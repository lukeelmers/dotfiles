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
#  6) Installs Ruby (with rbenv) & Rails


# settings
dir=~/dotfiles                       # dotfiles directory
olddir=~/dotfiles_backup             # old dotfiles backup directory
# list of files/folders to symlink in home directory
files=".bash_profile .bashrc .gitignore_global .hyper.js .psqlrc .shell_prompt.sh .tmux.conf .vim .vimrc .zshrc"
# create directory in order to install nvm via homebrew
mkdir ~/.nvm

# create backup directory
echo -n "Creating $olddir to backup existing dotfiles in ~ ..."
mkdir -p $olddir

cd $dir

# move any existing dotfiles in ~ to backup directory, then create symlinks from ~ to any files in $dir that are listed above
for file in $files; do
    echo "Moving $file from ~ to $olddir"
    mv ~/$file ~/dotfiles_old/
    echo "Creating symlink to $file in home directory."
    ln -s $dir/$file ~/$file
done
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

# Workaround for Homebrew Postgres issue documented here: stackoverflow.com/a/27708774
rm -r /usr/local/var/postgres
initdb -D /usr/local/var/postgres/
brew tap homebrew/services
brew services restart postgresql
createdb

brew doctor

# Install Xcode command line tools (required for Rails)
xcode-select --install

echo ''
echo 'Installing Ruby...'
echo ''
rbenv install 2.2.3
rbenv global 2.2.3
ruby -v

echo ''
echo 'Installing Rails (requires sudo)...'
echo ''
sudo gem install rails -v 4.2.3
rbenv rehash
rails -v

echo ''
echo 'Installing global npm modules...'
echo ''
npm install -g brunch
npm install -g bunyan
npm install -g caniuse-cmd
npm install -g git-open
npm install -g instant-markdown-d
npm install -g pino
npm install -g tldr

