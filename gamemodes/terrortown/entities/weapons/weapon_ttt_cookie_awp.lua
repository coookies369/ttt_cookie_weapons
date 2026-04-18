if SERVER then
    AddCSLuaFile()
end

DEFINE_BASECLASS("weapon_ttt_cookie_base")

SWEP.HoldType = "ar2"

if CLIENT then
    SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV = 54

    SWEP.Icon = "vgui/ttt/icon_awp"

    SWEP.EquipMenuData = {
        type = "item_weapon",
        name = "weapon_awp_name",
        desc = "weapon_awp_desc"
    }
end

SWEP.Base = "weapon_ttt_cookie_base"

SWEP.Kind = WEAPON_HEAVY
SWEP.spawnType = WEAPON_TYPE_SNIPER

SWEP.EffectiveRangeStart = 3000
SWEP.EffectiveRangeStop = 1000
SWEP.IneffectiveRangeMultiplier = 0.25

SWEP.Primary.Delay = 1.5
SWEP.Primary.Recoil = 7
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "357"
SWEP.Primary.Damage = 50
SWEP.Primary.Cone = 0.005
SWEP.Primary.ClipSize = 5
SWEP.Primary.ClipMax = 10
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Sound = Sound("weapons/awp/awp1.wav")
SWEP.SpeedModifier = 0.8

SWEP.HeadshotMultiplier = 4

SWEP.AutoSpawnable = true
SWEP.Spawnable = true
SWEP.AmmoEnt = "item_ammo_357_ttt"

SWEP.ViewModel = Model("models/weapons/cstrike/c_snip_awp.mdl")
SWEP.WorldModel = Model("models/weapons/w_snip_awp.mdl")

SWEP.IronSightsPos = Vector(5, -15, -2)
SWEP.IronSightsAng = Vector(2.6, 1.37, 3.5)

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "Zoomed")
    self:NetworkVar("Int", 0, "ZoomLevel")
end

function SWEP:Initialize()
    self:SetZoomed(false)
    self:SetZoomLevel(1)
    BaseClass.Initialize(self)
end

function SWEP:CycleZoomLevel()
    local zoomLevel = self:GetZoomLevel()
    zoomLevel = zoomLevel % 3 + 1
    self:EmitSound("buttons/lightswitch2.wav", SNDLVL_20dB, 100 + zoomLevel * 50, 0.5, CHAN_AUTO)
    self:SetZoomLevel(zoomLevel)
    self:UpdateFOV()
end

function SWEP:UpdateFOV()
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then
        return
    end

    if self:GetZoomed() then
        local zoomLevel = self:GetZoomLevel()
        if zoomLevel == 1 then
            owner:SetFOV(20, 0.5)
        elseif zoomLevel == 2 then
            owner:SetFOV(10, 0.5)
        elseif zoomLevel == 3 then
            owner:SetFOV(5, 0.5)
        end
    else
        owner:SetFOV(0, 0.5)
    end
end

function SWEP:SecondaryAttack()
end

function SWEP:PreDrop()
    self:SetIronsights(false)
    self:SetZoomed(false)

    return BaseClass.PreDrop(self)
end

function SWEP:Think()
    local player = self:GetOwner()
    if not IsValid(player) or not player:IsPlayer() then return end

    if player:KeyPressed(IN_ATTACK2) then
        self:EmitSound("weapons/sniper/sniper_zoomin.wav", SNDLVL_20dB, 100, 1, CHAN_AUTO)
        self:SetZoomed(true)
        self:SetIronsights(true)
        self:UpdateFOV()
    elseif player:KeyReleased(IN_ATTACK2) then
        self:EmitSound("weapons/sniper/sniper_zoomout.wav", SNDLVL_20dB, 100, 1, CHAN_AUTO)
        self:SetZoomed(false)
        self:SetIronsights(false)
        self:UpdateFOV()
    end
    if self:GetZoomed() and player:KeyPressed(IN_RELOAD) then
        self:CycleZoomLevel()
    end
end

function SWEP:Reload()
    if
        self:Clip1() == self.Primary.ClipSize
        or self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0
    then
        return
    end
    if self.Zoom ~= 0 then return end

    self:DefaultReload(ACT_VM_RELOAD)

    self:SetZoomed(false)
end

function SWEP:Holster()
    self:SetIronsights(false)
    self:SetZoomed(false)

    return true
end

function SWEP:Deploy()
    self:SetIronsights(false)
    self:SetZoomed(false)

    return true
end

if CLIENT then
    local scope = Material("gui/cookie/awp_crosshair.png", "noclamp smooth")

    ---
    -- @ignore
    function SWEP:DrawHUD()
        if self:GetZoomed() then
            surface.SetDrawColor(0, 0, 0, 255)

            local scrW = ScrW()
            local scrH = ScrH()

            local x = 0.5 * scrW
            local y = 0.5 * scrH
            local scope_size = scrH

            -- crosshair
            local length = scope_size

            surface.DrawLine(x - length, y, x, y)
            surface.DrawLine(x + length, y, x, y)
            surface.DrawLine(x, y - length, x, y)
            surface.DrawLine(x, y + length, x, y)

            -- cover edges
            local sh = 0.5 * scope_size
            local w = x - sh + 2

            surface.DrawRect(0, 0, w, scope_size)
            surface.DrawRect(x + sh - 2, 0, w, scope_size)

            -- cover gaps on top and bottom of screen
            surface.DrawLine(0, 0, scrW, 0)
            surface.DrawLine(0, scrH - 1, scrW, scrH - 1)

            -- scope
            surface.SetMaterial(scope)
            surface.DrawTexturedRect(x - scope_size / 2, 0, scope_size, scope_size, 0)
        else
            return BaseClass.DrawHUD(self)
        end
    end

    function SWEP:AdjustMouseSensitivity()
        if not self:GetZoomed() then return end
        local zoomLevel = self:GetZoomLevel()
        if zoomLevel == 1 then
            return 0.2
        elseif zoomLevel == 2 then
            return 0.1
        elseif zoomLevel == 3 then
           	return 0.05
        end
    end
end