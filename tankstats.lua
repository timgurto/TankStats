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

EventFrame:RegisterEvent("UNIT_HEALTH")
EventFrame:SetScript("OnEvent", function(self,event,...) 
    TankStats:EHBar_OnUpdate();
end);

EventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
EventFrame:SetScript("OnEvent", function(self,event,...) 
    TankStats:EHBar_OnUpdate();
end);


function TankStats:updateTargetLevel()
    TankStats.enemyLevel = UnitLevel("target");
    
	--0: nothing selected; use player
	if (TankStats.enemyLevel == 0) then
        TankStats.enemyLevel = UnitLevel("player")
    end
	
	---1: skull; use 63
	if (TankStats.enemyLevel == -1) then
		--TankStats.enemyLevel = UnitLevel("player") + 3;
		--TankStats.enemyLevel = 63;
	end
end


function TankStats:stats()
    TankStats:EHBar_OnUpdate();

    TankStats:updateTargetLevel();
    local levelDiff = TankStats.enemyLevel - UnitLevel("player");
    
    local runningTotal = 0;
    
    --1: MISS
    local baseDefense, armorDefense = UnitDefense("player");
    local defDiff = baseDefense - (5*UnitLevel("player"));
    local miss = 5 + .04*defDiff;
    --miss = min( (compare with runningTotal, 100)
    runningTotal = runningTotal + miss;
    
    local dodge = GetDodgeChance();
    local parry = GetParryChance();
    local block = GetBlockChance();
    
    DEFAULT_CHAT_FRAME:AddMessage("Miss: " .. format("%.2f", miss) .. "%");
    DEFAULT_CHAT_FRAME:AddMessage("Dodge: " .. format("%.2f", dodge) .. "%");
    DEFAULT_CHAT_FRAME:AddMessage("Parry: " .. format("%.2f", parry) .. "%");
    DEFAULT_CHAT_FRAME:AddMessage("Block: " .. format("%.2f", block) .. "%");
	DEFAULT_CHAT_FRAME:AddMessage("Target level: " .. TankStats.enemyLevel);
	
    
end

function TankStats:EHBar_OnLoad()
    TankStats:EHBar_OnUpdate();
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

SLASH_TANKSTATS1 = "/stats";

SlashCmdList["TANKSTATS"] = TankStats.stats;













