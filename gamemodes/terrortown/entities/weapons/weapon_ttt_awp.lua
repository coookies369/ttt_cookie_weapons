if SERVER then
    AddCSLuaFile()
end

DEFINE_BASECLASS("weapon_tttbase")

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

SWEP.Base = "weapon_tttbase"

SWEP.Kind = WEAPON_HEAVY
SWEP.WeaponID = AMMO_RIFLE
SWEP.builtin = true
SWEP.spawnType = WEAPON_TYPE_SNIPER

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

SWEP.HeadshotMultiplier = 4

SWEP.AutoSpawnable = true
SWEP.Spawnable = true
SWEP.AmmoEnt = "item_ammo_357_ttt"

SWEP.UseHands = true
SWEP.ViewModel = Model("models/weapons/cstrike/c_snip_awp.mdl")
SWEP.WorldModel = Model("models/weapons/w_snip_awp.mdl")
SWEP.idleResetFix = true

SWEP.IronSightsPos = Vector(5, -15, -2)
SWEP.IronSightsAng = Vector(2.6, 1.37, 3.5)

SWEP.Zoom = 0

function SWEP:SetZoomLevel(level)
    local owner = self:GetOwner()

    if not IsValid(owner) or not owner:IsPlayer() then
        return
    end

    --Make sure zoom level is actually changing
    if level == self.Zoom then return end

    if self.Zoom == 0 then
        self:EmitSound("weapons/sniper/sniper_zoomin.wav", SNDLVL_20dB, 100, 1, CHAN_AUTO)
    elseif level == 0 then
        self:EmitSound("weapons/sniper/sniper_zoomout.wav", SNDLVL_20dB, 100, 1, CHAN_AUTO)
    else
        self:EmitSound("buttons/lightswitch2.wav", SNDLVL_20dB, 100 + level * 50, 0.5, CHAN_AUTO)
    end

    if level == 1 then
        owner:SetFOV(20, 0.5)
    elseif level == 2 then
        owner:SetFOV(10, 0.5)
    elseif level == 3 then
        owner:SetFOV(5, 0.5)
    else
        owner:SetFOV(0, 0.5)
    end

    self:SetIronsights(level ~= 0)

    self.Zoom = level
end

function SWEP:SecondaryAttack()
end

function SWEP:PreDrop()
    self:SetIronsights(false)
    self:SetZoomLevel(0)

    return BaseClass.PreDrop(self)
end

function SWEP:Think()
    local player = self:GetOwner()
    if not IsValid(player) or not player:IsPlayer() then return end

    if player:KeyPressed(IN_ATTACK2) then
        self:SetZoomLevel(1)
    elseif player:KeyReleased(IN_ATTACK2) then
        self:SetZoomLevel(0)
    end
    if self.Zoom ~= 0 and player:KeyPressed(IN_RELOAD) then
        self:SetZoomLevel(self.Zoom % 3 + 1)
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

    self:SetZoomLevel(0)
end

function SWEP:Holster()
    self:SetZoomLevel(0)

    return true
end

function SWEP:Deploy()
    self:SetZoomLevel(0)

    return true
end

if CLIENT then
    local scope = Material("gui/awp_crosshair.png", "noclamp smooth")

    ---
    -- @ignore
    function SWEP:DrawHUD()
        if self:GetIronsights() then
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
        if self.Zoom == 1 then
            return 0.2
        elseif self.Zoom == 2 then
            return 0.1
        elseif self.Zoom == 3 then
           	return 0.05
        else
            return nil
        end
    end
end