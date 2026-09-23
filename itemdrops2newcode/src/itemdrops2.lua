-- dofile("../data/test_addons/itemdrops2/addon_d.ipf/itemdrops2/itemdrops2.lua")
local addonName = "ITEMDROPPLUS";
local verText = "1.0.0";
local autherName = "TOUKIBI";
local addonNameLower = string.lower(addonName);

_G['ADDONS'] = _G['ADDONS'] or {};
_G['ADDONS'][autherName] = _G['ADDONS'][autherName] or {};
_G['ADDONS'][autherName][addonName] = _G['ADDONS'][autherName][addonName] or {};

local Me = _G['ADDONS'][autherName][addonName];
Me.HandleList = Me.HandleList or {};
Me.last_update_tick = 0 

_G["ADDONS"]["COLOREDITEMNAMES"] = _G["ADDONS"]["COLOREDITEMNAMES"] or {};
COLOREDITEMNAMES = _G["ADDONS"]["COLOREDITEMNAMES"];

if _G["DROPS2_PERMANENT_GEO_LOCK"] == nil then _G["DROPS2_PERMANENT_GEO_LOCK"] = {} end
if _G["DROPS2_GLOBAL_POSITION_CACHE"] == nil then _G["DROPS2_GLOBAL_POSITION_CACHE"] = {} end

local function GetHairAccEnchantRank(itemObj)
    if not itemObj then return nil end
    if _G["shared_enchant_special_option"] and _G["shared_enchant_special_option"].get_item_rank then
        local is_success, item_rank = pcall(_G["shared_enchant_special_option"].get_item_rank, itemObj)
        if is_success and item_rank then
            return item_rank 
        end
    end
    return nil
end

local function GetItemGrade(itemObj)
    if not itemObj then return 1 end
    local grade = tonumber(itemObj.ItemGrade) or 1;
    local group = itemObj.GroupName;
    local stype = tostring(itemObj.MarketCategory);
    local itemIcon = tostring(itemObj.Icon);
    local itemname = tostring(itemObj.ClassName);
    
    if itemname:match("R_common_skill_enchant_jewal") then return 0;
    elseif (group == "Premium") or stype:match("Premium_") or itemname:match("ChallengeModeReset") or itemname:match("WeeklyBossEnteredCountReset") or stype:match("Gem_GemSkill") then
        if (grade < 2) then return 0 end return grade;
	
	elseif stype:match("HairAcc_") then
        local item_rank = GetHairAccEnchantRank(itemObj)
        local hair_grade = grade
        if item_rank ~= nil and item_rank ~= "None" then
            if item_rank == "D" then hair_grade = 1;
            elseif item_rank == "C" then hair_grade = 4;
            elseif item_rank == "B" then hair_grade = 5;
            elseif item_rank == "A" then hair_grade = 6;
            end
            return hair_grade;
        end
        return hair_grade;

    elseif stype:match("_Potion") or stype:match("_Quest") then
        return 1;
    elseif (group == "Recipe") then
        local rawMatch = itemIcon:match("misc(%d)");
        if rawMatch then
            local recipeGrade = tonumber(rawMatch) or 1;
            if (recipeGrade ~= 1) then recipeGrade = recipeGrade - 1 end return recipeGrade;
        end
        return grade;
    elseif (group == "Material") then
        if (grade < 2) then return 1 end return grade;
    else return grade; end
end



function COLOREDITEMNAMES.getItemRarityColor(itemObj)
    if not itemObj then return "E1E1E1" end
    local grade = GetItemGrade(itemObj);
    if (geItemTable.GetProp(itemObj.ClassID) and geItemTable.GetProp(itemObj.ClassID).setInfo ~= nil) then return "00FF00";
    elseif (grade == 0) then return "F3F781";
    elseif (grade == 1) then return "FFFFFF";
    elseif (grade == 2) then return "108CFF";
    elseif (grade == 3) then return "9F30FF";
    elseif (grade == 4) then return "FF4F00";
    elseif (grade == 5) then return "FFBF00";
    elseif (grade == 6) then return "088A68";
    else return "E1E1E1"; end
end

