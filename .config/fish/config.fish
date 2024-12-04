
# directory colors
eval (dircolors -c $HOME/.dir_colors)

direnv hook fish | source

# Path variables
set PATH $HOME/.local/bin $PATH
set PATH $HOME/.local/share/poetry/bin $PATH
set PATH $HOME/.cargo/bin $PATH
set PATH $HOME/.local/bin/ncbi $PATH

# Misc env variables
# stop homebrew from fucking updating and breaking everything during brew install
set -gx HOMEBREW_NO_AUTO_UPDATE 1

# vi mode
#set -g fish_key_bindings fish_vi_key_bindings

function fish_user_key_bindings
    bind \cr 'peco_select_history (commandline -b)'
    bind -M insert \cf accept-autosuggestion
    bind -M default _ beginning-of-line

    fish_vi_key_bindings
end

set -g fish_key_bindings fish_user_key_bindings

# set up ssh-agent
fish_ssh_agent

# aliases
alias vim "nvim"
alias ls "ls --color=auto"
alias dotfiles "git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
