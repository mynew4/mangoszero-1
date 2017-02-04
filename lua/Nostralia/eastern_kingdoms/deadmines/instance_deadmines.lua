--[[
 * http://nostralia.org/ True Australian Vanilla World of Warcraft
 * DESC   : Contains scripts not already handled in ACID or ScriptDev3.
 * UPDATED: 4th Feb 2017
 * AUTHOR : sundays
--]]

-- Constants
local CREATURE_DEFIAS_PIRATE = 657;
local CREATURE_GOBLIN_CRAFTSMAN = 1731;
local CREATURE_DEFIAS_BLACKGUARD = 636;
local SPELL_SUMMON_COMPANION = 5172;  -- Summon Bloodsail Companion
local SPELL_SUMMON_GOLEM     = 3605;  -- Summon Remote-Controlled Golem
local SPELL_MELT_ORE         = 5159;  -- Melt Ore
local SPELL_FADED            = 6408;
local SPELL_CHEAP_SHOT       = 1833;  -- @TODO: Confirm.
local SPELL_RUPTURE          = 14903; -- @TODO: Confirm.
local TEXT_FLEE = "%s attempts to run away in fear!";
local TEXT_BLACKGUARD = "%s jumps out of the shadows!";

-- Defias Pirate
local DefiasPirate = {};

function DefiasPirate.OnSpawned(event, creature)
	if (math.random(1, 100) <= 30) then
		creature:CastSpell(creature, SPELL_SUMMON_COMPANION);
	end
end

-- Goblin Craftsman
local GoblinCraftsman = {};

function GoblinCraftsman.CheckHealth(event, delay, repeats, creature)
	if (creature:GetHealthPct() <= 15) then
		creature:FleeToGetAssistance();
		creature:SendUnitEmote(string.format(TEXT_FLEE, creature:GetName()), nil, false);
		creature:RemoveEventById(event);
	end
end

function GoblinCraftsman.MeltOre(event, delay, repeats, creature)
	local pVictim = creature:GetVictim();
	creature:CastSpell(pVictim, SPELL_MELT_ORE, true);

	if (repeats == 1) then
		creature:RegisterEvent(GoblinCraftsman.MeltOre, math.random(25000, 52300), 0); -- Subsequent casts.
	end
end

function GoblinCraftsman.OnEnterCombat(event, creature, target)
	local meltOreTimer_initial = math.random(5600, 9700);

	if (math.random(1, 100) >= 65) then
		creature:CastSpell(creature, SPELL_SUMMON_GOLEM, true);
	end
	creature:RegisterEvent(GoblinCraftsman.CheckHealth, 2500, 0);
	creature:RegisterEvent(GoblinCraftsman.MeltOre, meltOreTimer_initial, 1);
end

function GoblinCraftsman.OnReset(event, creature)
	creature:RemoveEvents();
end

function GoblinCraftsman.OnDied(event, creature, killer)
	creature:RemoveEvents();
end

-- Defias Blackguard
local DefiasBlackguard = {};

function DefiasBlackguard.Rupture(event, delay, repeats, creature)
	local pVictim = creature:GetVictim();

	if (pVictim and math.random(1, 100) >= 55) then
		creature:CastSpell(pVictim, SPELL_RUPTURE);
	end
end

function DefiasBlackguard.OnEnterCombat(event, creature, target)
	if (target and math.random(1, 100) >= 90) then
		if (not target:HasAura(SPELL_CHEAP_SHOT)) then
			creature:CastSpell(target, SPELL_CHEAP_SHOT, true);
		end
	end

	creature:SendUnitEmote(string.format(TEXT_BLACKGUARD, creature:GetName()), nil, false);
	creature:RegisterEvent(DefiasBlackguard.Rupture, math.random(7000, 12500), 2);
end

function DefiasBlackguard.OnDied(event, creature, killer)
	creature:RemoveEvents();
end

-- Server hooks
RegisterCreatureEvent(CREATURE_DEFIAS_PIRATE, 5, DefiasPirate.OnSpawned);             -- CREATURE_EVENT_ON_SPAWN
RegisterCreatureEvent(CREATURE_GOBLIN_CRAFTSMAN, 1, GoblinCraftsman.OnEnterCombat);   -- CREATURE_EVENT_ON_ENTER_COMBAT
RegisterCreatureEvent(CREATURE_GOBLIN_CRAFTSMAN, 4, GoblinCraftsman.OnDied);
RegisterCreatureEvent(CREATURE_GOBLIN_CRAFTSMAN, 23, GoblinCraftsman.OnReset);        -- CREATURE_EVENT_ON_RESET
RegisterCreatureEvent(CREATURE_DEFIAS_BLACKGUARD, 1, DefiasBlackguard.OnEnterCombat);
RegisterCreatureEvent(CREATURE_DEFIAS_BLACKGUARD, 4, DefiasBlackguard.OnDied);

