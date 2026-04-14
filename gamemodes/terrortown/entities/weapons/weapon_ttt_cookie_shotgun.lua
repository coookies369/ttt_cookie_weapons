if SERVER then
    AddCSLuaFile()
end

DEFINE_BASECLASS("weapon_ttt_cookie_base")

SWEP.HoldType = "ar2"

if CLIENT then
    SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV = 54

    SWEP.Icon = "vgui/ttt/icon_aK"

    SWEP.EquipMenuData = {
        type = "item_weapon",
        name = "weapon_cookie_shotgun_name",
        desc = "weapon_cookie_shotgun_desc"
    }
end

SWEP.Base = "weapon_ttt_cookie_base"

SWEP.Kind = WEAPON_HEAVY
SWEP.spawnType = WEAPON_TYPE_SNIPER

-- (HP/DMG) * (60/RPM) = TTK

SWEP.Primary.Delay = 0.1
SWEP.Primary.Recoil = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "357"
SWEP.Primary.Damage = 10
SWEP.HeadshotMultiplier = 2
SWEP.Primary.NumShots = 8
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.ClipMax = 12
SWEP.Primary.Cone = 0.05
SWEP.Primary.Sound = Sound("weapons/xm1014/xm1014-1.wav")
SWEP.SpeedModifier = 0.95

SWEP.AutoSpawnable = true
SWEP.Spawnable = true
SWEP.AmmoEnt = "item_ammo_357_ttt"

SWEP.ViewModel = Model("models/weapons/cstrike/c_shot_xm1014.mdl")
SWEP.WorldModel = Model("models/weapons/w_shot_xm1014.mdl")

SWEP.IronSightsPos = Vector(-6.625, -10, 2.7)
SWEP.IronSightsAng = Vector(2, 0, 0)