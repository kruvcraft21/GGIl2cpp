local platform, sdk = gg.getTargetInfo().x64, gg.getTargetInfo().targetSdkVersion

---@class ClassInfoRaw
---@field ClassName string | nil
---@field ClassInfoAddress number

---@class ClassInfo
---@field ClassName string
---@field ClassAddress string
---@field Methods MethodInfo[] | nil
---@field Fields FieldInfo[] | nil
---@field Parent table | nil
---@field ClassNameSpace string
---@field StaticFieldData number | nil
---@field IsEnum boolean
---@field TypeMetadataHandle number
---@field GetFieldWithName fun(self : ClassInfo, name : string) : FieldInfo | nil @Get FieldInfo by Field Name. If Fields weren't dumped, then this function return `nil`. Also, if Field isn't found by name, then function will return `nil`
---@field GetMethodsWithName fun(self : ClassInfo, name : string) : MethodInfo[] | nil @Get MethodInfo[] by MethodName. If Methods weren't dumped, then this function return `nil`. Also, if Method isn't found by name, then function will return `table with zero size`

---@class ParentClassInfo
---@field ClassName string
---@field ClassAddress string

---@class FieldInfoRaw
---@field FieldInfoAddress number
---@field ClassName string | nil

---@class FieldApi
---@field Offset number
---@field Type number
---@field ClassOffset number

---@class TypeApi
---@field Type number

---@class GlobalMetadataApi
---@field typeDefinitionsSize number
---@field typeDefinitionsOffset number
---@field stringOffset number
---@field fieldDefaultValuesOffset number
---@field fieldDefaultValuesSize number
---@field fieldAndParameterDefaultValueDataOffset number
---@field version number

---@class ClassApi
---@field NameOffset number
---@field MethodsStep number
---@field CountMethods number
---@field MethodsLink number
---@field FieldsLink number
---@field FieldsStep number
---@field CountFields number
---@field ParentOffset number
---@field NameSpaceOffset number
---@field StaticFieldDataOffset number
---@field EnumType number
---@field EnumRsh number
---@field TypeMetadataHandle number

---@class ClassesMemory
---@field Config ClassConfig
---@field SearchResult ClassInfo[]

---@class MethodsApi
---@field ClassOffset number
---@field NameOffset number
---@field ParamCount number
---@field ReturnType number

---@class FieldInfo
---@field ClassName string 
---@field ClassAddress string 
---@field FieldName string
---@field Offset string
---@field IsStatic boolean
---@field Type string

---@class MethodInfoRaw
---@field MethodName string | nil
---@field Offset number | nil
---@field MethodInfoAddress number
---@field ClassName string | nil
---@field MethodAddress number

---@class ErrorSearch
---@field Error string

---@class MethodInfo : MethodInfoRaw
---@field MethodName string
---@field Offset string
---@field AddressInMemory string
---@field MethodInfoAddress number
---@field ClassName string
---@field ClassAddress string
---@field ParamCount number
---@field ReturnType string

---@class Il2cppApi
---@field FieldApiOffset number
---@field FieldApiType number
---@field FieldApiClassOffset number
---@field ClassApiNameOffset number
---@field ClassApiMethodsStep number
---@field ClassApiCountMethods number
---@field ClassApiMethodsLink number
---@field ClassApiFieldsLink number
---@field ClassApiFieldsStep number
---@field ClassApiCountFields number
---@field ClassApiParentOffset number
---@field ClassApiNameSpaceOffset number
---@field ClassApiStaticFieldDataOffset number
---@field ClassApiEnumType number
---@field ClassApiEnumRsh number
---@field ClassApiTypeMetadataHandle number
---@field MethodsApiClassOffset number
---@field MethodsApiNameOffset number
---@field MethodsApiParamCount number
---@field MethodsApiReturnType number
---@field typeDefinitionsSize number
---@field typeDefinitionsOffset number
---@field stringOffset number
---@field fieldDefaultValuesOffset number
---@field fieldDefaultValuesSize number
---@field fieldAndParameterDefaultValueDataOffset number
---@field TypeApiType number
---@field Il2CppTypeDefinitionApifieldStart number

---@class ClassConfig
---@field Class number | string @Class Name or Address Class
---@field FieldsDump boolean
---@field MethodsDump boolean

---@class Il2CppTypeDefinitionApi
---@field fieldStart number

Protect = {
    ErrorHandler = function(err)
        return {Error = err}
    end,
    Call = function(self, fun, ...) 
        return ({xpcall(fun, self.ErrorHandler, ...)})[2]
    end
}

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

