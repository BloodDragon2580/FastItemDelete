-- FastItemDelete (Retail: The War Within / future-proof for Midnight)
local addonName = ...
local f = CreateFrame("Frame", "FastItemDeleteFrame")

-- Which static popup dialogs are the "type DELETE to confirm" ones
local DESTROY_DIALOGS = {
  DELETE_ITEM = true,
  DELETE_GOOD_ITEM = true,
  DELETE_QUEST_ITEM = true,
  DELETE_GOOD_QUEST_ITEM = true,
}

local function GetCursorItemLinkFallback(itemName)
  local infoType, _, itemLink = GetCursorInfo()
  if infoType == "item" and itemLink then
    return itemLink
  end
  return itemName -- fallback (at least show something)
end

local function EnsureLinkFontString(popup)
  if popup.__FastItemDeleteLink then return popup.__FastItemDeleteLink end

  local fs = popup:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  fs:SetJustifyH("CENTER")
  fs:SetJustifyV("MIDDLE")
  fs:Hide()

  -- Anchor roughly where the edit box sits (works across popup instances)
  local editBox = popup.editBox or _G[popup:GetName() .. "EditBox"]
  if editBox then
    fs:SetPoint("CENTER", editBox, "CENTER", 0, 0)
  else
    fs:SetPoint("CENTER", popup, "CENTER", 0, -10)
  end

  popup:HookScript("OnHide", function(self)
    if self.__FastItemDeleteLink then
      self.__FastItemDeleteLink:Hide()
    end
  end)

  popup.__FastItemDeleteLink = fs
  return fs
end

function f:DELETE_ITEM_CONFIRM(itemName)
  -- Search the visible static popup(s). Retail has up to 4 concurrent dialogs.
  for i = 1, 4 do
    local popup = _G["StaticPopup" .. i]
    if popup and popup:IsShown() and DESTROY_DIALOGS[popup.which] then
      local editBox = popup.editBox or _G["StaticPopup" .. i .. "EditBox"]
      if editBox and editBox:IsShown() then
        editBox:Hide()
      end

      -- Make sure the accept button is clickable
      if popup.button1 then
        popup.button1:Enable()
      elseif _G["StaticPopup" .. i .. "Button1"] then
        _G["StaticPopup" .. i .. "Button1"]:Enable()
      end

      -- Show the item link (or name if link isn't available)
      local fs = EnsureLinkFontString(popup)
      fs:SetText(GetCursorItemLinkFallback(itemName))
      fs:Show()

      -- We handled the active destroy popup; stop here.
      return
    end
  end
end

function f:ADDON_LOADED(name)
  if name ~= addonName then return end
  -- Nothing required here, but keeping the event for clean startup.
end

f:SetScript("OnEvent", function(self, event, ...)
  if self[event] then self[event](self, ...) end
end)

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("DELETE_ITEM_CONFIRM")
