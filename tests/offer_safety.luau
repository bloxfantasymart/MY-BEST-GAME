assert(OfferSafety.canRoll({},false))
assert(not OfferSafety.canRoll({},true))
local offers={{id="a"},{id="b"},{id="c"}}
assert(not OfferSafety.canRoll(offers,false))
assert(OfferSafety.matches(offers,{"a","b","c"}))
assert(not OfferSafety.matches(offers,{"b","a","c"}))
assert(not OfferSafety.matches(offers,{"a","b"}))
assert(not OfferSafety.matches(offers,{"a","a","c"}))
assert(not OfferSafety.matches(offers,{"a","b","missing"}))
assert(not OfferSafety.matches(offers,{"a","b",{}}))
assert(not OfferSafety.matches(offers,nil))
assert(not OfferSafety.matches({},{}))
local dict={"a","b","c"}; dict.extra="c"
assert(not OfferSafety.matches(offers,dict))
local sparse={[1]="a",[3]="c"}; assert(not OfferSafety.matches(offers,sparse))
local current={{id="new"},{id="b"},{id="c"}}
assert(not OfferSafety.matches(current,{"a","b","c"}), "A stale discard must not remove new offers")
assert(not OfferSafety.matches({{id="a"},{id="a"}},{"a","a"}))
local nine,nineIds={},{}
for i=1,9 do nine[i]={id=tostring(i)}; nineIds[i]=tostring(i) end
assert(OfferSafety.matches(nine,nineIds))
table.insert(nine,{id="10"}); table.insert(nineIds,"10"); assert(not OfferSafety.matches(nine,nineIds))
print("Roll gating and exact reviewed offer matching passed")
assert(not OfferSafety.matches({{id=""}},{""}))
assert(not OfferSafety.matches({{id="a"}}, {[1]="a",[1.5]="x"})) -- invalid key is rejected before any removal
