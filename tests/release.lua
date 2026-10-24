function run_release(ns)
    local count=0
    local function check(v,m) count=count+1; assert(v,m) end
    local function event(name,...) ns.eventFrame.scripts.OnEvent(ns.eventFrame,name,...) end
    event("ADDON_LOADED","DropWatch"); event("PLAYER_ENTERING_WORLD",true,false)
    local H,N=ns.Session,ns.Notification
    ns.db.displayMode="notification"
    local function award(id)
        return {id=id,timestamp=time(),equipment=true,loaded=true,rarity=4,category="armor",player="Other",realm="Realm",
            itemID=123,itemName="Fixture",quantity=1,context={instance="Fixture",instanceID=123,difficulty=8,run=1}}
    end
    local originalLimit=H.limit; H.limit=5
    for id=1,100 do H:Put(award(id),true); TestAPI.advance(1) end
    local ids=0; for _ in pairs(N.ids) do ids=ids+1 end
    check(#H.entries==5 and ids==5 and N.count==5,"continuous awards bound notification tracking to retained session capacity")
    check(not N.ids[1] and N.ids[100],"eviction retracts only oldest outstanding contribution")
    local current=award(100); current.itemLevel=320
    H:Put(current,true); H:Put(current,true)
    check(N.count==5,"repeated enrichment cannot inflate a continuous notification batch")
    H:Remove(100)
    check(N.count==4 and not N.ids[100],"actual record removal retracts its outstanding notification")
    H:Remove(100); check(N.count==4,"repeat removal is harmless")
    for id=96,99 do H:Remove(id) end
    check(N.count==0 and not N.frame:IsShown(),"removing last retained award dismisses notification")
    H.limit=originalLimit; ns:Clear()
    -- A pending equippable observation later classifies as irrelevant.
    local oldInfo,oldInstant=C_Item.GetItemInfo,C_Item.GetItemInfoInstant
    C_Item.GetItemInfo=function() return nil end
    local link="|cffa335ee|Hitem:123|h[Fixture]|h|r"
    event("CHAT_MSG_LOOT","Other-Realm receives loot: "..link..".")
    check(#H.entries==0 and N.count==0,"equipment with unknown quality must wait before notifying")
    C_Item.GetItemInfoInstant=function() return 123,"Junk","Junk","",456,15,0 end
    C_Item.GetItemInfo=function() return "Junk",link,1,1,1,"Junk","Junk",1,"",456,1,15,0 end
    event("ITEM_DATA_LOAD_RESULT",123,true)
    check(#H.entries==0 and N.count==0 and not N.frame:IsShown(),"delayed irrelevant removal retracts notification")
    check(#ns.records==1 and #ns.raw>0,"raw/processed evidence survives irrelevant classification")
    C_Item.GetItemInfo,C_Item.GetItemInfoInstant=oldInfo,oldInstant
    ns:Clear(); ns.db.displayMode="manual"
    -- Group disband and leaving an instance cannot mutate earlier award context.
    event("CHAT_MSG_LOOT","Other-Realm receives loot: "..link..".")
    local record=ns.normalized[1]; local instance=record.context.instanceID
    GetInstanceInfo=function() return "World","none",0,"Normal",0,0,false,0,0 end
    event("GROUP_ROSTER_UPDATE"); event("PLAYER_ENTERING_WORLD",false,false)
    check(record.context.instanceID==instance and #H:Records(true)==1,"world/group changes preserve existing award snapshots")
    local row=ns.ItemRow:Create(UIParent)
    ns.ItemRow:Update(row,record,380)
    local originalTooltip=GameTooltip.SetHyperlink
    GameTooltip.SetHyperlink=function() error("unavailable tooltip") end
    GameTooltip:Show(); row.item.scripts.OnEnter(row.item)
    check(not GameTooltip:IsShown(),"failed native item query hides stale tooltip content")
    GameTooltip.SetHyperlink=originalTooltip; row.item.scripts.OnEnter(row.item)
    check(GameTooltip:IsShown() and GameTooltip.hyperlink==link,"successful tooltip still uses original item link")
    check(not ns.listenerErrors,"release regression subscriber callbacks succeed")
    print("PASS: "..count.." release stability assertions")
end
