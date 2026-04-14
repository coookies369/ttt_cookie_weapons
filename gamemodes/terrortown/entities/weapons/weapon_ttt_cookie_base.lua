if SERVER then
    AddCSLuaFile()
end

DEFINE_BASECLASS("weapon_tttbase")

SWEP.Base = "weapon_tttbase"

SWEP.Kind = WEAPON_HEAVY
SWEP.builtin = false
SWEP.SpeedModifier = 1

--TODO!
SWEP.EffectiveRangeStart = 500
SWEP.EffectiveRangeStop = 1000
SWEP.IneffectiveRangeMultiplier = 0.5

SWEP.UseHands = true
SWEP.idleResetFix = true

--TODO: buffer inputs for non-automatic weapons

function SWEP:PrimaryAttack(worldsnd)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

    if not self:CanPrimaryAttack() then
        return
    end

    if not worldsnd then
        self:EmitSound(self.Primary.Sound, self.Primary.SoundLevel)
    elseif SERVER then
        sound.Play(self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel)
    end

    local owner = self:GetOwner()
    if not IsValid(owner) or owner:IsNPC() then
        return
    end

    local hit_entities = {}
    local bullet = {
        Attacker = owner,
        Inflictor = self,
        Damage = 0,
        -- Store the trace result for each bullet that hit each entity
        -- The bullets do no damage right now; they will be given damage later
        Callback = (function(attacker, tr, dmgInfo)
            if hit_entities[tr.Entity:EntIndex()] == nil then
                hit_entities[tr.Entity:EntIndex()] = {}
            end
            table.insert(hit_entities[tr.Entity:EntIndex()], tr)
        end),
        Num = self.Primary.NumShots,
        Dir = owner:EyeAngles():Forward(),
        Spread = Vector(self.Primary.Cone, self.Primary.Cone, 0),
        Src = owner:EyePos()
    }
    owner:FireBullets(bullet)

    local dmg = DamageInfo()
	dmg:SetDamage(self.Primary.Damage)
	dmg:SetAttacker(owner)
	dmg:SetInflictor(self)
	dmg:SetDamageType(DMG_BULLET)

	local function getHitGroupPriority(hitgroup)
        if hitgroup == HITGROUP_LEFTARM
            or hitgroup == HITGROUP_RIGHTARM
            or hitgroup == HITGROUP_LEFTLEG
            or hitgroup == HITGROUP_RIGHTLEG
            or hitgroup == HITGROUP_GEAR then
            return 1
        elseif hitgroup == HITGROUP_HEAD then
            return 3
        elseif hitgroup ~= nil then
            return 2
        end
        return 0
	end

	--Each hit entity takes 1 instance of damage regardless of how many bullets hit
    for entIndex, tr in pairs(hit_entities) do
        local trace = nil
        for k, result in pairs(tr) do
            if getHitGroupPriority(result) > getHitGroupPriority(trace) then
                trace = result
            end
        end
        Entity(entIndex):DispatchTraceAttack(dmg, trace)
    end

    self:ShootEffects()

    self:TakePrimaryAmmo(1)

    if not owner.ViewPunch then return end
    owner:ViewPunch(
        Angle(
            util.SharedRandom(self:GetClass(), -0.2, -0.1, 0) * self:GetPrimaryRecoil(),
            util.SharedRandom(self:GetClass(), -0.1, 0.1, 1) * self:GetPrimaryRecoil(),
            0
        )
    )
end

hook.Add("TTTPlayerSpeedModifier", "TTTCookieSpeedModifier", function(ply, _, _, speedMultiplierModifier)
    if not IsValid(ply) then return end
    if not IsValid(ply:GetActiveWeapon()) then return end
    local modifier = ply:GetActiveWeapon().SpeedModifier
    if modifier ~= nil then
        speedMultiplierModifier[1] = speedMultiplierModifier[1] * modifier
    end
end)