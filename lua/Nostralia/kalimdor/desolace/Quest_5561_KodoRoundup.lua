--[[
 * http://nostralia.org/ True Australian Vanilla World of Warcraft
 * DESC   : Script for the quest 'Kodo Roundup'.
 * UPDATED: 29th Jan 2017
 * AUTHOR : sundays
--]]

local Quest = {
	Strings = {
		"That kodo sure is a beauty. Wait a minute, where are my bifocals? Perhaps you should inspect the beast for me.",
		"Hey, look out with that kodo! You had better inspect that beast before I give you credit!",
		"Ah... the wondrous sound of kodos. I love the way they make the ground shake... inspect the beast for me.";	
	};
};

local ITEM_KODO_KOMBOBULATOR = 13892;
local SPELL_PLYR_KODO_KOMBO  = 18172; -- Player debuff.
local SPELL_KOMBOBULATOR     = 18153; -- Spell used by item.
local SPELL_KODO_SELF_AURA   = 18377; -- The Kodo casts on self after being hit by 'kodo Item'.
 -- local SPELL_KODO_KOMBO_GOSSIP = 18362; -- Dummy aura not implemented
local CREATURE_SMEED         = 11596; -- Quest giver
local CREATURE_TAMED_KODO    = 11627;
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
	if (player:HasAura(SPELL_PLYR_KODO_KOMBO)) then
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
	creature:DespawnOrUnsummon(3000);
end

function Kodo.Update(_, _, _, creature)
	local playersInRange = creature:GetPlayersInRange(110, 2, 1);
	local targetCreature;
	local count = #playersInRange;
	local pOwner = nil;
	local kodoGUID = creature:GetGUIDLow();
	local randomText;
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
			pPlayer:RemoveAura(SPELL_PLYR_KODO_KOMBO);
		end
		RemoveKodo(creature);
	end

	targetCreature = creature:GetCreaturesInRange(12, CREATURE_SMEED, 2, 1)

	if (next(targetCreature)) then
		targetCreature = targetCreature[1];
		if (pOwner and pOwner:HasAura(SPELL_PLYR_KODO_KOMBO)) then
			randomText = math.random(1, 3);
			pOwner:RemoveAura(SPELL_PLYR_KODO_KOMBO);
			targetCreature:SendUnitSay(Quest.Strings[randomText], 0);
			pOwner:KilledMonsterCredit(CREATURE_TAMED_KODO);
		end
		creature:MoveExpire();
		creature:MoveStop();
		creature:SetRooted(true);
		RemoveKodo(creature);
	end 
end

function Kodo.OnTamed(_, caster, spellid, _, creature)
	if (spellid ~= SPELL_KOMBOBULATOR or creature:HasAura(SPELL_KODO_SELF_AURA)) then
		return false;
	end

	creature:UpdateEntry(CREATURE_TAMED_KODO);
	Kodo.Owners[creature:GetGUIDLow()] = caster:GetGUIDLow();
	caster:CastSpell(caster, SPELL_PLYR_KODO_KOMBO, true);
	creature:CastSpell(creature, SPELL_KODO_SELF_AURA, true);
	creature:MoveFollow(caster, 1, math.pi/2); -- PET_FOLLOW_DIST, PET_FOLLOW_ANGLE
	creature:RegisterEvent(Kodo.Update, 2500, 0);
end

function Kodo.OnDied(_, creature, _)
	RemoveKodo(creature);
end

RegisterCreatureEvent(CREATURE_AGED_KODO, 30, Kodo.OnTamed); -- CREATURE_EVENT_ON_DUMMY_EFFECT
RegisterCreatureEvent(CREATURE_DYING_KODO, 30, Kodo.OnTamed);
RegisterCreatureEvent(CREATURE_ANCIENT_KODO, 30, Kodo.OnTamed);
RegisterCreatureEvent(CREATURE_TAMED_KODO, 4, Kodo.OnDied); -- CREATURE_EVENT_ON_DIED

