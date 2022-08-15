local AndroidInfo = require("until.androidinfo")

---@class Searcher
local Searcher = {
    searchWord = ":EnsureCapacity",

    ---@param self Searcher
    FindGlobalMetaData = function(self)
        gg.clearResults()
        gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA |
                         gg.REGION_OTHER)
        local globalMetadata = gg.getRangesList('global-metadata.dat')
        if not self:IsValidData(globalMetadata) then
            globalMetadata = {}
            gg.clearResults()
            gg.searchNumber(self.searchWord, gg.TYPE_BYTE)
            gg.refineNumber(self.searchWord:sub(1, 2), gg.TYPE_BYTE)
            local EnsureCapacity = gg.getResults(gg.getResultsCount())
            gg.clearResults()
            for k, v in ipairs(gg.getRangesList()) do
                if (v.state == 'Ca' or v.state == 'A' or v.state == 'Cd' or v.state == 'Cb' or v.state == 'Ch' or
                    v.state == 'O') then
                    for key, val in ipairs(EnsureCapacity) do
                        globalMetadata[#globalMetadata + 1] =
                            (Il2cpp.FixValue(v.start) <= Il2cpp.FixValue(val.address) and Il2cpp.FixValue(val.address) <
                                Il2cpp.FixValue(v['end'])) and v or nil
                    end
                end
            end
        end
        return globalMetadata[1].start, globalMetadata[#globalMetadata]['end']
    end,

    ---@param self Searcher
    IsValidData = function(self, globalMetadata)
        if #globalMetadata ~= 0 then
            gg.searchNumber(self.searchWord, gg.TYPE_BYTE, false, gg.SIGN_EQUAL, globalMetadata[1].start,
                globalMetadata[#globalMetadata]['end'])
            if gg.getResultsCount() > 0 then
                gg.clearResults()
                return true
            end
        end
        return false
    end,

    FindIl2cpp = function()
        local il2cpp = gg.getRangesList('libil2cpp.so')
        if (#il2cpp == 0) then
            local splitconf = gg.getRangesList('split_config.')
            gg.setRanges(gg.REGION_CODE_APP)
            for k, v in ipairs(splitconf) do
                if (v.state == 'Xa') then
                    gg.searchNumber(':il2cpp', gg.TYPE_BYTE, false, gg.SIGN_EQUAL, v.start, v['end'])
                    if (gg.getResultsCount() > 0) then
                        il2cpp[#il2cpp + 1] = v
                        gg.clearResults()
                    end
                end
            end
        end
        return il2cpp[1].start, il2cpp[#il2cpp]['end']
    end,

    Il2CppMetadataRegistration = function()
        gg.clearResults()
        gg.setRanges(gg.REGION_C_HEAP | gg.REGION_C_ALLOC | gg.REGION_ANONYMOUS | gg.REGION_C_BSS | gg.REGION_C_DATA |
                         gg.REGION_OTHER)
        gg.loadResults({{
            address = Il2cpp.globalMetadataStart,
            flags = Il2cpp.MainType
        }})
        gg.searchPointer(0)
        if gg.getResultsCount() == 0 and AndroidInfo.platform and AndroidInfo.sdk >= 30 then
            gg.searchNumber(tostring(Il2cpp.globalMetadataStart | 0xB400000000000000), Il2cpp.MainType)
        end
        if gg.getResultsCount() > 0 then
            local GlobalMetadataPointers, s_GlobalMetadata = gg.getResults(gg.getResultsCount()), 0
            for i = 1, #GlobalMetadataPointers do
                if i ~= 1 then
                    local difference = GlobalMetadataPointers[i].address - GlobalMetadataPointers[i - 1].address
                    if (difference == Il2cpp.pointSize) then
                        s_GlobalMetadata = Il2cpp.FixValue(gg.getValues({{
                            address = GlobalMetadataPointers[i].address - 0x10,
                            flags = Il2cpp.MainType
                        }})[1].value)
                    end
                end
            end
            return s_GlobalMetadata
        end
        return 0
    end
}

return Searcher
