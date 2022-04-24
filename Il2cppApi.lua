local platform, libil, data, IsSplit = gg.getTargetInfo().x64, gg.getRangesList('libil2cpp.so'), gg.getRangesList('global-metadata.dat'), false

Il2CppApi = {
    Offset1 = platform and 0x10 or 0x8,
    Offset2 = platform and '!/lib/arm64-v8a/libil2cpp.so' or '!/lib/armeabi-v7a/libil2cpp.so',
    Offset3 = platform and 0x8 or 0x4,
    Offset4 = platform and 0x18 or 0xC,
    Offset5 = platform and 0xC or 0x8,
    NumMethods = platform and 0x11C or 0xA4,
    MethodsLink = platform and 0x98 or 0x4C,
    MethodsStep = platform and 0x8 or 0x4,
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
    IsClass = function(address)
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
                v.address = v.address - self.Offset1
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
                local NameAddress = self.value(gg.getValues({{address = value.address + self.Offset1,flags = self.MainType}})[1].value)
                if NameAddress > self.value(data[1].start) and NameAddress < self.value(data[#data]['end']) then
                    local AddressClass = self.value(gg.getValues({{address = value.address + self.Offset4,flags = self.MainType}})[1].value)
                    RetList[#RetList + 1] = {
                        NameFucntion = self.Utf8ToString(NameAddress),
                        Offset = string.format("%X", off),
                        AddressInMemory = string.format("%X", self.value(value.value)),
                        AddressOffset = value.address,
                        Class = self.Utf8ToString(gg.getValues({{address = AddressClass + self.Offset1,flags = self.MainType}})[1].value),
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
        if (#ClassNamePoint > 1) then
            for k,v in ipairs(ClassNamePoint) do
                local MainClass = gg.getValues({{address = v.address - self.ClassNameOffset,flags = v.flags}})[1]
                local assembly = self.value(MainClass.value)
                if (self.IsClass(gg.getValues({{address = assembly,flags = v.flags}})[1].value)) then ResultTable[#ResultTable + 1] = self.value(MainClass.address) end
            end
        end
        return ResultTable
    end,
    GetMethodsInfoInClass = function(self, AddressClass, ClassName)
        local MethodsCount, MethodsLink, RetTable = self:GetNumMethods(AddressClass), self:GetLinkMethods(AddressClass), {}
        for i = 1, MethodsCount do
            local method = self.value(gg.getValues({{address = MethodsLink + ((i - 1) * self.MethodsStep), flags = self.MainType}})[1].value)
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
        for i = 1, FieldsCount do
            local field = FieldsLink + ((i-1) * self.FieldsStep)
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
                local AddressClass = Il2CppApi.value(gg.getValues({{address = v.Address + Il2CppApi.Offset4,flags = Il2CppApi.MainType}})[1].value)
                RetIl2CppFuncs[#RetIl2CppFuncs + 1] = {
                    NameFucntion = namefucntion,
                    Offset = string.format("%X",v.AddressMethod - Il2CppApi.GetStartLibAddress(v.AddressMethod)),
                    AddressInMemory = string.format("%X",v.AddressMethod),
                    AddressOffset = v.Address,
                    Class = Il2CppApi.Utf8ToString(gg.getValues({{address = AddressClass + Il2CppApi.Offset1, flags = Il2CppApi.MainType}})[1].value),
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

function Il2cppClassesInfo(...)
    local retaddress, args = {}, {...}
    if #args == 0 then return {},"you didn't enter offsets" end 
    for keyClass, NameClass in pairs(args) do
        local FinalInfo = Protect:Call(Il2CppApi.GetClassInfo, Il2CppApi, NameClass, true, true)
        if (FinalInfo['Error']) then
            retaddress[#retaddress + 1] = {ClassName = NameClass, Error = FinalInfo['Error']}
        else
            retaddress[#retaddress + 1] = FinalInfo
        end
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