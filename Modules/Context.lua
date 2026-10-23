local _, ns = ...
local C, S = { run=0 }, ns.Safe
ns.Context = C
local function copy(value)
    if not value then return end
    local result={}
    for key, child in pairs(value) do result[key]=child end
    return result
end
function C:ResetActivity()
    self.active, self.lastSuccess, self.challenge = nil, nil, nil
    self.run = self.run+1
end
function C:RefreshInstance()
    local info, err = S.Call(GetInstanceInfo)
    local changed = self.knownInstanceID and info[8] and (self.knownInstanceID ~= info[8]
        or self.knownDifficulty ~= info[3] or self.knownInstanceType ~= info[2])
    if changed then self:ResetActivity() end
    if info[8] then self.knownInstanceID, self.knownDifficulty, self.knownInstanceType=info[8],info[3],info[2] end
    self.instance, self.instanceType, self.difficulty, self.difficultyName = info[1], info[2], info[3], info[4]
    self.instanceID, self.instanceError = info[8], err
end
function C:Update(event, args)
    self:RefreshInstance()
    if event == "PLAYER_ENTERING_WORLD" then
        if S.Value(args[1], "boolean") or S.Value(args[2], "boolean") then self:ResetActivity() end
        if not self.challenge then
            local map = S.Call(C_ChallengeMode and C_ChallengeMode.GetActiveChallengeMapID)
            local mapID=S.Value(map[1],"number")
            if mapID and mapID > 0 then self.challenge={ challengeMapID=mapID, state="active", recovered=true } end
        end
    elseif event == "CHALLENGE_MODE_RESET" then self:ResetActivity()
    elseif event == "CHALLENGE_MODE_START" then
        self:ResetActivity()
        local map = S.Call(C_ChallengeMode and C_ChallengeMode.GetActiveChallengeMapID)
        self.challenge = { mapID=S.Value(args[1], "number"), challengeMapID=S.Value(map[1],"number"), state="active", startedAt=GetTime() }
    elseif event == "CHALLENGE_MODE_COMPLETED" or event == "CHALLENGE_MODE_COMPLETED_REWARDS" then
        self.active = nil
        self.challenge = copy(self.challenge) or {}
        self.challenge.state = "completed"
        self.challenge.completedAt = self.challenge.completedAt or GetTime()
        if event == "CHALLENGE_MODE_COMPLETED_REWARDS" then self.challenge.rewardsMapID=S.Value(args[1], "number") end
    elseif event == "ENCOUNTER_START" then
        if self.challenge and self.challenge.state == "completed" then self:ResetActivity() end
        self.active = { id=S.Value(args[1], "number"), name=S.Value(args[2], "string"),
            difficulty=S.Value(args[3], "number"), groupSize=S.Value(args[4], "number"), state="active", observedAt=GetTime() }
    elseif event == "ENCOUNTER_END" then
        local ended = { id=S.Value(args[1], "number"), name=S.Value(args[2], "string"),
            difficulty=S.Value(args[3], "number"), groupSize=S.Value(args[4], "number"), state="ended",
            success=S.Value(args[5], "number"), observedAt=GetTime() }
        self.active=nil
        if ended.success == 1 then self.lastSuccess=ended end
    end
end
function C:Snapshot()
    self:RefreshInstance()
    return { instance=self.instance, instanceType=self.instanceType, difficulty=self.difficulty,
        difficultyName=self.difficultyName, instanceID=self.instanceID, instanceError=self.instanceError, run=self.run,
        activeEncounter=copy(self.active), lastSuccessfulEncounter=copy(self.lastSuccess),
        encounter=copy(self.active or self.lastSuccess), challenge=copy(self.challenge) }
end
