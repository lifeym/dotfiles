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

dockerconfigjson() {
    local OPTIND opt ns name user reg_url passwd fmt
    while getopts ":n:N:u:r:p:f:h" opt ; do
        case "$opt" in
            n)  # namespace for this secret
                ns="$OPTARG"
                ;;
            N)  # name for this secret
                name="$OPTARG"
                ;;
            u)  # docker user name
                user="$OPTARG"
                ;;
            r)  # docker registry address
                reg_url="$OPTARG"
                ;;
            p)  # docker password/token
                passwd="$OPTARG"
                ;;
            f)  # output format: [json | k8s]
                fmt="$OPTARG"
                ;;
            h)  # print help message
                echo "WIP!"
                return 0
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                ;;
            :)
                echo "Option -$OPTARG requires an argument." >&2
                return 1
                ;;
        esac
    done
    shift $((OPTIND-1))

    [ -z "$fmt" ] && fmt="json"
    if [[ "$fmt" != "json" ]] && [[ "$fmt" != "k8s" ]]; then
        echo "Invalid value of -f: $fmt"
        echo "Valid values are: json, k8s"
    fi

    if [[ -z "$user" ]] || [[ -z "$reg_url" ]]; then
        echo "-u and -r are required."
        return 1
    fi

    if [[ -z "$passwd" ]]; then
        echo "p:$passwd"
        echo "Enter password of docker registry:"
        read -s passwd
        if [[ -z "$passwd" ]]; then
            echo "Password cannot be empty."
            return 1
        fi
    fi

    local json="{
  \"auths\": {
    \"$reg_url\": {
      \"auth\": \"$(echo -n "$user:$passwd" | base64)\"
    }
  }
}"
    if [[ "$fmt" == "json" ]]; then
        echo $json
        return 0
    fi

    if [[ -z "$ns" ]]; then
        ns='default'
    fi

    if [[ -z "$name" ]]; then
        echo "When apply to clusters, -m is required."
        return 1
    fi

    cat <<EOF
apiVersion: v1
kind: Secret
metadata:
  namespace: $ns
  name: $name
data:
  config.json: $(echo -n $json | base64)
EOF
    return 0
}
