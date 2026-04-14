if SERVER then
    AddCSLuaFile()
end

DEFINE_BASECLASS("weapon_tttbase")

SWEP.HoldType = "ar2"

if CLIENT then
    SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV = 54

    SWEP.Icon = "vgui/ttt/icon_aK"

    SWEP.EquipMenuData = {
        type = "item_weapon",
        name = "weapon_ak_name",
        desc = "weapon_ak_desc"
    }
end

SWEP.Base = "weapon_tttbase"

SWEP.Kind = WEAPON_HEAVY
SWEP.WeaponID = AMMO_RIFLE
SWEP.builtin = true
SWEP.spawnType = WEAPON_TYPE_SNIPER

-- (HP/DMG) * (60/RPM) = TTK
-- 1
-- 0.5 Headshot

SWEP.Primary.Delay = 0.1
SWEP.Primary.Recoil = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "357"
SWEP.Primary.Damage = 10
SWEP.HeadshotMultiplier = 2
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.ClipMax = 60
SWEP.Primary.Cone = 0.005
SWEP.Primary.Sound = Sound("weapons/ak47/ak47-1.wav")

SWEP.AutoSpawnable = true
SWEP.Spawnable = true
SWEP.AmmoEnt = "item_ammo_357_ttt"

SWEP.UseHands = true
SWEP.ViewModel = Model("models/weapons/cstrike/c_rif_ak47.mdl")
SWEP.WorldModel = Model("models/weapons/w_rif_ak47.mdl")
SWEP.idleResetFix = true

SWEP.IronSightsPos = Vector(-6.625, -10, 2.7)
SWEP.IronSightsAng = Vector(2, 0, 0)