local function GetItemRarityEffect(itemObj)
    if not itemObj then return {Name = "F_item_drop_line_loop_white", scale = 6} end
    local itemProp = geItemTable.GetProp(itemObj.ClassID);
    local grade = GetItemGrade(itemObj);
    local group = itemObj.GroupName;
    local stype = tostring(itemObj.MarketCategory);
    local itemIcon = tostring(itemObj.Icon);
    local itemname = tostring(itemObj.ClassName);
	
    if itemProp and (itemProp.setInfo ~= nil) then 
		return { Name = "F_light183_green_loop", scale = 6 };
    elseif (grade == 0) then
        if stype:match("Gem_GemSkill") then 
			return { Name = "F_light114_pink_loop", scale = 6 };
        else 
			return { Name = "F_line024_yellow_loop", scale = 6 }; end
    elseif (grade == 1) then
        if (group == "Drug" or group == "Quest") then 
			return { Name = "F_light185_green_loop", scale = 6 };
		elseif stype:match("HairAcc_") then
			return { Name = "F_line024_white_loop", scale = 6 };
        else 
			return { Name = "F_magic_prison_line_white", scale = 6 }; end
    elseif (grade == 2) then 
		return { Name = "F_magic_prison_line_blue", scale = 6 };
    elseif (grade == 3) then 
		return { Name = "F_magic_prison_line", scale = 6 };
    elseif (grade == 4) then
        if itemname:match("goddess_seal1_misc03") or itemname:match("goddess_seal2_misc03") then 
			return { Name = "F_line024_red_loop", scale = 6 };
        else 
			return { Name = "F_magic_prison_line_red", scale = 6 }; end
    elseif (grade == 5) then 
		return { Name = "F_magic_prison_line_yellow", scale = 6 };
    elseif (grade == 6) then
        if itemIcon:match("evolve_stone") then 
			return { Name = "F_cleric_MagnusExorcismus_shot_burstup", scale = 6 };
        elseif itemIcon:match("transcendence_coupon") or itemname:match("piece_blessing_of_jurate3") or itemname:match("misc_goddess_noble") then 
			return { Name = "F_magic_prison_line_orange", scale = 6 };
        else 
			return { Name = "F_magic_prison_line_green", scale = 6 }; end
    else 
		return { Name = "F_item_drop_line_loop_white", scale = 6 }; end
end

function ITEMDROPS2_DESTROY_EFFECT_BY_TIMER(frame, timer, argStr, argNum)
    if frame ~= nil then
        frame:RemoveTimer("DROPS2_DESTROY_LIGHT_TIMER")
        local fxName = frame:GetUserStrValue("DROPS2_EFFECT_NAME")
        local handle = frame:GetUserIValue("DROPS2_ACTOR_HANDLE")
        
        if handle > 0 and fxName ~= "" then
            local targetActor = world.GetActor(handle)
            if targetActor ~= nil then
                pcall(function() effect.DetachActorEffect(targetActor, fxName) end)
            end
        end
        ui.DestroyFrame(frame:GetName())

        local currentMemKB = collectgarbage("count")
        if currentMemKB > 50000 then 
            collectgarbage("collect")
        end
    end
end


