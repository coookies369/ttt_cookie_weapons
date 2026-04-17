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

SWEP.Buckshot = {}
SWEP.Buckshot.NumShots = 8
SWEP.Buckshot.Damage = 10
SWEP.Buckshot.HeadshotMultiplier = 2
SWEP.Buckshot.Cone = 0.05

SWEP.Slug = {}
SWEP.Slug.NumShots = 1
SWEP.Slug.Damage = 10
SWEP.Slug.HeadshotMultiplier = 2
SWEP.Slug.Cone = 0.005

-- (HP/DMG) * (60/RPM) = TTK

SWEP.Primary.Delay = 0.6
SWEP.Primary.Recoil = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.Damage = SWEP.Buckshot.Damage
SWEP.HeadshotMultiplier = SWEP.Buckshot.HeadshotMultiplier
SWEP.Primary.NumShots = SWEP.Buckshot.NumShots
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.ClipMax = 12
SWEP.Primary.Cone = SWEP.Buckshot.Cone
SWEP.Primary.Sound = Sound("weapons/xm1014/xm1014-1.wav")
SWEP.SpeedModifier = 0.9

SWEP.AutoSpawnable = true
SWEP.Spawnable = true
SWEP.AmmoEnt = "item_box_buckshot_ttt"

SWEP.ViewModel = Model("models/weapons/cstrike/c_shot_xm1014.mdl")
SWEP.WorldModel = Model("models/weapons/w_shot_xm1014.mdl")

SWEP.IronSightsPos = Vector(-6.625, -10, 2.7)
SWEP.IronSightsAng = Vector(2, 0, 0)

BUCKSHOT = 1
SLUG = 2
FLECHETTE = 3

SWEP.Shells = {BUCKSHOT, SLUG, FLECHETTE, BUCKSHOT, BUCKSHOT, BUCKSHOT}

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "Reloading")
end

function SWEP:Reload()
    if self:GetReloading() then return end
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if self:Clip1() >= self.Primary.ClipSize then return end
    if owner:GetAmmoCount(self.Primary.Ammo) <= 0 then return end
    self:SetReloading(true)
    self:SetIronsights(false)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    self:SendWeaponAnim(ACT_VM_RELOAD)
    timer.Simple(self:SequenceDuration() - 0.1, function()
        self:SetReloading(false)
        self:SetClip1(self:Clip1() + 1)
    end)
end

if CLIENT then
    local shell_materials = {
        [BUCKSHOT] = Material("gui/cookie/buckshot.png", "noclamp smooth"),
        [SLUG] = Material("gui/cookie/slug.png", "noclamp smooth"),
        [FLECHETTE] = Material("gui/cookie/flechette.png", "noclamp smooth")
    }

    local shell_colors = {
        [BUCKSHOT] = Color(224, 27, 36),
        [SLUG] = Color(246, 211, 45),
        [FLECHETTE] = Color(53, 132, 228)
    }

    function SWEP:DrawHUD()
        local scrW = ScrW()
        local scrH = ScrH()

        local x = 0.5 * scrW
        local y = 0.5 * scrH

        local shell_size = scrW / 32
        local tube_height = shell_size * 0.6

        surface.SetDrawColor(0, 0, 0)
        surface.DrawRect(x + shell_size * -3, scrH - tube_height - (shell_size - tube_height)/2, shell_size * 6, tube_height)

        for index, shell in pairs(self.Shells) do
            surface.SetMaterial(shell_materials[shell])
            surface.SetDrawColor(shell_colors[shell])
            surface.DrawTexturedRect(x + (shell_size * -3) + ((index-1) * shell_size), scrH - shell_size, shell_size, shell_size)
        end

        return BaseClass.DrawHUD(self)
    end
end