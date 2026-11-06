--!strict
-- Pure sizing calculations for the actual safe-area frame, not the physical screen.
local UILayout={}
local function dimensions(width,height)
 return math.max(1,math.floor(width)),math.max(1,math.floor(height))
end
function UILayout.main(width,height)
 local w,h=dimensions(width,height)
 local margin=math.min(8,math.floor(w/20),math.floor(h/20))
 local gap=math.min(4,math.floor(h/30))
 local navWidth=math.min(120,math.floor(w*0.4),math.max(72,math.floor(w*0.25)))
 local navHeight=math.max(1,math.min(48,math.floor((h-2*margin-4*gap)/5)))
 local contentWidth=math.max(1,w-navWidth-3*margin)
 local panelWidth=math.max(1,math.min(940,w-2*margin,math.floor(w*0.92)))
 local panelHeight=math.max(1,math.min(700,h-2*margin,math.floor(h*0.88)))
 local hudHeight=math.max(1,math.min(55,math.floor(h*0.16)))
 local lineHeight=math.max(1,math.min(28,math.floor(h*0.08)))
 return {margin=margin,gap=gap,navWidth=navWidth,navHeight=navHeight,navX=w-margin-navWidth,
  contentWidth=contentWidth,hudHeight=hudHeight,lineHeight=lineHeight,panelWidth=panelWidth,panelHeight=panelHeight}
end
function UILayout.guide(contentWidth,requestedGap)
 local width=math.max(1,math.floor(contentWidth))
 if width<2 then return {textWidth=width,buttonWidth=0,gap=0} end
 local buttonWidth=math.max(1,math.min(100,math.floor(width*0.32)))
 local gap=math.max(0,math.min(math.floor(requestedGap),width-buttonWidth-1))
 return {textWidth=width-buttonWidth-gap,buttonWidth=buttonWidth,gap=gap}
end
function UILayout.hub(width,height)
 local w,h=dimensions(width,height)
 local margin=math.min(8,math.floor(w/20),math.floor(h/20))
 local settingsWidth=math.min(110,math.floor(w*0.34))
 return {margin=margin,settingsWidth=settingsWidth,headerWidth=math.max(1,w-settingsWidth-3*margin),
  headerHeight=math.max(1,math.min(65,math.floor(h*0.2))),
  panelWidth=math.max(1,math.min(940,w-2*margin,math.floor(w*0.92))),
  panelHeight=math.max(1,math.min(700,h-2*margin,math.floor(h*0.88)))}
end
function UILayout.rowHeight(text,panelWidth)
 local length=type(text)=="string" and #text or 0
 local perLine=math.max(12,math.floor((panelWidth-35)/8))
 return math.max(50,math.min(160,math.ceil(length/perLine)*18+14))
end
return UILayout
