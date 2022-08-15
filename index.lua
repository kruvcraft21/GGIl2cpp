require("until.il2cppconst")
require("il2cpp")

---@class ClassInfoRaw
---@field ClassName string | nil
---@field ClassInfoAddress number

---@class ClassInfo
---@field ClassName string
---@field ClassAddress string
---@field Methods MethodInfo[] | nil
---@field Fields FieldInfo[] | nil
---@field Parent table | nil
---@field ClassNameSpace string
---@field StaticFieldData number | nil
---@field IsEnum boolean
---@field TypeMetadataHandle number
---@field GetFieldWithName fun(self : ClassInfo, name : string) : FieldInfo | nil @Get FieldInfo by Field Name. If Fields weren't dumped, then this function return `nil`. Also, if Field isn't found by name, then function will return `nil`
---@field GetMethodsWithName fun(self : ClassInfo, name : string) : MethodInfo[] | nil @Get MethodInfo[] by MethodName. If Methods weren't dumped, then this function return `nil`. Also, if Method isn't found by name, then function will return `table with zero size`

---@class ParentClassInfo
---@field ClassName string
---@field ClassAddress string

---@class FieldInfoRaw
---@field FieldInfoAddress number
---@field ClassName string | nil

---@class FieldApi
---@field Offset number
---@field Type number
---@field ClassOffset number


---@class ClassApi
---@field NameOffset number
---@field MethodsStep number
---@field CountMethods number
---@field MethodsLink number
---@field FieldsLink number
---@field FieldsStep number
---@field CountFields number
---@field ParentOffset number
---@field NameSpaceOffset number
---@field StaticFieldDataOffset number
---@field EnumType number
---@field EnumRsh number
---@field TypeMetadataHandle number
---@field GetClassName fun(self : ClassApi, ClassAddress : number) : string
---@field GetClassMethods fun(self : ClassApi, MethodsLink : number, Count : number, ClassName : string | nil) : MethodInfo[]


---@class ClassesMemory
---@field Config ClassConfig
---@field SearchResult ClassInfo[]


---@class MethodsApi
---@field ClassOffset number
---@field NameOffset number
---@field ParamCount number
---@field ReturnType number


---@class FieldInfo
---@field ClassName string 
---@field ClassAddress string 
---@field FieldName string
---@field Offset string
---@field IsStatic boolean
---@field Type string
---@field IsConst boolean
---@field GetConstValue fun(self : FieldInfo) : nil | string | number


---@class MethodInfoRaw
---@field MethodName string | nil
---@field Offset number | nil
---@field MethodInfoAddress number
---@field ClassName string | nil
---@field MethodAddress number


---@class ErrorSearch
---@field Error string


---@class MethodInfo : MethodInfoRaw
---@field MethodName string
---@field Offset string
---@field AddressInMemory string
---@field MethodInfoAddress number
---@field ClassName string
---@field ClassAddress string
---@field ParamCount number
---@field ReturnType string


---@class Il2cppApi
---@field FieldApiOffset number
---@field FieldApiType number
---@field FieldApiClassOffset number
---@field ClassApiNameOffset number
---@field ClassApiMethodsStep number
---@field ClassApiCountMethods number
---@field ClassApiMethodsLink number
---@field ClassApiFieldsLink number
---@field ClassApiFieldsStep number
---@field ClassApiCountFields number
---@field ClassApiParentOffset number
---@field ClassApiNameSpaceOffset number
---@field ClassApiStaticFieldDataOffset number
---@field ClassApiEnumType number
---@field ClassApiEnumRsh number
---@field ClassApiTypeMetadataHandle number
---@field MethodsApiClassOffset number
---@field MethodsApiNameOffset number
---@field MethodsApiParamCount number
---@field MethodsApiReturnType number
---@field typeDefinitionsSize number
---@field typeDefinitionsOffset number
---@field stringOffset number
---@field fieldDefaultValuesOffset number
---@field fieldDefaultValuesSize number
---@field fieldAndParameterDefaultValueDataOffset number
---@field TypeApiType number
---@field Il2CppTypeDefinitionApifieldStart number
---@field MetadataRegistrationApitypes number


---@class ClassConfig
---@field Class number | string @Class Name or Address Class
---@field FieldsDump boolean
---@field MethodsDump boolean


---@class Il2CppTypeDefinitionApi
---@field fieldStart number





---@class Il2cppMemory
---@field Methods table<number | string, MethodInfo[] | ErrorSearch>
---@field Classes table<ClassConfig, ClassInfo[] | ErrorSearch>
---@field GetInformaionOfMethod fun(self : Il2cppMemory, searchParam : number | string) : MethodInfo[] | nil | ErrorSearch
---@field SetInformaionOfMethod fun(self : Il2cppMemory, searchParam : string | number, searchResult : MethodInfo[] | ErrorSearch) : void
---@field GetInfoOfClass fun(self : Il2cppMemory, searchParam : number | string) : ClassesMemory | nil
---@field GetInformationOfClass fun(self : Il2cppMemory, searchParam : ClassConfig) : ClassInfo[] | nil | ErrorSearch
---@field SetInformaionOfClass fun(self : Il2cppMemory, searchParam : ClassConfig, searchResult : ClassInfo[] | ErrorSearch) : void

Protect = {
    ErrorHandler = function(err)
        return {Error = err}
    end,
    Call = function(self, fun, ...) 
        return ({xpcall(fun, self.ErrorHandler, ...)})[2]
    end
}

return Il2cpp