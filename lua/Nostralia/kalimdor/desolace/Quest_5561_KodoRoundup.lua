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

local QUEST_KODO_ROUNDUP     = 5561;
local ITEM_KODO_KOMBOBULATOR = 13892;
local SPELL_PLYR_KODO_KOMBO  = 18172; -- Player debuff.
local SPELL_KOMBOBULATOR     = 18153; -- Spell used by item.
local SPELL_KODO_SELF_AURA   = 18377; -- The Kodo casts on self after being hit by 'kodo Item'.
local SPELL_KODO_GOSSIP      = 18362;
local CREATURE_SMEED         = 11596; -- Quest giver
local CREATURE_TAMED_KODO    = 11627;
local CREATURE_AGED_KODO     = 4700;
local CREATURE_DYING_KODO    = 4701;
local CREATURE_ANCIENT_KODO  = 4702;
local GOSSIP_MENU_ID         = 3650;
local GOSSIP_KODO_TEXT       = 4449;

-- Can be hit by Kodo Kombobulator.
Quest.Kodos = {
	CREATURE_AGED_KODO,
	CREATURE_DYING_KODO,
	CREATURE_ANCIENT_KODO;
};

function Quest.OnUseKombobulator(_, player, _, target)
	if (player:HasAura(SPELL_PLYR_KODO_KOMBO)) then
		return false;
	end

	if (player:GetQuestStatus(QUEST_KODO_ROUNDUP) == 1) then
		return false;
	end

	local tarEntry = target:GetEntry();
	for i = 1, 3 do
		if (Quest.Kodos[i] == tarEntry) then
			return true;
		end
	end
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
	local pOwner;
	local targetCreature;
	local pOwner = nil;
	local kodoGUID;
	local randomText;
	local next = next;

	if (creature:HasAura(SPELL_KODO_GOSSIP)) then
		-- Waiting to be inspected.
		return false;
	end

	kodoGUID = creature:GetGUIDLow();
	pOwner = GetPlayerByGUID(Kodo.Owners[kodoGUID]);

	if (not pOwner) then
		RemoveKodo(creature);
	end

	if (not pOwner:HasAura(SPELL_PLYR_KODO_KOMBO)) then
		RemoveKodo(creature);
	end

	targetCreature = creature:GetCreaturesInRange(15, CREATURE_SMEED, 2, 1);

	if (next(targetCreature)) then
		targetCreature = targetCreature[1];
		if (pOwner and pOwner:HasAura(SPELL_PLYR_KODO_KOMBO)) then
			randomText = math.random(1, 3);
			targetCreature:SendUnitSay(Quest.Strings[randomText], 0);
			creature:CastSpell(creature, SPELL_KODO_GOSSIP, true);
		end
		creature:SetNPCFlags(1); -- Enable gossip (so it can be 'inspected' by the player).
		creature:MoveStop();
		creature:MoveIdle();
		creature:SetRooted(true);
		creature:DespawnOrUnsummon(45000); -- Hangs around for 45s, probably wrong?
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
	creature:SetNPCFlags(0); -- Disable gossip.
	creature:RegisterEvent(Kodo.Update, 2500, 0);
end

function Kodo.OnGossipHello(event, player, creature)
	if (player:GetGUIDLow() ~= Kodo.Owners[creature:GetGUIDLow()]) then
		return false;
	end

	if (player:HasAura(SPELL_PLYR_KODO_KOMBO) and creature:HasAura(SPELL_KODO_GOSSIP)) then
		local playerGroup;
		local groupMembers;
		local groupCount;

		-- According to wowhead comment, credit is for entire group.
		if (player:IsInGroup()) then
			playerGroup = player:GetGroup();
			groupMembers = playerGroup:GetMembers();
			groupCount = playerGroup:GetMembersCount();
			
			for i = 1, groupCount do
				if (groupMembers[i]) then
					if (groupMembers[i]:HasQuest(QUEST_KODO_ROUNDUP) and groupMembers[i]:GetDistance(creature) <= 50) then
						groupMembers[i]:KilledMonsterCredit(CREATURE_TAMED_KODO);
					end
				end
			end
		else
			player:KilledMonsterCredit(CREATURE_TAMED_KODO);
		end

		player:RemoveAura(SPELL_PLYR_KODO_KOMBO);
		creature:RemoveAura(SPELL_KODO_SELF_AURA);
		player:GossipSendMenu(GOSSIP_KODO_TEXT, creature, GOSSIP_MENU_ID);
		creature:RemoveEvents();
		return true;
	end

	return false;
end

function Kodo.OnDied(_, creature, _)
	RemoveKodo(creature);
end

RegisterCreatureEvent(CREATURE_AGED_KODO, 30, Kodo.OnTamed); -- CREATURE_EVENT_ON_DUMMY_EFFECT
RegisterCreatureEvent(CREATURE_DYING_KODO, 30, Kodo.OnTamed);
RegisterCreatureEvent(CREATURE_ANCIENT_KODO, 30, Kodo.OnTamed);
RegisterCreatureEvent(CREATURE_TAMED_KODO, 4, Kodo.OnDied); -- CREATURE_EVENT_ON_DIED
RegisterCreatureGossipEvent(CREATURE_TAMED_KODO, 1, Kodo.OnGossipHello); 

