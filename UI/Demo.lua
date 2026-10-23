local _, ns = ...
local D={sequence=1000000}
ns.Demo=D
function D:Item(group,index,age)
    self.sequence=self.sequence+1
    local examples={{"Stormforged blade","weapon","INVTYPE_WEAPON","WARRIOR",135274},
        {"Tideweave mantle","armor","INVTYPE_SHOULDER","MAGE",135040},
        {"Moonstone band","ring","INVTYPE_FINGER","DRUID",133345},
        {"Fabled talisman","trinket","INVTYPE_TRINKET","PRIEST",133304}}
    local sample=examples[(index-1)%#examples+1]
    return {id=self.sequence,revision=1,demo=true,timestamp=time()-(age or 0),equipment=true,loaded=true,
        player=({"ExampleWarrior","ExampleMage","ExampleDruid","ExamplePriest"})[(index-1)%4+1],realm="DemoRealm",
        itemName=sample[1],category=sample[2],equipLoc=sample[3],classToken=sample[4],icon=sample[5],rarity=index%2==0 and 3 or 4,
        itemLevel=310+index,quantity=1,context={instance=group==1 and "DEMO · Azure Halls" or "DEMO · Ember Citadel",
            instanceID=group,run=group,difficulty=group==1 and 8 or 2,difficultyName=group==1 and "Mythic+" or "Heroic",
            challenge=group==1 and {state="completed",mapID=1,startedAt=GetTime()} or nil}}
end
function D:Start()
    ns.Notification:Dismiss()
    ns.Session.demo=true; ns.Session.demoEntries={}
    for i=1,6 do ns.Session.demoEntries[#ns.Session.demoEntries+1]=self:Item(i<=4 and 1 or 2,i,i<=4 and 3 or 1100) end
    ns.Session:Changed(); ns.Session:ScheduleExpiry(); ns.Main:NewAward(4)
    ns:Print("DEMO enabled: simulated records, placeholder items, whispers disabled. /loottracker demo off restores real loot; demo burst adds simulated drops.")
end
function D:Stop()
    ns.Session.demo,ns.Session.demoEntries=nil,nil
    ns.Notification:Dismiss(); ns.Session:Changed(); ns.Session:ScheduleExpiry()
    ns:Print("DEMO removed. Genuine session loot is unchanged.")
end
function D:Burst()
    if not ns.Session.demo then self:Start(); return end
    for i=1,3 do ns.Session.demoEntries[#ns.Session.demoEntries+1]=self:Item(1,i) end
    while #ns.Session.demoEntries>60 do table.remove(ns.Session.demoEntries,1) end
    ns.Session:Changed(); ns.Session:ScheduleExpiry(); ns.Main:NewAward(3)
end
