if SERVER then
    AddCSLuaFile()
end

hook.Add( "InitPostEntity", "cookie_ammo_modifier", function()
    scripted_ents.GetStored("item_ammo_357_ttt").t.Model = Model("models/cookies/rifle_ammo.mdl")
    scripted_ents.GetStored("item_ammo_revolver_ttt").t.Initialize = nil
end )