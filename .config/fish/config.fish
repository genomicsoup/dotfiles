
# directory colors
eval (dircolors -c $HOME/.dir_colors)

function fish_user_key_bindings
    bind \cr 'peco_select_history (commandline -b)'
end
direnv hook fish | source

# Path variables
set PATH $HOME/.local/bin $PATH
set PATH $HOME/edirect $PATH
set PATH $HOME/.cargo/bin $PATH
set PATH $HOME/.local/bin/ncbi $PATH

# Misc env variables
# stop homebrew from fucking updating and breaking everything during brew install
set -gx HOMEBREW_NO_AUTO_UPDATE 1

# set up ssh-agent
fish_ssh_agent

# aliases
alias vim "nvim"
alias ls "ls --color=auto"
alias dotfiles "git --git-dir=$HOME/.dotfiles --work-tree=$HOME"
