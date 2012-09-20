--HIT TABLE:
--Miss
--Dodge
--Parry
--Block
--Critical Hit
--Crushing Blow
--Hit

TankStats = {}


local EventFrame = CreateFrame("Frame")

EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventFrame:SetScript("OnEvent", function(self,event,...) 
    TankStats:EHBar_OnLoad();
end);


EventFrame:RegisterEvent("UNIT_RESISTANCES")
EventFrame:SetScript("OnEvent", function(self,event,...) 
    TankStats:EHBar_OnUpdate();
end);

EventFrame:RegisterEvent("UNIT_HEALTH")
EventFrame:SetScript("OnEvent", function(self,event,...) 
    TankStats:EHBar_OnUpdate();
end);

EventFrame:RegisterEvent("UNIT_DEFENSE")
EventFrame:SetScript("OnEvent", function(self,event,...) 
	TankStats:HitTable_OnUpdate();
end);

EventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
EventFrame:SetScript("OnEvent", function(self,event,...) 
    TankStats:EHBar_OnUpdate();
	TankStats:HitTable_OnUpdate();
end);

EventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
EventFrame:SetScript("OnEvent", function(self,event,...) 
    TankStats:EHBar_OnUpdate();
	TankStats:HitTable_OnUpdate();
end);

EventFrame:RegisterEvent("UNIT_STATS")
EventFrame:SetScript("OnEvent", function(self,event,...) 
    TankStats:EHBar_OnUpdate();
	TankStats:HitTable_OnUpdate();
end);


function TankStats:updateTargetLevel()
    TankStats.enemyLevel = UnitLevel("target");
    
	--0: nothing selected; use player
	if (TankStats.enemyLevel == 0) then
        TankStats.enemyLevel = UnitLevel("player")
    end
	
	---1: skull; use 63
	if (TankStats.enemyLevel == -1) then
		TankStats.enemyLevel = min(63, UnitLevel("player") + 10);
		--TankStats.enemyLevel = UnitLevel("player") + 3;
		--TankStats.enemyLevel = 63;
	end
end

function TankStats:EHBar_OnLoad()
    TankStats:EHBar_OnUpdate();
	TankStats:HitTable_OnUpdate();
end

local function formatEH(x)
	if (x < 1000) then
		return format("%.1f", x);
	end
	
	if (x < 10000) then
		return format("%d", x);
	end
	
	return format("%.3fk", x/1000);
end

