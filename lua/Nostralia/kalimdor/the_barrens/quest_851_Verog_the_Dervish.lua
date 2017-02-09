--[[
 * http://nostralia.org/ True Australian Vanilla World of Warcraft
 * DESC   : Random chance to summon Verog the Dervish on death.
 * UPDATED: 3rd Feb 2017
 * AUTHOR : sundays
--]]

local CREATURE_VEROG = 3395;
local TEXT_ON_DEATH     = "I am slain! Summon Verog!"; -- Chance on death.
local TEXT_VEROG_SUMMON = "I am summoned! Intruders, come to my tent and face your death!";
local CREATURE_KOLKAR_PACK_RUNNER = 3274;
local CREATURE_KOLKAR_MARAUDER    = 3275;
local CREATURE_BLOODCHARGER       = 3397;

local isVerogSpawned = false;

local function OnVerogSummonerDied(event, creature, killer)
	local randomChance = math.random(1, 100);

	if (randomChance > 80) then
		if (isVerogSpawned) then
			-- Check if this is still the case.
			local pVerog;
			pVerog = creature:GetNearestCreature(400, CREATURE_VEROG, 0, 1);
			if (not pVerog) then
				isVerogSpawned = false;
			end
 			return;
		end

		local x, y, z, o = creature:GetLocation();
		creature:SendUnitSay(TEXT_ON_DEATH, 0);
		creature:SpawnCreature(CREATURE_VEROG, x, y, z, o, 1, 360000); -- TEMPSUMMON_DEAD_DESPAWN
	end
end

local function OnVerogSpawned(event, creature)
	isVerogSpawned = true;
	creature:SendUnitYell(TEXT_VEROG_SUMMON, 0);
end

local function OnVerogDied(event, creature, killer)
	isVerogSpawned = false;
end

RegisterCreatureEvent(CREATURE_VEROG, 5, OnVerogSpawned); -- CREATURE_EVENT_ON_SPAWN
RegisterCreatureEvent(CREATURE_VEROG, 4, OnVerogDied);    -- CREATURE_EVENT_ON_DIED
RegisterCreatureEvent(CREATURE_KOLKAR_PACK_RUNNER, 4, OnVerogSummonerDied);
RegisterCreatureEvent(CREATURE_KOLKAR_MARAUDER, 4, OnVerogSummonerDied);
RegisterCreatureEvent(CREATURE_BLOODCHARGER, 4, OnVerogSummonerDied);

