#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# all environment variables are stored in ~/.env
export $(envsubst < .env)

# use of . builtin (aka source) to load aliases
. ~/.aliasrc

PS1='[\u@\h \W]\$ '
# Use bash-completion, if available
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion

set_path(){

    # Check if user id is 1000 or higher
    [ "$(id -u)" -ge 1000 ] || return

    for i in "$@";
    do
        # Check if the directory exists
        [ -d "$i" ] || continue

        # Check if it is not already in your $PATH.
        echo "$PATH" | grep -Eq "(^|:)$i(:|$)" && continue

        # Then append it to $PATH and export it
        export PATH="${PATH}:$i"
    done
}

set_path ~/.local/bin ~/scripts

# ignore upper and lowercase when TAB completion
bind "set completion-ignore-case on"
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'

# shopt
shopt -s autocd # change to named directory
shopt -s cdspell # autocorrects cd misspellings
shopt -s cmdhist # save multi-line commands in history as single line
shopt -s dotglob
shopt -s histappend # do not overwrite history
shopt -s expand_aliases # expand aliases

# add fzf autocompletion
export FZF_DEFAULT_COMMAND='fd .'

# ripgrep config
if type rg &> /dev/null; then
	export FZF_DEFAULT_COMMAND='rg --files --hidden'
fi

# more fzf utils
check_req() {
    type bat >/dev/null 2>&1 && type fd >/dev/null 2>&1 && type fzf >/dev/null 2>&1
}

fzf-nvim() {
    if check_req; then
        local selected_file
        selected_file=$(fd --type f --hidden --follow --max-depth 1 --exclude .git | fzf \
            --preview "if file --mime-type -b {} | grep -q '^image/';
                  then img2sixel {};
                  else bat --style=numbers --theme=gruvbox-dark --color=always {} | head -500; fi" \
            --preview-window=down:70% \
            --bind 'ctrl-d:preview-down,ctrl-u:preview-up' \
            --color=dark,fg:-1,bg:-1,hl:#5fff87,fg+:-1,bg+:-1,hl+:#ffaf5f \
            --color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7 \
            --query "$READLINE_LINE" --prompt="Open file in Neovim > ")

        if [ -n "$selected_file" ]; then
            if file --mime-type -b "$selected_file" | grep -q '^image/'; then
                img2sixel "$selected_file"
            else
                nvim "$selected_file"
            fi
        fi
    else
        echo "Error: bat, fd, or fzf not found. Please install them." >&2
    fi
}

fzf-cd() {
    if check_req; then
        local selected_file
        selected_file=$(fd --type d --hidden --follow --max-depth 1 --exclude .git | fzf \
            --preview "ls -l --color=auto {} | head -n 50" \
            --preview-window=down:70% \
            --bind 'ctrl-d:preview-down,ctrl-u:preview-up' \
            --color=dark,fg:-1,bg:-1,hl:#5fff87,fg+:-1,bg+:-1,hl+:#ffaf5f \
            --color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7 \
            --query "$READLINE_LINE" --prompt="Change dir to > ")

        if [ -n "$selected_file" ]; then
            cd "$selected_file" || return
        fi
    else
        echo "Error: bat, fd, or fzf not found. Please install them." >&2
    fi
}

bind -x '"\C-f": fzf-cd'
bind -x '"\C-k": fzf-nvim'

# launch starship shell prompt
eval "$(starship init bash)"

