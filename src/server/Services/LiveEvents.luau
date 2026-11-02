--!strict
-- Shared UTC schedule, reproducible across servers without MessagingService.
local LiveEvents={}
function LiveEvents.at(now)
 local frenzyOffset=now%1800
 local disasterOffset=now%900
 local disasterCycle=math.floor(now/900)%3
 local utc=os.date("!*t",now)
 local weekend=utc.wday==7 or utc.wday==1 or (utc.wday==6 and utc.hour>=17)
 return {
  frenzy=frenzyOffset<300,
  eclipse=disasterCycle==0 and disasterOffset<180,
  sigma=disasterCycle==1 and disasterOffset<120,
  storm=disasterCycle==2 and disasterOffset<120,
  weekend=weekend,
  frenzyOffset=frenzyOffset,
  disasterOffset=disasterOffset,
 }
end
function LiveEvents.text(event)
 local names={}
 if event.frenzy then table.insert(names,"Luck Frenzy "..(300-event.frenzyOffset).."s") end
 if event.eclipse then table.insert(names,"Eclipse "..(180-event.disasterOffset).."s") end
 if event.sigma then table.insert(names,"Sigma "..(120-event.disasterOffset).."s") end
 if event.storm then table.insert(names,"Ohio Storm "..(120-event.disasterOffset).."s") end
 if event.weekend then table.insert(names,"Weekend: 1.5x luck / 2x income") end
 if #names>0 then return table.concat(names," | ") end
 return "Next event in "..math.min(1800-event.frenzyOffset,900-event.disasterOffset).."s"
end
return LiveEvents
