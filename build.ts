import { bundle } from 'luabundle'
import fs from 'fs'
import path from "path"

const bundledLua = bundle('./index.lua', {
    metadata: false,
    rootModuleName: "GGIl2cpp"
})

const buildPath = path.normalize("build/Il2cppApi.lua")

fs.writeFile(buildPath, bundledLua, (err : any) => {
    if (err) throw err
    console.log("Il2cppApi.lua -> ОК\n")
})