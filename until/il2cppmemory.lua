-- Memorizing Il2cpp Search Result
---@class Il2cppMemory
local Il2cppMemory = {
    Methods = {},
    Classes = {},


    ---@param self Il2cppMemory
    ---@param searchParam number | string
    ---@return MethodInfo[] | nil | ErrorSearch
    GetInformaionOfMethod = function (self, searchParam)
        return self.Methods[searchParam]
    end,


    ---@param self Il2cppMemory
    ---@param searchParam string | number
    ---@param searchResult MethodInfo[] | ErrorSearch
    SetInformaionOfMethod = function(self, searchParam, searchResult)
        self.Methods[searchParam] = searchResult
    end,


    ---@param self Il2cppMemory
    ---@param searchParam number | string
    ---@return ClassesMemory | nil
    GetInfoOfClass = function (self, searchParam)
        return self.Classes[searchParam]
    end,


    ---@param self Il2cppMemory
    ---@param searchParam ClassConfig
    ---@return ClassInfo[] | nil | ErrorSearch
    GetInformationOfClass = function(self, searchParam)
        ---@type ClassesMemory | nil
        local ClassMemory = self:GetInfoOfClass(searchParam.Class)
        if not(ClassMemory and (ClassMemory.Config.FieldsDump == searchParam.FieldsDump and ClassMemory.Config.MethodsDump == searchParam.MethodsDump)) then
            return nil
        end
        return ClassMemory.SearchResult
    end,


    ---@param self Il2cppMemory
    ---@param searchParam ClassConfig
    ---@param searchResult ClassInfo[] | ErrorSearch
    SetInformaionOfClass = function(self, searchParam, searchResult)
        self.Classes[searchParam.Class] = {
            Config = {
                FieldsDump = searchParam.FieldsDump and true or false,
                MethodsDump = searchParam.MethodsDump and true or false
            },
            SearchResult = searchResult
        }
    end,
}

return Il2cppMemory