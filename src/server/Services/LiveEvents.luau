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
-- Scheduled current or next occurrence, in UTC epoch seconds. Admin overrides
-- are deliberately separate from these deterministic global schedule windows.
local function occurrence(now,period,offset,duration)
 local cycle=math.floor(now/period)*period
 local start=cycle+offset
 if now>=start+duration then start+=period end
 return {startsAt=start,endsAt=start+duration,active=now>=start and now<start+duration}
end
function LiveEvents.forecast(now)
 local t=math.floor(now)
 -- Unix epoch began on a Thursday; first Friday 17:00 UTC is at 147600.
 local weekStart=86400+17*3600
 local weeklyCycle=math.floor((t-weekStart)/604800)*604800+weekStart
 local weekend={startsAt=weeklyCycle,endsAt=weeklyCycle+55*3600,active=t<weeklyCycle+55*3600}
 if not weekend.active then weekend.startsAt+=604800; weekend.endsAt+=604800 end
 return {at=t,events={
  frenzy=occurrence(t,1800,0,300),
  eclipse=occurrence(t,2700,0,180),
  sigma=occurrence(t,2700,900,120),
  storm=occurrence(t,2700,1800,120),
  weekend=weekend,
 }}
end
function LiveEvents.applyOverride(event,name,remaining)
 local fields={Frenzy="frenzy",Eclipse="eclipse",Sigma="sigma",Storm="storm"}
 local field=fields[name]
 if field then
  event[field]=true
  if type(remaining)=="number" and remaining==remaining and remaining>=0 and remaining<=120 then
   event.override={name=name,remaining=remaining}
  end
 end
 return event
end
-- Informational display only; rolling still uses authoritative event flags.
function LiveEvents.frenzyClock(event)
 local active=event.frenzy==true
 local override=event.override
 local remaining
 if active then
  remaining=event.frenzyOffset<300 and (300-event.frenzyOffset) or 0
  if override and override.name=="Frenzy" then remaining=math.max(remaining,override.remaining) end
 else remaining=1800-event.frenzyOffset end
 remaining=math.max(0,math.ceil(remaining))
 local time=string.format("%02d:%02d",math.floor(remaining/60),remaining%60)
 return {text=(active and "2x NON-COMMON WEIGHT\nACTIVE: " or "2x NON-COMMON WEIGHT\nIN: ")..time,
  active=active,progress=active and 1 or math.clamp(event.frenzyOffset/1800,0,1)}
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
