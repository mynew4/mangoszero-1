--[[
 * http://nostralia.org/ True Australian Vanilla World of Warcraft
 * DESC   : Scripts for Ashenvale.
 * UPDATED: 4th Feb 2017
 * AUTHOR : sundays
--]]

-- Constants
local CREATURE_THISTLEFUR_AVENGER = 3925;
local SPELL_VENGEANCE = 8602;
local SPELL_COAT_OF_THISTLEFUR = 6813;
local TEXT_ENRAGE = "%s goes into a rage after seeing a friend fall in battle!";

-- Thistlefur Avenger
local ThistlefurAvenger = {};

function ThistlefurAvenger.CheckHealth(event, delay, repeats, creature)
	local friendlyInRange;
	local selfHealth;
	local len;

	friendlyInRange = creature:GetCreaturesInRange(20, 0, 2, 1);
	len = #friendlyInRange;
	for i = 1, len do
		if (friendlyInRange[i]:GetHealthPct() <= 10) then -- 10% health for friendlies
			creature:CastSpell(creature, SPELL_VENGEANCE);
			creature:SendUnitEmote(string.format(TEXT_ENRAGE, creature:GetName()), nil, false);
			creature:RemoveEventById(event);
			break;
		end
	end

	selfHealth = creature:GetHealthPct();
	if (selfHealth <= 30) then -- 30% health for self
		if (math.random(1, 100) >= 70) then
			creature:CastSpell(creature, SPELL_VENGEANCE);
		end
		creature:RemoveEventById(event);
	end
end

function ThistlefurAvenger.OnEnterCombat(event, creature, target)
	creature:RegisterEvent(ThistlefurAvenger.CheckHealth, 2000, 0);
	if (not creature:HasAura(SPELL_COAT_OF_THISTLEFUR)) then
		creature:CastSpell(creature, SPELL_COAT_OF_THISTLEFUR, true); -- @TODO: Fix RemoveEvents removing script auras.
	end
end

function ThistlefurAvenger.OnSpawn(event, creature)
	creature:CastSpell(creature, SPELL_COAT_OF_THISTLEFUR, true);
end

function ThistlefurAvenger.Reset(event, creature)
	creature:RemoveEvents();
end

RegisterCreatureEvent(CREATURE_THISTLEFUR_AVENGER, 1, ThistlefurAvenger.OnEnterCombat);
RegisterCreatureEvent(CREATURE_THISTLEFUR_AVENGER, 4, ThistlefurAvenger.Reset);  -- CREATURE_EVENT_ON_DIED
RegisterCreatureEvent(CREATURE_THISTLEFUR_AVENGER, 5, ThistlefurAvenger.OnSpawn);
RegisterCreatureEvent(CREATURE_THISTLEFUR_AVENGER, 23, ThistlefurAvenger.Reset); -- CREATURE_EVENT_ON_RESET

