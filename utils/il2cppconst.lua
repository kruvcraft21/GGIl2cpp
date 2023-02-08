local AndroidInfo = require("utils.androidinfo")

---@type table<number, Il2cppApi>
Il2CppConst = {
    [20] = {
        FieldApiOffset = 0xC,
        FieldApiType = 0x4,
        FieldApiClassOffset = 0x8,
        ClassApiNameOffset = 0x8,
        ClassApiMethodsStep = 2,
        ClassApiCountMethods = 0x9C,
        ClassApiMethodsLink = 0x3C,
        ClassApiFieldsLink = 0x30,
        ClassApiFieldsStep = 0x18,
        ClassApiCountFields = 0xA0,
        ClassApiParentOffset = 0x24,
        ClassApiNameSpaceOffset = 0xC,
        ClassApiStaticFieldDataOffset = 0x50,
        ClassApiEnumType = 0xB0,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = 0x2C,
        ClassApiInstanceSize = 0x78,
        ClassApiToken = 0x98,
        MethodsApiClassOffset = 0xC,
        MethodsApiNameOffset = 0x8,
        MethodsApiParamCount = 0x2E,
        MethodsApiReturnType = 0x10,
        MethodsApiFlags = 0x28,
        typeDefinitionsSize = 0x70,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x38,
        MetadataRegistrationApitypes = 0x1C,
    },
    [21] = {
        FieldApiOffset = 0xC,
        FieldApiType = 0x4,
        FieldApiClassOffset = 0x8,
        ClassApiNameOffset = 0x8,
        ClassApiMethodsStep = 2,
        ClassApiCountMethods = 0x9C,
        ClassApiMethodsLink = 0x3C,
        ClassApiFieldsLink = 0x30,
        ClassApiFieldsStep = 0x18,
        ClassApiCountFields = 0xA0,
        ClassApiParentOffset = 0x24,
        ClassApiNameSpaceOffset = 0xC,
        ClassApiStaticFieldDataOffset = 0x50,
        ClassApiEnumType = 0xB0,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = 0x2C,
        ClassApiInstanceSize = 0x78,
        ClassApiToken = 0x98,
        MethodsApiClassOffset = 0xC,
        MethodsApiNameOffset = 0x8,
        MethodsApiParamCount = 0x2E,
        MethodsApiReturnType = 0x10,
        MethodsApiFlags = 0x28,
        typeDefinitionsSize = 0x78,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x40,
        MetadataRegistrationApitypes = 0x1C,
    },
    [22] = {
        FieldApiOffset = 0xC,
        FieldApiType = 0x4,
        FieldApiClassOffset = 0x8,
        ClassApiNameOffset = 0x8,
        ClassApiMethodsStep = 2,
        ClassApiCountMethods = 0x94,
        ClassApiMethodsLink = 0x3C,
        ClassApiFieldsLink = 0x30,
        ClassApiFieldsStep = 0x18,
        ClassApiCountFields = 0x98,
        ClassApiParentOffset = 0x24,
        ClassApiNameSpaceOffset = 0xC,
        ClassApiStaticFieldDataOffset = 0x4C,
        ClassApiEnumType = 0xA9,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = 0x2C,
        ClassApiInstanceSize = 0x70,
        ClassApiToken = 0x90,
        MethodsApiClassOffset = 0xC,
        MethodsApiNameOffset = 0x8,
        MethodsApiParamCount = 0x2E,
        MethodsApiReturnType = 0x10,
        MethodsApiFlags = 0x28,
        typeDefinitionsSize = 0x78,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x40,
        MetadataRegistrationApitypes = 0x1C,
    },
    [23] = {
        FieldApiOffset = 0xC,
        FieldApiType = 0x4,
        FieldApiClassOffset = 0x8,
        ClassApiNameOffset = 0x8,
        ClassApiMethodsStep = 2,
        ClassApiCountMethods = 0x9C,
        ClassApiMethodsLink = 0x40,
        ClassApiFieldsLink = 0x34,
        ClassApiFieldsStep = 0x18,
        ClassApiCountFields = 0xA0,
        ClassApiParentOffset = 0x24,
        ClassApiNameSpaceOffset = 0xC,
        ClassApiStaticFieldDataOffset = 0x50,
        ClassApiEnumType = 0xB1,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = 0x2C,
        ClassApiInstanceSize = 0x78,
        ClassApiToken = 0x98,
        MethodsApiClassOffset = 0xC,
        MethodsApiNameOffset = 0x8,
        MethodsApiParamCount = 0x2E,
        MethodsApiReturnType = 0x10,
        MethodsApiFlags = 0x28,
        typeDefinitionsSize = 104,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x30,
        MetadataRegistrationApitypes = 0x1C,
    },
    [24.1] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x110 or 0xA8,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x114 or 0xAC,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x126 or 0xBE,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xEC or 0x84,
        ClassApiToken = AndroidInfo.platform and 0x10c or 0xa4,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 100,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x2C,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [24] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x114 or 0xAC,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x28 or 0x18,
        ClassApiCountFields = AndroidInfo.platform and 0x118 or 0xB0,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x129 or 0xC1,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF0 or 0x88,
        ClassApiToken = AndroidInfo.platform and 0x110 or 0xa8,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4E or 0x2E,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x48 or 0x28,
        typeDefinitionsSize = 104,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x30,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [24.2] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x118 or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x11c or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x12e or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF4 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x114 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 92,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x24,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [24.3] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x118 or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x11c or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x12e or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF4 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x114 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 92,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x24,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [24.4] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x118 or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x11c or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x12e or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF4 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x114 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 92,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x24,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [24.5] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x118 or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x11c or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x12e or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF4 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x114 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 92,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x24,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [27] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x11C or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x120 or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x132 or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF8 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x118 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 88,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x20,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [27.1] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x11C or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x120 or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x132 or 0xBA,
        ClassApiEnumRsh = 3,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF8 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x118 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 88,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x20,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [27.2] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x11C or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x120 or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x132 or 0xBA,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF8 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x118 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        MethodsApiParamCount = AndroidInfo.platform and 0x4A or 0x2A,
        MethodsApiReturnType = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiFlags = AndroidInfo.platform and 0x44 or 0x24,
        typeDefinitionsSize = 88,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x20,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    },
    [29] = {
        FieldApiOffset = AndroidInfo.platform and 0x18 or 0xC,
        FieldApiType = AndroidInfo.platform and 0x8 or 0x4,
        FieldApiClassOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiNameOffset = AndroidInfo.platform and 0x10 or 0x8,
        ClassApiMethodsStep = AndroidInfo.platform and 3 or 2,
        ClassApiCountMethods = AndroidInfo.platform and 0x11C or 0xA4,
        ClassApiMethodsLink = AndroidInfo.platform and 0x98 or 0x4C,
        ClassApiFieldsLink = AndroidInfo.platform and 0x80 or 0x40,
        ClassApiFieldsStep = AndroidInfo.platform and 0x20 or 0x14,
        ClassApiCountFields = AndroidInfo.platform and 0x120 or 0xA8,
        ClassApiParentOffset = AndroidInfo.platform and 0x58 or 0x2C,
        ClassApiNameSpaceOffset = AndroidInfo.platform and 0x18 or 0xC,
        ClassApiStaticFieldDataOffset = AndroidInfo.platform and 0xB8 or 0x5C,
        ClassApiEnumType = AndroidInfo.platform and 0x132 or 0xBA,
        ClassApiEnumRsh = 2,
        ClassApiTypeMetadataHandle = AndroidInfo.platform and 0x68 or 0x34,
        ClassApiInstanceSize = AndroidInfo.platform and 0xF8 or 0x80,
        ClassApiToken = AndroidInfo.platform and 0x118 or 0xa0,
        MethodsApiClassOffset = AndroidInfo.platform and 0x20 or 0x10,
        MethodsApiNameOffset = AndroidInfo.platform and 0x18 or 0xC,
        MethodsApiParamCount = AndroidInfo.platform and 0x52 or 0x2E,
        MethodsApiReturnType = AndroidInfo.platform and 0x28 or 0x14,
        MethodsApiFlags = AndroidInfo.platform and 0x4C or 0x28,
        typeDefinitionsSize = 88,
        typeDefinitionsOffset = 0xA0,
        stringOffset = 0x18,
        fieldDefaultValuesOffset = 0x40,
        fieldDefaultValuesSize = 0x44,
        fieldAndParameterDefaultValueDataOffset = 0x48,
        TypeApiType = AndroidInfo.platform and 0xA or 0x6,
        Il2CppTypeDefinitionApifieldStart = 0x20,
        MetadataRegistrationApitypes = AndroidInfo.platform and 0x38 or 0x1C,
    }
}


