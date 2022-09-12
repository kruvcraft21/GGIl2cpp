local AndroidInfo = require("utils.androidinfo")

---@class StringApi
---@field Utf16 table
local StringApi = {


    ---@param self StringApi
    CreateAlf = function(self)
        local Utf16 = {}
        for s in string.gmatch('АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя', "..") do
            local char = gg.bytes(s,'UTF-16LE')
            Utf16[char[1] + (char[2] * 256)] = s
        end
        for s in string.gmatch("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_/0123456789-'", ".") do
            local char = gg.bytes(s,'UTF-16LE')
            Utf16[char[1] + (char[2] * 256)] = s
        end
        self.Utf16 = Utf16
    end,


    ---@param self StringApi
    ---@param Address number
    ReadString = function(self, Address)
        if not self.Utf16 then
            self:CreateAlf()
        end
        local bytes, strAddress = {}, Il2cpp.FixValue(Address) + (AndroidInfo.platform and 0x10 or 0x8)
        local num = gg.getValues({{
            address = strAddress,
            flags = gg.TYPE_DWORD
        }})[1].value
        if num > 0 and num < 200 then
            for i = 1, num + 1 do
                bytes[#bytes + 1] = {
                    address = strAddress + (i << 1),
                    flags = gg.TYPE_WORD
                }
            end
            bytes = gg.getValues(bytes)
            for i, v in ipairs(bytes) do
                bytes[i] = v.value == 32 and " " or (self.Utf16[v.value] or "")
            end
            return table.concat(bytes)
        end
        return ""
    end
}

return StringApi