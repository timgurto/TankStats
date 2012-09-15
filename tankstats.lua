--HIT TABLE:
--Miss
--Dodge
--Parry
--Block
--Critical Hit
--Crushing Blow
--Hit


local function stats()

    local enemyLevel = UnitLevel("player")
    local levelDiff = enemyLevel - UnitLevel("player");
    
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
    
    


    local base, effectiveArmor, armor, posBuff, negBuff = UnitArmor("player");
    local ACreduction = effectiveArmor / (effectiveArmor + 400 + 85 * enemyLevel);
    local ACmultiplier = 1 / (1 - ACreduction);
    --DEFAULT_CHAT_FRAME:AddMessage("Armor: " .. effectiveArmor .. " (" .. format("%.1f", ACreduction*100) .. "% reduction)");
    local health, maxHealth = UnitHealth("player"), UnitHealthMax("player");
    --DEFAULT_CHAT_FRAME:AddMessage("HP: " .. health .. "/" .. maxHealth);
    local EH, maxEH = health*ACmultiplier, maxHealth*ACmultiplier;
    DEFAULT_CHAT_FRAME:AddMessage("EH: " .. format("%d", EH) .. "/" .. format("%d", maxEH));

    local maxResist = UnitLevel("player") * 5;

    local base, total, bonus, minus = UnitResistance("player", 2);
    local fireMultiplier = 1 / (1 - total / maxResist);
    local fireEH, fireMaxEH = health*fireMultiplier, maxHealth*fireMultiplier

    base, total, bonus, minus = UnitResistance("player", 3);
    local natureMultiplier = 1 / (1 - total / maxResist);

    base, total, bonus, minus = UnitResistance("player", 4);
    local frostMultiplier = 1 / (1 - total / maxResist);

    base, total, bonus, minus = UnitResistance("player", 5);
    local shadowMultiplier = 1 / (1 - total / maxResist);

    base, total, bonus, minus = UnitResistance("player", 6);
    local arcaneMultiplier = 1 / (1 - total / maxResist);

    --DEFAULT_CHAT_FRAME:AddMessage("Fire EH: " .. format("%d", fireEH) .. "/" .. format("%d", fireMaxEH));
    
end

SLASH_TANKSTATS1 = "/stats";

SlashCmdList["TANKSTATS"] = stats;