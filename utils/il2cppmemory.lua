-- Memorizing Il2cpp Search Result
---@class Il2cppMemory
---@field Methods table<number | string, MethodInfo[] | ErrorSearch>
---@field Classes table<ClassConfig, ClassInfo[] | ErrorSearch>
---@field Fields table<number | string, FieldInfo[] | ErrorSearch>
---@field Results table
---@field Types table<number, string>
---@field DefaultValues table<number, string | number>
---@field GetInformaionOfMethod fun(self : Il2cppMemory, searchParam : number | string) : MethodInfo[] | nil | ErrorSearch
---@field SetInformaionOfMethod fun(self : Il2cppMemory, searchParam : string | number, searchResult : MethodInfo[] | ErrorSearch) : void
---@field GetInfoOfClass fun(self : Il2cppMemory, searchParam : number | string) : ClassesMemory | nil
---@field GetInformationOfClass fun(self : Il2cppMemory, searchParam : ClassConfig) : ClassInfo[] | nil | ErrorSearch
---@field SetInformaionOfClass fun(self : Il2cppMemory, searchParam : ClassConfig, searchResult : ClassInfo[] | ErrorSearch) : void
---@field GetInformaionOfField fun(self : Il2cppMemory, searchParam : number | string) : FieldInfo[] | nil | ErrorSearch
---@field SetInformaionOfField fun(self : Il2cppMemory, searchParam : string | number, searchResult : FieldInfo[] | ErrorSearch) : void
---@field GetInformaionOfType fun(self : Il2cppMemory, index : number) : string | nil
---@field SetInformaionOfType fun(self : Il2cppMemory, index : number, typeName : string)
---@field SaveResults fun(self : Il2cppMemory) : void
---@field ClearSavedResults fun(self : Il2cppMemory) : void
local Il2cppMemory = {
    Methods = {},
    Classes = {},
    Fields = {},
    DefaultValues = {},
    Results = {},
    Types = {},


    ---@param self Il2cppMemory
    ---@return nil | string
    GetInformaionOfType = function(self, index)
        return self.Types[index]
    end,


    ---@param self Il2cppMemory
    SetInformaionOfType = function(self, index, typeName)
        self.Types[index] = typeName
    end,

    ---@param self Il2cppMemory
    SaveResults = function(self)
        if gg.getResultsCount() > 0 then
            self.Results = gg.getResults(gg.getResultsCount())
        end
    end,


    ---@param self Il2cppMemory
    ClearSavedResults = function(self)
        self.Results = {}
    end,


    ---@param self Il2cppMemory
    ---@param fieldIndex number
    ---@return string | number | nil
    GetDefaultValue = function(self, fieldIndex)
        return self.DefaultValues[fieldIndex]
    end,


    ---@param self Il2cppMemory
    ---@param fieldIndex number
    ---@param defaultValue number | string | nil
    SetDefaultValue = function(self, fieldIndex, defaultValue)
        self.DefaultValues[fieldIndex] = defaultValue or "nil"
    end,


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
                FieldsDump = searchParam.FieldsDump and true,
                MethodsDump = searchParam.MethodsDump and true
            },
            SearchResult = searchResult
        }
    end,


    ---@param self Il2cppMemory
    ---@return void
    ClearMemorize = function(self)
        self.Methods = {}
        self.Classes = {}
        self.Fields = {}
        self.DefaultValues = {}
        self.Results = {}
        self.Types = {}
    end
}

return Il2cppMemory
