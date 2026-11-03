# lite-samurai port (Mitsuhiko style), mirrors ~/.oh-my-zsh/custom/themes/lite-samurai.zsh-theme
#
#   user at host in ~/path on git:branch+? workon venv exited 1
#   $
function fish_prompt
    set -l last_status $status
    set -l n (set_color normal)

    echo
    printf '%s%s%s at %s%s%s in %s%s%s' \
        (set_color magenta) $USER $n \
        (set_color yellow) (prompt_hostname) $n \
        (set_color green) (prompt_pwd --full-length-dirs=99) $n

    # git: " on git:branch" + cyan "+" (changed) + green "?" (untracked)
    set -l branch (command git symbolic-ref --short HEAD 2>/dev/null; or command git rev-parse --short HEAD 2>/dev/null)
    if test -n "$branch"
        printf ' on %sgit%s:%s' (set_color blue) $n $branch
        set -l st (command git status --porcelain 2>/dev/null)
        if string match -qr '^(.M|M.|A.|D.|.D|R.)' -- $st
            printf '%s+' (set_color cyan)
        end
        if string match -qr '^\?\?' -- $st
            printf '%s?' (set_color green)
        end
        printf '%s' $n
    end

    # virtualenv: " workon <name>"
    if set -q VIRTUAL_ENV
        printf ' workon %s%s%s' (set_color red) (basename $VIRTUAL_ENV) $n
    end

    # non-zero exit status
    if test $last_status -ne 0
        printf ' exited %s%s%s' (set_color red) $last_status $n
    end

    printf ' \n$ '
end
