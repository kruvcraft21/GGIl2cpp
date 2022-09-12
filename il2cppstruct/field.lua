local Protect = require("utils.protect")

---@class FieldApi
---@field Offset number
---@field Type number
---@field ClassOffset number
---@field Find fun(self : FieldApi, fieldSearchCondition : string | number) : FieldInfo[] | ErrorSearch
local FieldApi = {


    ---@param self FieldApi
    ---@param FieldInfoAddress number
    UnpackFieldInfo = function(self, FieldInfoAddress)
        return {{ -- Field Name
            address = FieldInfoAddress,
            flags = Il2cpp.MainType
        }, { -- Offset Field
            address = FieldInfoAddress + self.Offset,
            flags = gg.TYPE_WORD
        }, { -- Field type
            address = FieldInfoAddress + self.Type,
            flags = Il2cpp.MainType
        }, { -- Class address
            address = FieldInfoAddress + self.ClassOffset,
            flags = Il2cpp.MainType
        }}
    end,


    ---@param self FieldApi
    DecodeFieldsInfo = function(self, FieldsInfo, ClassCharacteristic)
        local index, _FieldsInfo = 0, {}
        local fieldStart = gg.getValues({{
            address = ClassCharacteristic.TypeMetadataHandle + Il2cpp.Il2CppTypeDefinitionApi.fieldStart,
            flags = gg.TYPE_DWORD
        }})[1].value
        for i = 1, #FieldsInfo, 4 do
            index = index + 1
            local TypeInfo = Il2cpp.FixValue(FieldsInfo[i + 2].value)
            local _TypeInfo = gg.getValues({{
                address = TypeInfo + self.Type,
                flags = gg.TYPE_WORD
            }, { -- type index
                address = TypeInfo + Il2cpp.TypeApi.Type,
                flags = gg.TYPE_BYTE
            }, { -- index
                address = TypeInfo,
                flags = Il2cpp.MainType
            }})
            _FieldsInfo[index] = setmetatable({
                ClassName = ClassCharacteristic.ClassName or Il2cpp.ClassApi:GetClassName(FieldsInfo[i + 3].value),
                ClassAddress = string.format('%X', Il2cpp.FixValue(FieldsInfo[i + 3].value)),
                FieldName = Il2cpp.Utf8ToString(Il2cpp.FixValue(FieldsInfo[i].value)),
                Offset = string.format('%X', FieldsInfo[i + 1].value),
                IsStatic = (_TypeInfo[1].value & 0x10) ~= 0,
                Type = Il2cpp.TypeApi:GetTypeName(_TypeInfo[2].value, _TypeInfo[3].value),
                IsConst = (_TypeInfo[1].value & 0x40) ~= 0
            }, {
                __index = Il2cpp.FieldInfoApi,
                fieldIndex = fieldStart + index - 1
            })
        end
        return _FieldsInfo
    end,


    ---@param self FieldApi
    ---@param fieldName string
    ---@return FieldInfo[]
    FindFieldWithName = function(self, fieldName)
        local fieldNamePoint = Il2cpp.GlobalMetadataApi.GetPointersToString(fieldName)
        local ResultTable = {}
        for k, v in ipairs(fieldNamePoint) do
            local classAddress = gg.getValues({{
                address = v.address + self.ClassOffset,
                flags = Il2cpp.MainType
            }})[1].value
            if Il2cpp.ClassApi.IsClassInfo(classAddress) then
                local Il2cppClass = Il2cpp.FindClass({{
                    Class = classAddress,
                    FieldsDump = true
                }})[1]
                for i, class in ipairs(Il2cppClass) do
                    ResultTable[#ResultTable + 1] = class:GetFieldWithName(fieldName)
                end
            end
        end
        assert(#ResultTable > 0, 'The "' .. fieldName .. '" field is not initialized')
        return ResultTable
    end,


    FindFieldWithAddress = function(self, fieldAddress)
        local ResultTable = {}
        local Il2cppObject = Il2cpp.ObjectApi:Set(fieldAddress)
        local fieldOffset = fieldAddress - Il2cppObject.address
        local classAddress = Il2cpp.FixValue(Il2cppObject.value)
        local Il2cppClass = Il2cpp.FindClass({{
            Class = classAddress,
            FieldsDump = true
        }})[1]
        for i, v in ipairs(Il2cppClass) do
            ResultTable[#ResultTable + 1] = v:GetFieldWithOffset(fieldOffset)
        end
        assert(#ResultTable > 0, 'nothing was found for this address 0x' .. string.format("%X", fieldAddress))
        return ResultTable
    end,


    FindTypeCheck = {
        ---@param self FieldApi
        ---@param fieldName string
        ['string'] = function(self, fieldName)
            return Protect:Call(self.FindFieldWithName, self, fieldName)
        end,
        ---@param self FieldApi
        ---@param fieldAddress number
        ['number'] = function(self, fieldAddress)
            return Protect:Call(self.FindFieldWithAddress, self, fieldAddress)
        end,
        ['default'] = function()
            return {
                Error = 'Invalid search criteria'
            }
        end
    },


    ---@param self FieldApi
    ---@param fieldSearchCondition number | string
    ---@return FieldInfo[] | ErrorSearch
    Find = function(self, fieldSearchCondition)
        local FieldsInfo = (self.FindTypeCheck[type(fieldSearchCondition)] or self.FindTypeCheck['default'])(self, fieldSearchCondition)
        return FieldsInfo
    end
}

return FieldApi
