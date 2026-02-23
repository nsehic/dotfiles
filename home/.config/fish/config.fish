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
set -gx AWS_DEFAULT_PROFILE Kogan-Developer-105834552929

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

# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/nermin.sehic/.lmstudio/bin
# End of LM Studio CLI section


# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/nermin.sehic/Developer/google-cloud-sdk/path.fish.inc' ]; . '/Users/nermin.sehic/Developer/google-cloud-sdk/path.fish.inc'; end


function aws-login
    # Use passed profile or default
    set profile $argv[1]
    if test -z "$profile"
        set profile default
    end

    echo "Using AWS profile: $profile"

    # Clear old credentials
    set -e AWS_ACCESS_KEY_ID
    set -e AWS_SECRET_ACCESS_KEY
    set -e AWS_SESSION_TOKEN

    # SSO login + export fresh creds
    aws sso login --profile $profile
    aws configure export-credentials --profile $profile --format env | source

    # Only run dev scripts inside the K3 directory
    if test "$PWD" = "/Users/nermin.sehic/Developer/K3"
        echo "Running K3 dev setup..."
        ./dev_setup.sh service_down
        ./dev_setup.sh service_up
    end
end
