--[[
    Use this to add new sidebar containers
]]--

function onInit()
	LibraryData.aRecords["moves"] =
    {
        bExport = true,
        aDataMap = { "moves", "reference.moves" },
        sEditMode = "play",
        aDisplayIcon = { "button_sidebar_dockitem", "button_sidebar_dockitem_down" },
        sRecordDisplayClass = "move_sheet",
    }
end