--[[
 * http://nostralia.org/ True Australian Vanilla World of Warcraft
 * DESC   : Script for the quest 'Kodo Roundup'.
 * UPDATED: 29th Jan 2017
 * AUTHOR : sundays
--]]

local Quest = {};

local ITEM_KODO_KOMBOBULATOR = 13892;
local AURA_KODO_KOMBOBULATOR = 18172; -- Player debuff.
local SPELL_KOMBOBULATOR     = 18153; -- Spell used by item.
local CREATURE_SMEED         = 11596; -- Quest giver
local CREATURE_TAMED_KODO    = 11672;
local CREATURE_AGED_KODO     = 4700;
local CREATURE_DYING_KODO    = 4701;
local CREATURE_ANCIENT_KODO  = 4702;

-- Can be hit by Kodo Kombobulator.
Quest.Kodos = {
	CREATURE_AGED_KODO,
	CREATURE_DYING_KODO,
	CREATURE_ANCIENT_KODO;
};

function Quest.OnUseKombobulator(_, player, _, target)
	if (player:HasAura(AURA_KODO_KOMBOBULATOR)) then
		player:StopSpellCast(SPELL_KOMBOBULATOR);
		return false;
	end

	local tarEntry = target:GetEntry();
	for i = 1, 3 do
		if (Quest.Kodos[i] == tarEntry) then
			return true;
		end
	end
	player:StopSpellCast(SPELL_KOMBOBULATOR);
	return false; -- Invalid target.
end

RegisterItemEvent(ITEM_KODO_KOMBOBULATOR, 2, Quest.OnUseKombobulator); -- ITEM_EVENT_ON_USE

-- Tamed Kodo
local Kodo = {
	Owners = {
		-- KodoGUID, OwnerGUID
	};
};

local function RemoveKodo(creature)
	local guid = creature:GetGUIDLow();
	Kodo.Owners[guid] = nil;
	creature:RemoveEvents();
	creature:DespawnOrUnsummon();
end

function Kodo.Update(_, _, _, creature)
	local playersInRange = creature:GetPlayersInRange(110, 2, 1);
	local targetCreature;
	local count = #playersInRange;
	local pOwner = nil;
	local kodoGUID = creature:GetGUIDLow();
	local next = next;

	for i = 1, count do
		if (playersInRange[i]:GetGUIDLow() == Kodo.Owners[kodoGUID]) then
			pOwner = playersInRange[i];
			break;
		end
	end

	if (not pOwner) then
		local pPlayer = GetPlayerByGUID(Kodo.Owners[kodoGUID]); -- Might still be in the world.
		if (pPlayer) then
			pPlayer:RemoveAura(AURA_KODO_KOMBOBULATOR);
		end
		RemoveKodo(creature);
	end

	targetCreature = creature:GetCreaturesInRange(12, CREATURE_SMEED, 2, 1);

	if (next(targetCreature)) then
		if (pOwner and pOwner:HasAura(AURA_KODO_KOMBOBULATOR)) then
			pOwner:Kill(creature);
			pOwner:RemoveAura(AURA_KODO_KOMBOBULATOR);
		end
		RemoveKodo(creature);
	end 
end

function Kodo.OnTamed(_, caster, spellid, _, creature)
	if (spellid ~= SPELL_KOMBOBULATOR) then
		return false;
	end
	Kodo.Owners[creature:GetGUIDLow()] = caster:GetGUIDLow();
	creature:RegisterEvent(Kodo.Update, 2500, 0);
end

function Kodo.OnDied(_, creature, _)
	-- Quest credit not handled by lua. (when killed by player?)
	RemoveKodo(creature);
end

RegisterCreatureEvent(CREATURE_AGED_KODO, 30, Kodo.OnTamed); -- CREATURE_EVENT_ON_DUMMY_EFFECT
RegisterCreatureEvent(CREATURE_DYING_KODO, 30, Kodo.OnTamed);
RegisterCreatureEvent(CREATURE_ANCIENT_KODO, 30, Kodo.OnTamed);
RegisterCreatureEvent(CREATURE_TAMED_KODO, 4, Kodo.OnDied); -- CREATURE_EVENT_ON_DIED

