if SERVER then
    AddCSLuaFile()
end

DEFINE_BASECLASS("weapon_ttt_cookie_base")

SWEP.HoldType = "ar2"

if CLIENT then
    SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV = 54

    SWEP.Icon = "vgui/ttt/icon_mac"

    SWEP.EquipMenuData = {
        type = "item_weapon",
        name = "weapon_cookie_smg_name",
        desc = "weapon_cookie_smg_desc"
    }
end

SWEP.Base = "weapon_ttt_cookie_base"

SWEP.Kind = WEAPON_HEAVY
SWEP.spawnType = WEAPON_TYPE_SNIPER

-- (HP/DMG) * (60/RPM) = TTK

SWEP.Primary.Delay = 0.1
SWEP.Primary.Recoil = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.Damage = 10
SWEP.HeadshotMultiplier = 2
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.ClipMax = 60
SWEP.Primary.Cone = 0.05
SWEP.Primary.Sound = Sound("weapons/mac10/mac10-1.wav")
SWEP.SpeedModifier = 1

SWEP.AutoSpawnable = true
SWEP.Spawnable = true
SWEP.AmmoEnt = "item_ammo_pistol_ttt"

SWEP.ViewModel = Model("models/weapons/cstrike/c_smg_mac10.mdl")
SWEP.WorldModel = Model("models/weapons/w_smg_mac10.mdl")

SWEP.IronSightsPos = Vector(-8.735, -10, 4.039)
SWEP.IronSightsAng = Vector(-1.201, -0.201, -2)