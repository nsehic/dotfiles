# prod_shell — open a production bastion shell with a red terminal background.

function __prod_shell_reset -d "Restore the terminal background colour"
    printf '\e]111\a'
end

function __prod_shell_slug -d "Print the lowercased owner/repo slug of \$PWD's repo"
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "prod_shell: not inside a git repository" >&2
        return 1
    end

    set -l url (git remote get-url origin 2>/dev/null)
    if test -z "$url"
        echo "prod_shell: repo has no 'origin' remote, cannot identify it" >&2
        return 1
    end

    string replace -r '\.git$' '' -- $url \
        | string replace -r '^.*[:/]([^/:]+/[^/]+)$' '$1' \
        | string lower
end

function prod_shell -d "Prod bastion shell with a red terminal (allow-listed repos only)"
    argparse -x 'h,l,a,r,R' h/help l/list a/allow 'r/remove=?' R/reset -- $argv
    or return 2

    set -q PROD_SHELL_REPOS; or set -U PROD_SHELL_REPOS kogan/ksub kogan/k3
    set -q PROD_SHELL_BG; or set -g PROD_SHELL_BG '#3b0d0d'

    if set -q _flag_help
        echo "Usage: prod_shell [OPTIONS]

Runs ./shortcuts.sh prod_shell with a red terminal background, but only from
repositories on the allow-list.

Options:
  -a, --allow           Add the current repo to the allow-list
  -r, --remove [SLUG]   Remove SLUG from the allow-list (default: current repo)
  -l, --list            Show the allow-list
  -R, --reset           Restore the background colour if it gets stuck
  -h, --help            Show this help

Background colour: \$PROD_SHELL_BG (currently $PROD_SHELL_BG)"
        return 0
    end

    if set -q _flag_reset
        __prod_shell_reset
        return 0
    end

    if set -q _flag_list
        if test (count $PROD_SHELL_REPOS) -eq 0
            echo "prod_shell: allow-list is empty"
        else
            printf '%s\n' $PROD_SHELL_REPOS
        end
        return 0
    end

    if set -q _flag_allow
        set -l slug (__prod_shell_slug)
        test -n "$slug"; or return 1

        if contains -- $slug $PROD_SHELL_REPOS
            echo "prod_shell: $slug is already allowed"
            return 0
        end
        set -U PROD_SHELL_REPOS $PROD_SHELL_REPOS $slug
        echo "prod_shell: added $slug"
        return 0
    end

    if set -q _flag_remove
        set -l slug $_flag_remove
        if test -z "$slug"
            set slug (__prod_shell_slug)
            test -n "$slug"; or return 1
        end
        set slug (string lower -- $slug)

        if not contains -- $slug $PROD_SHELL_REPOS
            echo "prod_shell: $slug is not in the allow-list" >&2
            return 1
        end
        set -U PROD_SHELL_REPOS (string match -v -- $slug $PROD_SHELL_REPOS)
        echo "prod_shell: removed $slug"
        return 0
    end

    set -l slug (__prod_shell_slug)
    test -n "$slug"; or return 1

    if not contains -- $slug $PROD_SHELL_REPOS
        echo "prod_shell: '$slug' is not an allowed repo" >&2
        echo "            allowed: $PROD_SHELL_REPOS" >&2
        echo "            add it with: prod_shell --allow" >&2
        return 1
    end

    if not test -x ./shortcuts.sh
        if test -e ./shortcuts.sh
            echo "prod_shell: ./shortcuts.sh is not executable — chmod +x ./shortcuts.sh" >&2
        else
            echo "prod_shell: no ./shortcuts.sh in "(pwd)" — run from the repo root" >&2
        end
        return 1
    end

    function __prod_shell_restore --on-event fish_postexec
        __prod_shell_reset
        functions -e __prod_shell_restore
    end

    printf '\e]11;%s\a' $PROD_SHELL_BG
    ./shortcuts.sh prod_shell $argv
    set -l rc $status

    __prod_shell_reset
    return $rc
end
