if SERVER then
    AddCSLuaFile()
    util.AddNetworkString("UndeployMG")
end

DEFINE_BASECLASS("weapon_ttt_cookie_base")

SWEP.HoldType = "ar2"

if CLIENT then
    SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV = 54

    SWEP.Icon = "vgui/ttt/icon_mg"

    SWEP.EquipMenuData = {
        type = "item_weapon",
        name = "weapon_cookie_mg_name",
        desc = "weapon_cookie_mg_desc"
    }
end

SWEP.Base = "weapon_ttt_cookie_base"

SWEP.Kind = WEAPON_HEAVY
SWEP.spawnType = WEAPON_TYPE_SNIPER

-- (HP/DMG) * (60/RPM) = TTK

SWEP.DeployedStats = {}
SWEP.DeployedStats.Recoil = 2
SWEP.DeployedStats.Cone = 0.01

SWEP.UndeployedStats = {}
SWEP.UndeployedStats.Recoil = 4
SWEP.UndeployedStats.Cone = 0.1

SWEP.Primary.Delay = 0.1
SWEP.Primary.Recoil = SWEP.UndeployedStats.Recoil
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "AirboatGun"
SWEP.Primary.Damage = 10
SWEP.HeadshotMultiplier = 2
SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.ClipMax = 0
SWEP.Primary.Cone = SWEP.UndeployedStats.Cone
SWEP.Primary.Sound = Sound("weapons/m249/m249-1.wav")
SWEP.SpeedModifier = 0.8

SWEP.AutoSpawnable = true
SWEP.Spawnable = true

SWEP.ViewModel = Model("models/weapons/cstrike/c_mach_m249para.mdl")
SWEP.WorldModel = Model("models/weapons/w_mach_m249para.mdl")

SWEP.IronSightsPos = Vector(-5.96, -5.119, 2.349)
SWEP.IronSightsAng = Vector(0, 0, 0)

SWEP.DeployPositionLimit = 4
SWEP.DeployAngleLimit = 45

function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "IsDeployed")
    self:NetworkVar("Vector", 0, "DeployEyePos")
    self:NetworkVar("Angle", 0, "DeployEyeAngles")
    self:NetworkVar("Float", 0, "DeployFraction")

    BaseClass.SetupDataTables(self)
end

function SWEP:SecondaryAttack()
    local owner = self:GetOwner()
    if not owner:IsValid() then return end
    local frac = self:CalcDeployFraction(owner:EyePos(), owner:EyeAngles())
    if frac ~= nil then
        self:SetIsDeployed(true)
        self:SetDeployEyePos(owner:EyePos())
        self:SetDeployEyeAngles(owner:EyeAngles())
        self:SetDeployFraction(frac)

        self.Primary.Recoil = self.DeployedStats.Recoil
        self.Primary.Cone = self.DeployedStats.Cone
        self:EmitSound("weapons/tmp/tmp_clipin.wav", SNDLVL_30dB, 100, 1, CHAN_AUTO)
    end
    return BaseClass.SecondaryAttack(self)
end

-- Perform a trace to see if we can deploy, and return the "fraction"
-- (How far the trace went on a scale of 0 to 1)
function SWEP:CalcDeployFraction(pos, ang)
    local owner = self:GetOwner()
    if not owner:IsValid() then return nil end

    local tr = util.QuickTrace(pos + ang:Forward() * 24, ang:Up() * -16, owner)
    if tr.StartSolid then return nil end
    if not tr.Hit then return nil end
    if tr.Entity == nil then return nil end
    return tr.Fraction
end

SWEP.TraceTimer = 0
function SWEP:Think()
    if not self:GetIsDeployed() then return end
    local owner = self:GetOwner()
    if SERVER then
        if not owner:IsValid() then
            self:Undeploy()
            return
        end
        if not self:GetIronsights() then
            self:Undeploy()
            return
        end
        if not owner:EyePos():IsEqualTol(self:GetDeployEyePos(), self.DeployPositionLimit) then
            self:Undeploy()
            return
        end
        if not owner:EyeAngles():IsEqualTol(self:GetDeployEyeAngles(), self.DeployAngleLimit + 10) then
            self:Undeploy()
            return
        end
        -- Performing a trace every frame seems like a bad idea
        self.TraceTimer = (self.TraceTimer + 1) % 5
        local frac = self:CalcDeployFraction(self:GetDeployEyePos(), self:GetDeployEyeAngles())
        if frac == nil or math.abs(frac - self:GetDeployFraction()) > 0.05 then
            self:Undeploy()
            return
        end
    elseif owner == LocalPlayer() then
        -- Calculate angle between where we started aiming and where we are currently aiming
        local deploy_angle = self:GetDeployEyeAngles()
        local angle = owner:EyeAngles():Forward():Dot(deploy_angle:Forward()) / 1
        -- angle = angle / (owner:EyeAngles():Forward():Length() * deploy_angle:Forward():Length())
        angle = math.deg(math.acos(angle))
        -- If we have turned too far, correct it
        if angle > self.DeployAngleLimit then
            local new_angles = LerpAngle(self.DeployAngleLimit / angle, deploy_angle, owner:EyeAngles())
            new_angles.roll = 0
            owner:SetEyeAngles(new_angles)
        end
    end
end

function SWEP:Undeploy()
    self:EmitSound("weapons/tmp/tmp_clipout.wav", SNDLVL_30dB, 100, 1, CHAN_AUTO)
    self:SetIsDeployed(false)
    self.Primary.Recoil = self.UndeployedStats.Recoil
    self.Primary.Cone = self.UndeployedStats.Cone
    if SERVER then
        net.Start("UndeployMG")
        net.WriteEntity(self)
        net.Broadcast()
    end
end

net.Receive("UndeployMG", function()
    local wep = net.ReadEntity()
    if not wep:IsValid() then return end
    wep:Undeploy()
end )

function SWEP:Holster()
    self:Undeploy()

    return true
end

function SWEP:Deploy()
    self:Undeploy()

    return true
end

if CLIENT then
    local bipod = Material("gui/cookie/mg_bipod.png", "noclamp smooth")
    local bipod_deployed = Material("gui/cookie/mg_bipod_deployed.png", "noclamp smooth")

    function SWEP:DrawHUD()
        surface.SetDrawColor(LocalPlayer().GetRoleColor and LocalPlayer():GetRoleColor() or roles.INNOCENT.color)
        local scrW = ScrW()
        local scrH = ScrH()
        local x = 0.5 * scrW
        local y = 0.5 * scrH
        if self:GetIsDeployed() then
            surface.SetMaterial(bipod_deployed)
            surface.DrawTexturedRect(x - scrH / 32, y + scrH / 16, scrH / 16, scrH / 16, 0)

        -- TODO: none of this works and I don't know why :3
        -- elseif self:CalcDeployFraction(LocalPlayer():GetPos(), LocalPlayer():EyeAngles()) ~= nil then
        --     surface.SetMaterial(bipod)
        --     surface.DrawTexturedRect(x - scrH / 32, y + scrH / 16, scrH / 16, scrH / 16, 0)
        end
        return BaseClass.DrawHUD(self)
    end
end