vim9script

const INSTALL_ACTION_SKIP = 1
const INSTALL_ACTION_UPDATE = 2

export class Zy
    this._packPath: string
    this._cachePath: string

    def Private_DoInstall(packs: list<any>, clean: bool, action: number): void
        for pack in packs
            this.Private_InstallPack(pack, clean, action)
        endfor
    enddef

    def new(cachePath: string, packPath: string)
        this._packPath = packPath
        this._cachePath = cachePath
    enddef

    def Install(packs: list<any>, clean: bool = false)
        this.Private_DoInstall(packs, clean, INSTALL_ACTION_SKIP)
    enddef

    def Update(packs: list<any>, clean: bool = false)
        this.Private_DoInstall(packs, clean, INSTALL_ACTION_UPDATE)
    enddef

    def Private_InstallPack(pack: any, clean: bool, action: number): void
        if !has_key(pack, "name")
            Error("Package without a name cannot be processed, skipped.")
            return
        endif

        def MakePluginDir(sub: string): string
            const result = this._packPath .. "/pack/" .. pack.name .. "/" .. sub
            silent! mkdir(expand(result), 'p')
            return result
        enddef

        def InstallToLocation(sub: string): void
            const installTo = MakePluginDir("start")
            final allDirs = {}
            if clean
                for d in glob(expand(installTo))
                    allDirs[d] = 1
                endfor
            endif

            for plugin in pack.start
                const pluginDir = this.Private_InstallOne(plugin, installTo, action)
                if pluginDir != null_string && clean
                    remove(allDirs, pluginDir)
                endif
            endfor

            if clean
                for d in keys(allDirs)
                    delete(d, "rf")
                endfor
            endif
        enddef

        if has_key(pack, "start")
            InstallToLocation("start")
        endif

        if has_key(pack, "opt")
            InstallToLocation("opt")
        endif

        silent! helptags ALL
    enddef

    def Private_InstallOne(plugin: any, installTo: string, actionIfExists: number): string
        var url = plugin.url
        if !has_key(plugin, "type") || plugin.type == "github"
            url = "https://github.com/" .. url
        endif

        if !has_key(plugin, "url")
            Error("Plugin without name or url cannot be installed.")
            return null_string
        endif

        const subd = split(plugin.url, "/")
        const installTarget = expand(installTo .. "/" .. subd[-1])

        # If thers is a .git directory,
        # We can try an update, or skip
        if isdirectory(installTarget .. "/.git")
            if actionIfExists == INSTALL_ACTION_SKIP
                return installTarget
            elseif actionIfExists == INSTALL_ACTION_UPDATE
                system("git reset --hard " .. installTarget)
                system("git clean -d --force " .. installTarget)
                system("git pull --rebase " .. installTarget)
            endif
        endif

        mkdir(installTarget, 'p')
        system("git clone --depth=1 " .. url .. " " .. installTarget)
        return installTarget
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
endclass


def Error(...msglist: list<string>): void
    for msg in msglist
        echohl WarningMsg | echomsg '[zy] ' .. msg | echohl None
    endfor
enddef
