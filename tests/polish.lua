function run_polish(ns)
    local count=0
    local function check(v,m) count=count+1; assert(v,m) end
    local function event(name,...) ns.eventFrame.scripts.OnEvent(ns.eventFrame,name,...) end
    event("ADDON_LOADED","LootTracker"); event("PLAYER_ENTERING_WORLD",true,false)
    local M,H=ns.Main,ns.Session
    ns.db.displayMode="manual"
    local link="|cffa335ee|Hitem:123:0:0:0:0:0:0:0:80:0:0:2:1:2|h[Test Helm]|h|r"
    local function award(id,age)
        return {id=id,timestamp=time()-(age or 0),equipment=true,loaded=true,itemID=123,link=link,
            itemName="Helm",category="armor",player="Other",realm="Realm",quantity=1,
            context={instance="Test",instanceID=123,difficulty=8,run=1}}
    end
    local function put(r) H:Put(r,true); M:Render() end
    M:Show("loot"); local width=M.frame:GetWidth(); local empty=M.frame:GetHeight()
    check(not M.scrollbar:IsShown(),"1 empty scrollbar hidden")
    check(M.scroll.template==nil and M.scrollbar.template==nil and M.scrollbar:GetWidth()==4,"plain native scrollbar has no inherited arrows")
    put(award(1)); local one=M.frame:GetHeight()
    check(not M.scrollbar:IsShown() and one>=empty,"1 one item fits")
    put(award(2)); put(award(3)); local three=M.frame:GetHeight()
    check(three>one and three<=ns.db.window.height,"4 grows with content")
    local anchor={M.frame:GetPoint()}
    for i=4,20 do put(award(i)) end
    check(M.scrollbar:IsShown() and M.scrollMaximum>0,"2 overflow scrollbar visible")
    M.scroll.scripts.OnMouseWheel(M.scroll,-1)
    check(M.scroll:GetVerticalScroll()==51,"3 wheel scroll")
    M.scrollbar.scripts.OnValueChanged(M.scrollbar,80)
    check(M.scroll:GetVerticalScroll()==80,"thumb value maps to content offset")
    check(M.frame:GetWidth()==width,"9 adaptive width unchanged")
    local current={M.frame:GetPoint()}
    check(current[1]=="TOPLEFT" and current[4]==anchor[4] and current[5]==anchor[5],"15 top anchor stable")
    M.scrollbar.scripts.OnMouseDown(M.scrollbar)
    local held=M.frame:GetHeight()
    H:Clear(); M:Render()
    check(M.frame:GetHeight()==held,"active scroll interaction suspends adaptive resize")
    M.scrollbar.scripts.OnMouseUp(M.scrollbar)
    check(M.frame:GetHeight()<held and not M.scrollbar:IsShown(),"release adapts and hides scrollbar")
    put(award(21)); put(award(22)); put(award(23)); local before=M.frame:GetHeight()
    TestAPI.advance(900); M:Render()
    check(M.frame:GetHeight()<before and #H:Records(true)==0,"5 expiry shrinks panel")
    M:SetTab("history"); local expanded=M.frame:GetHeight()
    local key=H:Groups()[1].key
    M.collapsed[key]=true; M:Render(); local collapsed=M.frame:GetHeight()
    check(collapsed<expanded,"7 history collapse shrinks")
    M.collapsed[key]=nil; M:Render()
    check(M.frame:GetHeight()==expanded,"6 history expand grows")
    M.resize.scripts.OnMouseDown(M.resize,"LeftButton"); M.frame:SetSize(530,410)
    M.resize.scripts.OnMouseUp(M.resize)
    check(ns.db.window.width==530 and ns.db.window.height==410,"8 manual resize saves preferred dimensions")
    M:SaveWindow(); check(ns.db.window.height==410,"move/save does not overwrite maximum with adaptive height")
    ns.Settings:Create()
    local P=ns.Settings
    local default={P.frame:GetPoint()}
    check(default[1]=="CENTER" and default[4]==0 and default[5]==0,"settings default centered")
    P.frame:SetPoint("TOPLEFT",UIParent,"TOPLEFT",50,-60)
    P.bar.scripts.OnDragStop(P.bar); ns:LoadSettings()
    check(ns.db.settingsPosition.x==50 and ns.db.settingsPosition.y==-60,"10 independent settings position persists")
    local mainPoint={M.frame:GetPoint()}
    check(mainPoint[4]~=50 and P.frame~=M.frame,"11 settings movement independent")
    for _,opacity in ipairs({.2,.5,.75,1}) do
        P:Set("opacity",opacity)
        check(M.frame.backgroundColor[4]==opacity and P.frame.backgroundColor[4]==.96,"12 opacity limited to main backdrop")
        check(M.frame.alpha==nil and M.lootTab.alpha==nil and M.lootTab.backgroundColor[4]==.94 and M.frame.borderColor[4]==1,"12 controls and border remain opaque")
    end
    M:Minimize(true); check(M.frame:GetHeight()==32 and not M.scrollbar:IsShown(),"13 minimized state distinct")
    M:Minimize(false)
    check(M.frame:GetHeight()<=410 and ns.db.window.height==410 and not M.minimized,"13 restore uses adaptive maximum")
    H:Clear(); ns.db.displayMode="notification"; put(award(30))
    check(ns.Notification.frame:IsShown() and ns.Notification.count==1,"14 compact notification preserved")
    local filtered=award(30); filtered.bindingCategory="warbound"; filtered.classificationConfidence="confirmed"
    filtered.tradeability="confirmed-ineligible"; filtered.exclusionReason="Account / Warband binding"
    put(filtered)
    check(#H:Records(true)==0 and #H:Groups()==0 and not ns.Notification.frame:IsShown(),"22 delayed exclusion removes views and retracts notification")
    ns:Clear(); ns.db.displayMode="automatic"; M:Close()
    Enum={ItemBind={OnAcquire=1,OnEquip=2,ToWoWAccount=7,ToBnetAccount=8,ToBnetAccountUntilEquipped=9}}
    local untilEquip,account=false,false
    C_Item.IsItemBindToAccountUntilEquip=function(query) check(query==link,"binding API receives original link"); return untilEquip end
    C_Item.IsItemBindToAccount=function() return account end
    untilEquip=true
    event("CHAT_MSG_LOOT","Other-Realm receives loot: "..link..".")
    local canonical=ns.normalized[1]
    check(canonical.bindingCategory=="warbound" and not ns.Presentation:Visible(canonical),"16 confirmed Warbound excluded")
    check(#H:Records(true)==0 and #H:Groups()==0 and not M.frame:IsShown(),"16 filtered award cannot open automatic panel")
    check(#ns.records==1 and #ns.raw>=1 and #ns.normalized==1 and canonical.exclusionReason,"21 diagnostic evidence retained")
    event("ENCOUNTER_LOOT_RECEIVED",900,123,link,1,"Other-Realm","MAGE")
    check(#ns.normalized==1 and #canonical.observations==2,"23 filtering leaves cross-source dedup intact")
    C_Item.IsItemBindToAccountUntilEquip=function() return nil end
    ns.Normalize:Rebuild(canonical,"enriched")
    check(not ns.Presentation:Visible(canonical),"confirmed binding proof survives transient unavailable cache")
    C_Item.IsItemBindToAccountUntilEquip=function() return untilEquip end
    event("CHAT_MSG_LOOT","Different-Realm receives loot: "..link..".")
    check(#ns.normalized==2,"24 different players remain separate")
    untilEquip=nil; account=TestAPI.secret
    local unknown=award(100); ns.Presentation:Classify(unknown)
    check(ns.Presentation:Visible(unknown) and unknown.tradeability=="unknown","17 nil/secret binding stays visible")
    C_Item.IsItemBindToAccountUntilEquip=function() error("restricted") end
    ns.Presentation:Classify(unknown); check(ns.Presentation:Visible(unknown),"API error stays visible")
    C_Item.IsItemBindToAccountUntilEquip=nil; C_Item.IsItemBindToAccount=nil
    local soul=award(101); soul.bindType=1; ns.Presentation:Classify(soul)
    check(soul.bindingCategory=="soulbound" and ns.Presentation:Visible(soul),"18 ordinary Soulbound stays visible")
    local bonus=award(102); bonus.observations={{format="LOOT_ITEM_BONUS_ROLL_SELF",acquisition="loot"}}
    ns.Presentation:Classify(bonus)
    check(bonus.rewardSource=="bonus-roll" and ns.Presentation:Visible(bonus),"20 uncertain bonus remains visible")
    bonus.bindType=9; ns.Presentation:Classify(bonus)
    check(not ns.Presentation:Visible(bonus) and bonus.rewardSource=="bonus-roll","19 bonus with confirmed account binding excluded")
    account=true; C_Item.IsItemBindToAccount=function() return account end
    local warband=award(103); ns.Presentation:Classify(warband)
    check(not ns.Presentation:Visible(warband),"account-bound API true excludes")
    for _,bind in ipairs({7,8,9}) do
        C_Item.IsItemBindToAccount=nil
        local r=award(104); r.bindType=bind; ns.Presentation:Classify(r)
        check(not ns.Presentation:Visible(r),"runtime account bind enum "..bind)
    end
    -- Fully loaded item, binding API initially unavailable: bounded async reclassification.
    ns:Clear(); ns.db.displayMode="notification"; M:Close(); untilEquip=nil
    C_Item.IsItemBindToAccountUntilEquip=function() return untilEquip end
    event("CHAT_MSG_LOOT","Other-Realm receives loot: "..link..".")
    canonical=ns.normalized[1]; local id=canonical.id
    check(#H:Records(true)==1 and ns.records[1].deadline,"unknown cached binding gets bounded retry")
    untilEquip=true; event("ITEM_DATA_LOAD_RESULT",123,true)
    check(ns.normalized[1].id==id and #H:Records(true)==0 and canonical.exclusionReason,"22 async classification updates canonical in place")
    check(not ns.Notification.frame:IsShown() and #ns.normalized==1,"async exclusion retracts notification and preserves diagnostic record")
    ns:Clear(); ns.db.displayMode="notification"; untilEquip=false
    LOOT_ITEM_BONUS_ROLL="%s receives bonus loot: %s."
    event("CHAT_MSG_LOOT","Other-Realm receives bonus loot: "..link..".")
    check(ns.normalized[1].rewardSource=="bonus-roll" and #H:Records(true)==1,"localized bonus source stays visible without exclusion proof")
    ns:Clear(); untilEquip=true
    event("CHAT_MSG_LOOT","Other-Realm receives bonus loot: "..link..".")
    check(ns.normalized[1].rewardSource=="bonus-roll" and #H:Records(true)==0 and not ns.Notification.frame:IsShown(),"confirmed Warbound bonus does not notify")
    C_Item.IsItemBindToAccountUntilEquip=nil; C_Item.IsItemBindToAccount=nil; Enum=nil
    local noEnum=award(200); noEnum.bindType=9; ns.Presentation:Classify(noEnum)
    check(ns.Presentation:Visible(noEnum),"unknown enum values never guessed")
    ns.Settings:Set("locked",true)
    check(not M.resize:IsShown(),"locked panel hides custom grip")
    ns.Settings:Set("locked",false)
    check(M.resize:IsShown(),"unlocked panel restores grip")
    check(not ns.listenerErrors,"no subscriber errors")
    print("PASS: "..count.." UI polish/filter assertions (mock native APIs, Lua 5.1)")
end
