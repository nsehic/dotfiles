# Disable greeting
set fish_greeting

if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Google Cloud SDK PATH setup
if test -f "$HOME/google-cloud-sdk/path.fish.inc"
    source "$HOME/google-cloud-sdk/path.fish.inc"
end

if test -f "$HOME/google-cloud-sdk/completion.bash.inc"
  bass source "$HOME/google-cloud-sdk/completion.bash.inc"
end

set -gx EDITOR "nvim"
set -gx MANPAGER 'nvim +Man!'

set -g LDFLAGS -L/opt/homebrew/opt/openssl/lib
set -g CPPFLAGS -I/opt/homebrew/opt/openssl/include

function nvm
  bass source (brew --prefix nvm)/nvm.sh --no-use ';' nvm $argv
end
set -x NVM_DIR ~/.nvm
nvm use default --silent # Or a specific version you want to use by default

if test (uname -m) = "arm64"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
end

# uv
fish_add_path "$HOME/.local/bin"
fish_add_path /opt/homebrew/opt/libpq/bin
fish_add_path /opt/homebrew/opt/openssl/bin

# pycharm
fish_add_path "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
