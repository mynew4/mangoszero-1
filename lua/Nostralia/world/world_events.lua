--[[
 * http://nostralia.org/ True Australian Vanilla World of Warcraft
 * DESC   : Various scripts for world events, e.g. Lunar Festival.
 * UPDATED: 30th Jan 2017
 * AUTHOR : sundays
--]]

-- Lunar Festival
-- Quest: Lunar Fireworks

local QUEST_LUNAR_FIREWORKS = 8867;
local FIREWORK_CREDIT = 15893;
local CLUSTER_CREDIT  = 15894;

local Rockets = {
	{21571, CLUSTER_CREDIT},  -- Blue Rocket Cluster
	{21574, CLUSTER_CREDIT},  -- Green Rocket Cluster
	{21576, CLUSTER_CREDIT},  -- Red Rocket Cluster
	{21557, FIREWORK_CREDIT}, -- Small Red Rocket
	{21558, FIREWORK_CREDIT}, -- Small Blue Rocket
	{21559, FIREWORK_CREDIT}  -- Small Green Rocket
};

local function OnRocketUse(event, player, item, target, data)
	if (not player:HasQuest(QUEST_LUNAR_FIREWORKS)) then
		return;
	end

	player:KilledMonsterCredit(data[2]);
end

for i = 1, 6 do
	local data = Rockets[i];
	RegisterItemEvent(data[1], 2, function(event, player, item, target) OnRocketUse(event, player, item, target, data) end);
end

