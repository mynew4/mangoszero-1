--[[
 * http://nostralia.org/ True Australian Vanilla World of Warcraft
 * DESC   : Handles Area Trigges.
 * UPDATED: 2nd Feb 2017
 * AUTHOR : sundays
--]]

local SPELL_PORT_HALEH = 17159; -- Port to Haleh
local SPELL_PORT_MAZ   = 17160; -- Port to Mazthoril

local function PortToMazthoril(pPlayer)
	if (pPlayer) then
		pPlayer:CastSpell(pPlayer, SPELL_PORT_MAZ, true);
	end
end

local function PortToHaleh(pPlayer)
	if (pPlayer) then
		pPlayer:CastSpell(pPlayer, SPELL_PORT_HALEH, true);
	end
end

local TriggerIDs = {
	[2211] = function(pPlayer) PortToMazthoril(pPlayer) end, -- Rune teleport to Mazthoril
	[2213] = function(pPlayer) PortToHaleh(pPlayer) end,     -- Rune teleport to Haleh
};

local function OnAreaTrigger(event, player, triggerId)
	if (TriggerIDs[triggerId]) then
		TriggerIDs[triggerId](player, triggerId);
	end
end

RegisterServerEvent(24, OnAreaTrigger);

