---@class TypeApi
---@field Type number
---@field tableConst table
---@field tableTypes table
local TypeApi = {

    tableConst = {
        [2] = gg.TYPE_BYTE,
        [3] = gg.TYPE_BYTE,
        [4] = gg.TYPE_BYTE,
        [5] = gg.TYPE_BYTE,
        [6] = gg.TYPE_WORD,
        [7] = gg.TYPE_WORD,
        [8] = gg.TYPE_DWORD,
        [9] = gg.TYPE_DWORD,
        [10] = gg.TYPE_QWORD,
        [11] = gg.TYPE_QWORD,
        [12] = gg.TYPE_FLOAT,
        [13] = gg.TYPE_DOUBLE,
    },
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
            if not (Il2cpp.GlobalMetadataApi.version < 27) then
                index = gg.getValues({{
                    address = Il2cpp.FixValue(index),
                    flags = Il2cpp.MainType
                }})[1].value
            end
            index = gg.getValues({{
                address = Il2cpp.FixValue(index),
                flags = Il2cpp.MainType
            }})[1].value
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
    end,


    ---@param self TypeApi
    GetGGTYPEInIl2CppType = function(self, Il2CppType)
        local typeEnum =self:GetTypeEnum(Il2CppType)
        if self.tableConst[typeEnum] then
            return self.tableConst[typeEnum]
        end
        return "Not support type"
    end,


    ---@param self TypeApi
    ---@param typeEnum number
    GetGGTYPEFromTypeEnum = function(self, typeEnum)
        if self.tableConst[typeEnum] then
            return self.tableConst[typeEnum]
        end
        return "Not support type"
    end,


    ---@param self TypeApi
    ---@param Il2CppType number
    GetTypeEnum = function(self, Il2CppType)
        return gg.getValues({{address = Il2CppType + self.Type, flags = gg.TYPE_BYTE}})[1].value
    end
}

return TypeApi