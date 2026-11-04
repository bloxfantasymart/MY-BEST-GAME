--!strict
-- Server-owned session course progress. Character identity, sequence and timing
-- are checked here; the caller must also verify server-observed position/health.
local Obby={}
Obby.Checkpoints=9
Obby.MinStepSeconds=0.35
Obby.MaxStepSeconds=45
Obby.MaxRunSeconds=180
Obby.ClaimWindow=60
Obby.Cooldown=6*60*60
Obby.Cash=50000
Obby.Vouchers=3

function Obby.touch(state,index,character,now)
 if type(index)~="number" or index%1~=0 or index<1 or index>Obby.Checkpoints or character==nil then return false end
 local run=state.obbyRun
 if index==1 then
  -- Multiple body parts can touch the first platform at once.
  if run and run.character==character and run.step==1 and now>=run.last and now-run.last<1 then return false end
  state.obbyRun={step=1,character=character,started=now,last=now,ready=false}
  return true
 end
 if not run or run.character~=character or run.ready or index~=run.step+1 then return false end
 local stepTime=now-run.last
 if stepTime<0 or now<run.started or stepTime>Obby.MaxStepSeconds or now-run.started>Obby.MaxRunSeconds then
  state.obbyRun=nil; return false
 end
 if stepTime<Obby.MinStepSeconds then return false end
 run.step=index; run.last=now
 if index==Obby.Checkpoints then run.ready=true end
 return true
end
function Obby.remaining(lastClaim,epoch)
 if not lastClaim or lastClaim==0 then return 0 end
 return math.max(0,lastClaim+Obby.Cooldown-epoch)
end
function Obby.status(state,character,now,epoch)
 local run=state.obbyRun
 if run and (run.character~=character or now<run.last or now<run.started
  or (run.ready and now-run.last>Obby.ClaimWindow)
  or (not run.ready and (now-run.last>Obby.MaxStepSeconds or now-run.started>Obby.MaxRunSeconds))) then
  state.obbyRun=nil; run=nil
 end
 return {step=run and run.step or 0,ready=run and run.ready or false,remaining=Obby.remaining(state.obbyLastClaim,epoch)}
end
function Obby.claim(state,character,now,epoch,maxVouchers)
 local run=state.obbyRun
 if not run or not run.ready or run.character~=character then return nil,"Complete the course first." end
 if now<run.last or now-run.last>Obby.ClaimWindow then state.obbyRun=nil; return nil,"Summit attempt expired. Start again." end
 if Obby.remaining(state.obbyLastClaim,epoch)>0 then return nil,"Summit reward is still on its six-hour cooldown." end
 if state.extras.rollVouchers+Obby.Vouchers>maxVouchers then return nil,"Use some vouchers before claiming." end
 -- No yields between validation and applying both rewards and the cooldown.
 state.obbyLastClaim=epoch; state.cash+=Obby.Cash; state.extras.rollVouchers+=Obby.Vouchers; state.obbyRun=nil
 return true
end
return Obby
