vim9script

var zyCacheDir: string = "~/.cache/zy/cache"

export class Zy
    this._cacheDir: string

    def new(cacheDir: string)
        this._cacheDir = cacheDir
    enddef

    def Install(plugins: any): void
        for plugin in plugins.start
            # echo "repo: " .. plugin
            this.InstallOne(plugin.type, plugin.url, "start")
        endfor

        for plugin in plugins.opt
            echo "repo: " .. plugin
            this.InstallOne(plugin.type, plugin.url, "opt")
        endfor

        for f in plugins.archieves
            #echo "file: " .. f[0]
            #system("curl -o ".substitute(&rtp, ",.*", "", "")."/".f[0]." -L ".f[1])
        endfor

        silent! helptags ALL
        #echo "Plugins installed"
    enddef

    def InstallOne(ptype: string, urlOrName: string, sub: string)
        #var dir = substitute(&packpath, ",.*", "", "") .. "/pack/bundles/" .. sub .. "/"
        var d = expand("~/.vim/pack/bundles/" .. sub .. "/")
        echo d
        silent! mkdir(d, 'p')
        var url = urlOrName
        if ptype == "github"
            url = "https://github.com/" .. url
        endif
        echo "git clone --separate-git-dir " .. expand(zyCacheDir) .. " --depth=1 " .. url .. " " .. d
        system("git clone --separate-git-dir " .. expand(zyCacheDir) .. " --depth=1 " .. url .. " " .. d)
    enddef
endclass
