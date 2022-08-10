
---@type Il2cppMemory
local Il2cppMemory = require("until.il2cppmemory")

---@type VersionEngine
local VersionEngine = require("until.version")

local AndroidInfo = require("until.androidinfo")

---@class Il2cpp
Il2cpp = {
    il2cppStart = 0,
    il2cppEnd = 0,
    globalMetadataStart = 0,
    globalMetadataEnd = 0,
    globalMetadataHeader = 0,
    MainType = AndroidInfo.platform and gg.TYPE_QWORD or gg.TYPE_DWORD,

    
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


    ---@param Address number
    ---@return string
    Utf8ToString = function(Address)
        local chars, char = {}, {
            address = Address,
            flags = gg.TYPE_BYTE
        }
        repeat
            _char = gg.getValues({char})[1].value
            chars[#chars + 1] = string.char(_char & 0xFF)
            char.address = char.address + 0x1
        until _char <= 0
        return table.concat(chars, "", 1, #chars - 1)
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

---@type Il2CppTypeDefinitionApi
Il2cpp.Il2CppTypeDefinitionApi = {}

Il2cpp.TypeApi = require("il2cppstruct.type")
Il2cpp.MethodsApi = require("il2cppstruct.method")
Il2cpp.GlobalMetadataApi = require("il2cppstruct.globalmetadata")
Il2cpp.FieldApi = require("il2cppstruct.field")
Il2cpp.ClassApi = require("il2cppstruct.class")
Il2cpp.ObjectApi = require("il2cppstruct.object")

Il2cpp = setmetatable(Il2cpp, {
    ---@param self Il2cpp
    __call = function(self, libilcpp, globalMetadata, il2cppVersion, globalMetadataHeader)
        
        local function FindGlobalMetaData()
            local globalMetadata = gg.getRangesList('global-metadata.dat')
            gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA | gg.REGION_OTHER)
            if (#globalMetadata ~= 0) then gg.searchNumber(':EnsureCapacity',gg.TYPE_BYTE,false,gg.SIGN_EQUAL,globalMetadata[1].start,globalMetadata[#globalMetadata]['end']) end
            if (gg.getResultsCount() == 0 or #globalMetadata == 0) then
                globalMetadata = {}
                gg.clearList()
                gg.searchNumber(':EnsureCapacity', gg.TYPE_BYTE)
                gg.refineNumber(':E', gg.TYPE_BYTE)
                    local EnsureCapacity = gg.getResults(gg.getResultsCount())
                    gg.clearResults()
                    for k,v in ipairs(gg.getRangesList()) do
                        if (v.state == 'Ca' or v.state == 'A' or v.state == 'Cd' or v.state == 'Cb' or v.state == 'Ch' or v.state == 'O') then
                            for key, val in ipairs(EnsureCapacity) do
                                globalMetadata[#globalMetadata + 1] = (Il2cpp.FixValue(v.start) <= Il2cpp.FixValue(val.address) and Il2cpp.FixValue(val.address) < Il2cpp.FixValue(v['end'])) 
                                    and v 
                                    or nil
                            end
                        end
                    end
            else gg.clearResults()
            end
            return globalMetadata[1].start, globalMetadata[#globalMetadata]['end']
        end

        local function FindIl2cpp()
            local il2cpp = gg.getRangesList('libil2cpp.so')
            if (#il2cpp == 0) then
                local splitconf = gg.getRangesList('split_config.')
                gg.setRanges(gg.REGION_CODE_APP)
                for k,v in ipairs(splitconf) do
                    if (v.state == 'Xa') then
                        gg.searchNumber(':il2cpp',gg.TYPE_BYTE,false,gg.SIGN_EQUAL,v.start,v['end'])
                        if (gg.getResultsCount() > 0) then
                            il2cpp[#il2cpp + 1] = v
                            gg.clearResults()
                        end
                    end
                end
            end
            return il2cpp[1].start, il2cpp[#il2cpp]['end']
        end

        if libilcpp then
            self.il2cppStart, self.il2cppEnd = libilcpp.start, libilcpp['end']
        else
            self.il2cppStart, self.il2cppEnd = FindIl2cpp()
        end

        if globalMetadata then
            self.globalMetadataStart, self.globalMetadataEnd = globalMetadata.start, globalMetadata['end']
        else
            self.globalMetadataStart, self.globalMetadataEnd = FindGlobalMetaData()
        end

        self.globalMetadataHeader = globalMetadataHeader and globalMetadataHeader or self.globalMetadataStart

        VersionEngine:ChooseVersion(il2cppVersion)

        Il2cppMemory.Methods = {}
        Il2cppMemory.Classes = {}
    end
})

return Il2cpp