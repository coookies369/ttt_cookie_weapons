if SERVER then
    AddCSLuaFile()
end

hook.Add( "InitPostEntity", "cookie_content_disabler", function()
    scripted_ents.GetStored("item_ammo_357_ttt").t.Model = Model("models/cookies/rifle_ammo.mdl")
    scripted_ents.GetStored("item_ammo_revolver_ttt").t.Initialize = nil

    scripted_ents.GetStored("item_ammo_smg1_ttt").t.AutoSpawnable = false
    scripted_ents.GetStored("item_ammo_pistol_ttt").t.AutoSpawnable = false

    weapons.GetStored("weapon_ttt_m16").AutoSpawnable = false
    weapons.GetStored("weapon_zm_mac10").AutoSpawnable = false
    weapons.GetStored("weapon_zm_rifle").AutoSpawnable = false
    weapons.GetStored("weapon_zm_shotgun").AutoSpawnable = false
    weapons.GetStored("weapon_zm_sledge").AutoSpawnable = false

    weapons.GetStored("weapon_ttt_glock").AutoSpawnable = false
    weapons.GetStored("weapon_zm_pistol").AutoSpawnable = false
    weapons.GetStored("weapon_zm_revolver").AutoSpawnable = false
end )