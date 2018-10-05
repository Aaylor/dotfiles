
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

