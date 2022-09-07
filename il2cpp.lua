local Il2cppMemory = require("utils.il2cppmemory")
local VersionEngine = require("utils.version")
local AndroidInfo = require("utils.androidinfo")
local Searcher = require("utils.universalsearcher")

function GetTypeClassName(index)
    return Il2cpp.GlobalMetadataApi:GetClassNameFromIndex(index)
end

function getAlfUtf16()
    local Utf16 = {}
    for s in string.gmatch('АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя', "..") do
        local char = gg.bytes(s,'UTF-16LE')
        Utf16[char[1] + (char[2] * 256)] = s
    end
    for s in string.gmatch("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_/0123456789-'", ".") do
        local char = gg.bytes(s,'UTF-16LE')
        Utf16[char[1] + (char[2] * 256)] = s
    end
    return Utf16
end

function getValidStartAddress(Address)
    local lenAddress = #string.format("%X", Address)
    local checkTable = {['C'] = true, ['4'] = true, ['8']= true, ['0'] = true}
    while not checkTable[string.format("%X", Address):sub(lenAddress)] do
        Address = Address - 1
    end
    return Address
end


---@class Il2cpp
Il2cpp = {
    il2cppStart = 0,
    il2cppEnd = 0,
    globalMetadataStart = 0,
    globalMetadataEnd = 0,
    globalMetadataHeader = 0,
    MainType = AndroidInfo.platform and gg.TYPE_QWORD or gg.TYPE_DWORD,
    pointSize = AndroidInfo.platform and 8 or 4,
    ---@type Il2CppTypeDefinitionApi
    Il2CppTypeDefinitionApi = {},
    MetadataRegistrationApi = require("il2cppstruct.metadataRegistration"),
    TypeApi = require("il2cppstruct.type"),
    MethodsApi = require("il2cppstruct.method"),
    GlobalMetadataApi = require("il2cppstruct.globalmetadata"),
    FieldApi = require("il2cppstruct.field"),
    ClassApi = require("il2cppstruct.class"),
    ObjectApi = require("il2cppstruct.object"),
    ClassInfoApi = require("il2cppstruct.api.classinfo"),
    FieldInfoApi = require("il2cppstruct.api.fieldinfo"),
    
    --- Patch `Bytescodes` to `add`
    ---
    --- Example:
    --- arm64: 
    --- `mov w0,#0x1`
    --- `ret`
    ---
    --- `Il2cpp.PatchesAddress(0x100, "\x20\x00\x80\x52\xc0\x03\x5f\xd6")`
    ---@param add number
    ---@param Bytescodes string
    PatchesAddress = function(add, Bytescodes)
        local patch = {}
        for code in string.gmatch(Bytescodes, '.') do
            patch[#patch + 1] = {
                address = add + #patch,
                value = string.byte(code),
                flags = gg.TYPE_BYTE
            }
        end
        gg.setValues(patch)
    end,


    --- Searches for a method, or rather information on the method, by name or by offset, you can also send an address in memory to it.
    --- 
    --- Return table with information about methods.
    ---@generic TypeForSearch : number | string
    ---@param searchParams TypeForSearch[] @TypeForSearch = number | string
    ---@return table<number, MethodInfo[] | ErrorSearch>
    FindMethods = function(searchParams)
        for i = 1, #searchParams do
            ---@type number | string
            local searchParam = searchParams[i]
            local searchResult = Il2cppMemory:GetInformaionOfMethod(searchParam)
            if not searchResult then
                searchResult = Il2cpp.MethodsApi:Find(searchParam)
                Il2cppMemory:SetInformaionOfMethod(searchParam, searchResult)
            end
            searchParams[i] = searchResult
        end
        return searchParams
    end,


    --- Searches for a class, by name, or by address in memory.
    --- 
    --- Return table with information about class.
    ---@param searchParams ClassConfig[]
    ---@return table<number, ClassInfo[] | ErrorSearch>
    FindClass = function(searchParams)
        for i = 1, #searchParams do
            ---@type ClassConfig
            local searchParam = searchParams[i]
            local searchResult = Il2cppMemory:GetInformationOfClass(searchParam)
            if not searchResult then
                searchResult = Il2cpp.ClassApi:Find(searchParam)
                Il2cppMemory:SetInformaionOfClass(searchParam, searchResult)
            end
            searchParams[i] = searchResult
        end
        return searchParams
    end,


    --- Searches for an object by name or by class address, in memory.
    --- 
    --- In some cases, the function may return an incorrect result for certain classes. For example, sometimes the garbage collector may not have time to remove an object from memory and then a `fake object` will appear or for a turnover, the object may still be `not implemented` or `not created`.
    ---
    --- Returns a table of objects.
    ---@param searchParams table
    ---@return table
    FindObject = function(searchParams)
        for i = 1, #searchParams do
            local searchParam = searchParams[i]
            local classesMemory = Il2cppMemory:GetInfoOfClass(searchParam)
            if classesMemory then
                searchParams[i] = Il2cpp.ObjectApi:Find(classesMemory.SearchResult)
            else
                local classConfig = {
                    Class = searchParam
                }
                local searchResult = Il2cpp.ClassApi:Find(classConfig)
                Il2cppMemory:SetInformaionOfClass(classConfig, searchResult)
                searchParams[i] = Il2cpp.ObjectApi:Find(searchResult)
            end
        end
        return searchParams
    end,


    --- Searches for a field, or rather information about the field, by name or by address in memory.
    --- 
    --- Return table with information about fields.
    ---@generic TypeForSearch : number | string
    ---@param searchParams TypeForSearch[] @TypeForSearch = number | string
    ---@return table<number, FieldInfo[] | ErrorSearch>
    FindFields = function(searchParams)
        for i = 1, #searchParams do
            ---@type number | string
            local searchParam = searchParams[i]
            local searchResult = Il2cppMemory:GetInformaionOfField(searchParam)
            if not searchResult then
                searchResult = Il2cpp.FieldApi:Find(searchParam)
                Il2cppMemory:SetInformaionOfField(searchParam, searchResult)
            end
            searchParams[i] = searchResult
        end
        return searchParams
    end,


    ---@param Address number
    ---@param length? number
    ---@return string
    Utf8ToString = function(Address, length)
        local chars, char = {}, {
            address = Address,
            flags = gg.TYPE_BYTE
        }
        if not length then
            repeat
                _char = gg.getValues({char})[1].value
                chars[#chars + 1] = string.char(_char & 0xFF)
                char.address = char.address + 0x1
            until _char <= 0
            return table.concat(chars, "", 1, #chars - 1)
        else
            for i = 1, length do
                local _char = gg.getValues({char})[1].value
                chars[i] = string.char(_char & 0xFF)
                char.address = char.address + 0x1
            end
            return table.concat(chars)
        end
    end,


    Utf16ToString = function(Address)
        local bytes, strAddress = {}, Il2cpp.FixValue(Address) + (AndroidInfo.platform and 0x10 or 0x8)
        local num = gg.getValues({{
            address = strAddress,
            flags = gg.TYPE_DWORD
        }})[1].value
        if num > 0 and num < 200 then
            for i = 1, num + 1 do
                bytes[#bytes + 1] = {
                    address = strAddress + (i << 1),
                    flags = gg.TYPE_WORD
                }
            end
        end
        return #bytes > 0 and tostring(setmetatable(gg.getValues(bytes), {
            __tostring = function(self)
                local Utf16 = getAlfUtf16()
                for k, v in ipairs(self) do
                    self[k] = v.value == 32 and " " or (Utf16[v.value] or "")
                end
                return table.concat(self)
            end
        })) or ""
    end,


    ---@param bytes string
    ChangeBytesOrder = function(bytes)
        local newBytes, index, lenBytes = {}, 0, #bytes / 2
        for byte in string.gmatch(bytes, "..") do
            newBytes[lenBytes - index] = byte
            index = index + 1
        end
        return table.concat(newBytes)
    end,


    FixValue = function(val)
        return AndroidInfo.platform and val & 0x00FFFFFFFFFFFFFF or val & 0xFFFFFFFF
    end,


    ---@param self Il2cpp
    ---@param address number | string
    SearchPointer = function(self, address)
        address = self.ChangeBytesOrder(type(address) == 'number' and string.format('%X', address) or address)
        gg.searchNumber('h ' .. address)
        gg.refineNumber('h ' .. address:sub(1, 6))
        gg.refineNumber('h ' .. address:sub(1, 2))
        local FindsResult = gg.getResults(gg.getResultsCount())
        gg.clearResults()
        return FindsResult
    end,
}

Il2cpp = setmetatable(Il2cpp, {
    ---@param self Il2cpp
    __call = function(self, libilcpp, globalMetadata, il2cppVersion, globalMetadataHeader, metadataRegistration)

        if libilcpp then
            self.il2cppStart, self.il2cppEnd = libilcpp.start, libilcpp['end']
        else
            self.il2cppStart, self.il2cppEnd = Searcher.FindIl2cpp()
        end

        if globalMetadata then
            self.globalMetadataStart, self.globalMetadataEnd = globalMetadata.start, globalMetadata['end']
        else
            self.globalMetadataStart, self.globalMetadataEnd = Searcher:FindGlobalMetaData()
        end

        self.globalMetadataHeader = globalMetadataHeader or self.globalMetadataStart

        self.MetadataRegistrationApi.metadataRegistration = metadataRegistration

        VersionEngine:ChooseVersion(il2cppVersion)

        Il2cppMemory.Methods = {}
        Il2cppMemory.Classes = {}
        Il2cppMemory.Fields = {}
    end
})

return Il2cpp