---@class Il2CppFlags
---@field Method MethodFlags
---@field Field FieldFlags
Il2CppFlags = {
    Method = {
        METHOD_ATTRIBUTE_MEMBER_ACCESS_MASK = 0x0007,
        Access = {
            "private", -- METHOD_ATTRIBUTE_PRIVATE
            "internal", -- METHOD_ATTRIBUTE_FAM_AND_ASSEM
            "internal", -- METHOD_ATTRIBUTE_ASSEM
            "protected", -- METHOD_ATTRIBUTE_FAMILY
            "protected internal", -- METHOD_ATTRIBUTE_FAM_OR_ASSEM
            "public", -- METHOD_ATTRIBUTE_PUBLIC
        },
        METHOD_ATTRIBUTE_STATIC = 0x0010,
        METHOD_ATTRIBUTE_ABSTRACT = 0x0400,
    },
    Field = {
        FIELD_ATTRIBUTE_FIELD_ACCESS_MASK = 0x0007,
        Access = {
            "private", -- FIELD_ATTRIBUTE_PRIVATE
            "internal", -- FIELD_ATTRIBUTE_FAM_AND_ASSEM
            "internal", -- FIELD_ATTRIBUTE_ASSEMBLY
            "protected", -- FIELD_ATTRIBUTE_FAMILY
            "protected internal", -- FIELD_ATTRIBUTE_FAM_OR_ASSEM
            "public", -- FIELD_ATTRIBUTE_PUBLIC
        },
        FIELD_ATTRIBUTE_STATIC = 0x0010,
        FIELD_ATTRIBUTE_LITERAL = 0x0040,
    }
}