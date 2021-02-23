
function lsml() {
    local ls_directories=()
    local ls_options=()

    while test $# -gt 0; do
        case "$1"; in
            -*)
                ls_options+=("$1");;
            *)
                ls_directories+=("$1");;
        esac
        shift
    done

    output=(
        $(find "${ls_directories[@]}" \
               -maxdepth 1 \
               \( -name '*.ml' -o \
               -name '*.mli' -o \
               -name '*.eliom' -o \
               -name '*.eliomi' \))
    )

    if [ ${#output} -eq 0 ]; then
        echo "No OCaml files found."
    else
        ls --color=tty "${output[@]}" $ls_options
    fi
}

function tdib() {
    if ! which tis-do > /dev/null 2>&1; then
        echo "tis-do is not installed..." 2>&1
        return 1
    fi

    tis_utils=$(tis-config get utils)
    if [ -z "$tis_utils" ]; then
        echo "unable to get the tis_utils directory..." 2>&1
        return 2
    fi

    pushd "$tis_utils" > /dev/null 2>&1
    {
        branch_name=$(git symbolic-ref HEAD | sed 's|refs/heads/||')
    }
    popd > /dev/null 2>&1

    set -x
    tis-do install "${branch_name}" "$@"
}

function tcb() {
    tis_utils=$(tis-config get utils)
    if [ -z "$tis_utils" ]; then
        echo "unable to get the tis_utils directory..." 2>&1
        return 2
    fi

    pushd "$tis_utils" > /dev/null 2>&1
    {
        branch_name=$(git symbolic-ref HEAD | sed 's|refs/heads/||')
    }
    popd > /dev/null 2>&1

    tis_choose "${branch_name}"
}

function tmake() {
    if ! which tis-env > /dev/null 2>&1; then
        >&2 echo "tis-env is not installed..."
        return 2
    fi

    tis_utils=$(tis-config get utils)
    if [ -z "$tis_utils" ]; then
        >&2 echo "unable to get the tis_utils directory..."
        return 2
    fi

    (
        pushd "${tis_utils}/taas"
        {
            branch_name=$(git symbolic-ref HEAD | sed 's|refs/heads/||')
            tis-env -n"$branch_name" make "$@" || true
        }
        popd
    )
}

function __emacs() {
    # This check if I have already run an emacsclient --create-frame,
    # if yes, use the current frame, if no create a new frame.
    emacsclient -c -n "$@"
}

alias cedit='emacsclient -c -nw'
alias wedit='__emacs'
alias start_emacs='emacs --daemon'
alias stop_emacs='emacsclient -e "(kill-emacs)"'
