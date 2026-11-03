# ~/.config/fish/config.fish — managed by rig (fish/config.fish)
# Secrets and machine-specific aliases live in ~/.config/fish/conf.d/local.fish
# (rig: fish/config.local.fish, git-ignored).

# --- Environment ---
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8
set -gx CHROME_EXECUTABLE /Applications/Dia.app/Contents/MacOS/Dia
set -gx ANDROID_HOME $HOME/Library/Android/sdk
set -gx BUN_INSTALL $HOME/.bun
set -gx SSH_AUTH_SOCK $HOME/.1password/agent.sock
set -gx TERM xterm-256color
test -f $HOME/.config/gws/credentials.json
and set -gx GOOGLE_WORKSPACE_CLI_CREDENTIALS_FILE $HOME/.config/gws/credentials.json

# --- PATH: prepended (highest priority first; missing dirs are skipped) ---
fish_add_path --global --move \
    $HOME/.local/bin \
    /opt/homebrew/share/google-cloud-sdk/bin \
    $HOME/.jenv/bin \
    $HOME/.opencode/bin \
    $BUN_INSTALL/bin \
    /opt/homebrew/opt/postgresql@15/bin \
    $HOME/.amp/bin \
    /opt/homebrew/bin

# --- PATH: appended (lowest priority) ---
fish_add_path --global --append \
    $HOME/.docker/bin \
    $ANDROID_HOME/emulator \
    $HOME/.maestro/bin

# --- jenv (adds ~/.jenv/shims, sets JAVA_HOME) ---
if type -q jenv; and not set -q JENV_LOADED
    jenv init - fish | source
    set -gx JAVA_HOME (jenv prefix 2>/dev/null)
end

# Prompt: pure (pure-fish/pure via fisher, see fish/fish_plugins)
set -g fish_greeting

if status is-interactive
    abbr -a lspci system_profiler SPUSBDataType
    abbr -a gs git status
    abbr -a gcm git commit
    abbr -a gca git commit --amend
    abbr -a gco git checkout
    abbr -a gcb git checkout -b
    abbr -a gb git branch
    abbr -a gba git branch -a
    abbr -a gbd git branch -d
    abbr -a ga git add .
    abbr -a gaa git add -A
    abbr -a gd git diff
    abbr -a gds git diff --staged
    abbr -a gl git log --oneline --graph --decorate
    abbr -a gpl git pull
    abbr -a gp git push origin
    abbr -a gpf git push --force-with-lease
    abbr -a gr git restore
    abbr -a grs git restore --staged
    abbr -a gcl git clone
    abbr -a gsta git stash
    abbr -a gstp git stash pop
    abbr -a gstl git stash list
end
