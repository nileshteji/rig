# Snapshot file
# Unset all aliases to avoid conflicts with functions
unalias -a 2>/dev/null || true
# Functions

# setopts 2
setopt nohashdirs
setopt login

# aliases 41
alias arya='ssh 10.0.3.129 -l ubuntu'
alias asgard='ssh 10.0.3.91 -l ubuntu'
alias database='PGPASSWORD='\''(leap_staging)'\'' psql -h 10.0.3.163 -p 5433 -U postgres'
alias ga='git add .'
alias gaa='git add -A'
alias gb='git branch'
alias gba='git branch -a'
alias gbd='git branch -d'
alias gca='git commit --amend'
alias gcb='git checkout -b'
alias gcl='git clone'
alias gcm='git commit'
alias gco='git checkout'
alias gd='git diff'
alias gds='git diff --staged'
alias gl='git log --oneline --graph --decorate'
alias gp='git push origin'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias gr='git restore'
alias grs='git restore --staged'
alias gs='git status'
alias gsta='git stash'
alias gstl='git stash list'
alias gstp='git stash pop'
alias jarvis='ssh 10.0.3.63 -l ubuntu+'
alias lspci='system_profiler SPUSBDataType'
alias mario='ssh 10.0.3.89 -l ubuntu'
alias nginx_server='ssh 10.0.1.120 -l ubuntu'
alias popeye='ssh 10.0.3.120 -l ubuntu'
alias prod='ssh 20.0.2.196 -l ubuntu'
alias robin='ssh 10.0.3.104 -l ubuntu'
alias run-help=man
alias spartan='ssh 10.0.3.35 -l ubuntu'
alias staging='ssh 10.0.3.214 -l ubuntu'
alias stagingd='PGPASSWORD=RvSr00axOg  psql -h 10.0.3.144 -p 5432 -U postgres'
alias thanos='ssh 10.0.3.49 -l ubuntu'
alias thor='ssh 10.0.3.211 -l ubuntu'
alias ultron='ssh 10.0.3.96 -l ubuntu'
alias which-command=whence
alias white='ssh 10.0.3.143 -l ubuntu'

# exports 27
export CHROME_EXECUTABLE=/Applications/Dia.app/Contents/MacOS/Dia
export COLORTERM=truecolor
export COMMAND_MODE=unix2003
export GHOSTTY_BIN_DIR=/Applications/Ghostty.app/Contents/MacOS
export GHOSTTY_RESOURCES_DIR=/Applications/Ghostty.app/Contents/Resources/ghostty
export GHOSTTY_SHELL_FEATURES=cursor,path,title
export HOME=/Users/nileshteji
export KAMKANAM_GEMINI_API_KEY=AIzaSyDnKiLbKouK3OOE-vSQEkwjM4UgUSBOepY
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LOGNAME=nileshteji
export LaunchInstanceID=6491B40B-F399-499F-90E4-583D28830581
export OSLogRateLimit=64
export SECURITYSESSIONID=186b9
export SHELL=/bin/zsh
export SSH_AUTH_SOCK=/Users/nileshteji/.1password/agent.sock
export TERM=xterm-ghostty
export TERMINFO=/Applications/Ghostty.app/Contents/Resources/terminfo
export TERM_PROGRAM=ghostty
export TERM_PROGRAM_VERSION=1.2.3
export TMPDIR=/var/folders/xp/qp0cj29x0lqby11zccv6f_w40000gp/T/
export USER=nileshteji
export XDG_DATA_DIRS=/usr/local/share:/usr/share:/Applications/Ghostty.app/Contents/Resources/ghostty/..
export XPC_FLAGS=0x0
export XPC_SERVICE_NAME=0
export __CFBundleIdentifier=com.mitchellh.ghostty
export __CF_USER_TEXT_ENCODING=0x1F6:0x0:0x0
