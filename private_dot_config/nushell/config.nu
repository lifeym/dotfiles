# The default config record. This is where much of your global configuration is setup.
$env.config = $env.config? | default {} | merge {
    show_banner: false # true or false to enable or disable the welcome banner at startup

    history: {
        max_size: 1000 # Session has to be reloaded for this to take effect
    }

    filesize: {
        metric: true # true => KB, MB, GB (ISO standard), false => KiB, MiB, GiB (Windows standard)
    }

    edit_mode: vi # emacs, vi
    hooks: {
        pre_prompt: [{ null }] # run before the prompt is shown
        env_change: {
            PWD: (source hooks/env_change/PWD/all.nu)
            # PWD: [
            #     # direnv
            #     { ||
            #         if (which direnv | is-empty) {
            #             return
            #         }

            #         direnv export json | from json | default {} | load-env
            #     }
            # ]
        }
        pre_execution: (source hooks/pre_execution/all.nu)
    }
}

### utils

# copy file's path to cb's default(system) clipboard
def copypath [f: string] {
    $f | path expand | path dirname | do {|| if (which cb | is-empty) {print} else {cb}}
}

###

### alias

alias ll = ls -al

###

# starship
use ~/.cache/starship/init.nu

# zoxide
source ~/.cache/zoxide/.zoxide.nu
