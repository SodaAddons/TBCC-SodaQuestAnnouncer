local addon = LibStub("AceAddon-3.0"):NewAddon("SQADB")
local icon = LibStub("LibDBIcon-1.0")

local SQALDB = LibStub("LibDataBroker-1.1"):NewDataObject("SQA!", {
  type = "data source",
  text = "SQA!",
  icon = "Interface\\Icons\\INV_Misc_Gem_Pearl_06",
  OnTooltipShow = function(tooltip)
    tooltip:AddLine("SQA")
    if SQAIsEnabled then
      tooltip:AddLine("Announcing quests")
    else
      tooltip:AddLine("Announcing disabled")
    end
  end,
})

function SQALDB:OnClick()
    SQAIsEnabled = not SQAIsEnabled
    SQALDB.icon = SQAIsEnabled and "Interface\\Icons\\INV_Misc_Gem_Pearl_06" or "Interface\\Icons\\INV_Misc_Gem_Pearl_05"
    SQALDB.text = SQAIsEnabled and "Quest announcement enabled" or "Quest announcement disabled"
    --print(SQAIsEnabled)
end

function addon:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("SQADB", { profile = { minimap = { hide = false, }, }, }) icon:Register("SQA!", SQALDB, self.db.profile.minimap)
    SQALDB.icon = SQAIsEnabled and "Interface\\Icons\\INV_Misc_Gem_Pearl_06" or "Interface\\Icons\\INV_Misc_Gem_Pearl_05"
end


local frame = CreateFrame("FRAME", "myFrame")
frame:RegisterEvent("QUEST_WATCH_UPDATE")
frame:RegisterEvent("QUEST_LOG_UPDATE")
frame:RegisterEvent("QUEST_TURNED_IN")
frame:RegisterEvent("UI_INFO_MESSAGE")

SLASH_SQA1 = "/SQA"

local function MyCommands(msg, editbox)
    local case, text = strsplit(" ", msg, 2)
    if case == "enable" then
        SQAIsEnabled = true
    end
    if case == "disable" then
        SQAIsEnabled = false
    end
    if case == "" then
        SQAIsEnabled = not SQAIsEnabled
    end
    print(SQAIsEnabled)
end
SlashCmdList["SQA"] = MyCommands
local updatedQuestID = nil;
local questUpdateMessage = nil;
local function eventHandler(self, event, ...)
    if SQAIsEnabled and IsInGroup() then
        if (event == "UI_INFO_MESSAGE") then
          errorType, message = ...
          if errorType >= 287 and errorType <= 292 then
            questUpdateMessage = message
          end
        end
        if (event == "QUEST_WATCH_UPDATE") then
            updatedQuestID = ... --the quest id that changed
        end
        if (event == "QUEST_LOG_UPDATE" and updatedQuestID ~= nil) then
            questIndex = GetQuestLogIndexByID(updatedQuestID)
            local questTitle, level, questTag, suggestedGroup, isHeader, isComplete, isDaily, questID = GetQuestLogTitle(questIndex)
            if (isComplete == 1) then
              SendChatMessage("Completed Quest: ".. questTitle, "PARTY", nil, UnitName("player"))
              updatedQuestID = nil
            else
              SendChatMessage("\""..questTitle.."\", ".. questUpdateMessage, "PARTY", nil, UnitName("player"))
              updatedQuestID = nil
            end
        end
        if (event == "QUEST_TURNED_IN") then
            local questID = ...
            local title = C_QuestLog.GetQuestInfo(questID)
            SendChatMessage("Quest turned in: \"" .. title.."\"", "PARTY", nil, "Tarbal")
        end
    end
end
frame:SetScript("OnEvent", eventHandler)