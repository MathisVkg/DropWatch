function run_minimap(ns)
    local checks=0
    local function check(value,message) checks=checks+1; assert(value,message) end
    local function close(a,b) return math.abs(a-b)<0.000001 end
    local function event(name,...) ns.eventFrame.scripts.OnEvent(ns.eventFrame,name,...) end
    event("ADDON_LOADED","DropWatch"); event("PLAYER_ENTERING_WORLD",true,false)
    local B,button=ns.Minimap,ns.Main.minimap
    check(B.button==button and button.parent==Minimap,"button is parented to actual Minimap")
    check(ns.db.minimapAngle==45,"upgrade default angle is upper-right 45 degrees")
    check(button.icon.texture=="Interface/AddOns/DropWatch/Assets/DropWatch-Mini.tga","custom artwork preserved")
    local function position(angle)
        ns.db.minimapAngle=angle; B:Position()
        local p={button:GetPoint()}
        check(p[1]=="CENTER" and p[2]==Minimap and p[3]=="CENTER","center anchored to real map")
        local expected=math.min(Minimap:GetWidth(),Minimap:GetHeight())/2
        check(close(p[4],math.cos(math.rad(angle))*expected) and close(p[5],math.sin(math.rad(angle))*expected),"polar position uses live dimensions")
        check(close(math.sqrt(p[4]^2+p[5]^2),expected),"center stays on circular orbit")
    end
    for _,size in ipairs({120,150,240}) do
        Minimap:SetSize(size,size)
        for _,scale in ipairs({0.64,1,1.5}) do
            Minimap.scale=scale
            for _,angle in ipairs({0,45,90,180,225,270,359}) do position(angle) end
        end
    end
    Minimap:SetSize(220,160); position(135)
    button:SetSize(40,40); position(315)
    button:SetSize(30,30); Minimap:SetSize(150,150)
    local x,y
    function GetCursorPosition() return x,y end
    for _,scale in ipairs({0.64,1,1.5}) do
        Minimap.scale=scale
        for _,angle in ipairs({0,45,90,135,180,225,270,315}) do
            local radians=math.rad(angle)
            x,y=(500+100*math.cos(radians))*scale,(400+100*math.sin(radians))*scale
            button.scripts.OnDragStart(button)
            check(button.dragging and button.scripts.OnUpdate,"drag enables temporary update")
            button.scripts.OnUpdate(button,.01)
            check(close(ns.db.minimapAngle,angle),"cursor converts physical pixels through effective map scale")
            button.scripts.OnEvent(button,"GLOBAL_MOUSE_UP","LeftButton")
            check(not button.dragging and not button.scripts.OnUpdate,"outside release stops drag update")
        end
    end
    -- Resize/show/scale invalidation keeps the same saved angular location.
    ns.db.minimapAngle=90; B:Position(); Minimap:SetSize(240,240)
    local p={button:GetPoint()}; check(close(p[5],120),"map resize hook recomputes orbit")
    ns.db.minimapAngle=180; button.scripts.OnEvent(button,"UI_SCALE_CHANGED")
    p={button:GetPoint()}; check(close(p[4],-120),"scale event refreshes polar anchor")
    ns.db.minimapAngle=270; button.scripts.OnEvent(button,"DISPLAY_SIZE_CHANGED")
    p={button:GetPoint()}; check(close(p[5],-120),"display event refreshes anchor")
    ns.db.minimapAngle=0; Minimap:Hide(); Minimap:Show()
    p={button:GetPoint()}; check(close(p[4],120),"map show hook recomputes position")
    -- Center/no layout/restricted geometry must leave the angle unchanged.
    x,y=500*Minimap.scale,400*Minimap.scale
    button.scripts.OnDragStart(button)
    check(ns.db.minimapAngle==0,"cursor at center preserves last angle")
    button.scripts.OnDragStop(button)
    Minimap:SetSize(0,0); B:Position()
    check(ns.db.minimapAngle==0,"unlaid-out map preserves saved angle")
    Minimap:SetSize(150,150)
    local center=Minimap.GetCenter
    Minimap.GetCenter=function() return nil,nil end
    button.scripts.OnDragStart(button); button.scripts.OnDragStop(button)
    check(ns.db.minimapAngle==0,"unavailable center does not corrupt saved angle")
    Minimap.GetCenter=center
    -- Persistence validation is shared by reload and a genuine new login.
    for _,pair in ipairs({{405,45},{-90,270},{720,0},{123.5,123.5}}) do
        ns.db.minimapAngle=pair[1]; ns:LoadSettings()
        check(ns.db.minimapAngle==pair[2],"finite saved angles normalize to 0..360")
    end
    for _,bad in ipairs({"bad",math.huge,0/0,TestAPI.secret}) do
        ns.db.minimapAngle=bad; ns:LoadSettings()
        check(ns.db.minimapAngle==45,"invalid saved angle uses safe default")
    end
    ns.db.minimapAngle=123.5; ns:LoadSettings(); B:Refresh()
    check(ns.db.minimapAngle==123.5 and LootTrackerDB.minimapAngle==123.5,"angle survives SavedVariables rebuild")
    -- Hide during drag stops updates; showing restores the chosen angle.
    Minimap.scale=1; x,y=400,400
    button.scripts.OnDragStart(button); ns.Settings:Set("hideMinimap",true)
    check(not button:IsShown() and not button.dragging and not button.scripts.OnUpdate,"hide interrupts drag cleanly")
    local saved=ns.db.minimapAngle
    ns.Settings:Set("hideMinimap",false)
    check(button:IsShown() and ns.db.minimapAngle==saved,"show restores saved position")
    -- Drag release does not toggle the panel; subsequent deliberate clicks do.
    local toggles,settings=0,0
    ns.Main.Toggle=function() toggles=toggles+1 end
    ns.Settings.Toggle=function() settings=settings+1 end
    button.scripts.OnDragStart(button); button.scripts.OnDragStop(button)
    button.scripts.OnClick(button,"LeftButton")
    check(toggles==0,"drag-release click suppressed")
    TestAPI.advance(.11); button.scripts.OnClick(button,"LeftButton")
    button.scripts.OnClick(button,"RightButton")
    check(toggles==1 and settings==1,"normal left/right clicks preserved")
    button.scripts.OnEnter(button)
    check(GameTooltip:IsShown() and GameTooltip.text:find("Drag:",1,true),"tooltip describes click and drag controls")
    button.scripts.OnLeave(button); check(not GameTooltip:IsShown(),"tooltip hides on leave")
    local same=B.button; B:Initialize()
    check(B.button==same,"initialization idempotent")
    check(not button.scripts.OnUpdate,"idle button has no polling update")
    print("PASS: "..checks.." minimap positioning/drag assertions (mock geometry and UI scale)")
end
