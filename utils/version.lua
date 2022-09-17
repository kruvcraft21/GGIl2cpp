---@class VersionEngine
local VersionEngine = {
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
    ---@return number
    GetUnityVersion = function()
        gg.setRanges(gg.REGION_CODE_APP)
        gg.clearResults()
        gg.searchNumber("32h;30h;0~~0;0~~0;2Eh;0~~0;2Eh;66h::11", gg.TYPE_BYTE, false, gg.SIGN_EQUAL, nil, nil, 16)
        local versionTable = gg.getResults(1)
        gg.clearResults()
        return gg.getResultsCount() > 0 and versionTable[1].address or 0
    end,
    ReadUnityVersion = function(versionAddress)
        local verisonName = Il2cpp.Utf8ToString(versionAddress)
        local i, j = string.find(verisonName, "f")
        if j then verisonName = string.sub(verisonName, 1, j - 1) end
        return string.gmatch(verisonName, "([^%.]+)%.([^%.]+)%.([^%.]+)")()
    end,
    ---@param self VersionEngine
    ---@param version? number
    ChooseVersion = function(self, version, globalMetadataHeader)
        if not version then
            local unityVersionAddress = self.GetUnityVersion()
            if unityVersionAddress == 0 then
                version = gg.getValues({{address = globalMetadataHeader + 0x4, flags = gg.TYPE_DWORD}})[1].value
            else
                local p1, p2, p3 = self.ReadUnityVersion(unityVersionAddress)
                ---@type number | fun(p2 : string, p3: string):number
                version = self.Year[tonumber(p1)] or 29
                if type(version) == 'function' then
                    version = version(p2, p3)
                end
            end
            
        end
        local api = assert(Il2cppApi[version], 'Not support this il2cpp version')
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
        Il2cpp.ClassApi.InstanceSize = api.ClassApiInstanceSize

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

        Il2cpp.MetadataRegistrationApi.types = api.MetadataRegistrationApitypes
    end,
}

return VersionEngine