if SERVER then
    AddCSLuaFile()
end

DEFINE_BASECLASS("weapon_tttbase")

SWEP.Base = "weapon_tttbase"

SWEP.Kind = WEAPON_HEAVY
SWEP.builtin = false
SWEP.SpeedModifier = 1

-- (HP/DMG) * (60/RPM) = TTK
-- 1
-- 0.5 Headshot

SWEP.UseHands = true
SWEP.idleResetFix = true

hook.Add("TTTPlayerSpeedModifier", "TTTCookieSpeedModifier", function(ply, _, _, speedMultiplierModifier)
    if not IsValid(ply) then return end
    if not IsValid(ply:GetActiveWeapon()) then return end
    local modifier = ply:GetActiveWeapon().SpeedModifier
    if modifier ~= nil then
        speedMultiplierModifier[1] = speedMultiplierModifier[1] * modifier
    end
end)