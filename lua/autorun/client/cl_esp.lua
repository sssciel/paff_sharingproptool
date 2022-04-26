local job_col

surface.CreateFont("sp_title", {size = 31, weight = 450, antialias = true, extended = true, font = "Montserrat"})
surface.CreateFont("sp_title_sub", {size = 25, weight = 450, antialias = true, extended = true, font = "Montserrat"})
surface.CreateFont("sp_nick", {size = 23, weight = 450, antialias = true, extended = true, font = "Montserrat"})
surface.CreateFont( "paffProtect_main", {
  font = "Montserrat",
  size = 25,
  weight = 500,
  antialias = true,
  extended = true,
} )
surface.CreateFont( "paffProtect_submain", {
  font = "Montserrat",
  size = 25,
  weight = 500,
  antialias = true,
  extended = true,
} )
surface.CreateFont( "paffProtect_sub", {
  font = "Montserrat",
  size = 20,
  weight = 250,
  antialias = true,
  extended = true,
} )
surface.CreateFont( "paffProtect_close", {
  font = "Montserrat",
  size = 30,
  weight = 250,
  antialias = true,
  extended = true,
} )

paffSharing = {}

function paffSharing.findPlayer(info)
  if not info or info == "" then return nil end
  local pls = player.GetAll()

  for k = 1, #pls do -- Proven to be faster than pairs loop.
      local v = pls[k]
      if tonumber(info) == v:UserID() then
          return v
      end

      if info == v:SteamID() then
          return v
      end

      if string.find(string.lower(v:Nick()), string.lower(tostring(info)), 1, true) ~= nil then
          return v
      end

      if string.find(string.lower(v:SteamName()), string.lower(tostring(info)), 1, true) ~= nil then
          return v
      end
  end
  return nil
end

local function drawRectOutline( x, y, w, h, color )
	surface.SetDrawColor( color )
	surface.DrawOutlinedRect( x, y, w, h )
end

hook.Add( "InitPostEntity", "paff_sharing_create", function()
  if IsValid(LocalPlayer()) then LocalPlayer().propBuddies = {} end    
end )

local blur = Material("pp/blurscreen")
local function DrawBlur(panel, amount) --Panel blur function
  local x, y = panel:LocalToScreen(0, 0)
  local scrW, scrH = ScrW(), ScrH()
  surface.SetDrawColor(255, 255, 255)
  surface.SetMaterial(blur)
  for i = 1, 6 do
    blur:SetFloat("$blur", (i / 3) * (amount or 6))
    blur:Recompute()
    render.UpdateScreenEffectTexture()
    surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
  end
end

concommand.Add("paff_sharingtools", function()
  if IsValid(main) then
      main:Remove()
  end
  main = vgui.Create("EditablePanel")
  main:SetSize(400,400)
  main:Center()
  main:MakePopup()
  main.Paint = function(k, w,h)
      DrawBlur(main, 2)
      drawRectOutline( 0, 0, w,h, color_white )	
      draw.RoundedBox(0,0,0,w,h,Color(0,0,0,150))
  end
  local toppanel = vgui.Create("DPanel",main)
  toppanel:Dock(TOP)
  toppanel:SetTall(45)
  toppanel.Paint = function(k, w,h)
      draw.RoundedBox(0,1,1,w-1,h-1,Color(0,0,0,150))
      drawRectOutline( 0, 0, w,h, Color(0,0,0,85) )	
      draw.SimpleText( "paffSharingTool", "paffProtect_main", w / 2, h/2 - 1, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
  end
  local closebtn = vgui.Create("DButton", toppanel)
  closebtn:SetSize(toppanel:GetTall(),toppanel:GetTall())
  closebtn:Dock(RIGHT)
  closebtn:SetText("✖")
  closebtn:SetTextColor(color_white)
  closebtn:SetFont( "paffProtect_close" )
  closebtn.DoClick = function()
      main:Remove()
  end
  closebtn.Paint = function(k, w,h)
  end

  local playerlist_bg = vgui.Create("DPanel",main)
  playerlist_bg:Dock(FILL)
  playerlist_bg:SetTall(200)
  playerlist_bg.Paint = function(k, w,h)
  end

  local allplayer_bg = vgui.Create("DPanel",playerlist_bg)
  allplayer_bg:SetPos(10,10)
  allplayer_bg:SetSize(150,200)

  local selplayers_bg = vgui.Create("DPanel",playerlist_bg)
  selplayers_bg:SetPos(main:GetWide()-160,10)
  selplayers_bg:SetSize(150,200)

  local allplayers_ = vgui.Create("DListView", allplayer_bg)
  allplayers_:Dock(FILL)
  allplayers_:AddColumn("Players list")
  allplayers_:SetMultiSelect(false)
  for k,v in pairs(player.GetAll()) do
      if LocalPlayer().propBuddies[v] or v == LocalPlayer() then continue end   
      allplayers_:AddLine(v:Nick())
  end

  local selplayers_ = vgui.Create("DListView", selplayers_bg)
  selplayers_:Dock(FILL)
  selplayers_:AddColumn("Players with access")
  selplayers_:SetMultiSelect(false)
  for k,v in pairs(player.GetAll()) do
      if !LocalPlayer().propBuddies[v] then continue end   
      selplayers_:AddLine(v:Nick())
  end

  local selplayer_s = vgui.Create("DButton",playerlist_bg)
  selplayer_s:SetPos(main:GetWide()/2-35,80+30-20)
  selplayer_s:SetSize(70,40)
  selplayer_s:SetFont("paffProtect_sub")
  selplayer_s:SetText("Select")
  selplayer_s:SetTextColor(color_white)
  selplayer_s.Paint = function(k, w,h)
      draw.RoundedBox(0,1,1,w-1,h-1,Color(0,0,0,150))
  end
  selplayer_s.DoClick = function()
      if allplayers_:GetSelectedLine() then
          local selectedline = allplayers_:GetLine(allplayers_:GetSelectedLine())
          local selectedlinetext = allplayers_:GetLine(allplayers_:GetSelectedLine()):GetValue(1)
          selplayers_:AddLine(selectedlinetext)
          allplayers_:RemoveLine(selectedline:GetID())
          local pL = paffSharing.findPlayer(selectedlinetext)
          LocalPlayer().propBuddies[pL] = true
          surface.PlaySound( "npc/roller/mine/rmine_chirp_answer1.wav" )
          net.Start( "sharing_prop" )
            net.WriteEntity(pL)
          net.SendToServer()
      end
      if selplayers_:GetSelectedLine() then
          local selectedline = selplayers_:GetLine(selplayers_:GetSelectedLine())
          local selectedlinetext = selplayers_:GetLine(selplayers_:GetSelectedLine()):GetValue(1)
          allplayers_:AddLine(selectedlinetext)
          selplayers_:RemoveLine(selectedline:GetID())
          local pL = paffSharing.findPlayer(selectedlinetext)
          LocalPlayer().propBuddies[pL] = false
          surface.PlaySound( "npc/roller/mine/rmine_chirp_answer1.wav" )
          net.Start( "sharing_prop" )
            net.WriteEntity(pL)
          net.SendToServer()
      end
  end

end)

hook.Add( "OnPlayerChat", "openmenu", function( ply, strText, bTeam, bDead ) 
  if ( ply != LocalPlayer() ) then return end
if ( string.lower( strText ) == "/propsharing" or  string.lower( strText ) == "!propsharing") then 
  RunConsoleCommand("paff_sharingtools")
  return true
end
end )
