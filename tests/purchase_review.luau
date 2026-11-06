local function offer(id,mutation)
 return {id=id,name="Dirt",kind="Head",rarity=1,income=2,price=20,mutation=mutation or "Standard",mutationMultiplier=mutation and 2.5 or 1,rarityChance=0.5,exactChance=0.1}
end
local function fresh()
 return {cash=50,parts={},creatures={},rolls={offer("a"),offer("b","Golden")},extras={rollVouchers=1},offerExpires=60,autoRolling=false}
end
local s=fresh()
local function review(id,voucher,now,token,capacity)
 local q=PurchaseReview.review(s,id or "a",voucher==true,capacity or 10,now or 1,token or "token"); s.purchaseQuote=q; return q
end
assert(not PurchaseReview.review(s,"a","false",10,1,"token"))
assert(not PurchaseReview.review(s,"",false,10,1,"token") and not PurchaseReview.review(s,"a",false,10,1,""))
assert(not review("missing") and not review("a",false,1,"token",0))
s.autoRolling=true; assert(not review()); s.autoRolling=false
s.cash=19; assert(not review()); s.cash=50
s.extras.rollVouchers=0; assert(not review("a",true)); s.extras.rollVouchers=1
assert(not review("a",false,60))
local q=review(); assert(q and q.expires==60 and q.item.id=="a" and not q.willProtect and not q.voucher)
assert(not PurchaseReview.confirm(s,"wrong",10,2,Inventory) and s.cash==50 and #s.parts==0 and #s.rolls==2)
assert(not PurchaseReview.confirm(s,"token",10,2,Inventory))
q=review(); assert(not PurchaseReview.confirm(s,"token",10,60,Inventory) and s.cash==50)
q=review(); s.rolls[1].price=21; assert(not PurchaseReview.confirm(s,"token",10,2,Inventory) and s.cash==50); s.rolls[1].price=20
q=review(); s.rolls[1].exactChance=0.2; assert(not PurchaseReview.confirm(s,"token",10,2,Inventory)); s.rolls[1].exactChance=0.1
q=review(); s.manualProtectMutations=false; assert(not PurchaseReview.confirm(s,"token",10,2,Inventory)); s.manualProtectMutations=true
q=review(); s.cash=19; assert(not PurchaseReview.confirm(s,"token",10,2,Inventory)); s.cash=50
q=review(); assert(not PurchaseReview.confirm(s,"token",0,2,Inventory) and s.cash==50)
q=review(); s.autoRolling=true; assert(not PurchaseReview.confirm(s,"token",10,2,Inventory)); s.autoRolling=false
q=review(); local removed=table.remove(s.rolls,1); assert(ItemIds.collect(s).a, "A stale review must reserve the offer ID")
assert(not PurchaseReview.confirm(s,"token",10,2,Inventory)); table.insert(s.rolls,1,removed)
q=review(); local item=PurchaseReview.confirm(s,"token",10,2,Inventory)
assert(item and item.id=="a" and not item.locked and s.cash==30 and #s.parts==1 and #s.rolls==1 and s.offerExpires==60)
assert(not PurchaseReview.confirm(s,"token",10,2,Inventory) and s.cash==30)
q=review("b",true); assert(q and q.willProtect and q.voucher and q.item.price==20)
item=PurchaseReview.confirm(s,"token",10,2,Inventory)
assert(item and item.locked and s.cash==30 and s.extras.rollVouchers==0 and #s.parts==2 and s.offerExpires==0)
-- Explicit opt-out is captured in the review; it cannot silently change afterward.
s=fresh(); s.manualProtectMutations=false
q=review("b",false); assert(q and not q.willProtect)
item=PurchaseReview.confirm(s,"token",10,2,Inventory); assert(item and not item.locked and s.cash==30)
-- A new review supersedes the previous one; a wrong token consumes the quote.
s=fresh(); q=review("a",false,1,"old"); local replacement=review("b",true,2,"new")
assert(replacement and not PurchaseReview.confirm(s,"old",10,3,Inventory) and not PurchaseReview.confirm(s,"new",10,3,Inventory))
assert(s.cash==50 and s.extras.rollVouchers==1 and #s.parts==0)
print("Reviewed cash and voucher purchases, protection, expiry, stale state and replay passed")
-- Batch quote is all cash, exact order, and atomic even when one offer changes.
s=fresh()
local function batch(now,token,capacity)
 local result=PurchaseReview.reviewAll(s,capacity or 10,now or 1,token or "batch"); s.purchaseQuote=result; return result
end
q=batch(); assert(q and q.kind=="all" and q.total==40 and #q.items==2 and not q.items[1].willProtect and q.items[2].willProtect)
assert(not PurchaseReview.confirmAll(s,"wrong",10,2) and s.cash==50 and #s.rolls==2 and #s.parts==0)
assert(not PurchaseReview.confirmAll(s,"batch",10,2))
q=batch(); assert(not PurchaseReview.confirm(s,"batch",10,2,Inventory) and s.cash==50)
q=review(); assert(not PurchaseReview.confirmAll(s,"token",10,2) and s.cash==50)
q=batch(); assert(not PurchaseReview.confirmAll(s,"batch",10,60) and #s.rolls==2)
q=batch(); s.rolls[2].price=21; assert(not PurchaseReview.confirmAll(s,"batch",10,2) and s.cash==50 and #s.parts==0); s.rolls[2].price=20
q=batch(); s.rolls[1],s.rolls[2]=s.rolls[2],s.rolls[1]; assert(not PurchaseReview.confirmAll(s,"batch",10,2) and s.cash==50); s.rolls[1],s.rolls[2]=s.rolls[2],s.rolls[1]
q=batch(); local removedBatch=table.remove(s.rolls,2); assert(ItemIds.collect(s).b); assert(not PurchaseReview.confirmAll(s,"batch",10,2)); table.insert(s.rolls,removedBatch)
q=batch(); table.insert(s.rolls,offer("new")); assert(not PurchaseReview.confirmAll(s,"batch",10,2)); table.remove(s.rolls,3)
q=batch(); s.manualProtectMutations=false; assert(not PurchaseReview.confirmAll(s,"batch",10,2)); s.manualProtectMutations=true
q=batch(); s.cash=39; assert(not PurchaseReview.confirmAll(s,"batch",10,2) and s.cash==39 and #s.parts==0); s.cash=50
q=batch(); assert(not PurchaseReview.confirmAll(s,"batch",1,2) and s.cash==50)
s.cash=30; assert(not batch() and #s.rolls==2 and #s.parts==0); s.cash=50
q=batch(); local result=PurchaseReview.confirmAll(s,"batch",10,2)
assert(result and s.cash==10 and #s.parts==2 and #s.rolls==0 and s.offerExpires==0 and s.extras.rollVouchers==1)
assert(not s.parts[1].locked and s.parts[2].locked and not PurchaseReview.confirmAll(s,"batch",10,2))
-- Nine-offer token batches use the same all-or-nothing bounds.
s=fresh(); s.rolls={}; s.cash=200; s.manualProtectMutations=false
for i=1,9 do table.insert(s.rolls,offer("id"..i,"Golden")) end
q=batch(); assert(q and #q.items==9 and q.total==180 and not q.items[1].willProtect)
assert(PurchaseReview.confirmAll(s,"batch",9,2) and #s.parts==9 and s.cash==20)
for _,p in ipairs(s.parts) do assert(not p.locked) end
s=fresh(); s.rolls={offer("only")}; assert(not batch())
s=fresh(); s.rolls={offer("duplicate"),offer("duplicate")}; assert(not batch() and #s.parts==0)
s=fresh(); s.offerExpires=5; q=batch(2); assert(q and q.expires==5 and not PurchaseReview.confirmAll(s,"batch",10,5))
print("Reviewed batch purchase, cross-mode tokens, capacity, staleness and all-or-nothing commit passed")
