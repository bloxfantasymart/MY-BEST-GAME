local sizes={{320,568},{568,320},{390,844},{844,390},{768,1024},{1024,768},{1920,1080},{2560,1440},{240,240}}
for _,size in ipairs(sizes) do
 local w,h=size[1],size[2]
 local m=UILayout.main(w,h)
 assert(m.navWidth>0 and m.navHeight>0 and m.contentWidth>0)
 assert(m.navX>=0 and m.navX+m.navWidth<=w)
 assert(m.margin+5*m.navHeight+4*m.gap<=h, "All five navigation buttons must fit")
 assert(m.margin+m.contentWidth<=m.navX, "HUD must not overlap the navigation column")
 assert(m.panelWidth>0 and m.panelWidth<=w and m.panelHeight>0 and m.panelHeight<=h)
 local hub=UILayout.hub(w,h)
 assert(hub.headerWidth>0 and hub.settingsWidth>0 and hub.headerHeight>0)
 assert(hub.margin+hub.headerWidth<=w-hub.margin-hub.settingsWidth)
 assert(hub.panelWidth<=w and hub.panelHeight<=h)
end
assert(UILayout.rowHeight("Short",300)==50)
local long=string.rep("information ",20)
assert(UILayout.rowHeight(long,300)>UILayout.rowHeight(long,800))
assert(UILayout.rowHeight(string.rep("x",10000),240)==160)
assert(MotionPolicy.active(nil,false,100))
assert(MotionPolicy.active(100,false,100) and not MotionPolicy.active(100.1,false,100))
assert(not MotionPolicy.active(0,true,100) and not MotionPolicy.active(nil,true,100))
print("Responsive safe-area layout and motion policy tests passed")
for width=1,2000 do
 local guide=UILayout.guide(width,4)
 assert(guide.textWidth>=1 and guide.buttonWidth>=0 and guide.gap>=0)
 assert(guide.textWidth+guide.buttonWidth+guide.gap==width)
 if width>=2 then assert(guide.buttonWidth>=1 and guide.buttonWidth<=100) end
end
print("Tutorial goal control fits the content width")
