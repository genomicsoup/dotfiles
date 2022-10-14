set --export PYENV_ROOT ${HOME}/.pyenv

# fish_add_path "$PYENV_ROOT/shims"
contains "$PYENV_ROOT/shims" $fish_user_paths; or set -Ua fish_user_paths "$PYENV_ROOT/shims"

# Enable virtualenv autocomplete
status --is-interactive; and pyenv init - | source
# status --is-interactive; and pyenv virtualenv-init - | source

