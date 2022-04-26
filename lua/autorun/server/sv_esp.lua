paffSharing = {}
paffSharing.List = {}

util.AddNetworkString( "sharing_prop" )
util.AddNetworkString( "sharing_prop_open" )
util.AddNetworkString( "player_sharingspawn" )

function paffSharing.notify(ply, msgtype, len, msg)
    if not istable(ply) then
        if not IsValid(ply) then
            print(msg)
            return
        end

        ply = {ply}
    end

    local rcp = RecipientFilter()
    for _, v in pairs(ply) do
        rcp:AddPlayer(v)
    end

    if hook.Run("onNotify", rcp:GetPlayers(), msgtype, len, msg) == true then return end

    umsg.Start("_Notify", rcp)
        umsg.String(msg)
        umsg.Short(msgtype)
        umsg.Long(len)
    umsg.End()
end

function paffSharing.notifyAll(msgtype, len, msg)
    if hook.Run("onNotify", player.GetAll(), msgtype, len, msg) == true then return end

    umsg.Start("_Notify")
        umsg.String(msg)
        umsg.Short(msgtype)
        umsg.Long(len)
    umsg.End()
end

local sound = "npc/roller/mine/rmine_chirp_answer1.wav"
timer.Simple(.1, function()
net.Receive("sharing_prop", function(len,pl)

	local target = net.ReadEntity()

	if not IsValid(target) then
		paffSharing.notify(pl, 1, 4, "ERROR")
		return
	end

	pl.propBuddies = pl.propBuddies or {}

	if not pl.propBuddies[target] then
		paffSharing.notify(pl, 1, 4, "You shared access with "..target:Nick())
		paffSharing.notify(target, 1, 4, pl:Nick().." granted you access to the props")
		target:SendLua("surface.PlaySound(\"npc/roller/mine/rmine_chirp_answer1.wav\")")
		pl.propBuddies[target] = true
	else
		paffSharing.notify(pl, 1, 4, "You took access from "..target:Nick())
		paffSharing.notify(target, 1, 4, pl:Nick().." took away your access")
		target:SendLua("surface.PlaySound(\"npc/roller/mine/rmine_chirp_answer1.wav\")")
		pl.propBuddies[target] = false
	end
end)

function PlayerCanManipulate(pl, ent)
	if IsValid(ent:CPPIGetOwner()) and ent:CPPIGetOwner().propBuddies and ent:CPPIGetOwner().propBuddies[pl] then
		return true
	end

	return (ent:CPPIGetOwner() == pl) or (pl:IsAdmin() and IsValid(ent:CPPIGetOwner()))
end

hook.Add('PhysgunPickup', 'PhysgunPickuppp', function(pl, ent)

	if !ent:IsPlayer() and !pl:IsAdmin() then
		if IsValid(ent) then
			local canphys = PlayerCanManipulate(pl, ent)

			if (not canphys) and ent.PhysgunPickup then
				canphys = ent:PhysgunPickup(pl)
			end

			if (canphys == true) then
				ent.BeingPhysed = true
			end

			return canphys
		end
		return false
	end

end)
end)
