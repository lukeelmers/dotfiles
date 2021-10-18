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
files=".bash_profile .bashrc .gitignore_global .hyper.js .psqlrc .shell_prompt.sh .tmux.conf .vim .vimrc .vscode .zshrc"

if ! type "git" > /dev/null; then
  echo "ERROR: git must be installed before running."
  exit 1
fi

if ! type "code" > /dev/null; then
  echo "ERROR: vscode must be installed before running."
  exit 1
fi

# create directory in order to install nvm via homebrew
mkdir ~/.nvm

# create directory for todo.sh addons
mkdir ~/.todo.actions.d

# create Developer directory
mkdir ~/Developer

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

# Symlink vscode dotfiles
ln -s ~/.vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
ln -s ~/.vscode/keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json
ln -s ~/.vscode/snippets/ ~/Library/Application\ Support/Code/User/snippets

# Install vscode extensions
code --install-extension arthurwhite.white
code --install-extension asciidoctor.asciidoctor-vscode
code --install-extension BazelBuild.vscode-bazel
code --install-extension buster.ndjson-colorizer
code --install-extension dawhite.mustache
code --install-extension dbaeumer.vscode-eslint
code --install-extension eamodio.gitlens
code --install-extension Equinusocio.vsc-community-material-theme
code --install-extension Equinusocio.vsc-material-theme
code --install-extension equinusocio.vsc-material-theme-icons
code --install-extension formulahendry.auto-rename-tag
code --install-extension futagozaryuu.pegjs-syntax
code --install-extension GitHub.copilot
code --install-extension GitHub.vscode-pull-request-github
code --install-extension golang.go
code --install-extension hashicorp.terraform
code --install-extension jakearl.search-editor-apply-changes
code --install-extension joaompinto.asciidoctor-vscode
code --install-extension mechatroner.rainbow-csv
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension ms-toolsai.jupyter
code --install-extension ms-toolsai.jupyter-keymap
code --install-extension ms-toolsai.jupyter-renderers
code --install-extension msjsdiag.debugger-for-chrome
code --install-extension redhat.vscode-commons
code --install-extension redhat.vscode-yaml
code --install-extension ryu1kn.partial-diff
code --install-extension silvenon.mdx
code --install-extension vscodevim.vim
code --install-extension wayou.vscode-todo-highlight
code --install-extension xdae.vscode-snazzy-theme

echo ''
echo 'Installing global npm modules...'
echo ''
npm install -g brunch caniuse-cmd clinic git-open instant-markdown-d ndb npm tldr yarn

echo 'Installing SDKMAN & Java...'
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install java

