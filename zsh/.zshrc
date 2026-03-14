# Oh My Zsh configuration (commented out)
# export ZSH="$HOME/.oh-my-zsh"
# ZSH_THEME="robbyrussell"
# plugins=(git)
# source $ZSH/oh-my-zsh.sh

alias lspci="system_profiler SPUSBDataType"
alias gs="git status"
alias gcm="git commit"
alias gca="git commit --amend"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gb="git branch"
alias gba="git branch -a"
alias gbd="git branch -d"
alias ga="git add ."
alias gaa="git add -A"
alias gd="git diff"
alias gds="git diff --staged"
alias gl="git log --oneline --graph --decorate"
alias gpl="git pull"
alias gp="git push origin"
alias gpf="git push --force-with-lease"
alias gr="git restore"
alias grs="git restore --staged"
alias gcl="git clone"
alias gsta="git stash"
alias gstp="git stash pop"
alias gstl="git stash list"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export CHROME_EXECUTABLE="/Applications/Dia.app/Contents/MacOS/Dia"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/Users/nileshteji/Library/Android/sdk/emulator"
export PATH="/Users/nileshteji/.amp/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export SSH_AUTH_SOCK="$HOME/.1password/agent.sock"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# opencode
export PATH=/Users/nileshteji/.opencode/bin:$PATH
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
export PATH="$HOME/.jenv/bin:$PATH"
export TERM=xterm-256color

# Google Workspace CLI credentials
if [[ -f "$HOME/.config/gws/credentials.json" ]]; then
    export GOOGLE_WORKSPACE_CLI_CREDENTIALS_FILE="$HOME/.config/gws/credentials.json"
fi

# Google Cloud CLI (Homebrew)
for gcloud_sdk_root in "/opt/homebrew/share/google-cloud-sdk" "/usr/local/share/google-cloud-sdk"; do
    if [[ -d "$gcloud_sdk_root" ]]; then
        export PATH="$gcloud_sdk_root/bin:$PATH"
        if [[ -f "$gcloud_sdk_root/path.zsh.inc" ]]; then
            . "$gcloud_sdk_root/path.zsh.inc"
        fi
        if [[ -f "$gcloud_sdk_root/completion.zsh.inc" ]]; then
            . "$gcloud_sdk_root/completion.zsh.inc"
        fi
        break
    fi
done

# Load machine-specific secrets (zsh/.zshrc.local in dotfiles)
DOTFILES_ZSH_DIR="$(dirname "$(readlink -f "${(%):-%x}")" 2>/dev/null)"
if [[ -n "$DOTFILES_ZSH_DIR" && -f "$DOTFILES_ZSH_DIR/.zshrc.local" ]]; then
    source "$DOTFILES_ZSH_DIR/.zshrc.local"
fi

# bun completions
[ -s "/Users/nilesh/.bun/_bun" ] && source "/Users/nilesh/.bun/_bun"
