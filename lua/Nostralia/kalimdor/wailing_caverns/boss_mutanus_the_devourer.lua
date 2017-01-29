--[[
 * http://nostralia.org/ True Australian Vanilla World of Warcraft
 * DESC  : Fix for Mutanus' spawntime.
 * AUTHOR: sundays
--]]

local Mutanus = {};

local CREATURE_MUTANUS = 3654;

function Mutanus.OnSummoned(_, creature, _)
	creature:SetRespawnDelay(3600 * 10); -- 10 hours
end

RegisterCreatureEvent(CREATURE_MUTANUS, 22, Mutanus.OnSummoned);