function TankStats:EHBar_OnUpdate()
    TankStats:updateTargetLevel();

	--Physical
    local base, effectiveArmor, armor, posBuff, negBuff = UnitArmor("player");
    local ACreduction = effectiveArmor / (effectiveArmor + 400 + 85 * TankStats.enemyLevel);
    local ACmultiplier = 1 / (1 - ACreduction);
    local health, maxHealth = UnitHealth("player"), UnitHealthMax("player");
    local EH, maxEH = health*ACmultiplier, maxHealth*ACmultiplier;
	
    EHFrameEHBar:SetMinMaxValues(0, maxEH);
    EHFrameEHBar:SetValue(EH);
    EHFrameEHBarText:SetText("Physical: " ..
							 formatEH(EH) ..
	                         " / " ..
							 formatEH(maxEH));
							 
	--Resists
    local maxResist = TankStats.enemyLevel * 5;
	local base, total, bonus, minus, modWidth;

	
	--Fire EH
    base, total, bonus, minus = UnitResistance("player", 2);
    local fireMultiplier = 1 / (1 - (min(total / maxResist, 1)) * .75);
    local fireEH, maxFireEH = health*fireMultiplier, maxHealth*fireMultiplier;
	
    EHFrameFireEHBar:SetMinMaxValues(0, maxFireEH);
    EHFrameFireEHBar:SetValue(fireEH);
    EHFrameFireEHBarText:SetText("Fire: " ..
	                             formatEH(fireEH) ..
	                             " / " ..
							     formatEH(maxFireEH));
							 
	--Shadow EH
    base, total, bonus, minus = UnitResistance("player", 5);
    local shadowMultiplier = 1 / (1 - (min(total / maxResist, 1)) * .75);
    local shadowEH, maxShadowEH = health*shadowMultiplier, maxHealth*shadowMultiplier;
	
    EHFrameShadowEHBar:SetMinMaxValues(0, maxShadowEH);
    EHFrameShadowEHBar:SetValue(shadowEH);
    EHFrameShadowEHBarText:SetText("Shadow: " ..
	                               formatEH(shadowEH) ..
								   " / " ..
							       formatEH(maxShadowEH));
							 
	--Nature EH
    base, total, bonus, minus = UnitResistance("player", 3);
    local natureMultiplier = 1 / (1 - (min(total / maxResist, 1)) * .75);
    local natureEH, maxNatureEH = health*natureMultiplier, maxHealth*natureMultiplier;
	
    EHFrameNatureEHBar:SetMinMaxValues(0, maxNatureEH);
    EHFrameNatureEHBar:SetValue(natureEH);
    EHFrameNatureEHBarText:SetText("Nature: " ..
	                               formatEH(natureEH) ..
								   " / " ..
								   formatEH(maxNatureEH));
							 
	--Frost EH
    base, total, bonus, minus = UnitResistance("player", 4);
    local frostMultiplier = 1 / (1 - (min(total / maxResist, 1)) * .75);
    local frostEH, maxFrostEH = health*frostMultiplier, maxHealth*frostMultiplier;
	
    EHFrameFrostEHBar:SetMinMaxValues(0, maxFrostEH);
    EHFrameFrostEHBar:SetValue(frostEH);
    EHFrameFrostEHBarText:SetText("Frost: " ..
	                               formatEH(frostEH) ..
								   " / " ..
								   formatEH(maxFrostEH));
							 
	--Arcane EH
    base, total, bonus, minus = UnitResistance("player", 6);
    local arcaneMultiplier = 1 / (1 - (min(total / maxResist, 1)) * .75);
    local arcaneEH, maxArcaneEH = health*arcaneMultiplier, maxHealth*arcaneMultiplier;
	
    EHFrameArcaneEHBar:SetMinMaxValues(0, maxArcaneEH);
    EHFrameArcaneEHBar:SetValue(arcaneEH);
    EHFrameArcaneEHBarText:SetText("Arcane: " ..
	                               formatEH(arcaneEH) ..
								   " / " ..
								   formatEH(maxArcaneEH));
							 

	--Normalize bar widths
	local maxMax = max(maxEH, maxFireEH, maxShadowEH, maxNatureEH, maxFrostEH, maxArcaneEH);
	local widthModifier = EHFrame:GetWidth() / maxMax;
	
	EHFrameMaxEHBar:SetWidth(maxEH * widthModifier);
	EHFrameEHBar:SetWidth(maxEH * widthModifier);
	EHFrameMaxFireEHBar:SetWidth(maxFireEH * widthModifier);
	EHFrameFireEHBar:SetWidth(maxFireEH * widthModifier);
	EHFrameMaxShadowEHBar:SetWidth(maxShadowEH * widthModifier);
	EHFrameShadowEHBar:SetWidth(maxShadowEH * widthModifier);
	EHFrameMaxNatureEHBar:SetWidth(maxNatureEH * widthModifier);
	EHFrameNatureEHBar:SetWidth(maxNatureEH * widthModifier);
	EHFrameMaxFrostEHBar:SetWidth(maxFrostEH * widthModifier);
	EHFrameFrostEHBar:SetWidth(maxFrostEH * widthModifier);
	EHFrameMaxArcaneEHBar:SetWidth(maxArcaneEH * widthModifier);
	EHFrameArcaneEHBar:SetWidth(maxArcaneEH * widthModifier);
	
end

