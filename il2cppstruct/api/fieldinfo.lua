---@type FieldInfo
local FieldInfoApi = {


    ---@param self FieldInfo
    ---@return nil | string | number
    GetConstValue = function(self)
        if self.IsConst then
            local fieldIndex = getmetatable(self).fieldIndex
            return Il2cpp.GlobalMetadataApi:GetDefaultFieldValue(fieldIndex)
        end
        return nil
    end
}

return FieldInfoApi