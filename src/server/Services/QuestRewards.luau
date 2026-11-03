--!strict
-- No yields between capacity checks, claiming the objective and granting its reward.
local Progression=require(script.Parent.Progression)
local RewardExtras=require(script.Parent.RewardExtras)
local QuestRewards={}
function QuestRewards.claim(progress,extras,key,now)
 local quest=Progression.readyQuest(progress,key,now)
 if not quest then return nil,"Quest is not ready or has already been claimed." end
 if quest.rewardKind=="potion2" and extras.doubleLuckPotions>=RewardExtras.MaxPotions then return nil,"Use a 2x potion before claiming." end
 if quest.rewardKind=="uncommonBox" and extras.uncommonBoxes>=RewardExtras.MaxBoxes then return nil,"Open a mystery box before claiming." end
 -- The quest's reward definition is server-owned, not provided by the client.
 if quest.rewardKind~="cash" and quest.rewardKind~="potion2" and quest.rewardKind~="uncommonBox" then return nil,"Quest reward unavailable." end
 if Progression.claimQuest(progress,key,now)==nil then return nil,"Quest is no longer ready." end
 if quest.rewardKind=="potion2" then extras.doubleLuckPotions+=1 end
 if quest.rewardKind=="uncommonBox" then extras.uncommonBoxes+=1 end
 return quest
end
return QuestRewards
