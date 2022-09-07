-- Memorizing Il2cpp Search Result
---@class Il2cppMemory
---@field Methods table<number | string, MethodInfo[] | ErrorSearch>
---@field Classes table<ClassConfig, ClassInfo[] | ErrorSearch>
---@field Fields table<number | string, FieldInfo[] | ErrorSearch>
---@field GetInformaionOfMethod fun(self : Il2cppMemory, searchParam : number | string) : MethodInfo[] | nil | ErrorSearch
---@field SetInformaionOfMethod fun(self : Il2cppMemory, searchParam : string | number, searchResult : MethodInfo[] | ErrorSearch) : void
---@field GetInfoOfClass fun(self : Il2cppMemory, searchParam : number | string) : ClassesMemory | nil
---@field GetInformationOfClass fun(self : Il2cppMemory, searchParam : ClassConfig) : ClassInfo[] | nil | ErrorSearch
---@field SetInformaionOfClass fun(self : Il2cppMemory, searchParam : ClassConfig, searchResult : ClassInfo[] | ErrorSearch) : void
---@field GetInformaionOfField fun(self : Il2cppMemory, searchParam : number | string) : FieldInfo[] | nil | ErrorSearch
---@field SetInformaionOfField fun(self : Il2cppMemory, searchParam : string | number, searchResult : FieldInfo[] | ErrorSearch) : void
local Il2cppMemory = {
    Methods = {},
    Classes = {},
    Fields = {},


    ---@param self Il2cppMemory
    ---@param searchParam number | string
    ---@return FieldInfo[] | nil | ErrorSearch
    GetInformaionOfField = function(self, searchParam)
        return self.Fields[searchParam]
    end,


    ---@param self Il2cppMemory
    ---@param searchParam number | string
    ---@param searchResult FieldInfo[] | ErrorSearch
    SetInformaionOfField = function(self, searchParam, searchResult)
        self.Fields[searchParam] = searchResult
    end,


    GetInformaionOfMethod = function(self, searchParam)
        return self.Methods[searchParam]
    end,


    SetInformaionOfMethod = function(self, searchParam, searchResult)
        self.Methods[searchParam] = searchResult
    end,


    GetInfoOfClass = function(self, searchParam)
        return self.Classes[searchParam]
    end,


    GetInformationOfClass = function(self, searchParam)
        local ClassMemory = self:GetInfoOfClass(searchParam.Class)
        if not (ClassMemory and
            (ClassMemory.Config.FieldsDump == searchParam.FieldsDump and ClassMemory.Config.MethodsDump ==
                searchParam.MethodsDump)) then
            return nil
        end
        return ClassMemory.SearchResult
    end,


    SetInformaionOfClass = function(self, searchParam, searchResult)
        self.Classes[searchParam.Class] = {
            Config = {
                FieldsDump = searchParam.FieldsDump and true or false,
                MethodsDump = searchParam.MethodsDump and true or false
            },
            SearchResult = searchResult
        }
    end
}

return Il2cppMemory
