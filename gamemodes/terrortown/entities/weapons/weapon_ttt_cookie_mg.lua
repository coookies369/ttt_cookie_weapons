if SERVER then
    AddCSLuaFile()
end

DEFINE_BASECLASS("weapon_ttt_cookie_base")

SWEP.HoldType = "ar2"

if CLIENT then
    SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV = 54

    SWEP.Icon = "vgui/ttt/icon_mg"

    SWEP.EquipMenuData = {
        type = "item_weapon",
        name = "weapon_mg_name",
        desc = "weapon_mg_desc"
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
SWEP.Primary.ClipSize = 50
SWEP.Primary.DefaultClip = 50
SWEP.Primary.ClipMax = 0
SWEP.Primary.Cone = 0.05
SWEP.Primary.Sound = Sound("weapons/m249/m249-1.wav")
SWEP.SpeedModifier = 0.8

SWEP.AutoSpawnable = true
SWEP.Spawnable = true
SWEP.AmmoEnt = "item_ammo_357_ttt"

SWEP.ViewModel = Model("models/weapons/cstrike/c_mach_m249para.mdl")
SWEP.WorldModel = Model("models/weapons/w_mach_m249para.mdl")

SWEP.IronSightsPos = Vector(-6.625, -10, 2.7)
SWEP.IronSightsAng = Vector(2, 0, 0)


if CLIENT then
    local bipod = Material("gui/mg_bipod.png", "noclamp smooth")

    function SWEP:DrawHUD()
        surface.SetDrawColor(LocalPlayer().GetRoleColor and LocalPlayer():GetRoleColor() or roles.INNOCENT.color)

        local scrW = ScrW()
        local scrH = ScrH()
        local x = 0.5 * scrW
        local y = 0.5 * scrH

        surface.SetMaterial(bipod)
        surface.DrawTexturedRect(x - scrH/32, y + scrH/16, scrH/16, scrH/16, 0)
        return BaseClass.DrawHUD(self)
    end
end