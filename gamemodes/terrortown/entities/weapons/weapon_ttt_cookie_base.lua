if SERVER then
    AddCSLuaFile()
end

DEFINE_BASECLASS("weapon_tttbase")

SWEP.Base = "weapon_tttbase"

SWEP.Kind = WEAPON_HEAVY
SWEP.builtin = false

-- (HP/DMG) * (60/RPM) = TTK
-- 1
-- 0.5 Headshot

SWEP.UseHands = true
SWEP.idleResetFix = true