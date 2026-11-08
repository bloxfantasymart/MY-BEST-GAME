--!strict
-- Bounded envelope validation for untrusted client RemoteEvents. This does not
-- authorize actions: each gameplay service must still validate its own schema,
-- ownership, proximity, quote and funds before changing state.
local RemoteInput={}
local main={}
local function register(kind,names)
 for _,name in ipairs(names) do main[name]=kind end
end
register("none",{"sync","requestCheckpoint","requestEvents","requestOdds","roll","multiRoll","cancelPurchaseReview",
 "refreshPasses","dailyReward","useLuckPotion","useDoubleLuckPotion","cancelDuplicateReview","cancelRefineReview",
 "openUncommonBox","openStandardBox","claimSeason","claimRepeatRolls","cancelBulkSaleReview","cancelSelectedSaleReview",
 "cancelSingleSaleReview","cancelStandLayoutReview","upgradeBackpack","upgradeSlots","cancelCraftReview","cancelFusionReview",
 "cancelRebirthReview","collect","upgradeStands"})
register("string",{"buy","buyWithVoucher","buyPass","claimGift","teleport","skip","theme","bulkSaleConfirm",
 "selectedSaleConfirm","singleSaleConfirm","applyStandLayout","craftConfirm","fusionConfirm","rebirthReview","rebirthConfirm",
 "purchaseConfirm","batchPurchaseConfirm","duplicateConfirm","refineConfirm"})
register("table",{"adminAction","purchaseReview","batchPurchaseReview","duplicateReview","refineReview","claimQuest",
 "discardOffers","setItemLock","bulkSetItemLock","bulkSaleReview","selectedSaleReview","singleSaleReview",
 "saveStandLayout","deleteStandLayout","reviewStandLayout","craftReview","fusionReview","stand","level"})
register("boolean",{"setManualMutationProtection","setAutoCollect"})
register("auto",{"autoRoll"})
register("optionalNumber",{"adminOpen"})
local hub={directory=true,visitBooth=true,visitPortal=true,refresh=true,release=true,add=true,remove=true}
RemoteInput.MaxString=128
RemoteInput.MaxDepth=5
RemoteInput.MaxTableEntries=400
RemoteInput.MaxTotalEntries=1600
local function validNumber(value)
 return value==value and value~=math.huge and value~=-math.huge
end
local function bounded(value,depth,seen,budget)
 local kind=type(value)
 if kind=="boolean" then return true end
 if kind=="number" then return validNumber(value) end
 if kind=="string" then return #value<=RemoteInput.MaxString end
 if kind~="table" or depth>RemoteInput.MaxDepth or seen[value] then return false end
 seen[value]=true
 local entries=0
 for key,item in pairs(value) do
  entries+=1; budget.count+=1
  if entries>RemoteInput.MaxTableEntries or budget.count>RemoteInput.MaxTotalEntries then return false end
  local keyKind=type(key)
  if keyKind=="string" then if #key<1 or #key>64 then return false end
  elseif keyKind=="number" then if not validNumber(key) or key%1~=0 or key<1 or key>365 then return false end
  else return false end
  if not bounded(item,depth+1,seen,budget) then return false end
 end
 return true
end
function RemoteInput.accept(place,action,value)
 if type(action)~="string" or #action<1 or #action>40 then return false end
 local kind=place=="main" and main[action] or (place=="hub" and hub[action] and "table" or nil)
 if not kind then return false end
 if kind=="none" then return value==nil end
 if kind=="optionalNumber" and value==nil then return true end
 if kind=="auto" and value==false then return true end
 if kind=="auto" then kind="table" elseif kind=="optionalNumber" then kind="number" end
 if type(value)~=kind then return false end
 return bounded(value,1,{}, {count=0})
end
return RemoteInput
