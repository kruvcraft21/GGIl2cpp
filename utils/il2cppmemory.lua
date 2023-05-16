-- Memorizing Il2cpp Search Result
---@class Il2cppMemory
---@field Methods table<number | string, MethodMemory>
---@field Classes table<string | number, table<string, ClassInfo[] | ErrorSearch | number | ClassConfig>>
---@field Fields table<number | string, FieldInfo[] | ErrorSearch>
---@field Results table
---@field Types table<number, string>
---@field DefaultValues table<number, string | number>
---@field GetInformaionOfMethod fun(self : Il2cppMemory, searchParam : number | string) : MethodMemory | nil
---@field SetInformaionOfMethod fun(self : Il2cppMemory, searchParam : string | number, searchResult : MethodMemory) : void
---@field GetInfoOfClass fun(self : Il2cppMemory, searchParam : number | string) : ClassesMemory | nil
---@field GetInformationOfClass fun(self : Il2cppMemory, searchParam : string | number) : table<string, ClassInfo[] | ErrorSearch | number | ClassConfig>
---@field SetInformationOfClass fun(self : Il2cppMemory, searchParam : string | number, searchResult : table<string, ClassInfo[] | ErrorSearch | number | ClassConfig>) : void
---@field GetInformationOfField fun(self : Il2cppMemory, searchParam : number | string) : FieldInfo[] | nil | ErrorSearch
---@field SetInformationOfField fun(self : Il2cppMemory, searchParam : string | number, searchResult : FieldInfo[] | ErrorSearch) : void
---@field GetInformationOfType fun(self : Il2cppMemory, index : number) : string | nil
---@field SetInformationOfType fun(self : Il2cppMemory, index : number, typeName : string)
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
    GetInformationOfType = function(self, index)
        return self.Types[index]
    end,


    ---@param self Il2cppMemory
    SetInformationOfType = function(self, index, typeName)
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
    GetInformationOfField = function(self, searchParam)
        return self.Fields[searchParam]
    end,


    ---@param self Il2cppMemory
    ---@param searchParam number | string
    ---@param searchResult FieldInfo[] | ErrorSearch
    SetInformationOfField = function(self, searchParam, searchResult)
        if not searchResult.Error then
            self.Fields[searchParam] = searchResult
        end
    end,


    GetInformaionOfMethod = function(self, searchParam)
        return self.Methods[searchParam]
    end,


    SetInformaionOfMethod = function(self, searchParam, searchResult)
        if not searchResult.Error then
            self.Methods[searchParam] = searchResult
        end
    end,


    GetInformationOfClass = function(self, searchParam)
        return self.Classes[searchParam]
    end,


    SetInformationOfClass = function(self, searchParam, searchResult)
        self.Classes[searchParam] = searchResult
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