function Me.UpdateData()
    local curTime = imcTime.GetAppTime()
    if curTime < (Me.last_update_tick + 0.15) then return end 
    Me.last_update_tick = curTime

    for _, value in pairs(Me.HandleList) do value.LiveChecked = false; end
    local FoundList, FoundCount = SelectObject(GetMyPCObject(), 200, "ALL") 

    for i = 1, FoundCount do
        local FoundItem = FoundList[i];
        local handle = GetHandle(FoundItem);
        local actor = world.GetActor(handle);
        if actor and actor:GetObjType() == GT_ITEM then
            local pos = actor:GetPos()
 
            local posKey = (math.floor(pos.x)..math.floor(pos.y)..math.floor(pos.z))
            
            if Me.HandleList[tostring(handle)] == nil then
                local itemObj = GetClass("Item", FoundItem.ClassName);
                if FoundItem.ClassName == "MoneyBag" or FoundItem.ClassName == "MoneyBag_1" then itemObj = GetClass("Item", "Vis"); end
                if itemObj ~= nil then
                    Me.HandleList[tostring(handle)] = { TryTimes = 0, LiveChecked = true, HighlightChecked = false, doHighlight = true, Effect = GetItemRarityEffect(itemObj) };
                end
            else Me.HandleList[tostring(handle)].LiveChecked = true; end
            
            if Me.HandleList[tostring(handle)] then
                if _G["DROPS2_GLOBAL_POSITION_CACHE"][posKey] then Me.HandleList[tostring(handle)].HighlightChecked = true end
                if not Me.HandleList[tostring(handle)].HighlightChecked then
                    if _G["DROPS2_PERMANENT_GEO_LOCK"][posKey] ~= true then
                        local frameName = "itemdrops_" .. handle
                        local itemFrame = ui.CreateNewFrame("notice_on_pc", frameName, 0)
                        itemFrame:EnableHitTest(0)
                        itemFrame:SetUserValue("_AT_OFFSET_HANDLE", handle)
                        itemFrame:SetUserValue("_AT_OFFSET_X", -itemFrame:GetWidth() / 2)
                        itemFrame:SetUserValue("_AT_OFFSET_Y", 3)
                        itemFrame:SetUserValue("_AT_OFFSET_TYPE", 1)
                        itemFrame:SetUserValue("_AT_AUTODESTROY", 1)
                        _FRAME_AUTOPOS(itemFrame)
                        itemFrame:RunUpdateScript("_FRAME_AUTOPOS", 0.01)
                        itemFrame:ShowWindow(1)
						

                        _G["DROPS2_PERMANENT_GEO_LOCK"][posKey] = true
                        _G["ITEMDROPS_ACTIVE_TICK"] = curTime + 2.0
                        
                        pcall(function() 
                            effect.AddActorEffectByOffset(actor, Me.HandleList[tostring(handle)].Effect.Name, Me.HandleList[tostring(handle)].Effect.scale, 0, 0, 0)
                            effect.SetEffectAttachToGround(actor, Me.HandleList[tostring(handle)].Effect.Name, 1)
                        end)
						
                        local lightDuration = 5.0
                        local objItem = actor:GetIESObj()
                        if objItem then
                            local itemGrade = GetItemGrade(objItem)
                            if itemGrade == 1 then lightDuration = 1.0
                            elseif itemGrade == 2 then lightDuration = 2.0
                            elseif itemGrade == 3 or itemGrade == 4 then lightDuration = 4.0
                            elseif itemGrade == 5 then lightDuration = 8.0
                            elseif itemGrade == 6 then lightDuration = 12.0 end
                        end
                        itemFrame:SetUserValue("DROPS2_EFFECT_NAME", Me.HandleList[tostring(handle)].Effect.Name)
                        itemFrame:SetUserValue("DROPS2_ACTOR_HANDLE", handle)
                        itemFrame:CreateTimer("DROPS2_DESTROY_LIGHT_TIMER", lightDuration, "ITEMDROPS2_DESTROY_EFFECT_BY_TIMER")

                    end
                    Me.HandleList[tostring(handle)].TryTimes = Me.HandleList[tostring(handle)].TryTimes + 1;
                    if Me.HandleList[tostring(handle)].TryTimes >= 3 then 
                        Me.HandleList[tostring(handle)].HighlightChecked = true; 
                        _G["DROPS2_GLOBAL_POSITION_CACHE"][posKey] = true
                    end
                end
            end
        end
    end
    local LostList = {};
    for handle, value in pairs(Me.HandleList) do if not value.LiveChecked then table.insert(LostList, handle) end end
    for _, handle in ipairs(LostList) do
        local targetActor = world.GetActor(tonumber(handle))
        if targetActor ~= nil then
            local pos = targetActor:GetPos()
            if pos then _G["DROPS2_PERMANENT_GEO_LOCK"][(math.floor(pos.x)..math.floor(pos.y)..math.floor(pos.z))] = nil end
        end
        Me.HandleList[tostring(handle)] = nil;
        if ui.GetFrame("itemdrops_" .. handle) then ui.DestroyFrame("itemdrops_" .. handle); end
    end 
end

function COLOREDITEMNAMES.getColoredName(itemClass, ...)
    local nameString = _G["GET_FULL_NAME_OLD"] and _G["GET_FULL_NAME_OLD"](itemClass, ...) or "";
    if nameString == "" then return "" end
    local itemColor = COLOREDITEMNAMES.getItemRarityColor(itemClass);
    return string.format("{#%s}{ol}%s{/}{/}", itemColor, nameString);
