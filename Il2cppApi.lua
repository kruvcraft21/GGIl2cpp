local platform = gg.getTargetInfo().x64

function switch(check, table, e, ...)
    return ({
        xpcall(
            table[check],
            function ()
                return table[check] or (
                    function()
                        if type(e) ~= 'function' then return e end
                        return e()
                    end
                )()
            end,
            ...
        )
    })[2]
end

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

function addresspath(StartAddress, ...)
    local args, patch = {...}, {}
    for i = 1,#args do
        StartAddress = i ~= 1 and StartAddress + 0x4 or StartAddress
        patch[#patch + 1] = {address = StartAddress, flags = gg.TYPE_DWORD, value = args[i]:gsub('.', function (c) return string.format('%02X', string.byte(c)) end)..'r'}
    end
    gg.setValues(patch)
end

Il2cpp = {
    il2cppStart = 0,
    il2cppEnd = 0,
    globalMetadataStart = 0,
    globalMetadataEnd = 0,
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
    FindMethods = function(searchArgs)
        for i = 1, #searchArgs do
            searchArgs[i] = Il2cpp.MethodsApi.Find(Il2cpp.MethodsApi, searchArgs[i])
        end
        return searchArgs
    end,
    FindClass = function(searchArgs)
        for i = 1, #searchArgs do
            searchArgs[i] = Il2cpp.ClassApi.Find(Il2cpp.ClassApi, searchArgs[i])
        end
        return searchArgs
    end,
    Utf8ToString = function(Address)
        local bytes, char = {}, {address = Il2cpp.FixValue(Address), flags = gg.TYPE_BYTE}
        while gg.getValues({char})[1].value > 0 do
            bytes[#bytes + 1] = {address = char.address, flags = char.flags}
            char.address = char.address + 0x1
        end
        return tostring(setmetatable(gg.getValues(bytes), {
            __tostring = function(self)
                for k,v in ipairs(self) do
                    self[k] = string.char(v.value) 
                end
                return table.concat(self)
            end
        }))
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
    FixValue = function(val)
        return platform and val or val & 0xFFFFFFFF
    end,
    MainType = platform and gg.TYPE_QWORD or gg.TYPE_DWORD,
    FieldApi = {
        Offset = platform and 0x18 or 0xC,
        Type = platform and 0x8 or 0x4,
        ClassOffset = platform and 0x10 or 0x8, 
        UnpackFieldInfo = function(self, FieldInfo)
            return {
                { -- Field Name
                    address = FieldInfo.FieldInfoAddress,
                    flags = Il2cpp.MainType
                },
                { -- Offset Field
                    address = FieldInfo.FieldInfoAddress + self.Offset,
                    flags = gg.TYPE_WORD
                },
                { -- Field type
                    address = FieldInfo.FieldInfoAddress + self.Type,
                    flags = Il2cpp.MainType
                },
                { -- Class address
                    address = FieldInfo.FieldInfoAddress + self.ClassOffset,
                    flags = Il2cpp.MainType
                }
            },
            {
                ClassName = FieldInfo.ClassName or nil,
            }
        end,
        DecodeFieldsInfo = function(self, _FieldsInfo, FieldsInfo)
            for i = 1, #_FieldsInfo do
                local index = (i - 1) << 2
                _FieldsInfo[i] = {
                    ClassName = _FieldsInfo.ClassName or Il2cpp.Utf8ToString(gg.getValues({{address = FieldsInfo[index + 4].value + Il2cpp.ClassApi.NameOffset, flags = Il2cpp.MainType}})[1].value),
                    ClassAddress = string.format('%X', Il2cpp.FixValue(FieldsInfo[index + 3].value)),
                    FieldName = Il2cpp.Utf8ToString(FieldsInfo[index + 1].value),
                    Offset = string.format('%X', FieldsInfo[index + 2].value),
                    IsStatic = (gg.getValues({{address = Il2cpp.FixValue(FieldsInfo[index + 3].value) + self.Type, flags = gg.TYPE_WORD}})[1].value & 0x10) ~= 0
                }
            end
        end
    },
    ClassApi = {
        NameOffset = platform and 0x10 or 0x8,
        MethodsStep = platform and 3 or 2,
        CountMethods = platform and 0x11C or 0xA4,
        MethodsLink = platform and 0x98 or 0x4C,
        FieldsLink = platform and 0x80 or 0x40,
        FieldsStep = platform and 0x20 or 0x14,
        CountFields = platform and 0x120 or 0xA8,
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
        GetClassFields = function(self, FieldsLink, Count, ClassName)
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
                FieldInfo, _FieldsInfo[i] = Il2cpp.FieldApi:UnpackFieldInfo({FieldInfoAddress = Il2cpp.FixValue(_FieldsInfo[i].address), ClassName = ClassName})
                table.move(FieldInfo, 1, #FieldInfo, #FieldsInfo + 1, FieldsInfo)
            end
            FieldsInfo = gg.getValues(FieldsInfo)
            Il2cpp.FieldApi:DecodeFieldsInfo(_FieldsInfo, FieldsInfo)
            return _FieldsInfo
        end,
        UnpackClassInfo = function(self, ClassInfo, Config)
            local _ClassInfo = gg.getValues({
                { -- Class Name
                    address = ClassInfo.ClassInfoAddress + self.NameOffset,
                    flags = Il2cpp.MainType
                },
                { -- Methods Count
                    address = ClassInfo.ClassInfoAddress + self.CountMethods,
                    flags = gg.TYPE_WORD
                },
                { -- Fields Count
                    address = ClassInfo.ClassInfoAddress + self.CountFields,
                    flags = gg.TYPE_WORD
                },
                { -- Link as Methods
                    address = ClassInfo.ClassInfoAddress + self.MethodsLink,
                    flags = Il2cpp.MainType
                },
                { -- Link as Fields
                    address = ClassInfo.ClassInfoAddress + self.FieldsLink,
                    flags = Il2cpp.MainType
                }
            })
            return {
                ClassName = ClassInfo.Class or Il2cpp.Utf8ToString(_ClassInfo[1].value),
                ClassAddress = string.format('%X', Il2cpp.FixValue(ClassInfo.ClassInfoAddress)),
                Methods = (_ClassInfo[2].value > 0 and Config.MethodsDump) and self:GetClassMethods(_ClassInfo[4].value, _ClassInfo[2].value, ClassInfo.Class) or nil,
                Fields = (_ClassInfo[3].value > 0 and Config.FieldsDump) and self:GetClassFields(_ClassInfo[5].value, _ClassInfo[3].value, ClassInfo.Class) or nil
            }
        end,
        FindClassWithName = function(self, ClassName)
            gg.clearResults()
            gg.setRanges(0)
            gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_HEAP | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA | gg.REGION_OTHER | gg.REGION_C_ALLOC)
            gg.searchNumber("Q 00 '" .. ClassName .. "' 00 ",gg.TYPE_BYTE,false,gg.SIGN_EQUAL, Il2cpp.globalMetadataStart, Il2cpp.globalMetadataEnd)
            gg.searchPointer(0)
            local ClassNamePoint, ResultTable = gg.getResults(gg.getResultsCount()), {}
            gg.clearResults()
            if (#ClassNamePoint > 0) then
                for k,v in ipairs(ClassNamePoint) do
                    local MainClass = gg.getValues({{address = v.address - self.NameOffset,flags = v.flags}})[1]
                    local assembly = Il2cpp.FixValue(MainClass.value)
                    if (Il2cpp.Utf8ToString(gg.getValues({{address = assembly,flags = v.flags}})[1].value):find(".dll")) then 
                        ResultTable[#ResultTable + 1] = {
                            ClassInfoAddress = Il2cpp.FixValue(MainClass.address),
                            ClassName = ClassName
                        }
                    end
                end
            end
            if (#ResultTable == 0) then error('the "' .. ClassName .. '" function pointer was not found') end
            return ResultTable
        end,
        FindClassWithAddressInMemory = function(self, ClassAddress)
            local assembly, ResultTable = Il2cpp.FixValue(gg.getValues({{address = ClassAddress, flags = Il2cpp.MainType}})[1].value), {}
            if (Il2cpp.Utf8ToString(gg.getValues({{address = assembly,flags = v.flags}})[1].value):find(".dll")) then 
                ResultTable[#ResultTable + 1] = {
                    ClassInfoAddress = ClassAddress,
                }
            end
            if (#ResultTable == 0) then error('nothing was found for this address 0x' .. string.format("%X", ClassAddress)) end
            return ResultTable
        end,
        Find = function (self, class)
            local ClassInfo = switch(type(class.Class), {
                ['number'] = function (self, _class)
                    return Protect:Call(self.FindClassWithAddressInMemory, self, _class)
                end,
                ['string'] = function (self, _class)
                    return Protect:Call(self.FindClassWithName, self, _class)
                end,
            }, {Error = 'Invalid search criteria'},self, class.Class)
            if (#ClassInfo == 0) then
                ClassInfo = {ClassInfo}
            else
                for k = 1, #ClassInfo do
                    ClassInfo[k] = self:UnpackClassInfo(ClassInfo[k], {FieldsDump = class.FieldsDump, MethodsDump = class.MethodsDump})
                end
            end
            return ClassInfo
        end
    },
    MethodsApi = {
        ClassOffset = platform and 0x18 or 0xC,
        NameOffset = platform and 0x10 or 0x8,
        ParamCount = platform and 0x4A or 0x2A,
        FindMethodWithName = function(self, MethodName)
            local FinalMethods, name = {}, "00 " .. MethodName:gsub('.', function (c) return string.format('%02X', string.byte(c)) .. " " end) .. "00"
            gg.clearResults()
            gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA | gg.REGION_OTHER)
            gg.searchNumber('h ' .. name, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, Il2cpp.globalMetadataStart, Il2cpp.globalMetadataEnd)
            if gg.getResultsCount() == 0 then error('the "' .. MethodName .. '" function was not found') end
            gg.searchNumber('h ' .. string.sub(name,4,5)) 
            local r = gg.getResults(gg.getResultsCount())
            gg.clearResults()
            for j = 1, #r do
                if gg.BUILD < 16126 then 
                    gg.searchNumber(string.format("%8.8X", Il2cpp.FixValue(r[j].address)) .. 'h',self.MainType)
                else 
                    gg.loadResults({r[j]})
                    gg.searchPointer(0)
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
        FindMethodWithOffset = function (self, MethodOffset)
            local MethodsInfo = {}
            local tmpMethodsInfo = self.FindMethodWithAddressInMemory(Il2cpp.il2cppStart + MethodOffset, MethodOffset)
            table.move(tmpMethodsInfo, 1, #tmpMethodsInfo, #MethodsInfo + 1, MethodsInfo)
            if (#MethodsInfo == 0) then error('nothing was found for this offset 0x' .. string.format("%X", MethodOffset)) end
            return MethodsInfo
        end,
        FindMethodWithAddressInMemory = function (MethodAddress, MethodOffset)
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
                    MethodOffset = MethodOffset
                }
            end
            if (#RawMethodsInfo == 0 and MethodOffset == nil) then error('nothing was found for this address 0x' .. string.format("%X", MethodAddress)) end
            return RawMethodsInfo
        end,
        DecodeMethodsInfo = function(self, _MethodsInfo, MethodsInfo)
            for i = 1, #_MethodsInfo do
                local index = (i - 1) << 2
                local MethodAddress = Il2cpp.FixValue(MethodsInfo[index + 1].value)
                _MethodsInfo[i] = {
                    MethodName = _MethodsInfo[i].MethodName or Il2cpp.Utf8ToString(MethodsInfo[index + 2].value),
                    Offset = _MethodsInfo[i].Offset or string.format("%X", MethodAddress - Il2cpp.il2cppStart),
                    AddressInMemory = string.format("%X", MethodAddress),
                    MethodInfoAddress = _MethodsInfo[i].MethodInfoAddress,
                    ClassName = _MethodsInfo[i].ClassName or Il2cpp.Utf8ToString(gg.getValues({{address = Il2cpp.FixValue(MethodsInfo[index + 3].value) + Il2cpp.ClassApi.NameOffset,flags = Il2cpp.MainType}})[1].value),
                    ClassAddress = string.format('%X', Il2cpp.FixValue(MethodsInfo[index + 3].value)),
                    ParamCount = MethodsInfo[index + 4].value
                }
            end
        end,
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
                }
            }, 
            {
                MethodName = MethodInfo.MethodName or nil,
                Offset = MethodInfo.Offset or nil,
                MethodInfoAddress = MethodInfo.MethodInfoAddress,
                ClassName = MethodInfo.ClassName,
            }
        end,
        Find = function (self, method)
            local _MethodsInfo = switch(type(method), {
                ['number'] = function (self, method)
                    if (method > Il2cpp.il2cppStart and method < Il2cpp.il2cppEnd) then
                        return Protect:Call(self.FindMethodWithAddressInMemory, self, method)
                    else
                        return Protect:Call(self.FindMethodWithOffset, self, method)
                    end
                end,
                ['string'] = function (self, method)
                    return Protect:Call(self.FindMethodWithName, self, method)
                end,
            }, 'Invalid search criteria',self, method)
            if (#_MethodsInfo == 0) then
                _MethodsInfo = {_MethodsInfo}
            else
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
    }
}

Il2cpp = setmetatable(Il2cpp, {
    __call = function(self, ...)
        local args = {...}
        switch(#args, {
            [0] = function(_Il2cpp, Addresses, FunctionForFound)
                _Il2cpp.il2cppStart, _Il2cpp.il2cppEnd = FunctionForFound.FindIl2cpp()
                _Il2cpp.globalMetadataStart, _Il2cpp.globalMetadataEnd = FunctionForFound.FindGlobalMetaData()
            end,
            [1] = function(_Il2cpp, Addresses, FunctionForFound)
                _Il2cpp.il2cppStart, _Il2cpp.il2cppEnd = FunctionForFound.FindIl2cpp()
                _Il2cpp.globalMetadataStart, _Il2cpp.globalMetadataEnd = Addresses[1].start, Addresses[1]['end']
            end,
            [2] = function(_Il2cpp, Addresses, FunctionForFound)
                _Il2cpp.il2cppStart, _Il2cpp.il2cppEnd = Addresses[2].start, Addresses[2]['end']
                _Il2cpp.globalMetadataStart, _Il2cpp.globalMetadataEnd = Addresses[1].start, Addresses[1]['end']
            end
        }, function ()
            error("Много аргументов для функции Il2cpp\nMany arguments for the Il2cpp function")
        end, self, args, {
            FindIl2cpp = function()
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
            end,
            FindGlobalMetaData = function()
                local globalMetadata = gg.getRangesList('global-metadata.dat')
                gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA | gg.REGION_OTHER)
                if (#globalMetadata ~= 0) then gg.searchNumber(':filter_by_type_name',gg.TYPE_BYTE,false,gg.SIGN_EQUAL,globalMetadata[1].start,globalMetadata[#globalMetadata]['end']) end
                if (gg.getResultsCount() == 0 or #globalMetadata == 0) then
                    globalMetadata = {}
                    gg.searchNumber(':filter_by_type_name', gg.TYPE_BYTE)
                    if (gg.getResultsCount() > 0) then
                        gg.searchNumber(':f', gg.TYPE_BYTE)
                        local filter_by_type_name = gg.getResults(gg.getResultsCount())
                        gg.clearResults()
                        for k,v in ipairs(gg.getRangesList()) do
                            if (v.state == 'Ca' or v.state == 'A' or v.state == 'Cd' or v.state == 'Cb' or v.state == 'Ch' or v.state == 'O') then
                                for key, val in ipairs(filter_by_type_name) do
                                    globalMetadata[#globalMetadata + 1] = (Il2CppApi.value(v.start) <= Il2CppApi.value(val.address) and Il2CppApi.value(val.address) < Il2CppApi.value(v['end'])) 
                                        and v 
                                        or nil
                                end
                            end
                        end
                    end
                else gg.clearResults()
                end
                return globalMetadata[1].start, globalMetadata[#globalMetadata]['end']
            end
        })
    end
})