--- Is a function that was created to patch the desired address. The first argument should be an offset, and the subsequent ones should be constructs.
---@param StartAddress number
function addresspath(StartAddress, ...)
    local params, patch = {...}, {}
    for i = 1,#params do
        StartAddress = i ~= 1 and StartAddress + 0x4 or StartAddress
        patch[#patch + 1] = {address = StartAddress, flags = gg.TYPE_DWORD, value = params[i]:gsub('.', function (c) return string.format('%02X', string.byte(c)) end)..'r'}
    end
    gg.setValues(patch)
end

function GetTypeClassName(index)
    return Il2cpp.GlobalMetadataApi:GetClassNameFromIndex(index)
end

---@class VersionEngine
VersionEngine = {
    Year = {
        [2017] = function(p2, p3)
            return 24
        end,
        [2018] = function(p2, p3)
            return tonumber(p2) >= 3 and 24.1 or 24
        end,
        [2019] = function(p2, p3)
            p2, p3 = tonumber(p2), tonumber(p3)
            local version = 24.2
            if p2 == 3 then
                if p3 >= 7 then
                    version = 24.3
                end
            end

            if p2 > 3 then
                version = 24.3
            end

            if p2 == 4 then
                if p3 >= 15 then
                    version = 24.4
                end
                if p3 >= 21 then
                    version = 24.5
                end
            end
            return version
        end,
        [2020] = function(p2, p3)
            p2, p3 = tonumber(p2), tonumber(p3)
            local version = 24.3
            if p2 == 1 and p3 >= 11 then
                version = 24.4
            end

            if p2 == 2 then
                version = 27
            end

            if p2 > 2 or (p2 == 2 and p3 >= 4) then
                version = 27.1
            end
            return version
        end,
        [2021] = function(p2, p3)
            return tonumber(p2) >= 2 and 29 or 27.2
        end,
        [2022] = function(p2, p3)
            return 29
        end,
    },
    ---@return string @year
    ---@return string 
    ---@return string
    GetUnityVersion = function()
        gg.setRanges(gg.REGION_CODE_APP)
        gg.clearResults()
        gg.searchNumber("32h;30h;0~~0;0~~0;2Eh;0~~0;2Eh;66h::11", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, nil, nil, 16)
        local versionTable = gg.getResults(1)
        gg.clearResults()
        local verisonName = Il2cpp.Utf8ToString(versionTable[1].address)
        local i, j = string.find(verisonName, ".+f")
        if j then verisonName = string.sub(verisonName, i,j - 1) end
        return string.gmatch(verisonName, "([^%.]+)%.([^%.]+)%.([^%.]+)")()
    end,
    ---@param self VersionEngine
    ---@param version? number
    ChooseVersion = function(self, version)
        if not version then
            local p1, p2, p3 = self.GetUnityVersion()
            ---@type number | fun(p2 : string, p3: string):number
            version = self.Year[tonumber(p1)] or 29
            if type(version) == 'function' then
                version = version(p2, p3)
            end
        end
        local api = Il2cppApi[version] 
        if (api) then
            Il2cpp.FieldApi.Offset = api.FieldApiOffset
            Il2cpp.FieldApi.Type = api.FieldApiType
            Il2cpp.FieldApi.ClassOffset = api.FieldApiClassOffset

            Il2cpp.ClassApi.NameOffset = api.ClassApiNameOffset
            Il2cpp.ClassApi.MethodsStep = api.ClassApiMethodsStep
            Il2cpp.ClassApi.CountMethods = api.ClassApiCountMethods
            Il2cpp.ClassApi.MethodsLink = api.ClassApiMethodsLink
            Il2cpp.ClassApi.FieldsLink = api.ClassApiFieldsLink
            Il2cpp.ClassApi.FieldsStep = api.ClassApiFieldsStep
            Il2cpp.ClassApi.CountFields = api.ClassApiCountFields
            Il2cpp.ClassApi.ParentOffset = api.ClassApiParentOffset
            Il2cpp.ClassApi.NameSpaceOffset = api.ClassApiNameSpaceOffset
            Il2cpp.ClassApi.StaticFieldDataOffset = api.ClassApiStaticFieldDataOffset
            Il2cpp.ClassApi.EnumType = api.ClassApiEnumType
            Il2cpp.ClassApi.EnumRsh = api.ClassApiEnumRsh
            Il2cpp.ClassApi.TypeMetadataHandle = api.ClassApiTypeMetadataHandle

            Il2cpp.MethodsApi.ClassOffset = api.MethodsApiClassOffset
            Il2cpp.MethodsApi.NameOffset = api.MethodsApiNameOffset
            Il2cpp.MethodsApi.ParamCount = api.MethodsApiParamCount
            Il2cpp.MethodsApi.ReturnType = api.MethodsApiReturnType

            Il2cpp.GlobalMetadataApi.typeDefinitionsSize = api.typeDefinitionsSize
            Il2cpp.GlobalMetadataApi.version = version

            local consts = gg.getValues({
                { -- [1] 
                    address = Il2cpp.globalMetadataHeader + api.typeDefinitionsOffset,
                    flags = gg.TYPE_DWORD
                },
                { -- [2]
                    address = Il2cpp.globalMetadataHeader + api.stringOffset,
                    flags = gg.TYPE_DWORD,
                },
                { -- [3]
                    address = Il2cpp.globalMetadataHeader + api.fieldDefaultValuesOffset,
                    flags = gg.TYPE_DWORD,
                },
                { -- [4]
                    address = Il2cpp.globalMetadataHeader + api.fieldDefaultValuesSize,
                    flags = gg.TYPE_DWORD
                },
                { -- [5]
                    address = Il2cpp.globalMetadataHeader + api.fieldAndParameterDefaultValueDataOffset,
                    flags = gg.TYPE_DWORD
                }
            })
            Il2cpp.GlobalMetadataApi.typeDefinitionsOffset = consts[1].value
            Il2cpp.GlobalMetadataApi.stringOffset = consts[2].value
            Il2cpp.GlobalMetadataApi.fieldDefaultValuesOffset = consts[3].value
            Il2cpp.GlobalMetadataApi.fieldDefaultValuesSize = consts[4].value
            Il2cpp.GlobalMetadataApi.fieldAndParameterDefaultValueDataOffset = consts[5].value

            Il2cpp.TypeApi.Type = api.TypeApiType

            Il2cpp.Il2CppTypeDefinitionApi.fieldStart = api.Il2CppTypeDefinitionApifieldStart
        else
            error('Not support this il2cpp version')
        end 
    end,
}

---@type table<number, Il2cppApi>
Il2cppApi = {
    [24.1] = {
        FieldApiOffset = platform and 0x18 or 0xC,
        FieldApiType = platform and 0x8 or 0x4,
        FieldApiClassOffset = platform and 0x10 or 0x8,
        ClassApiNameOffset = platform and 0x10 or 0x8,
        ClassApiMethodsStep = platform and 3 or 2,
        ClassApiCountMethods = platform and 0x110 or 0xA8,
        ClassApiMethodsLink = platform and 0x98 or 0x4C,
        ClassApiFieldsLink = platform and 0x80 or 0x40,
        ClassApiFieldsStep = platform and 0x20 or 0x14,
        ClassApiCountFields = platform and 0x114 or 0xAC,
        ClassApiParentOffset = platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = platform and 0xB8 or 0x5C,
        ClassApiEnumType = platform and 0x126 or 0xBE,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = platform and 0x68 or 0x34,
        MethodsApiClassOffset = platform and 0x18 or 0xC,
        MethodsApiNameOffset = platform and 0x10 or 0x8,
        MethodsApiParamCount = platform and 0x4A or 0x2A,
        MethodsApiReturnType = platform and 0x20 or 0x10,
        typeDefinitionsSize = 100,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x2C,
    },
    [24] = {
        FieldApiOffset = platform and 0x18 or 0xC,
        FieldApiType = platform and 0x8 or 0x4,
        FieldApiClassOffset = platform and 0x10 or 0x8,
        ClassApiNameOffset = platform and 0x10 or 0x8,
        ClassApiMethodsStep = platform and 3 or 2,
        ClassApiCountMethods = platform and 0x114 or 0xAC,
        ClassApiMethodsLink = platform and 0x98 or 0x4C,
        ClassApiFieldsLink = platform and 0x80 or 0x40,
        ClassApiFieldsStep = platform and 0x28 or 0x18,
        ClassApiCountFields = platform and 0x118 or 0xB0,
        ClassApiParentOffset = platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = platform and 0xB8 or 0x5C,
        ClassApiEnumType = platform and 0x129 or 0xC1,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = platform and 0x68 or 0x34,
        MethodsApiClassOffset = platform and 0x18 or 0xC,
        MethodsApiNameOffset = platform and 0x10 or 0x8,
        MethodsApiParamCount = platform and 0x4E or 0x2E,
        MethodsApiReturnType = platform and 0x20 or 0x10,
        typeDefinitionsSize = 104,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x30,
    },
    [24.2] = {
        FieldApiOffset = platform and 0x18 or 0xC,
        FieldApiType = platform and 0x8 or 0x4,
        FieldApiClassOffset = platform and 0x10 or 0x8,
        ClassApiNameOffset = platform and 0x10 or 0x8,
        ClassApiMethodsStep = platform and 3 or 2,
        ClassApiCountMethods = platform and 0x118 or 0xA4,
        ClassApiMethodsLink = platform and 0x98 or 0x4C,
        ClassApiFieldsLink = platform and 0x80 or 0x40,
        ClassApiFieldsStep = platform and 0x20 or 0x14,
        ClassApiCountFields = platform and 0x11c or 0xA8,
        ClassApiParentOffset = platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = platform and 0xB8 or 0x5C,
        ClassApiEnumType = platform and 0x12e or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = platform and 0x68 or 0x34,
        MethodsApiClassOffset = platform and 0x18 or 0xC,
        MethodsApiNameOffset = platform and 0x10 or 0x8,
        MethodsApiParamCount = platform and 0x4A or 0x2A,
        MethodsApiReturnType = platform and 0x20 or 0x10,
        typeDefinitionsSize = 92,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x24,
    },
    [24.3] = {
        FieldApiOffset = platform and 0x18 or 0xC,
        FieldApiType = platform and 0x8 or 0x4,
        FieldApiClassOffset = platform and 0x10 or 0x8,
        ClassApiNameOffset = platform and 0x10 or 0x8,
        ClassApiMethodsStep = platform and 3 or 2,
        ClassApiCountMethods = platform and 0x118 or 0xA4,
        ClassApiMethodsLink = platform and 0x98 or 0x4C,
        ClassApiFieldsLink = platform and 0x80 or 0x40,
        ClassApiFieldsStep = platform and 0x20 or 0x14,
        ClassApiCountFields = platform and 0x11c or 0xA8,
        ClassApiParentOffset = platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = platform and 0xB8 or 0x5C,
        ClassApiEnumType = platform and 0x12e or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = platform and 0x68 or 0x34,
        MethodsApiClassOffset = platform and 0x18 or 0xC,
        MethodsApiNameOffset = platform and 0x10 or 0x8,
        MethodsApiParamCount = platform and 0x4A or 0x2A,
        MethodsApiReturnType = platform and 0x20 or 0x10,
        typeDefinitionsSize = 92,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x24,
    },
    [24.4] = {
        FieldApiOffset = platform and 0x18 or 0xC,
        FieldApiType = platform and 0x8 or 0x4,
        FieldApiClassOffset = platform and 0x10 or 0x8,
        ClassApiNameOffset = platform and 0x10 or 0x8,
        ClassApiMethodsStep = platform and 3 or 2,
        ClassApiCountMethods = platform and 0x118 or 0xA4,
        ClassApiMethodsLink = platform and 0x98 or 0x4C,
        ClassApiFieldsLink = platform and 0x80 or 0x40,
        ClassApiFieldsStep = platform and 0x20 or 0x14,
        ClassApiCountFields = platform and 0x11c or 0xA8,
        ClassApiParentOffset = platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = platform and 0xB8 or 0x5C,
        ClassApiEnumType = platform and 0x12e or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = platform and 0x68 or 0x34,
        MethodsApiClassOffset = platform and 0x18 or 0xC,
        MethodsApiNameOffset = platform and 0x10 or 0x8,
        MethodsApiParamCount = platform and 0x4A or 0x2A,
        MethodsApiReturnType = platform and 0x20 or 0x10,
        typeDefinitionsSize = 92,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x24,
    },
    [24.5] = {
        FieldApiOffset = platform and 0x18 or 0xC,
        FieldApiType = platform and 0x8 or 0x4,
        FieldApiClassOffset = platform and 0x10 or 0x8,
        ClassApiNameOffset = platform and 0x10 or 0x8,
        ClassApiMethodsStep = platform and 3 or 2,
        ClassApiCountMethods = platform and 0x118 or 0xA4,
        ClassApiMethodsLink = platform and 0x98 or 0x4C,
        ClassApiFieldsLink = platform and 0x80 or 0x40,
        ClassApiFieldsStep = platform and 0x20 or 0x14,
        ClassApiCountFields = platform and 0x11c or 0xA8,
        ClassApiParentOffset = platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = platform and 0xB8 or 0x5C,
        ClassApiEnumType = platform and 0x12e or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = platform and 0x68 or 0x34,
        MethodsApiClassOffset = platform and 0x18 or 0xC,
        MethodsApiNameOffset = platform and 0x10 or 0x8,
        MethodsApiParamCount = platform and 0x4A or 0x2A,
        MethodsApiReturnType = platform and 0x20 or 0x10,
        typeDefinitionsSize = 92,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x24,
    },
    [27] = {
        FieldApiOffset = platform and 0x18 or 0xC,
        FieldApiType = platform and 0x8 or 0x4,
        FieldApiClassOffset = platform and 0x10 or 0x8,
        ClassApiNameOffset = platform and 0x10 or 0x8,
        ClassApiMethodsStep = platform and 3 or 2,
        ClassApiCountMethods = platform and 0x11C or 0xA4,
        ClassApiMethodsLink = platform and 0x98 or 0x4C,
        ClassApiFieldsLink = platform and 0x80 or 0x40,
        ClassApiFieldsStep = platform and 0x20 or 0x14,
        ClassApiCountFields = platform and 0x120 or 0xA8,
        ClassApiParentOffset = platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = platform and 0xB8 or 0x5C,
        ClassApiEnumType = platform and 0x132 or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = platform and 0x68 or 0x34,
        MethodsApiClassOffset = platform and 0x18 or 0xC,
        MethodsApiNameOffset = platform and 0x10 or 0x8,
        MethodsApiParamCount = platform and 0x4A or 0x2A,
        MethodsApiReturnType = platform and 0x20 or 0x10,
        typeDefinitionsSize = 88,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x20,
    },
    [27.1] = {
        FieldApiOffset = platform and 0x18 or 0xC,
        FieldApiType = platform and 0x8 or 0x4,
        FieldApiClassOffset = platform and 0x10 or 0x8,
        ClassApiNameOffset = platform and 0x10 or 0x8,
        ClassApiMethodsStep = platform and 3 or 2,
        ClassApiCountMethods = platform and 0x11C or 0xA4,
        ClassApiMethodsLink = platform and 0x98 or 0x4C,
        ClassApiFieldsLink = platform and 0x80 or 0x40,
        ClassApiFieldsStep = platform and 0x20 or 0x14,
        ClassApiCountFields = platform and 0x120 or 0xA8,
        ClassApiParentOffset = platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = platform and 0xB8 or 0x5C,
        ClassApiEnumType = platform and 0x132 or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = platform and 0x68 or 0x34,
        MethodsApiClassOffset = platform and 0x18 or 0xC,
        MethodsApiNameOffset = platform and 0x10 or 0x8,
        MethodsApiParamCount = platform and 0x4A or 0x2A,
        MethodsApiReturnType = platform and 0x20 or 0x10,
        typeDefinitionsSize = 88,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x20,
    },
    [27.2] = {
        FieldApiOffset = platform and 0x18 or 0xC,
        FieldApiType = platform and 0x8 or 0x4,
        FieldApiClassOffset = platform and 0x10 or 0x8,
        ClassApiNameOffset = platform and 0x10 or 0x8,
        ClassApiMethodsStep = platform and 3 or 2,
        ClassApiCountMethods = platform and 0x11C or 0xA4,
        ClassApiMethodsLink = platform and 0x98 or 0x4C,
        ClassApiFieldsLink = platform and 0x80 or 0x40,
        ClassApiFieldsStep = platform and 0x20 or 0x14,
        ClassApiCountFields = platform and 0x120 or 0xA8,
        ClassApiParentOffset = platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = platform and 0xB8 or 0x5C,
        ClassApiEnumType = platform and 0x132 or 0xBA,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = platform and 0x68 or 0x34,
        MethodsApiClassOffset = platform and 0x18 or 0xC,
        MethodsApiNameOffset = platform and 0x10 or 0x8,
        MethodsApiParamCount = platform and 0x4A or 0x2A,
        MethodsApiReturnType = platform and 0x20 or 0x10,
        typeDefinitionsSize = 88,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x20,
    },
    [29] = {
        FieldApiOffset = platform and 0x18 or 0xC,
        FieldApiType = platform and 0x8 or 0x4,
        FieldApiClassOffset = platform and 0x10 or 0x8,
        ClassApiNameOffset = platform and 0x10 or 0x8,
        ClassApiMethodsStep = platform and 3 or 2,
        ClassApiCountMethods = platform and 0x11C or 0xA4,
        ClassApiMethodsLink = platform and 0x98 or 0x4C,
        ClassApiFieldsLink = platform and 0x80 or 0x40,
        ClassApiFieldsStep = platform and 0x20 or 0x14,
        ClassApiCountFields = platform and 0x120 or 0xA8,
        ClassApiParentOffset = platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = platform and 0xB8 or 0x5C,
        ClassApiEnumType = platform and 0x132 or 0xBA,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = platform and 0x68 or 0x34,
        MethodsApiClassOffset = platform and 0x20 or 0x10,
        MethodsApiNameOffset = platform and 0x18 or 0xC,
        MethodsApiParamCount = platform and 0x52 or 0x2E,
        MethodsApiReturnType = platform and 0x28 or 0x14,
        typeDefinitionsSize = 88,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x20,
    }
}

-- Memorizing Il2cpp Search Result
---@class Il2cppMemory
Il2cppMemory = {
    Methods = {},
    Classes = {},
    ---@param self Il2cppMemory
    ---@param searchParam number | string
    ---@return MethodInfo[] | nil | ErrorSearch
    GetInformaionOfMethod = function (self, searchParam)
        return self.Methods[searchParam]
    end,
    ---@param self Il2cppMemory
    ---@param searchParam string | number
    ---@param searchResult MethodInfo[] | ErrorSearch
    SetInformaionOfMethod = function(self, searchParam, searchResult)
        self.Methods[searchParam] = searchResult
    end,
    ---@param self Il2cppMemory
    ---@param searchParam number | string
    ---@return ClassesMemory | nil
    GetInfoOfClass = function (self, searchParam)
        return self.Classes[searchParam]
    end,
    ---@param self Il2cppMemory
    ---@param searchParam ClassConfig
    ---@return ClassInfo[] | nil | ErrorSearch
    GetInformationOfClass = function(self, searchParam)
        ---@type ClassesMemory | nil
        local ClassMemory = self:GetInfoOfClass(searchParam.Class)
        if not(ClassMemory and (ClassMemory.Config.FieldsDump == searchParam.FieldsDump and ClassMemory.Config.MethodsDump == searchParam.MethodsDump)) then
            return nil
        end
        return ClassMemory.SearchResult
    end,
    ---@param self Il2cppMemory
    ---@param searchParam ClassConfig
    ---@param searchResult ClassInfo[] | ErrorSearch
    SetInformaionOfClass = function(self, searchParam, searchResult)
        self.Classes[searchParam.Class] = {
            Config = {
                FieldsDump = searchParam.FieldsDump and true or false,
                MethodsDump = searchParam.MethodsDump and true or false
            },
            SearchResult = searchResult
        }
    end,
}

---@class Il2cpp
Il2cpp = {
    il2cppStart = 0,
    il2cppEnd = 0,
    globalMetadataStart = 0,
    globalMetadataEnd = 0,
    globalMetadataHeader = 0,
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
                local classConfig = {Class = searchParam}
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
        local chars, char = {}, {address = Address, flags = gg.TYPE_BYTE}
        repeat
            _char = gg.getValues({char})[1].value
            chars[#chars + 1] = string.char(_char & 0xFF)
            char.address = char.address + 0x1
        until _char <= 0
        return table.concat(chars, "", 1, #chars - 1)
    end,
    Utf16ToString = function(Address)
        local bytes, strAddress = {}, Il2cpp.FixValue(Address) + (platform and 0x10 or 0x8)
        local num = gg.getValues({{address = strAddress,flags = gg.TYPE_DWORD}})[1].value
        if num > 0 and num < 200 then
            for i = 1, num + 1 do
                bytes[#bytes + 1] = {address = strAddress + (i << 1), flags = gg.TYPE_WORD}
            end
        end
        return #bytes > 0 and tostring(setmetatable(gg.getValues(bytes), {
            __tostring = function(self)
                local Utf16 = getAlfUtf16()
                for k,v in ipairs(self) do
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
        return platform and val & 0x00FFFFFFFFFFFFFF or val & 0xFFFFFFFF
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
    MainType = platform and gg.TYPE_QWORD or gg.TYPE_DWORD,
    ---@type Il2CppTypeDefinitionApi
    Il2CppTypeDefinitionApi = {},
    ---@type GlobalMetadataApi
    GlobalMetadataApi = {
        ---@param self GlobalMetadataApi
        ---@param index number
        GetStringFromIndex = function(self, index)
            local stringDefinitions = Il2cpp.globalMetadataStart + self.stringOffset
            return Il2cpp.Utf8ToString(stringDefinitions + index)
        end,
        ---@param self GlobalMetadataApi
        GetClassNameFromIndex = function(self, index)
            if (self.version < 27) then
                local typeDefinitions = Il2cpp.globalMetadataStart + self.typeDefinitionsOffset
                index = (self.typeDefinitionsSize * index) + typeDefinitions
            else
                index = Il2cpp.FixValue(index)
            end
            local typeDefinition = gg.getValues({{address = index, flags = gg.TYPE_DWORD}})[1].value
            return self:GetStringFromIndex(typeDefinition)
        end,
        ---@param self GlobalMetadataApi
        ---@param dataIndex number
        GetFieldOrParameterDefalutValue = function(self, dataIndex)
            return gg.getValues({{address = self.fieldAndParameterDefaultValueDataOffset + Il2cpp.globalMetadataStart + dataIndex, flags = gg.TYPE_WORD}})[1].value
        end,
        ---@param self GlobalMetadataApi
        ---@param index string
        GetIl2CppFieldDefaultValue = function(self, index)
            gg.clearResults()
            gg.setRanges(0)
            gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_HEAP | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA | gg.REGION_OTHER | gg.REGION_C_ALLOC)
            gg.searchNumber(
                tostring(index), 
                gg.TYPE_DWORD, 
                false, 
                gg.SIGN_EQUAL, 
                Il2cpp.globalMetadataStart + self.fieldDefaultValuesOffset, 
                Il2cpp.globalMetadataStart + self.fieldDefaultValuesOffset + self.fieldDefaultValuesSize
            )
            if gg.getResultsCount() > 0 then
                local Il2CppFieldDefaultValue = gg.getResults(1)
                gg.clearResults()
                return Il2CppFieldDefaultValue
            end
            return {}
        end,
        ---@param self GlobalMetadataApi
        ---@param index number
        ---@return any | nil
        GetDefaultFieldValue = function(self, index)
            local Il2CppFieldDefaultValue = self:GetIl2CppFieldDefaultValue(tostring(index))
            if #Il2CppFieldDefaultValue > 0 then
                local dataIndex = gg.getValues({{address = Il2CppFieldDefaultValue[1].address + 8, flags = gg.TYPE_DWORD}})[1].value
                return self:GetFieldOrParameterDefalutValue(dataIndex)
            end
            return nil
        end
    },
    ---@type TypeApi
    TypeApi = {
        tableTypes = {
            [1] = "void",
            [2] = "bool",
            [3] = "char",
            [4] = "sbyte",
            [5] = "byte",
            [6] = "short",
            [7] = "ushort",
            [8] = "int",
            [9] = "uint",
            [10] = "long",
            [11] = "ulong",
            [12] = "float",
            [13] = "double",
            [14] = "string",
            [22] = "TypedReference",
            [24] = "IntPtr",
            [25] = "UIntPtr",
            [28] = "object",
            [17] = GetTypeClassName,
            [18] = GetTypeClassName,
            [29] = function(index)
                local typeMassiv = gg.getValues({
                    {
                        address = Il2cpp.FixValue(index),
                        flags = Il2cpp.MainType
                    },
                    {
                        address = Il2cpp.FixValue(index) + Il2cpp.TypeApi.Type,
                        flags = gg.TYPE_BYTE
                    }
                })
                return Il2cpp.TypeApi:GetTypeName(typeMassiv[2].value, typeMassiv[1].value) .. "[]"
            end,
            [21] = function(index)
                if not (Il2cpp.GlobalMetadataApi.version <= 27) then
                    index = gg.getValues({{address = Il2cpp.FixValue(index), flags = Il2cpp.MainType}})[1].value
                end
                index = gg.getValues({{address = Il2cpp.FixValue(index), flags = Il2cpp.MainType}})[1].value
                return Il2cpp.GlobalMetadataApi:GetClassNameFromIndex(index)
            end
        },
        ---@param self TypeApi
        ---@param typeIndex number @number for tableTypes
        ---@param index number @for an api that is higher than 24, this can be a reference to the index
        ---@return string
        GetTypeName = function(self, typeIndex, index)
            ---@type string | fun(index : number) : string
            local typeName = self.tableTypes[typeIndex] or "not support type -> 0x" .. string.format('%X', typeIndex)
            if (type(typeName) == 'function') then
                typeName = typeName(index)
            end
            return typeName
        end
    },
    ---@type FieldApi
    FieldApi = {
        ---@param self FieldApi
        ---@param FieldInfoAddress number
        UnpackFieldInfo = function(self, FieldInfoAddress)
            return {
                { -- Field Name
                    address = FieldInfoAddress,
                    flags = Il2cpp.MainType
                },
                { -- Offset Field
                    address = FieldInfoAddress + self.Offset,
                    flags = gg.TYPE_WORD
                },
                { -- Field type
                    address = FieldInfoAddress + self.Type,
                    flags = Il2cpp.MainType
                },
                { -- Class address
                    address = FieldInfoAddress + self.ClassOffset,
                    flags = Il2cpp.MainType
                }
            }
        end,
        ---@param self FieldApi
        DecodeFieldsInfo = function(self, FieldsInfo, ClassCharacteristic)
            local fieldStart, index, _FieldsInfo = nil, 0, {}
            if ClassCharacteristic.IsEnum then
                fieldStart = gg.getValues({{address = ClassCharacteristic.TypeMetadataHandle + Il2cpp.Il2CppTypeDefinitionApi.fieldStart, flags = gg.TYPE_DWORD}})[1].value
            end
            for i = 1, #FieldsInfo, 4 do
                index = index + 1
                local TypeInfo = Il2cpp.FixValue(FieldsInfo[i + 2].value)
                local _TypeInfo = gg.getValues({
                    {
                        address = TypeInfo + self.Type,
                        flags = gg.TYPE_WORD
                    },
                    { -- type index
                        address = TypeInfo + Il2cpp.TypeApi.Type,
                        flags = gg.TYPE_BYTE
                    },
                    { -- index
                        address = TypeInfo,
                        flags = Il2cpp.MainType
                    }
                })
                local DefaultValue = nil
                if ClassCharacteristic.IsEnum and FieldsInfo[i + 1].value == 0 then
                    DefaultValue = Il2cpp.GlobalMetadataApi:GetDefaultFieldValue(index + fieldStart - 1)
                end
                _FieldsInfo[index] = {
                    ClassName = ClassCharacteristic.ClassName or Il2cpp.ClassApi:GetClassName(FieldsInfo[i + 3].value),
                    ClassAddress = string.format('%X', Il2cpp.FixValue(FieldsInfo[i + 3].value)),
                    FieldName = Il2cpp.Utf8ToString(Il2cpp.FixValue(FieldsInfo[i].value)),
                    Offset = string.format('%X', FieldsInfo[i + 1].value),
                    IsStatic = (_TypeInfo[1].value & 0x10) ~= 0,
                    Type = Il2cpp.TypeApi:GetTypeName(_TypeInfo[2].value, _TypeInfo[3].value),
                    DefaultValue = DefaultValue
                }
            end
            return _FieldsInfo
        end
    },
    ClassInfoApi = {
        ---Get FieldInfo by Field Name. If Field isn't found by name, then function will return `nil`
        ---@param self ClassInfo
        ---@param name string
        ---@return FieldInfo | nil
        GetFieldWithName = function(self, name) 
            local FieldsInfo = self.Fields
            if FieldsInfo then
                for fieldIndex = 1, #FieldsInfo do
                    if FieldsInfo[fieldIndex].FieldName == name then
                        return FieldsInfo[fieldIndex]
                    end
                end
            else
                local ClassAddress = tonumber(self.ClassAddress, 16)
                local _ClassInfo = gg.getValues({
                    { -- Link as Fields
                        address = ClassAddress + Il2cpp.ClassApi.FieldsLink,
                        flags = Il2cpp.MainType
                    },
                    { -- Fields Count
                        address = ClassAddress + Il2cpp.ClassApi.CountFields,
                        flags = gg.TYPE_WORD
                    }
                })
                self.Fields = Il2cpp.ClassApi:GetClassFields(Il2cpp.FixValue(_ClassInfo[1].value), _ClassInfo[2].value, {ClassName = self.ClassName, IsEnum = self.IsEnum, TypeMetadataHandle = self.TypeMetadataHandle})
                return self:GetFieldWithName(name)
            end
            return nil
        end,
        ---Get MethodInfo[] by MethodName. If Method isn't found by name, then function will return `table with zero size`
        ---@param self ClassInfo
        ---@param name string
        ---@return MethodInfo[]
        GetMethodsWithName = function(self, name)
            local MethodsInfo, MethodsInfoResult = self.Methods, {}
            if MethodsInfo then
                for methodIndex = 1, #MethodsInfo do
                    if MethodsInfo[methodIndex].MethodName == name then
                        MethodsInfoResult[#MethodsInfoResult + 1] = MethodsInfo[methodIndex]
                    end
                end
                return MethodsInfoResult
            else
                local ClassAddress = tonumber(self.ClassAddress, 16)
                local _ClassInfo = gg.getValues({
                    { -- Link as Methods
                        address = ClassAddress + Il2cpp.ClassApi.MethodsLink,
                        flags = Il2cpp.MainType,
                    },
                    { -- Methods Count
                        address = ClassAddress + Il2cpp.ClassApi.CountMethods,
                        flags = gg.TYPE_WORD
                    }
                })
                self.Methods = Il2cpp.ClassApi:GetClassMethods(Il2cpp.FixValue(_ClassInfo[1].value), _ClassInfo[2].value, self.ClassName)
                return self:GetMethodsWithName(name)
            end
        end,
    },
    ---@type ClassApi
    ClassApi = {
        ---@param self ClassApi
        ---@param ClassAddress number
        GetClassName = function(self, ClassAddress)
            return Il2cpp.Utf8ToString(Il2cpp.FixValue(gg.getValues({{address = Il2cpp.FixValue(ClassAddress) + self.NameOffset,flags = Il2cpp.MainType}})[1].value))
        end,
        ---@param self ClassApi
        ---@param MethodsLink number
        ---@param Count number
        ---@param ClassName string | nil
        GetClassMethods = function (self, MethodsLink, Count, ClassName)
            local MethodsInfo, _MethodsInfo = {}, {}
            for i = 0, Count - 1 do
                _MethodsInfo[#_MethodsInfo + 1] = {
                    address = MethodsLink + (i << self.MethodsStep),
                    flags = Il2cpp.MainType
                }
            end
            _MethodsInfo = gg.getValues(_MethodsInfo)
            for i = 1, #_MethodsInfo do
                local MethodInfo
                MethodInfo, _MethodsInfo[i] = Il2cpp.MethodsApi:UnpackMethodInfo({MethodInfoAddress = Il2cpp.FixValue(_MethodsInfo[i].value), ClassName = ClassName})
                table.move(MethodInfo, 1, #MethodInfo, #MethodsInfo + 1, MethodsInfo)
            end
            MethodsInfo = gg.getValues(MethodsInfo)
            Il2cpp.MethodsApi:DecodeMethodsInfo(_MethodsInfo, MethodsInfo)
            return _MethodsInfo
        end,
        GetClassFields = function(self, FieldsLink, Count, ClassCharacteristic)
            local FieldsInfo, _FieldsInfo = {}, {}
            for i = 0, Count - 1 do
                _FieldsInfo[#_FieldsInfo + 1] = {
                    address = FieldsLink + (i * self.FieldsStep),
                    flags = Il2cpp.MainType
                }
            end
            _FieldsInfo = gg.getValues(_FieldsInfo)
            for i = 1, #_FieldsInfo do
                local FieldInfo
                FieldInfo = Il2cpp.FieldApi:UnpackFieldInfo(Il2cpp.FixValue(_FieldsInfo[i].address))
                table.move(FieldInfo, 1, #FieldInfo, #FieldsInfo + 1, FieldsInfo)
            end
            FieldsInfo = gg.getValues(FieldsInfo)
            _FieldsInfo = Il2cpp.FieldApi:DecodeFieldsInfo(FieldsInfo, ClassCharacteristic)
            return _FieldsInfo
        end,
        ---@param self ClassApi
        ---@param ClassInfo ClassInfoRaw
        ---@param Config table
        ---@return table
        UnpackClassInfo = function(self, ClassInfo, Config)
            local _ClassInfo = gg.getValues({ 
                { -- Class Name [1]
                    address = ClassInfo.ClassInfoAddress + self.NameOffset,
                    flags = Il2cpp.MainType
                },
                { -- Methods Count [2]
                    address = ClassInfo.ClassInfoAddress + self.CountMethods,
                    flags = gg.TYPE_WORD
                },
                { -- Fields Count [3]
                    address = ClassInfo.ClassInfoAddress + self.CountFields,
                    flags = gg.TYPE_WORD
                },
                { -- Link as Methods [4]
                    address = ClassInfo.ClassInfoAddress + self.MethodsLink,
                    flags = Il2cpp.MainType
                },
                { -- Link as Fields [5]
                    address = ClassInfo.ClassInfoAddress + self.FieldsLink,
                    flags = Il2cpp.MainType
                },
                { -- Link as Parent Class [6]
                    address = ClassInfo.ClassInfoAddress + self.ParentOffset,
                    flags = Il2cpp.MainType
                },
                { -- Class NameSpace [7]
                    address = ClassInfo.ClassInfoAddress + self.NameSpaceOffset,
                    flags = Il2cpp.MainType
                },
                { -- Class Static Field Data [8]
                    address = ClassInfo.ClassInfoAddress + self.StaticFieldDataOffset,
                    flags = Il2cpp.MainType
                },
                { -- EnumType [9]
                    address = ClassInfo.ClassInfoAddress + self.EnumType,
                    flags = gg.TYPE_BYTE
                },
                { -- TypeMetadataHandle [10]
                    address = ClassInfo.ClassInfoAddress + self.TypeMetadataHandle,
                    flags = Il2cpp.MainType
                }
            })
            local ClassName = ClassInfo.ClassName or Il2cpp.Utf8ToString(Il2cpp.FixValue(_ClassInfo[1].value))
            local ClassCharacteristic = {ClassName = ClassName, IsEnum = ((_ClassInfo[9].value >> self.EnumRsh) & 1) == 1, TypeMetadataHandle = Il2cpp.FixValue(_ClassInfo[10].value)}
            return setmetatable({
                ClassName = ClassName,
                ClassAddress = string.format('%X', Il2cpp.FixValue(ClassInfo.ClassInfoAddress)),
                Methods = (_ClassInfo[2].value > 0 and Config.MethodsDump) and self:GetClassMethods(Il2cpp.FixValue(_ClassInfo[4].value), _ClassInfo[2].value, ClassName) or nil,
                Fields = (_ClassInfo[3].value > 0 and Config.FieldsDump) and self:GetClassFields(Il2cpp.FixValue(_ClassInfo[5].value), _ClassInfo[3].value, ClassCharacteristic) or nil,
                Parent = _ClassInfo[6].value ~= 0 and {ClassAddress = string.format('%X', Il2cpp.FixValue(_ClassInfo[6].value)), ClassName = self:GetClassName(_ClassInfo[6].value)} or nil,
                ClassNameSpace = Il2cpp.Utf8ToString(Il2cpp.FixValue(_ClassInfo[7].value)),
                StaticFieldData = _ClassInfo[8].value ~= 0 and Il2cpp.FixValue(_ClassInfo[8].value) or nil,
                IsEnum = ClassCharacteristic.IsEnum,
                TypeMetadataHandle = ClassCharacteristic.TypeMetadataHandle
            }, {
                __index = Il2cpp.ClassInfoApi
            })
        end,
        FindClassWithName = function(self, ClassName)
            gg.clearResults()
            gg.setRanges(0)
            gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_HEAP | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA | gg.REGION_OTHER | gg.REGION_C_ALLOC)
            gg.searchNumber("Q 00 '" .. ClassName .. "' 00 ",gg.TYPE_BYTE,false,gg.SIGN_EQUAL, Il2cpp.globalMetadataStart, Il2cpp.globalMetadataEnd)
            gg.searchPointer(0)
            local ClassNamePoint, ResultTable = gg.getResults(gg.getResultsCount()), {}
            gg.clearResults()
            for k,v in ipairs(ClassNamePoint) do
                local MainClass = gg.getValues({{address = v.address - self.NameOffset,flags = v.flags}})[1]
                local assembly = Il2cpp.FixValue(MainClass.value)
                if (Il2cpp.Utf8ToString(Il2cpp.FixValue(gg.getValues({{address = assembly,flags = v.flags}})[1].value)):find(".dll")) then 
                    ResultTable[#ResultTable + 1] = {
                        ClassInfoAddress = Il2cpp.FixValue(MainClass.address),
                        ClassName = ClassName
                    }
                end
            end
            if (#ResultTable == 0) then error('the "' .. ClassName .. '" function pointer was not found') end
            return ResultTable
        end,
        FindClassWithAddressInMemory = function(self, ClassAddress)
            local assembly, ResultTable = Il2cpp.FixValue(gg.getValues({{address = ClassAddress, flags = Il2cpp.MainType}})[1].value), {}
            if (Il2cpp.Utf8ToString(Il2cpp.FixValue(gg.getValues({{address = assembly,flags = Il2cpp.MainType}})[1].value)):find(".dll")) then 
                ResultTable[#ResultTable + 1] = {
                    ClassInfoAddress = ClassAddress,
                }
            end
            if (#ResultTable == 0) then error('nothing was found for this address 0x' .. string.format("%X", ClassAddress)) end
            return ResultTable
        end,
        FindParamsCheck = {
            ---@param self ClassApi
            ---@param _class number @Class Address In Memory
            ['number'] = function (self, _class)
                return Protect:Call(self.FindClassWithAddressInMemory, self, _class)
            end,
            ---@param self ClassApi
            ---@param _class string @Class Name
            ['string'] = function (self, _class)
                return Protect:Call(self.FindClassWithName, self, _class)
            end,
            ['default'] = function()
                return {Error = 'Invalid search criteria'}
            end
        },
        ---@param self ClassApi
        ---@param class ClassConfig
        ---@return ClassInfo[] | ErrorSearch
        Find = function (self, class)
            local ClassInfo = (self.FindParamsCheck[type(class.Class)] or self.FindParamsCheck['default'])(self, class.Class)
            if #ClassInfo ~= 0 then
                for k = 1, #ClassInfo do
                    ClassInfo[k] = self:UnpackClassInfo(ClassInfo[k], {FieldsDump = class.FieldsDump, MethodsDump = class.MethodsDump})
                end
            end
            return ClassInfo
        end
    },
    ---@type MethodsApi
    MethodsApi = {
        ---@param self MethodsApi
        ---@param MethodName string
        ---@return MethodInfoRaw[]
        FindMethodWithName = function(self, MethodName)
            local FinalMethods, name = {}, "00 " .. MethodName:gsub('.', function (c) return string.format('%02X', string.byte(c)) .. " " end) .. "00"
            gg.clearResults()
            gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA | gg.REGION_OTHER)
            gg.searchNumber('h ' .. name, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, Il2cpp.globalMetadataStart, Il2cpp.globalMetadataEnd)
            if gg.getResultsCount() == 0 then error('the "' .. MethodName .. '" function was not found') end
            gg.refineNumber('h ' .. string.sub(name,4,5)) 
            local r = gg.getResults(gg.getResultsCount())
            gg.clearResults()
            for j = 1, #r do
                if gg.BUILD < 16126 then 
                    gg.searchNumber(string.format("%8.8X", Il2cpp.FixValue(r[j].address)) .. 'h',self.MainType)
                else 
                    gg.loadResults({r[j]})
                    gg.searchPointer(0)
                end
                if gg.getResultsCount() <= 0 and platform and sdk >= 30 then
                    gg.searchNumber(tostring(tonumber(Il2cpp.FixValue(r[j].address), 16) | 0xB400000000000000), gg.TYPE_QWORD)
                end
                local MethodsInfo = gg.getResults(gg.getResultsCount())
                gg.clearResults()
                for k, v in ipairs(MethodsInfo) do
                    v.address = v.address - self.NameOffset
                    local FinalAddress = Il2cpp.FixValue(gg.getValues({v})[1].value)
                    if (FinalAddress > Il2cpp.il2cppStart and FinalAddress < Il2cpp.il2cppEnd) then 
                        FinalMethods[#FinalMethods + 1] = {
                            MethodName = MethodName,
                            MethodAddress = FinalAddress,
                            MethodInfoAddress = v.address
                        }
                    end
                end
            end
            if (#FinalMethods == 0) then error('the "' .. MethodName .. '" function pointer was not found') end
            return FinalMethods
        end,
        ---@param self MethodsApi
        ---@param MethodOffset number
        ---@return MethodInfoRaw[]
        FindMethodWithOffset = function (self, MethodOffset)
            local MethodsInfo = self.FindMethodWithAddressInMemory(Il2cpp.il2cppStart + MethodOffset, MethodOffset)
            if (#MethodsInfo == 0) then error('nothing was found for this offset 0x' .. string.format("%X", MethodOffset)) end
            return MethodsInfo
        end,
        ---@param self MethodsApi
        ---@param MethodAddress number
        ---@param MethodOffset number | nil
        ---@return MethodInfoRaw[]
        FindMethodWithAddressInMemory = function (self, MethodAddress, MethodOffset)
            local RawMethodsInfo = {} -- the same as MethodsInfo
            gg.clearResults()
            gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA | gg.REGION_OTHER)
            if gg.BUILD < 16126 then 
                gg.searchNumber(string.format("%8.8X", MethodAddress) .. 'h', Il2cpp.MainType)
            else 
                gg.loadResults({{address = MethodAddress, flags = Il2cpp.MainType}})
                gg.searchPointer(0)
            end
            local r = gg.getResults(gg.getResultsCount())
            gg.clearResults()
            for j = 1, #r do
                RawMethodsInfo[#RawMethodsInfo + 1] = {
                    MethodAddress = MethodAddress,
                    MethodInfoAddress = r[j].address,
                    Offset = MethodOffset
                }
            end
            if (#RawMethodsInfo == 0 and MethodOffset == nil) then error('nothing was found for this address 0x' .. string.format("%X", MethodAddress)) end
            return RawMethodsInfo
        end,
        ---@param self MethodsApi
        ---@param _MethodsInfo MethodInfo[]
        DecodeMethodsInfo = function(self, _MethodsInfo, MethodsInfo)
            for i = 1, #_MethodsInfo do
                local index = (i - 1) * 5
                local TypeInfo = Il2cpp.FixValue(MethodsInfo[index + 5].value)
                local _TypeInfo = gg.getValues({
                    { -- type index
                        address = TypeInfo + Il2cpp.TypeApi.Type,
                        flags = gg.TYPE_BYTE
                    },
                    { -- index
                        address = TypeInfo,
                        flags = Il2cpp.MainType
                    }
                })
                local MethodAddress = Il2cpp.FixValue(MethodsInfo[index + 1].value)
                _MethodsInfo[i] = {
                    MethodName = _MethodsInfo[i].MethodName or Il2cpp.Utf8ToString(Il2cpp.FixValue(MethodsInfo[index + 2].value)),
                    Offset = string.format("%X", _MethodsInfo[i].Offset or MethodAddress - Il2cpp.il2cppStart),
                    AddressInMemory = string.format("%X", MethodAddress),
                    MethodInfoAddress = _MethodsInfo[i].MethodInfoAddress,
                    ClassName = _MethodsInfo[i].ClassName or Il2cpp.ClassApi:GetClassName(MethodsInfo[index + 3].value),
                    ClassAddress = string.format('%X', Il2cpp.FixValue(MethodsInfo[index + 3].value)),
                    ParamCount = MethodsInfo[index + 4].value,
                    ReturnType = Il2cpp.TypeApi:GetTypeName(_TypeInfo[1].value, _TypeInfo[2].value)
                }
            end
        end,
        ---@param self MethodsApi
        ---@param MethodInfo MethodInfoRaw
        UnpackMethodInfo = function(self, MethodInfo)
            return {
                { -- Address Method in Memory
                    address = MethodInfo.MethodInfoAddress,
                    flags = Il2cpp.MainType
                },
                { -- Name Address
                    address = MethodInfo.MethodInfoAddress + self.NameOffset,
                    flags = Il2cpp.MainType
                },
                { -- Class address
                    address = MethodInfo.MethodInfoAddress + self.ClassOffset,
                    flags = Il2cpp.MainType
                },
                { -- Param Count
                    address = MethodInfo.MethodInfoAddress + self.ParamCount,
                    flags = gg.TYPE_WORD
                },
                { -- Return Type
                    address = MethodInfo.MethodInfoAddress + self.ReturnType,
                    flags = Il2cpp.MainType
                }
            }, 
            {
                MethodName = MethodInfo.MethodName or nil,
                Offset = MethodInfo.Offset or nil,
                MethodInfoAddress = MethodInfo.MethodInfoAddress,
                ClassName = MethodInfo.ClassName,
            }
        end,
        FindParamsCheck = {
            ---@param self MethodsApi
            ---@param method number
            ['number'] = function(self, method)
                if (method > Il2cpp.il2cppStart and method < Il2cpp.il2cppEnd) then
                    return Protect:Call(self.FindMethodWithAddressInMemory, self, method)
                else
                    return Protect:Call(self.FindMethodWithOffset, self, method)
                end
            end,
            ---@param self MethodsApi
            ---@param method string
            ['string'] = function(self, method)
                return Protect:Call(self.FindMethodWithName, self, method)
            end,
            ['default'] = function()
                return {Error = 'Invalid search criteria'}
            end
        },
        ---@param self MethodsApi
        ---@param method number | string
        ---@return MethodInfo[] | ErrorSearch
        Find = function (self, method)
            ---@type MethodInfoRaw[] | ErrorSearch
            local _MethodsInfo = (self.FindParamsCheck[type(method)] or self.FindParamsCheck['default'])(self, method)
            if (#_MethodsInfo > 0) then
                local MethodsInfo = {}
                for k = 1, #_MethodsInfo do
                    local MethodInfo
                    MethodInfo, _MethodsInfo[k] = self:UnpackMethodInfo(_MethodsInfo[k])
                    table.move(MethodInfo, 1, #MethodInfo, #MethodsInfo + 1, MethodsInfo)
                end
                MethodsInfo = gg.getValues(MethodsInfo)
                self:DecodeMethodsInfo(_MethodsInfo, MethodsInfo)
            end

            return _MethodsInfo
        end
    },
    ---@class ObjectApi
    ObjectApi = {
        ---@param self ObjectApi
        ---@param Objects table
        FilterObjects = function(self, Objects)
            local FilterObjects = {}
            for k, v in ipairs(gg.getValuesRange(Objects)) do
                if v == 'A' then
                    FilterObjects[#FilterObjects + 1] = Objects[k]
                end
            end
            Objects = FilterObjects
            gg.loadResults(Objects)
            gg.searchPointer(0)
            if gg.getResultsCount() <= 0 and platform and sdk >= 30 then
                local FixRefToObjects = {}
                for k,v in ipairs(Objects) do
                    gg.searchNumber(tostring(v.address | 0xB400000000000000), gg.TYPE_QWORD)
                    ---@type tablelib
                    local RefToObject = gg.getResults(gg.getResultsCount())
                    RefToObject:move(1, #RefToObject, #FixRefToObjects + 1, FixRefToObjects)
                    gg.clearResults()
                end
                gg.loadResults(FixRefToObjects)
            end
            local RefToObjects, FilterObjects = gg.getResults(gg.getResultsCount()), {}
            gg.clearResults()
            for k,v in ipairs(gg.getValuesRange(RefToObjects)) do
                if v == 'A' then
                    FilterObjects[#FilterObjects + 1] = {address = Il2cpp.FixValue(RefToObjects[k].value), flags = RefToObjects[k].flags}
                end
            end
            gg.loadResults(FilterObjects)
            local _FilterObjects = gg.getResults(gg.getResultsCount())
            gg.clearResults()
            return _FilterObjects
        end,
        ---@param self ObjectApi
        ---@param ClassAddress string
        FindObjects = function(self, ClassAddress)
            gg.clearResults()
            gg.setRanges(0)
            gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_HEAP | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA | gg.REGION_C_ALLOC)
            gg.loadResults({{address = tonumber(ClassAddress, 16), flags = Il2cpp.MainType}})
            gg.searchPointer(0)
            if gg.getResultsCount() <= 0 and platform and sdk >= 30 then
                gg.searchNumber(tostring(tonumber(ClassAddress, 16) | 0xB400000000000000), gg.TYPE_QWORD)
            end
            local FindsResult = gg.getResults(gg.getResultsCount())
            gg.clearResults()
            return self:FilterObjects(FindsResult)
        end,
        ---@param self ObjectApi
        ---@param ClassesInfo ClassInfo[]
        Find = function(self, ClassesInfo)
            local Objects = {}
            for j = 1, #ClassesInfo do
                local FindResult = self:FindObjects(ClassesInfo[j].ClassAddress)
                table.move(FindResult, 1, #FindResult, #Objects + 1, Objects)
            end
            return Objects
        end
    }
}

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