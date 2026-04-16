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

SWEP.Primary.Delay = 0.9
SWEP.Primary.Recoil = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.Damage = 10
SWEP.HeadshotMultiplier = 2
SWEP.Primary.NumShots = 8
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.ClipMax = 12
SWEP.Primary.Cone = 0.05
SWEP.Primary.Sound = Sound("weapons/m3/m3-1.wav")
SWEP.SpeedModifier = 0.9

SWEP.AutoSpawnable = true
SWEP.Spawnable = true
SWEP.AmmoEnt = "item_box_buckshot_ttt"

SWEP.ViewModel = Model("models/weapons/cstrike/c_shot_m3super90.mdl")
SWEP.WorldModel = Model("models/weapons/w_shot_m3super90.mdl")

SWEP.IronSightsPos = Vector(-6.625, -10, 2.7)
SWEP.IronSightsAng = Vector(2, 0, 0)

if CLIENT then
    local buckshot = Material("gui/cookie/buckshot.png", "noclamp smooth")

    function SWEP:DrawHUD()
        local scrW = ScrW()
        local scrH = ScrH()

        local x = 0.5 * scrW
        local y = 0.5 * scrH

        surface.SetMaterial(buckshot)
        surface.DrawTexturedRect(scrW - 96, scrH - 96, 64, 64, 0)

        return BaseClass.DrawHUD(self)
    end
end