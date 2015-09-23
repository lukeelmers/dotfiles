# ==============================================================================
# bash_profile - github.com/lukeelmers/dotfiles
# ==============================================================================


# GENERAL ----------------------------------------------------------------------

# style command prompt
source ~/.shell_prompt.sh

# initialize rbenv
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# To install Homebrew in your Home folder:
# $ cd ~ && git clone https://github.com/mxcl/homebrew.git && ln -s /usr/local/bin ~/homebrew/bin
# PATH=${HOME}/Homebrew/bin:${PATH}

# Include /usr/local/sbin in PATH to prevent Homebrew warnings
PATH="/usr/local/sbin:$PATH"

export PATH

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Append to the Bash history file, rather than overwriting it
shopt -s histappend;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Add tab completion for many Bash commands
if which brew > /dev/null && [ -f "$(brew --prefix)/share/bash-completion/bash_completion" ]; then
    source "$(brew --prefix)/share/bash-completion/bash_completion";
elif [ -f /etc/bash_completion ]; then
    source /etc/bash_completion;
fi;

# Add tab completion for SSH hostnames based on ~/.ssh/config, ignoring wildcards
[ -e "$HOME/.ssh/config" ] && complete -o "default" -o "nospace" -W "$(grep "^Host" ~/.ssh/config | grep -v "[?*]" | cut -d " " -f2- | tr ' ' '\n')" scp sftp ssh;

# Add `killall` tab completion for common apps
complete -o "nospace" -W "Contacts Calendar Dock Finder Mail Safari iTunes SystemUIServer Terminal Twitter" killall;

# Enable aliases to be sudo'ed
alias sudo="sudo "


# SHOWING/HIDING ---------------------------------------------------------------

# show/hide a specific file from Finder
alias hide="chflags hidden"
alias show="chflags nohidden"

# show/hide hidden files
alias hideall="defaults write com.apple.finder AppleShowAllFiles FALSE && killall Finder"
alias showall="defaults write com.apple.finder AppleShowAllFiles TRUE && killall Finder"

# show/hide desktop icons (useful when presenting)
alias hidedesktop="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias showdesktop="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"


# NAVIGATION -------------------------------------------------------------------

# shortcuts
alias d="cd ~/Dropbox"
alias dv="cd ~/Sites"
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias h="history"
alias j="jobs"

# up 'n' folders
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

# detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
    colorflag="--color"
else # OS X `ls`
    colorflag="-G"
fi

# List all files colorized in long format
alias l="ls -lhF ${colorflag}"

# List all files colorized in long format, including dot files
alias la="ls -lahF ${colorflag}"

# List only directories
alias lsd="ls -lhF ${colorflag} | grep --color=never '^d'"

# Always use color output for `ls`
alias ls="command ls ${colorflag}"
export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'

# grep with color
alias grep="grep --color=auto"


# GIT --------------------------------------------------------------------------

# git aliases
alias g='git'
alias gitundo='git reset --soft HEAD~1'
alias glg='git log --date-order --all --graph --format="%C(green)%h%Creset %C(yellow)%an%Creset %C(blue bold)%ar%Creset %C(red bold)%d%Creset%s"'
alias glg2='git log --date-order --all --graph --name-status --format="%C(green)%H%Creset %C(yellow)%an%Creset %C(blue bold)%ar%Creset %C(red bold)%d%Creset%s"'


# UTILITIES --------------------------------------------------------------------

# Check IP
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Run speedtest from speedtest.net: github.com/sivel/speedtest-cli
alias speedtest="speedtest-cli"

# Processes
alias ps="ps -ax"

# View HTTP traffic
alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

# Get OS X Software Updates, and update installed Ruby gems, Homebrew, npm, and their installed packages
alias update='sudo softwareupdate -i -a; brew update; brew upgrade --all; brew cleanup; npm install npm -g; npm update -g; sudo gem update --system; sudo gem update'

# Flush Directory Service cache
alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"

# Recursively delete `.DS_Store` files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"

# Kill all the tabs in Chrome to free up memory: commandlinefu.com/commands/view/402/exclude-grep-from-your-grepped-output-of-ps-alias-included-in-description
alias chromekill="ps ux | grep '[C]hrome Helper --type=renderer' | grep -v extension-process | tr -s ' ' | cut -d ' ' -f2 | xargs kill"


# TOOLS ------------------------------------------------------------------------

# Lock computer
alias lock='/System/Library/CoreServices/"Menu Extras"/User.menu/Contents/Resources/CGSession -suspend'

# refresh shell
alias reload="exec $SHELL -l"

# tar/untar files
alias zip="tar -czvf"
alias unzip="tar -xzvf"

# Get screengrab of any webpage: paulhammond.org/webkit2png
alias screengrab="webkit2png --fullsize --width=1800 -D ~/Desktop"

# Merge PDF files (usage: `mergepdf -o output.pdf input{1,2,3}.pdf`)
alias mergepdf="/System/Library/Automator/Combine\ PDF\ Pages.action/Contents/Resources/join.py"

# Get week number
alias week="date +%V"

# Stopwatch
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

# Mute volume
alias mute="osascript -e 'set volume output muted true'"

# Start elastic search manually instead of using launchctl or 'brew services start elasticsearch'
alias elasticstart="elasticsearch --config=/usr/local/opt/elasticsearch/config/elasticsearch.yml"
