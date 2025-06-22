# The default config record. This is where much of your global configuration is setup.
$env.config = $env.config? | default {} | merge {
    show_banner: false # true or false to enable or disable the welcome banner at startup

    history: {
        max_size: 1000 # Session has to be reloaded for this to take effect
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

# ENV
$env.EDITOR = "vim"

# Work around for direnv error:
#   direnv: error Couldn't find a configuration directory for direnv
# See: https://github.com/direnv/direnv/issues/442
if (not ('HOME' in $env)) {
  $env.HOME = $env.HOMEDRIVE + $env.HOMEPATH
}

### utils

# copy file's path to cb's default(system) clipboard
def copypath [f: string] {
    $f | path expand | path dirname | do {|| if (which cb | is-empty) {print} else {cb}}
}

###

### alias

alias ll = ls -al
alias vi = vim

###

$env.FZF_DEFAULT_COMMAND = "rg --files"

# Git for windows embded a ssh client, which buggy,
# cause `git clone` to be stuck with ssh protocol in ssh_config.
# Windows 11 come with `openssh` preinstalled, use this if exists.
if ("C:/WINDOWS/System32/OpenSSH/ssh.exe" | path exists) {
  $env.GIT_SSH = "C:/WINDOWS/System32/OpenSSH/ssh.exe"
}

# starship
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

# zoxide
zoxide init nushell | save -f ($nu.data-dir | path join "vendor/autoload/zoxide.nu")
