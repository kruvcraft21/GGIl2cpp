io.open('il2cppapi.lua',"w+"):write(gg.makeRequest("https://raw.githubusercontent.com/kruvcraft21/GGIl2cpp/master/Il2cppApi.lua").content):close()
require('il2cppapi')
os.remove('il2cppapi.lua')

Il2cpp()

---@type ClassConfig
local TestClassConfig = {}

TestClassConfig.Class = "TestClass"
TestClassConfig.FieldsDump = true
TestClassConfig.MethodsDump = true

local TestClasses = Il2cpp.FindClass({TestClassConfig})[1]

local ChangeTestClasses = {}

print(TestClasses)

for k,v in ipairs(TestClasses) do
    local TestClassObject = Il2cpp.FindObject({tonumber(v.ClassAddress, 16)})[1]
    if #v.Fields > 1 then
        for i = 1, #TestClassObject do
            ChangeTestClasses[#ChangeTestClasses + 1] = {
                address = TestClassObject[i].address + tonumber(v:GetFieldWithName("field1").Offset, 16),
                flags = gg.TYPE_DWORD,
                value = 40
            }
            ChangeTestClasses[#ChangeTestClasses + 1] = {
                address = TestClassObject[i].address + tonumber(v:GetFieldWithName("field2").Offset, 16),
                flags = gg.TYPE_FLOAT,
                value = 33
            }
        end
    
        ChangeTestClasses[#ChangeTestClasses + 1] = {
            address = v.StaticFieldData + tonumber(v:GetFieldWithName("field3").Offset, 16),
            flags = gg.TYPE_DWORD,
            value = 12
        }
    end

end

gg.setValues(ChangeTestClasses)

for k,v in ipairs(TestClasses) do
    if v.Methods then
        local Methods = v:GetMethodsWithName("GetField4")
        for i = 1, #Methods do
            Il2cpp.PatchesAddress(tonumber(Methods[i].AddressInMemory, 16), Il2cpp.MainType == gg.TYPE_QWORD and "\x40\x02\x80\x52\xc0\x03\x5f\xd6" or "\x12\x00\xa0\xe3\x1e\xff\x2f\xe1")
        end
    end
end