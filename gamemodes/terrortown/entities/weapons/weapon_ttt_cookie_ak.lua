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
        name = "weapon_ak_name",
        desc = "weapon_ak_desc"
    }
end

SWEP.Base = "weapon_ttt_cookie_base"

SWEP.Kind = WEAPON_HEAVY
SWEP.spawnType = WEAPON_TYPE_SNIPER

SWEP.EffectiveRangeStart = 1000
SWEP.EffectiveRangeStop = 3000
SWEP.IneffectiveRangeMultiplier = 0.25

SWEP.Focused = {
    Cone = 0.005,
    HeadshotMultiplier = 3,
}

SWEP.Unfocused = {
    Cone = 0.05,
    HeadshotMultiplier = 2,
}

-- (HP/DMG) * (60/RPM) = TTK
-- 1
-- 0.5 Headshot

SWEP.Primary.Delay = 0.1
SWEP.Primary.Recoil = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "357"
SWEP.Primary.Damage = 10
SWEP.HeadshotMultiplier = SWEP.Unfocused.HeadshotMultiplier
SWEP.Primary.ClipSize = 30
SWEP.Primary.DefaultClip = 30
SWEP.Primary.ClipMax = 60
SWEP.Primary.Cone = SWEP.Unfocused.Cone
SWEP.Primary.Sound = Sound("weapons/ak47/ak47-1.wav")
SWEP.SpeedModifier = 0.9

SWEP.AutoSpawnable = true
SWEP.Spawnable = true
SWEP.AmmoEnt = "item_ammo_357_ttt"

SWEP.ViewModel = Model("models/weapons/cstrike/c_rif_ak47.mdl")
SWEP.WorldModel = Model("models/weapons/w_rif_ak47.mdl")

SWEP.IronSightsPos = Vector(-6.625, -10, 2.7)
SWEP.IronSightsAng = Vector(2, 0, 0)

SWEP.FocusMinTime = 0
SWEP.FocusMaxTime = 3

function SWEP:SetupDataTables()
    self:NetworkVar("Float", 0, "FocusTime")
    BaseClass.SetupDataTables(self)
end

function SWEP:Initialize()
    self:SetFocusTime(0)
    BaseClass.Initialize(self)
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if SERVER then
        if self:GetIronsights()
            and self:GetNextPrimaryFire() < CurTime()
            and owner:GetVelocity():IsEqualTol(Vector(0, 0, 0), 1) then
            if self:GetFocusTime() == 0 then
                self:SetFocusTime(CurTime())
            end
        else
            -- This is a sentinal value, which you generally want to avoid
            -- I easily COULD avoid this, but I'm not
            self:SetFocusTime(0)
        end
    end

    self.Primary.Cone = Lerp(self:GetFocusFraction(), self.Unfocused.Cone, self.Focused.Cone)
    self.HeadshotMultiplier = self.Unfocused.HeadshotMultiplier

    BaseClass.Think(self)
end

function SWEP:GetFocusFraction()
    local fraction = 0
    if self:GetFocusTime() ~= 0 then
        fraction = (CurTime() - self:GetFocusTime())
        fraction = math.Clamp(fraction, self.FocusMinTime, self.FocusMaxTime - self.FocusMinTime)
        fraction = fraction - self.FocusMinTime / (self.FocusMaxTime - self.FocusMinTime)
        fraction = fraction - 1
    end
    return fraction
end

if CLIENT then
    function SWEP:CalcView(ply, pos, ang, fov)
	    return pos, ang, fov * Lerp(self:GetFocusFraction(), 1, 0.9)
	end
end