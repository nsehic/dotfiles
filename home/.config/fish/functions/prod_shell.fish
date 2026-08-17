function prod_shell -d "Prod bastion shell with a colored terminal background (allow-listed repos only)"
    argparse -x 'h,l,a,r,R' h/help l/list a/allow 'r/remove=?' R/reset readonly -- $argv
    or return 2

    set -q PROD_SHELL_REPOS; or set -U PROD_SHELL_REPOS kogan/ksub kogan/k3
    set -q PROD_SHELL_BG; or set -g PROD_SHELL_BG '#3b0d0d'
    set -q PROD_SHELL_READONLY_BG; or set -g PROD_SHELL_READONLY_BG '#0d3b0d'

    if set -q _flag_help
        echo "Usage: prod_shell [OPTIONS]

Runs ./shortcuts.sh prod_shell with a red or green terminal background, but only from
repositories on the allow-list.

Options:
      --readonly        Run prod_shell_readonly with a green background
  -a, --allow           Add the current repo to the allow-list
  -r, --remove [SLUG]   Remove SLUG from the allow-list (default: current repo)
  -l, --list            Show the allow-list
  -R, --reset           Restore the background colour if it gets stuck
  -h, --help            Show this help

Background colour: \$PROD_SHELL_BG (currently $PROD_SHELL_BG)
Read-only background colour: \$PROD_SHELL_READONLY_BG (currently $PROD_SHELL_READONLY_BG)"
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

    # Determine command and background color based on --readonly flag
    set -l shortcut_cmd "prod_shell"
    set -l bg_color $PROD_SHELL_BG

    if set -q _flag_readonly
        set shortcut_cmd "prod_shell_readonly"
        set bg_color $PROD_SHELL_READONLY_BG
    end

    printf '\e]11;%s\a' $bg_color
    ./shortcuts.sh $shortcut_cmd $argv
    set -l rc $status

    __prod_shell_reset
    return $rc
end

