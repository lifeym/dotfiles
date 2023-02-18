vim9script

export class Zy
    this._packPath: string
    this._cachePath: string

    def new(cachePath: string, packPath: string)
        this._packPath = packPath
        this._cachePath = cachePath
    enddef

    def InstallPack(pack: any): void
        def MakePluginDir(sub: string): string
            const result = this._packPath .. "/pack/" .. pack.name .. "/" .. sub
            silent! mkdir(expand(result), 'p')
            return result
        enddef

        var installTo = MakePluginDir("start")
        for plugin in pack.start
            this.InstallOne(plugin.type, plugin.url, installTo)
        endfor

        for plugin in pack.opt
            echo "repo: " .. plugin
            this.InstallOne(plugin.type, plugin.url, "opt")
        endfor

        for f in pack.archieves
            #echo "file: " .. f[0]
            #system("curl -o ".substitute(&rtp, ",.*", "", "")."/".f[0]." -L ".f[1])
        endfor

        silent! helptags ALL
        #echo "Plugins installed"
    enddef

    def InstallOne(ptype: string, urlOrName: string, installTo: string)
        var url = urlOrName
        if ptype == "github"
            url = "https://github.com/" .. url
        endif

        const subd = split(urlOrName, "/")
        const installTarget = installTo .. "/" .. subd[-1]
        mkdir(expand(installTarget), 'p')
        system("git clone --depth=1 " .. url .. " " .. expand(installTarget))
    enddef
endclass

abstract class Utils
    static def IsWindows(): bool
        return has('win32') || has('win64')
    enddef

    static def IsMac(): bool
        return Utils.IsWindows()
            && !has('win32unix') 
            && (has('mac') || has('macunix') || has('gui_macvim') || (!isdirectory('/proc') && executable('sw_vers')))
    enddef

    # Danger!
    # Try remove a directory and all it's contents!
    static def Rmdir(d: string): number
        if Utils.IsWindows()
            system("rd /s /q " .. d)
        else
            system("rm -r " .. d)
        endif

        return v:shell_error
    enddef
endclass
