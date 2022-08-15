-- Memorizing Il2cpp Search Result
---@type Il2cppMemory
local Il2cppMemory = {
    Methods = {},
    Classes = {},


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
