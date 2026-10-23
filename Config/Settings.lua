local _, ns = ...
function ns:LoadSettings()
    local old = type(LootTrackerDB) == "table" and LootTrackerDB or {}
    -- Rebuild the saved table: records and arbitrary old fields never persist.
    self.db = {
        debug = old.debug == true,
        trackMounts = old.trackMounts == true,
        maxRecords = 200,
        displayMode = (old.displayMode=="notification" or old.displayMode=="manual") and old.displayMode or "automatic",
        opacity = math.max(0.2,math.min(1,ns.Safe.Value(old.opacity,"number") or 0.88)),
        locked = old.locked == true,
        hideMinimap = old.hideMinimap == true,
        minimapAngle = (ns.Safe.Value(old.minimapAngle,"number") or 45)%360,
        window = { point="CENTER", relativePoint="CENTER", x=0, y=0, width=420, height=300 },
        settingsPosition = { point="CENTER", relativePoint="CENTER", x=0, y=0 },
        position = { point = "CENTER", relativePoint = "CENTER", x = 0, y = 0 },
    }
    local points = { CENTER=true, TOP=true, BOTTOM=true, LEFT=true, RIGHT=true,
        TOPLEFT=true, TOPRIGHT=true, BOTTOMLEFT=true, BOTTOMRIGHT=true }
    if type(old.position) == "table" then
        local p = old.position
        if points[p.point] and points[p.relativePoint] and type(p.x) == "number" and type(p.y) == "number"
            and math.abs(p.x) < 10000 and math.abs(p.y) < 10000 then
            self.db.position = { point=p.point, relativePoint=p.relativePoint, x=p.x, y=p.y }
        end
    end
    if type(old.window)=="table" then
        local p=old.window
        local x,y=ns.Safe.Value(p.x,"number"),ns.Safe.Value(p.y,"number")
        if points[p.point] and points[p.relativePoint] and x and y and math.abs(x)<10000 and math.abs(y)<10000 then
            self.db.window.point,self.db.window.relativePoint,self.db.window.x,self.db.window.y=p.point,p.relativePoint,x,y
        end
        self.db.window.width=math.max(360,math.min(1000,ns.Safe.Value(p.width,"number") or 420))
        self.db.window.height=math.max(180,math.min(900,ns.Safe.Value(p.height,"number") or 300))
    end
    if type(old.settingsPosition)=="table" then
        local p=old.settingsPosition
        local x,y=ns.Safe.Value(p.x,"number"),ns.Safe.Value(p.y,"number")
        if points[p.point] and points[p.relativePoint] and x and y and math.abs(x)<10000 and math.abs(y)<10000 then
            self.db.settingsPosition={point=p.point,relativePoint=p.relativePoint,x=x,y=y}
        end
    end
    LootTrackerDB = self.db
end