end


function COLOREDITEMNAMES.linkItem(invItem)
    local chatFrame = GET_CHATFRAME(); local editCtrl = GET_CHILD(chatFrame, "mainchat", "ui::CEditControl");
    local itemObj = GetIES(invItem:GetObject()); local itemName = _G["GET_FULL_NAME_OLD"](itemObj);
    local imgTag = string.format("{img %s %d %d}", GET_ITEM_ICON_IMAGE(itemObj), editCtrl:GetOriginalHeight(), editCtrl:GetOriginalHeight());
    local properties = (itemObj.ClassName == "Scroll_SkillItem") and GetSkillItemProperiesString(itemObj) or GET_MODIFIED_PROPERTIES_STRING(itemObj);
    if (properties == "") then properties = 'nullval'; end
    SET_LINK_TEXT(string.format("{a SLI %s %d}%s%s{/}", properties, itemObj.ClassID, imgTag, (itemObj.ClassName == "Scroll_SkillItem") and itemName .. "(" .. GetClassByType("Skill", itemObj.SkillType).Name ..")" or itemName));
end

function COLOREDITEMNAMES.getColoredTooltipName(tooltipFrame, itemObj, mainstritem, ...)
    if _G["UPDATE_ITEM_TOOLTIP_OLD"] then _G["UPDATE_ITEM_TOOLTIP_OLD"](tooltipFrame, itemObj, mainstritem, ...)
    elseif _G["ITEM_TOOLTIP_SET_NAME_OLD"] then _G["ITEM_TOOLTIP_SET_NAME_OLD"](tooltipFrame, itemObj, mainstritem, ...) end
    if tooltipFrame and itemObj and tooltipFrame:GetChild("gbox") then
        local nameCtrl = tooltipFrame:GetChild("gbox"):GetChild("name") or tooltipFrame:GetChild("gbox"):GetChild("itemname")
        if nameCtrl then
            local itemNameStr = _G["GET_FULL_NAME_OLD"] and _G["GET_FULL_NAME_OLD"](itemObj, mainstritem) or tostring(itemObj.Name)
            local itemColor = COLOREDITEMNAMES.getItemRarityColor(itemObj)
            nameCtrl:SetText(string.format("{#%s}{ol}%s{/}{/}", itemColor, itemNameStr))
        end
    end
end


function COLOREDITEMNAMES.setHooks(newFunction, oldFunction)
    if _G[oldFunction] ~= nil and _G[oldFunction .. "_OLD"] == nil then 
        _G[oldFunction .. "_OLD"] = _G[oldFunction]; 
        _G[oldFunction] = newFunction; 
    end
end

function COLOREDITEMNAMES.init()
    if (COLOREDITEMNAMES.isLoaded ~= true) and _G["GET_FULL_NAME"] and _G["GET_FULL_NAME_OLD"] == nil then
        COLOREDITEMNAMES.setHooks(COLOREDITEMNAMES.getColoredName, "GET_FULL_NAME"); 
        COLOREDITEMNAMES.setHooks(COLOREDITEMNAMES.linkItem, "LINK_ITEM_TEXT");
        if _G["UPDATE_ITEM_TOOLTIP"] then 
            COLOREDITEMNAMES.setHooks(COLOREDITEMNAMES.getColoredTooltipName, "UPDATE_ITEM_TOOLTIP"); 
        end
        if _G["ITEM_TOOLTIP_SET_NAME"] then 
            COLOREDITEMNAMES.setHooks(COLOREDITEMNAMES.getColoredTooltipName, "ITEM_TOOLTIP_SET_NAME"); 
        end
        if _G["GET_FULL_NAME_OLD"] ~= nil then 
            COLOREDITEMNAMES.isLoaded = true; 
        end
    end
end
function TOUKIBI_ITEMDROPS2_UPDATE()
    if COLOREDITEMNAMES.isLoaded ~= true then 
        COLOREDITEMNAMES.init() 
    end
    Me.UpdateData()
end

function ITEMDROPS2_ON_INIT(addon, frame)
    if addon ~= nil then
        addon:RegisterMsg("FPS_UPDATE", "TOUKIBI_ITEMDROPS2_UPDATE");
    end
    if frame ~= nil then
        frame:ShowWindow(0);
    end
end
