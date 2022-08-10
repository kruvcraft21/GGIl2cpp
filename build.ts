import { bundle } from 'luabundle'

const fs = require('fs')

const bundledLua = bundle('./index.lua', {
    metadata: false,
    rootModuleName: "GGIl2cpp",
    isolate : true
})

fs.writeFile("Il2cppApi.lua", bundledLua, (err : any) => {
    if (err) throw err
    console.log("Il2cppApi.lua -> \n" + fs.readFileSync("Il2cppApi.lua"))
})