{||
    if (commandline | is-empty) {
        if ('.git' | path exists) {
            git status -u .
        } else {
            ls | print
        }
    }
}
