local first={frenzy=true,eclipse=true,sigma=false,storm=false,weekend=false}
local initial=EventPresentation.started(nil,first)
assert(#initial==2 and initial[1]:find("FRENZY",1,true) and initial[2]:find("ECLIPSE",1,true))
local previous=EventPresentation.copy(first); first.frenzy=false
assert(previous.frenzy and #EventPresentation.started(previous,previous)==0)
local nextFlags={frenzy=true,sigma=true,weekend=true}
local starts=EventPresentation.started(previous,nextFlags)
assert(#starts==2 and starts[1]:find("SIGMA",1,true) and starts[2]:find("WEEKEND",1,true))
assert(#EventPresentation.started(previous,nil)==0)
local falseFlags=EventPresentation.copy({frenzy="yes",storm=false})
assert(not falseFlags.frenzy and not falseFlags.storm and not falseFlags.sigma)
assert(#EventPresentation.started(falseFlags,{frenzy=true})==1)
print("Event start presentation and transition deduplication passed")
