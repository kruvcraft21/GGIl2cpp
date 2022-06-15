local platform, libil, data, IsSplit = gg.getTargetInfo().x64, gg.getRangesList('libil2cpp.so'), gg.getRangesList('global-metadata.dat'), false

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

Il2CppApi = {
    NameLibIl2cpp = platform and '!/lib/arm64-v8a/libil2cpp.so' or '!/lib/armeabi-v7a/libil2cpp.so',
    NumMethods = platform and 0x11C or 0xA4,
    MethodsLink = platform and 0x98 or 0x4C,
    MethodsStep = platform and 0x8 or 0x4,
    MethodsStep1 = platform and 3 or 2,
    MethodNameOffset = platform and 0x10 or 0x8,
    MethodClassOffset = platform and 0x18 or 0xC,
    NameFucntionOffset = platform and 0x10 or 0x8,
    ClassNameOffset = platform and 0x10 or 0x8, 
    NumFields = platform and 0x120 or 0xA8,
    FieldsLink = platform and 0x80 or 0x40,
    FieldsStep = platform and 0x20 or 0x14,
    FieldsOffset = platform and 0x18 or 0xC,  
    FieldsType = platform and 0x8 or 0x4,
    MainType = platform and gg.TYPE_QWORD or gg.TYPE_DWORD,
    value = function(ret)
        return platform and ret or ret & 0xFFFFFFFF
    end,
    PatchAddres = function(addres, patch, typeset)
        gg.setValues({{address = addres,flags = typeset and typeset or gg.TYPE_DWORD,value = patch:gsub('.', function (c) return string.format('%02X', string.byte(c)) end)..'r'}})
    end,
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
    Utf8ToString = function(Address)
        local bytes, char = {}, {address = Il2CppApi.value(Address), flags = gg.TYPE_BYTE}
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
        local bytes, strAddress = {}, Il2CppApi.value(Address) + (platform and 0x10 or 0x8)
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
    DataCheck = function(address)
        return (Il2CppApi.value(address) > Il2CppApi.value(data[1].start) and Il2CppApi.value(address) < Il2CppApi.value(data[#data]['end']))
    end,
    GetStartLibAddress = function(Address)
        local start = 0
        for k,v in ipairs(libil) do
            if (Il2CppApi.value(Address) > Il2CppApi.value(v.start) and Il2CppApi.value(Address) < Il2CppApi.value(v['end'])) then start = v.start end
        end
        return start
    end,
    SearchFunction = function(self, NameFucntion)
        local FinalMethods, name = {}, "00 " .. NameFucntion:gsub('.', function (c) return string.format('%02X', string.byte(c)) .. " " end) .. "00"
        gg.clearResults()
        gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA | gg.REGION_OTHER)
        gg.searchNumber('h ' .. name, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, data[1].start, data[#data]['end'])
        if gg.getResultsCount() == 0 then error('the "' .. NameFucntion .. '" function was not found') end
        gg.searchNumber('h ' .. string.sub(name,4,5)) 
        local r = gg.getResults(gg.getResultsCount())
        gg.clearResults()
        for key, value in ipairs(r) do
            if gg.BUILD < 16126 then 
                gg.searchNumber(string.format("%8.8X", self.value(value.address)) .. 'h',self.MainType)
            else 
                gg.loadResults({value})
                gg.searchPointer(0)
            end
            local MethodsInfo = gg.getResults(gg.getResultsCount())
            gg.clearResults()
            for k, v in ipairs(MethodsInfo) do
                v.address = v.address - self.MethodNameOffset
                local FinalAddress = self.value(gg.getValues({v})[1].value)
                if (FinalAddress > libil[1].start and FinalAddress < libil[#libil]['end']) then 
                    FinalMethods[#FinalMethods + 1] = {
                        AddressMethod = FinalAddress,
                        Address = v.address
                    }
                end
            end
        end
        if (#FinalMethods == 0) then error('the "' .. NameFucntion .. '" function pointer was not found') end
        return FinalMethods
    end,
    SearchOffset = function(self, off)
        local RetList = {}
        gg.clearResults() 
        gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA | gg.REGION_OTHER | gg.REGION_CODE_APP)
        for k,v in ipairs(IsSplit and libil or {libil[1]}) do
            if gg.BUILD < 16126 then 
                gg.searchNumber(string.format("%8.8X", v.start + off) .. 'h', self.MainType)
            else 
                gg.loadResults(gg.getValues({{address = v.start + off, flags = self.MainType}}))
                gg.searchPointer(0)
            end
            for key, value in ipairs(gg.getResults(gg.getResultsCount())) do
                local NameAddress = self.value(gg.getValues({{address = value.address + self.MethodNameOffset,flags = self.MainType}})[1].value)
                if NameAddress > self.value(data[1].start) and NameAddress < self.value(data[#data]['end']) then
                    local AddressClass = self.value(gg.getValues({{address = value.address + self.MethodClassOffset,flags = self.MainType}})[1].value)
                    RetList[#RetList + 1] = {
                        NameFucntion = self.Utf8ToString(NameAddress),
                        Offset = string.format("%X", off),
                        AddressInMemory = string.format("%X", self.value(value.value)),
                        AddressOffset = value.address,
                        Class = self.Utf8ToString(gg.getValues({{address = AddressClass + self.ClassNameOffset,flags = self.MainType}})[1].value),
                        ClassAddress = string.format('%X', AddressClass)
                    }
                end
            end
        end
        if (#RetList == 0) then error('nothing was found for this offset 0x' .. string.format("%X", off)) end
        return RetList
    end,
    GetNumMethods = function(self, ClassAddress)
        return gg.getValues({{address = ClassAddress + self.NumMethods, flags = gg.TYPE_WORD}})[1].value
    end,
    GetLinkMethods = function(self, ClassAddress)
        return gg.getValues({{address = ClassAddress + self.MethodsLink, flags = self.MainType}})[1].value
    end,
    GetClassesAddress = function(self, name)
        gg.clearResults()
        gg.setRanges(0)
        gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_HEAP | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA | gg.REGION_OTHER | gg.REGION_C_ALLOC)
        gg.searchNumber("Q 00 '" .. name .. "' 00 ",gg.TYPE_BYTE,false,gg.SIGN_EQUAL,data[1].start,data[1]['end'])
        gg.searchPointer(0)
        local ClassNamePoint, ResultTable = gg.getResults(gg.getResultsCount()), {}
        gg.clearResults()
        if (#ClassNamePoint > 0) then
            for k,v in ipairs(ClassNamePoint) do
                local MainClass = gg.getValues({{address = v.address - self.ClassNameOffset,flags = v.flags}})[1]
                local assembly = self.value(MainClass.value)
                if (self.DataCheck(gg.getValues({{address = assembly,flags = v.flags}})[1].value)) then ResultTable[#ResultTable + 1] = self.value(MainClass.address) end
            end
        end
        return ResultTable
    end,
    GetMethodsInfoInClass = function(self, AddressClass, ClassName)
        local MethodsCount, MethodsLink, RetTable = self:GetNumMethods(AddressClass), self:GetLinkMethods(AddressClass), {}
        for i = 0, MethodsCount - 1 do
            -- local method = self.value(gg.getValues({{address = MethodsLink + (i * self.MethodsStep), flags = self.MainType}})[1].value)
            local method = self.value(gg.getValues({{address = MethodsLink + (i << self.MethodsStep1), flags = self.MainType}})[1].value)
            local methodInfo = gg.getValues({
                {--AddressInMemory
                    address = method,
                    flags = self.MainType
                },
                {--NameFunction
                    address = method + self.NameFucntionOffset,
                    flags = self.MainType
                }
            })
            RetTable[#RetTable + 1] = {
                NameFucntion = self.Utf8ToString(self.value(methodInfo[2].value)),
                AddressInMemory = string.format("%X", self.value(methodInfo[1].value)),
                AddressOffset = method,
                Offset = string.format("%X",self.value(methodInfo[1].value) - Il2CppApi.GetStartLibAddress(methodInfo[1].value)),
                Class = ClassName,
                ClassAddress = string.format('%X', AddressClass)
            }
        end
        return RetTable, MethodsCount
    end,
    GetNumFields = function(self, ClassAddress)
        return gg.getValues({{address = ClassAddress + self.NumFields, flags = gg.TYPE_WORD}})[1].value
    end,
    GetLinkFields = function(self, ClassAddress)
        return gg.getValues({{address = ClassAddress + self.FieldsLink, flags = self.MainType}})[1].value
    end,
    GetFieldsInfoInClass = function(self, AddressClass, ClassName)
        local FieldsCount, FieldsLink, RetTable = self:GetNumFields(AddressClass), self.value(self:GetLinkFields(AddressClass)), {}
        for i = 0, FieldsCount - 1 do
            local field = FieldsLink + (i * self.FieldsStep)
            local fieldInfo = gg.getValues({
                {--NameField
                    address = field,
                    flags = self.MainType
                },
                {--Offset
                    address = field + self.FieldsOffset,
                    flags = gg.TYPE_WORD
                },
                {--FieldType
                    address = field + self.FieldsType,
                    flags = self.MainType
                }
            })
            RetTable[#RetTable + 1] = {
                Class = ClassName,
                ClassAddress = string.format('%X', AddressClass),
                NameField = self.Utf8ToString(self.value(fieldInfo[1].value)),
                Offset = string.format('%X', fieldInfo[2].value),
                IsStatic = (gg.getValues({{address = self.value(fieldInfo[3].value) + self.FieldsType, flags = gg.TYPE_WORD}})[1].value & 0x10) ~= 0
            }
        end
        return RetTable, FieldsCount
    end,
    GetClassInfo = function(self, ClassName, FieldsInfo, MethodsInfo)
        local AddressClasses, RetTable = self:GetClassesAddress(ClassName), {Methods = {}, Fields = {}}
        for k,v in ipairs(AddressClasses) do
            if (MethodsInfo) then
                local MethodsTable, MethodsCount = self:GetMethodsInfoInClass(v, ClassName)
                table.move(MethodsTable, 1, MethodsCount, #RetTable.Methods + 1, RetTable.Methods)
            end
            if (FieldsInfo) then
                local FieldsTable, FieldsCount = self:GetFieldsInfoInClass(v, ClassName)
                table.move(FieldsTable, 1, FieldsCount, #RetTable.Fields + 1, RetTable.Fields)
            end
        end
        if (#RetTable.Methods == 0 and #RetTable.Fields == 0) then error('the "' .. ClassName .. '" not found') end
        return RetTable
    end,
}

Protect = {
    ErrorHandler = function(err)
        return {Error = err}
    end,
    Call = function(self, fun, ...) 
        return ({xpcall(fun, self.ErrorHandler, ...)})[2]
    end
}

if #libil == 0 then
    IsSplit = true
    local splitconf = gg.getRangesList('split_config.')
    gg.setRanges(gg.REGION_CODE_APP)
    for k,v in ipairs(splitconf) do
        if (v.state == 'Xa') then
            gg.searchNumber(':il2cpp',gg.TYPE_BYTE,false,gg.SIGN_EQUAL,v.start,v['end'])
            if (gg.getResultsCount() > 0) then
                libil[#libil + 1] = v
                gg.clearResults()
            end
        end
    end
end

function CheckIsValidData() 
    gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA | gg.REGION_OTHER)
    if (#data ~= 0) then gg.searchNumber(':filter_by_type_name',gg.TYPE_BYTE,false,gg.SIGN_EQUAL,data[1].start,data[#data]['end']) end
    if (gg.getResultsCount() == 0 or #data == 0) then
        data = {}
        gg.searchNumber(':filter_by_type_name', gg.TYPE_BYTE)
        if (gg.getResultsCount() > 0) then
            gg.searchNumber(':f', gg.TYPE_BYTE)
            local filter_by_type_name = gg.getResults(gg.getResultsCount())
            gg.clearResults()
            for k,v in ipairs(gg.getRangesList()) do
                if (v.state == 'Ca' or v.state == 'A' or v.state == 'Cd' or v.state == 'Cb' or v.state == 'Ch' or v.state == 'O') then
                    for key, val in ipairs(filter_by_type_name) do
                        data[#data + 1] = (Il2CppApi.value(v.start) <= Il2CppApi.value(val.address) and Il2CppApi.value(val.address) < Il2CppApi.value(v['end'])) 
                            and v 
                            or nil
                    end
                end
            end
        end
    else gg.clearResults()
    end
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

function il2cpp(...)
    args = {...}
    if #args < 2 then return {},"you didn't enter the function" end 
    local finaladdres = Protect:Call(Il2CppApi.SearchFunction, Il2CppApi, args[1])
    for k,v in pairs(finaladdres) do
        if (k ~= 'Error') then 
            for i = 2,#args do
                if i ~= 2 then v.AddressMethod = v.AddressMethod + 0x4 end
                Il2CppApi.PatchAddres(v.AddressMethod, args[i])
            end
        end
    end
    return 'true'
end

function il2cppfunc(...)
    local args, RetIl2CppFuncs = {...}, {}
    if args[1] == nil or args[1] == "" or args[1] == " " then return {},"you didn't enter the function" end 
    for keyname,namefucntion in ipairs(args) do
        local finaladdres = Protect:Call(Il2CppApi.SearchFunction, Il2CppApi, namefucntion)
        for k,v in pairs(finaladdres) do
            if (k ~= 'Error') then
                local AddressClass = Il2CppApi.value(gg.getValues({{address = v.Address + Il2CppApi.MethodClassOffset,flags = Il2CppApi.MainType}})[1].value)
                RetIl2CppFuncs[#RetIl2CppFuncs + 1] = {
                    NameFucntion = namefucntion,
                    Offset = string.format("%X",v.AddressMethod - Il2CppApi.GetStartLibAddress(v.AddressMethod)),
                    AddressInMemory = string.format("%X",v.AddressMethod),
                    AddressOffset = v.Address,
                    Class = Il2CppApi.Utf8ToString(gg.getValues({{address = AddressClass + Il2CppApi.ClassNameOffset, flags = Il2CppApi.MainType}})[1].value),
                    ClassAddress = string.format('%X', AddressClass)
                }
            else
                RetIl2CppFuncs[#RetIl2CppFuncs + 1] = {
                    NameFucntion = namefucntion,
                    Error = v
                }
            end
        end
    end
    return RetIl2CppFuncs,'true'
end

function offsets(...)
    local retaddress, args = {}, {...}  
    if #args == 0 then return {},"you didn't enter offsets" end 
    if (IsSplit) then gg.alert("ДЛЯ ИГРЫ, КОТОРАЯ РАЗДЕЛЕНА, API БУДЕТ ДОЛГО РАБОТАТЬ\nFOR A GAME THAT IS SPLIT, THE API WILL TAKE A LONG TIME TO WORK") end
    for keyOff, Off in pairs(args) do
        local FinalAddress = Protect:Call(Il2CppApi.SearchOffset, Il2CppApi, Off)
        for k, v in pairs(FinalAddress) do
            retaddress[#retaddress + 1] = (k ~= 'Error') and v or {Offset = string.format("%X", Off), Error = v}
        end
    end
    gg.clearResults() 
    return retaddress,'true'
end

function Il2cppClassesInfo(tab)
    local retaddress = {}
    if #tab == 0 or type(tab) ~= 'table' then return {},"you didn't enter class name" end 
    for keyClass, Class in pairs(tab) do
        local FinalInfo = Protect:Call(Il2CppApi.GetClassInfo, Il2CppApi, Class.ClassName, Class.FieldsDump, Class.MethodsDump)
        retaddress[#retaddress + 1] = (FinalInfo['Error']) and {ClassName = Class.ClassName, Error = FinalInfo['Error']} or FinalInfo
    end
    gg.clearResults() 
    return retaddress,'true'
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
    FindMethods = function(...)
        local searchArgs, resultSearch = {...}, {}
        for i = 1, #searchArgs do
            resultSearch[i] = Il2cpp.MethodsApi.Find(Il2cpp.MethodsApi, searchArgs[i])
        end
        return resultSearch
    end,
    FindClass = function(...)
        local searchArgs, resultSearch = {...}, {}
        for i = 1, #searchArgs do
            local tmpResult = Il2cpp.ClassApi.Find(Il2cpp.ClassApi, searchArgs[i])
            table.move(tmpResult, 1, #tmpResult, #resultSearch + 1, resultSearch)
        end
        return resultSearch
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
    FixValue = function(val)
        return platform and val or val & 0xFFFFFFFF
    end,
    MainType = platform and gg.TYPE_QWORD or gg.TYPE_DWORD,
    DataCheck = function(address)
        return (Il2CppApi.value(address) > Il2CppApi.value(data[1].start) and Il2CppApi.value(address) < Il2CppApi.value(data[#data]['end']))
    end,
    GetStartLibAddress = function(Address)
        local start = 0
        for k,v in ipairs(libil) do
            if (Il2cpp.FixValue(Address) > Il2cpp.FixValue(v.start) and Il2cpp.FixValue(Address) < Il2cpp.FixValue(v['end'])) then start = v.start end
        end
        return start
    end,
    FieldApi = {
        Offset = platform and 0x18 or 0xC,
        Type = platform and 0x8 or 0x4,
        ClassOffset = platform and 0x10 or 0x8, 
        UnpackFieldInfo = function(self, FieldInfo)
            local _FieldInfo = gg.getValues({
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
            })
            return {
                ClassName = FieldInfo.ClassName or Il2cpp.Utf8ToString(gg.getValues({{address = _FieldInfo[4].value + Il2cpp.ClassApi.NameOffset, flags = Il2cpp.MainType}})[1].value),
                ClassAddress = string.format('%X', Il2cpp.FixValue(_FieldInfo[3].value)),
                FieldName = Il2cpp.Utf8ToString(_FieldInfo[1].value),
                Offset = string.format('%X', _FieldInfo[2].value),
                IsStatic = (gg.getValues({{address = Il2cpp.FixValue(_FieldInfo[3].value) + self.Type, flags = gg.TYPE_WORD}})[1].value & 0x10) ~= 0
            }
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
                MethodInfo, _MethodsInfo[#_MethodsInfo + 1] = Il2cpp.MethodsApi:UnpackMethodInfo({MethodInfoAddress = Il2cpp.FixValue(_MethodsInfo[i].value), ClassName = ClassName})
                table.move(MethodInfo, 1, #MethodInfo, #MethodsInfo + 1, MethodsInfo)
            end
            MethodsInfo = gg.getValues(MethodsInfo)
            _MethodsInfo = Il2cpp.MethodsApi:DecodeMethodsInfo(_MethodsInfo, MethodsInfo)
            return _MethodsInfo
        end,
        GetClassFields = function(self, FieldsLink, Count, ClassName)
            local FieldsInfo = {}
            for i = 0, Count - 1 do
                FieldsInfo[#FieldsInfo + 1] = {
                    address = FieldsLink + (i * self.FieldsStep),
                    flags = Il2cpp.MainType
                }
            end
            FieldsInfo = gg.getValues(FieldsInfo)
            for i = 1, #FieldsInfo do
                FieldsInfo[i] = Il2cpp.FieldApi:UnpackFieldInfo({FieldInfoAddress = Il2cpp.FixValue(FieldsInfo[i].address), ClassName = ClassName})
            end
            return FieldsInfo
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
            gg.searchNumber("Q 00 '" .. ClassName .. "' 00 ",gg.TYPE_BYTE,false,gg.SIGN_EQUAL,data[1].start,data[1]['end'])
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
            gg.searchNumber('h ' .. name, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, data[1].start, data[#data]['end'])
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
                    if (FinalAddress > libil[1].start and FinalAddress < libil[#libil]['end']) then 
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
            for k,v in ipairs(IsSplit and libil or {libil[1]}) do
                local tmpMethodsInfo = self.FindMethodWithAddressInMemory(v.start + MethodOffset, MethodOffset)
                table.move(tmpMethodsInfo, 1, #tmpMethodsInfo, #MethodsInfo + 1, MethodsInfo)
            end
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
                    Offset = _MethodsInfo[i].Offset or string.format("%X", MethodAddress - Il2cpp.GetStartLibAddress(MethodAddress)),
                    AddressInMemory = string.format("%X", MethodAddress),
                    MethodInfoAddress = _MethodsInfo[i].MethodInfoAddress,
                    ClassName = _MethodsInfo[i].ClassName or Il2cpp.Utf8ToString(gg.getValues({{address = Il2cpp.FixValue(MethodsInfo[index + 3].value) + Il2cpp.ClassApi.NameOffset,flags = Il2cpp.MainType}})[1].value),
                    ClassAddress = string.format('%X', Il2cpp.FixValue(MethodsInfo[index + 3].value)),
                    ParamCount = MethodsInfo[index + 4].value
                }
            end
            return _MethodsInfo
        end,
        UnpackMethodInfo = function(self, MethodInfo)
            -- local _MethodInfo = gg.getValues({
            --     { -- Address Method in Memory
            --         address = MethodInfo.MethodInfoAddress,
            --         flags = Il2cpp.MainType
            --     },
            --     { -- Name Address
            --         address = MethodInfo.MethodInfoAddress + self.NameOffset,
            --         flags = Il2cpp.MainType
            --     },
            --     { -- Class address
            --         address = MethodInfo.MethodInfoAddress + self.ClassOffset,
            --         flags = Il2cpp.MainType
            --     },
            --     { -- Param Count
            --         address = MethodInfo.MethodInfoAddress + self.ParamCount,
            --         flags = gg.TYPE_WORD
            --     }
            -- })
            -- MethodInfo.MethodAddress = MethodInfo.MethodAddress or Il2cpp.FixValue(_MethodInfo[1].value)
            -- return {
            --     MethodName = MethodInfo.MethodName or Il2cpp.Utf8ToString(_MethodInfo[2].value),
            --     Offset = MethodInfo.Offset or string.format("%X", MethodInfo.MethodAddress - Il2cpp.GetStartLibAddress(MethodInfo.MethodAddress)),
            --     AddressInMemory = string.format("%X", MethodInfo.MethodAddress),
            --     MethodInfoAddress = MethodInfo.MethodInfoAddress,
            --     ClassName = MethodInfo.ClassName or Il2cpp.Utf8ToString(gg.getValues({{address = Il2cpp.FixValue(_MethodInfo[3].value) + Il2cpp.ClassApi.NameOffset,flags = Il2cpp.MainType}})[1].value),
            --     ClassAddress = string.format('%X', Il2cpp.FixValue(_MethodInfo[3].value)),
            --     ParamCount = _MethodInfo[4].value
            -- }
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
                    return Protect:Call(self.FindMethodWithOffset, self, method)
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
                    MethodInfo, _MethodsInfo[k] = self:UnpackMethodInfo(MethodsInfo[k])
                    table.move(MethodInfo, 1, #MethodInfo, #MethodsInfo + 1, MethodsInfo)
                end
                MethodsInfo = gg.getValues(MethodsInfo)
                _MethodsInfo = self:DecodeMethodsInfo(_MethodsInfo, MethodsInfo)
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
                end
                gg.clearResults()
                return globalMetadata[1].start, globalMetadata[#globalMetadata]['end']
            end
        })
    end
})