function TankStats:HitTable_OnUpdate()
    TankStats:updateTargetLevel();
    local baseDefense, armorDefense = UnitDefense("player");
    local levelDiff = TankStats.enemyLevel - UnitLevel("player");
	local extraFromLevel = -0.04 * (TankStats.enemyLevel*5 - baseDefense);
    
	
    TankStats.miss = 5 + extraFromLevel;
    
    TankStats.dodge = GetDodgeChance() + extraFromLevel;
    TankStats.parry = GetParryChance() + extraFromLevel;
    TankStats.block = GetBlockChance() + extraFromLevel;
	TankStats.crit = max(0, 5 - extraFromLevel);
	
	--shield?
	if (UnitCreatureType("target") == "Elemental") then
		TankStats.block = 0;
	end

	
	TankStats.crush = max(0, (TankStats.enemyLevel * 5 - min(baseDefense, 5*UnitLevel("player"))) * 2 - 15);
	
	
	TankStats.miss  = min(TankStats.miss,  100);
	TankStats.dodge = min(TankStats.dodge, 100 - TankStats.miss);
	TankStats.parry = min(TankStats.parry, 100 - TankStats.miss - TankStats.dodge);
	TankStats.block = min(TankStats.block, 100 - TankStats.miss - TankStats.dodge - TankStats.parry);
	TankStats.crit  = min(TankStats.crit , 100 - TankStats.miss - TankStats.dodge - TankStats.parry - TankStats.block);
	TankStats.crush = min(TankStats.crush, 100 - TankStats.miss - TankStats.dodge - TankStats.parry - TankStats.block - TankStats.crit);
	TankStats.hit   =                      100 - TankStats.miss - TankStats.dodge - TankStats.parry - TankStats.block - TankStats.crit - TankStats.crush;
	
	
	local barSize = HitTable:GetWidth() * .01;
	
	if (TankStats.miss > 0) then HitTableMissBarText:SetText("M"); else HitTableMissBarText:SetText(""); end
	if (TankStats.dodge > 0) then HitTableDodgeBarText:SetText("D"); else HitTableDodgeBarText:SetText(""); end
	if (TankStats.parry > 0) then HitTableParryBarText:SetText("P"); else HitTableParryBarText:SetText(""); end
	if (TankStats.block > 0) then HitTableBlockBarText:SetText("B"); else HitTableBlockBarText:SetText(""); end
	if (TankStats.crit > 0) then HitTableCritBarText:SetText("C"); else HitTableCritBarText:SetText(""); end
	if (TankStats.crush > 0) then HitTableCrushBarText:SetText("Cu"); else HitTableCrushBarText:SetText(""); end
	if (TankStats.hit > 0) then HitTableHitBarText:SetText("H"); else HitTableHitBarText:SetText(""); end
	
	--zero-size messes up anchors
	local missSize = max(0.01, TankStats.miss);
	local dodgeSize = max(0.01, TankStats.dodge);
	local parrySize = max(0.01, TankStats.parry);
	local blockSize = max(0.01, TankStats.block);
	local critSize = max(0.01, TankStats.crit);
	local crushSize = max(0.01, TankStats.crush);
	local hitSize = max(0.01, TankStats.hit);
	
	HitTableMissBar:SetWidth(missSize * barSize);
	HitTableDodgeBar:SetWidth(dodgeSize * barSize);
	HitTableParryBar:SetWidth(parrySize * barSize);
	HitTableBlockBar:SetWidth(blockSize * barSize);
	HitTableCritBar:SetWidth(critSize * barSize);
	HitTableCrushBar:SetWidth(crushSize * barSize);
	HitTableHitBar:SetWidth(hitSize * barSize);
	
	TankStats.summaryText = "";
	if (TankStats.miss > 0) then TankStats.summaryText = TankStats.summaryText .. format("%.2f", TankStats.miss) .. "% miss" end
	if (TankStats.dodge > 0) then TankStats.summaryText = TankStats.summaryText .. " | " .. format("%.2f", TankStats.dodge) .. "% dodge" end
	if (TankStats.parry > 0) then TankStats.summaryText = TankStats.summaryText .. " | " .. format("%.2f", TankStats.parry) .. "% parry" end
	if (TankStats.block > 0) then TankStats.summaryText = TankStats.summaryText .. " | " .. format("%.2f", TankStats.block) .. "% block" end
	if (TankStats.crit > 0) then TankStats.summaryText = TankStats.summaryText .. " | " .. format("%.2f", TankStats.crit) .. "% crit" end
	if (TankStats.crush > 0) then TankStats.summaryText = TankStats.summaryText .. " | " .. format("%.2f", TankStats.crush) .. "% crush" end
	if (TankStats.hit > 0) then TankStats.summaryText = TankStats.summaryText .. " | " .. format("%.2f", TankStats.hit) .. "% hit" end
	TankStats.summaryText = TankStats.summaryText .. "  (from lvl " .. TankStats.enemyLevel .. " target)";
end

function TankStats:showHitTableText()	
	HitTableText:SetText(TankStats.summaryText);
end

function TankStats:hideHitTableText()
	HitTableText:SetText("");
end


function TankStats:stats()
    TankStats:HitTable_OnUpdate();


    
	DEFAULT_CHAT_FRAME:AddMessage("Target level: " .. TankStats.enemyLevel);
	
    if (TankStats.miss > 0) then DEFAULT_CHAT_FRAME:AddMessage("Miss: " .. format("%.2f", TankStats.miss) .. "%"); end
    if (TankStats.dodge > 0) then DEFAULT_CHAT_FRAME:AddMessage("Dodge: " .. format("%.2f", TankStats.dodge) .. "%"); end
    if (TankStats.parry > 0) then DEFAULT_CHAT_FRAME:AddMessage("Parry: " .. format("%.2f", TankStats.parry) .. "%"); end
    if (TankStats.block > 0) then DEFAULT_CHAT_FRAME:AddMessage("Block: " .. format("%.2f", TankStats.block) .. "%"); end
    if (TankStats.crit > 0) then DEFAULT_CHAT_FRAME:AddMessage("Crit: " .. format("%.2f", TankStats.crit) .. "%"); end
    if (TankStats.crush > 0) then DEFAULT_CHAT_FRAME:AddMessage("Crush: " .. format("%.2f", TankStats.crush) .. "%"); end
    if (TankStats.hit > 0) then DEFAULT_CHAT_FRAME:AddMessage("Hit: " .. format("%.2f", TankStats.hit) .. "%"); end

	
    local id, texture, checkRelic = GetInventorySlotInfo("MainHandSlot");
	local name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(id);
	DEFAULT_CHAT_FRAME:AddMessage("Offhand name: " .. id);
end


SLASH_TANKSTATS1 = "/stats";

SlashCmdList["TANKSTATS"] = TankStats.stats;










