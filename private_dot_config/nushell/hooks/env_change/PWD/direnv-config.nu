{||
    if (which direnv | is-empty) {
        return
    }

    direnv export json | from json | default {} | load-env

    # direnv export 'PATH' as string, but nushell use 'PATH' as list<string>
    # so we need next line for converting 'PATH' from string back to list<string>
    # this is no problem for bash zsh etc... with linux...
    $env.PATH = $env.PATH | split row (char env_sep)

    # strange bug with windows 11
    # Under windows, nushell prefer use env var 'Path', not 'PATH'!
    # 'PATH' is not exist before direnv export, and would be added after that.(expected)
    # 'Path' is a list<string>, before direnv export, and would be changed to <nothing> after direnv(strange)
    if (('Path' in $env) and ('PATH' in $env)) {
      $env.Path = $env.PATH
      $env | reject PATH
    }
}
