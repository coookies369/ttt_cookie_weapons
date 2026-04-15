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
        name = "weapon_mg_name",
        desc = "weapon_mg_desc"
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

SWEP.IronSightsPos = Vector(-6.625, -10, 2.7)
SWEP.IronSightsAng = Vector(2, 0, 0)

SWEP.DeployPositionLimit = 4
SWEP.DeployAngleLimit = 45

SWEP.IsDeployed = false
-- Where the player was when the bipod was deployed
SWEP.DeployPosition = nil
-- The angle the player was aiming when the bipod was deployed
SWEP.DeployAngle = nil
-- The object we are deployed on
SWEP.DeployMount = nil

function SWEP:SecondaryAttack()
    local ent = self:GetDeployableEntity()
    if ent ~= nil then
        local owner = self:GetOwner()
        if not owner:IsValid() then return end
        self.DeployPosition = owner:GetPos()
        self.DeployAngle = owner:EyeAngles()
        self.DeployMount = ent
        self.IsDeployed = true

        self.Primary.Recoil = self.DeployedStats.Recoil
        self.Primary.Cone = self.DeployedStats.Cone
        self:EmitSound("weapons/tmp/tmp_clipin.wav")
    end
    return BaseClass.SecondaryAttack(self)
end

-- Return the entity we can deploy on, if any
function SWEP:GetDeployableEntity()
    local owner = self:GetOwner()
    if not owner:IsValid() then return nil end

    local tr = util.QuickTrace(owner:EyePos() + owner:EyeAngles():Forward() * 24, owner:EyeAngles():Up() * -16, owner)
    if tr.StartSolid then return nil end
    if not tr.Hit then return nil end
    if tr.Fraction < 0.5 then return nil end
    if tr.Entity == nil then return nil end
    return tr.Entity
end

function SWEP:Think()
    if not self.IsDeployed then return end
    local owner = self:GetOwner()
    if SERVER then
        if not owner:IsValid() then
            self:Undeploy()
            return
        end
        if not owner:GetPos():IsEqualTol(self.DeployPosition, self.DeployPositionLimit) then
            self:Undeploy()
            return
        end
        if not self:GetIronsights() then
            self:Undeploy()
            return
        end
        if IsValid(self.DeployMount)
            and IsValid(self.DeployMount:GetPhysicsObject())
            and not self.DeployMount:GetPhysicsObject():IsAsleep()
        then
            self:Undeploy()
            return
        end
        -- if owner:EyeAngles():IsEqualTol(self.DeployAngle, self.DeployAngleLimit + 5) then
        --     self:Undeploy()
        --     return
        -- end
    elseif owner == LocalPlayer() then
        -- Calculate angle between where we started aiming and where we are currently aiming
        local angle = owner:EyeAngles():Forward():Dot(self.DeployAngle:Forward())
        angle = angle / (owner:EyeAngles():Forward():Length() * self.DeployAngle:Forward():Length())
        angle = math.deg(math.acos(angle))
        -- If we have turned too far, correct it
        if angle > self.DeployAngleLimit then
            local new_angles = LerpAngle(self.DeployAngleLimit / angle, self.DeployAngle, owner:EyeAngles())
            new_angles.roll = 0
            owner:SetEyeAngles(new_angles)
        end
    end
end

function SWEP:Undeploy()
    if not self.IsDeployed then return end
    self:EmitSound("weapons/tmp/tmp_clipout.wav")
    self.IsDeployed = false
    self.Primary.Recoil = self.UndeployedStats.Recoil
    self.Primary.Cone = self.UndeployedStats.Cone
    if SERVER then
        net.Start("UndeployMG")
        net.WriteEntity(Entity(self:EntIndex()))
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
    local bipod = Material("gui/mg_bipod.png", "noclamp smooth")

    function SWEP:DrawHUD()
        if self:GetDeployableEntity() ~= nil then
            surface.SetDrawColor(LocalPlayer().GetRoleColor and LocalPlayer():GetRoleColor() or roles.INNOCENT.color)

            local scrW = ScrW()
            local scrH = ScrH()
            local x = 0.5 * scrW
            local y = 0.5 * scrH

            surface.SetMaterial(bipod)
            surface.DrawTexturedRect(x - scrH / 32, y + scrH / 16, scrH / 16, scrH / 16, 0)
        end
        return BaseClass.DrawHUD(self)
    end
end