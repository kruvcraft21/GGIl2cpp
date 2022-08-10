---@type FieldApi
local FieldApi = {


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
            fieldStart = gg.getValues({{
                address = ClassCharacteristic.TypeMetadataHandle + Il2cpp.Il2CppTypeDefinitionApi.fieldStart,
                flags = gg.TYPE_DWORD
            }})[1].value
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
}

return FieldApi