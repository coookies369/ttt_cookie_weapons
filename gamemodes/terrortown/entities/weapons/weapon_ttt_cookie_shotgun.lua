if SERVER then
    AddCSLuaFile()
end

DEFINE_BASECLASS("weapon_ttt_cookie_base")

SWEP.HoldType = "ar2"

if CLIENT then
    SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV = 54

    SWEP.Icon = "vgui/ttt/icon_shotgun"

    SWEP.EquipMenuData = {
        type = "item_weapon",
        name = "weapon_cookie_shotgun_name",
        desc = "weapon_cookie_shotgun_desc"
    }
end

SWEP.Base = "weapon_ttt_cookie_base"

SWEP.Kind = WEAPON_HEAVY
SWEP.spawnType = WEAPON_TYPE_SNIPER

BUCKSHOT = 1
SLUG = 2
FLECHETTE = 3

STATS = {
    [BUCKSHOT] = {
        NumShots = 8,
        Damage = 10,
        HeadshotMultiplier = 2,
        Cone = 0.05,
    },
    [SLUG] = {
        NumShots = 1,
        Damage = 10,
        HeadshotMultiplier = 2,
        Cone = 0.005,
    },
    [FLECHETTE] = {
        NumShots = 20,
        Damage = 10,
        HeadshotMultiplier = 2,
        Cone = 0.05,
    }
}

-- (HP/DMG) * (60/RPM) = TTK

SWEP.Primary.Delay = 0.6
SWEP.Primary.Recoil = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.Damage = STATS[BUCKSHOT].Damage
SWEP.HeadshotMultiplier = STATS[BUCKSHOT].HeadshotMultiplier
SWEP.Primary.NumShots = STATS[BUCKSHOT].NumShots
SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 6
SWEP.Primary.ClipMax = 12
SWEP.Primary.Cone = STATS[BUCKSHOT].Cone
SWEP.Primary.Sound = Sound("weapons/xm1014/xm1014-1.wav")
SWEP.SpeedModifier = 0.9

SWEP.AutoSpawnable = true
SWEP.Spawnable = true
SWEP.AmmoEnt = "item_box_buckshot_ttt"

SWEP.ViewModel = Model("models/weapons/cstrike/c_shot_xm1014.mdl")
SWEP.WorldModel = Model("models/weapons/w_shot_xm1014.mdl")

SWEP.IronSightsPos = Vector(-6.881, -9.214, 2.66)
SWEP.IronSightsAng = Vector(-0.101, -0.7, -0.201)


function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 0, "Reloading")
    self:NetworkVar("String", 0, "Shells")
    self:NetworkVar("Int", 0, "SelectedShell")
    BaseClass.SetupDataTables(self)
end

function SWEP:Initialize()
    self:SetSelectedShell(BUCKSHOT)
    self:SetShells(util.TableToJSON({ BUCKSHOT, BUCKSHOT, BUCKSHOT, BUCKSHOT, BUCKSHOT, BUCKSHOT }))
    BaseClass.Initialize(self)
end

function SWEP:PrimaryAttack()
    BaseClass.PrimaryAttack(self)
    self:CycleShells()
end

function SWEP:CycleShells()
    local shells = util.JSONToTable(self:GetShells())
    table.remove(shells, #shells)
    self:SetShells(util.TableToJSON(shells))
    self:UpdateStats()
end

function SWEP:UpdateStats()
    local shells = util.JSONToTable(self:GetShells())
    local shell = shells[#shells]
    if shell == nil then return end
    local stats = STATS[shell]
    self.Primary.NumShots = stats.NumShots
    self.Primary.Damage = stats.Damage
    self.Primary.HeadshotMultiplier = stats.HeadshotMultiplier
    self.Primary.Cone = stats.Cone
end

function SWEP:ChangeSelectedShell()
    local selected_shell = self:GetSelectedShell()
    if selected_shell == BUCKSHOT then
        self:SetSelectedShell(SLUG)
    elseif selected_shell == SLUG then
        self:SetSelectedShell(FLECHETTE)
    else
        self:SetSelectedShell(BUCKSHOT)
    end
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
    timer.Simple(0.2, function()
        self:SetClip1(self:Clip1() + 1)
        local shells = util.JSONToTable(self:GetShells())
        local selected_shell = self:GetSelectedShell()
        if selected_shell < 1 or selected_shell > 3 then
            selected_shell = BUCKSHOT
        end
        table.insert(shells, #shells + 1, selected_shell)
        self:SetShells(util.TableToJSON(shells))
        self:UpdateStats()
        owner:RemoveAmmo(1, self.Primary.Ammo, false)
    end)
    timer.Simple(self:SequenceDuration() - 0.1, function()
        self:SetReloading(false)
        self:SendWeaponAnim(ACT_SHOTGUN_RELOAD_FINISH)
    end)
end

function SWEP:Think()
    local owner = self:GetOwner()
    if not IsValid(owner) or not owner:IsPlayer() then return end
    if owner:KeyPressed(IN_WALK) then
        self:ChangeSelectedShell()
    end
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
        -- Tube
        surface.DrawRect(x + shell_size * -3, scrH - tube_height - (shell_size - tube_height)/2, shell_size * 6, tube_height)
        -- Selected shell
        surface.DrawRect(x + shell_size * -4.5, scrH - tube_height - (shell_size - tube_height)/2, shell_size, tube_height)

        local shells = util.JSONToTable(self:GetShells())
        for index, shell in pairs(shells) do
            surface.SetMaterial(shell_materials[shell])
            surface.SetDrawColor(shell_colors[shell])
            surface.DrawTexturedRect(x + (shell_size * -3) + ((#shells - index) * shell_size), scrH - shell_size, shell_size, shell_size)
        end

        local selected_shell = self:GetSelectedShell()
        if selected_shell < 1 or selected_shell > 3 then
            selected_shell = BUCKSHOT
        end
        surface.SetMaterial(shell_materials[selected_shell])
        surface.SetDrawColor(shell_colors[selected_shell])
        surface.DrawTexturedRect(x + shell_size * -4.5, scrH - shell_size, shell_size, shell_size)

        return BaseClass.DrawHUD(self)
    end
end