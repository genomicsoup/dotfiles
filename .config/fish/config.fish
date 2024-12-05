
# lets us handle specific linux/macos cases
set -l OS (uname)

# directory colors
if test "$OS" = Darwin
    eval (gdircolors -c $HOME/.dir_colors)
else
    eval (dircolors -c $HOME/.dir_colors)
end

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
    bind -M default \cr 'peco_select_history (commandline -b)'
    bind -M insert \cr 'peco_select_history (commandline -b)'
    bind -M insert \cf accept-autosuggestion
    bind -M default _ beginning-of-line
    bind -M visual _ beginning-of-line

    fish_vi_key_bindings
end

set -g fish_key_bindings fish_user_key_bindings

# set up ssh-agent
fish_ssh_agent

# aliases
alias vim "nvim"
alias ls "gls --color=auto"
alias tmux "tmux -2"
alias dotfiles "git --git-dir=$HOME/.dotfiles --work-tree=$HOME"

# color theme shit
set -gx fish_color_end 7a7a7a
set -gx fish_color_error ffaa88
set -gx fish_color_quote 708090
set -gx fish_color_param aaaaaa
set -gx fish_color_option aaaaaa
set -gx fish_color_normal CCCCCC
set -gx fish_color_escape 789978
set -gx fish_color_comment 555555
set -gx fish_color_command CCCCCC
set -gx fish_color_keyword 7a7a7a
set -gx fish_color_operator 7788aa
set -gx fish_color_redirection ffaa88
set -gx fish_color_autosuggestion 555555
set -gx fish_color_selection --background=555555
set -gx fish_color_search_match --background=555555
set -gx fish_pager_color_prefix 999999
set -gx fish_pager_color_progress 555555
set -gx fish_pager_color_completion cccccc
set -gx fish_pager_color_description 7a7a7a
set -gx fish_pager_color_selected_background --background=555555

