# kubecfg
kubecfg() {
    local ctx_home="$HOME/.kube/contexts"
    [[ -d $ctx_home ]] || mkdir -p $ctx_home
    if [[ $# -eq 0 ]]; then
        printf "help wip!"
        return 0
    fi

    print_usage() {
        printf "help wip!\n"
    }

    refresh_env_kubeconfig() {
        # Add default kube config first
        export KUBECONFIG="$HOME/.kube/config"
        for c in $(IFS=$'\n' find ~/.kube/contexts -type f); do
            export KUBECONFIG="$c:$KUBECONFIG"
        done
    }

    local cmd=$1
    shift
    case $cmd in
        cd)
            cd "$ctx_home"
            ;;
        clear)
            export KUBECONFIG=
            ;;
        path)
            printf "$ctx_home"
            ;;
        refresh|ref)
            refresh_env_kubeconfig
            ;;
        *)
            printf "Unknown command:%s\n" $cmd
            print_usage
    esac
}

kubecfg ref

alias k=kubectl
alias kcr="kubecfg ref"
alias kc="kubectl config"
alias kccc="kubectl config current-context"
alias kcgc="kubectl config get-contexts"
alias kcuc="kubectl config use-context"
