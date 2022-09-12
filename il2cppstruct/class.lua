local Protect = require("utils.protect")

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
---@field InstanceSize number
---@field GetClassName fun(self : ClassApi, ClassAddress : number) : string
---@field GetClassMethods fun(self : ClassApi, MethodsLink : number, Count : number, ClassName : string | nil) : MethodInfo[]
local ClassApi = {
    
    
    ---@param self ClassApi
    ---@param ClassAddress number
    GetClassName = function(self, ClassAddress)
        return Il2cpp.Utf8ToString(Il2cpp.FixValue(gg.getValues({{
            address = Il2cpp.FixValue(ClassAddress) + self.NameOffset,
            flags = Il2cpp.MainType
        }})[1].value))
    end,
    
    
    ---@param self ClassApi
    ---@param MethodsLink number
    ---@param Count number
    ---@param ClassName string | nil
    GetClassMethods = function(self, MethodsLink, Count, ClassName)
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
            MethodInfo, _MethodsInfo[i] = Il2cpp.MethodsApi:UnpackMethodInfo({
                MethodInfoAddress = Il2cpp.FixValue(_MethodsInfo[i].value),
                ClassName = ClassName
            })
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
            },
            { -- InstanceSize [11]
                address = ClassInfo.ClassInfoAddress + self.InstanceSize,
                flags = gg.TYPE_DWORD
            }
        })
        local ClassName = ClassInfo.ClassName or Il2cpp.Utf8ToString(Il2cpp.FixValue(_ClassInfo[1].value))
        local ClassCharacteristic = {
            ClassName = ClassName,
            IsEnum = ((_ClassInfo[9].value >> self.EnumRsh) & 1) == 1,
            TypeMetadataHandle = Il2cpp.FixValue(_ClassInfo[10].value)
        }
        return setmetatable({
            ClassName = ClassName,
            ClassAddress = string.format('%X', Il2cpp.FixValue(ClassInfo.ClassInfoAddress)),
            Methods = (_ClassInfo[2].value > 0 and Config.MethodsDump) and
                self:GetClassMethods(Il2cpp.FixValue(_ClassInfo[4].value), _ClassInfo[2].value, ClassName) or nil,
            Fields = (_ClassInfo[3].value > 0 and Config.FieldsDump) and
                self:GetClassFields(Il2cpp.FixValue(_ClassInfo[5].value), _ClassInfo[3].value, ClassCharacteristic) or
                nil,
            Parent = _ClassInfo[6].value ~= 0 and {
                ClassAddress = string.format('%X', Il2cpp.FixValue(_ClassInfo[6].value)),
                ClassName = self:GetClassName(_ClassInfo[6].value)
            } or nil,
            ClassNameSpace = Il2cpp.Utf8ToString(Il2cpp.FixValue(_ClassInfo[7].value)),
            StaticFieldData = _ClassInfo[8].value ~= 0 and Il2cpp.FixValue(_ClassInfo[8].value) or nil,
            IsEnum = ClassCharacteristic.IsEnum,
            TypeMetadataHandle = ClassCharacteristic.TypeMetadataHandle,
            InstanceSize = _ClassInfo[11].value
        }, {
            __index = Il2cpp.ClassInfoApi
        })
    end,


    IsClassInfo = function(Address)
        local assembly = Il2cpp.FixValue(gg.getValues({{
            address = Il2cpp.FixValue(Address),
            flags = Il2cpp.MainType
        }})[1].value)
        return Il2cpp.Utf8ToString(Il2cpp.FixValue(gg.getValues({{
            address = assembly,
            flags = Il2cpp.MainType
        }})[1].value)):find(".dll") ~= nil
    end,


    ---@param self ClassApi
    FindClassWithName = function(self, ClassName)
        local ClassNamePoint = Il2cpp.GlobalMetadataApi.GetPointersToString(ClassName)
        local ResultTable = {}
        for i, v in ipairs(ClassNamePoint) do
            local MainClass = gg.getValues({{
                address = v.address - self.NameOffset,
                flags = v.flags
            }})[1]
            if (self.IsClassInfo(MainClass.address)) then
                ResultTable[#ResultTable + 1] = {
                    ClassInfoAddress = Il2cpp.FixValue(MainClass.address),
                    ClassName = ClassName
                }
            end
        end
        assert(#ResultTable > 0, 'The "' .. ClassName .. '" class is not initialized')
        return ResultTable
    end,


    ---@param self ClassApi
    FindClassWithAddressInMemory = function(self, ClassAddress)
        local ResultTable = {}
        if self.IsClassInfo(ClassAddress) then
            ResultTable[#ResultTable + 1] = {
                ClassInfoAddress = ClassAddress
            }
        end
        assert(#ResultTable > 0, 'nothing was found for this address 0x' .. string.format("%X", ClassAddress))
        return ResultTable
    end,


    FindParamsCheck = {
        ---@param self ClassApi
        ---@param _class number @Class Address In Memory
        ['number'] = function(self, _class)
            return Protect:Call(self.FindClassWithAddressInMemory, self, _class)
        end,
        ---@param self ClassApi
        ---@param _class string @Class Name
        ['string'] = function(self, _class)
            return Protect:Call(self.FindClassWithName, self, _class)
        end,
        ['default'] = function()
            return {
                Error = 'Invalid search criteria'
            }
        end
    },


    ---@param self ClassApi
    ---@param class ClassConfig
    ---@return ClassInfo[] | ErrorSearch
    Find = function(self, class)
        local ClassInfo =
            (self.FindParamsCheck[type(class.Class)] or self.FindParamsCheck['default'])(self, class.Class)
        if #ClassInfo ~= 0 then
            for k = 1, #ClassInfo do
                ClassInfo[k] = self:UnpackClassInfo(ClassInfo[k], {
                    FieldsDump = class.FieldsDump,
                    MethodsDump = class.MethodsDump
                })
            end
        end
        return ClassInfo
    end
}

return ClassApi