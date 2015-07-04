if SERVER then
	resource.AddFile "materials/vscoreboard/webdings_muter_off.png"
	resource.AddFile "materials/vscoreboard/webdings_muter_on.png"
	resource.AddFile "materials/vscoreboard/steam.png"
	--resource.AddFile "materials/"

	return
end



local btn_mute = Material "vscoreboard/webdings_muter_off.png"
local btn_unmute = Material "vscoreboard/webdings_muter_on.png"



vScoreboard.hook.Add("vScoreboard_FetchTeamColor", "Standard team colors", function(t)
	if type(t) == "number" and team.Valid(t) then
		return team.GetColor(t)
	end
end)



vScoreboard.hook.Add("vScoreboard_PopulateColumns", "Common shenanigans", function(cols, add)
	add {
		Name = "Ping",
		Width = { "999 II", "Ping" },

		Content = function(self)
			return vgui.Create("vScoreboard_PingMeter", self.Right)
		end
	}
end)




vScoreboard.hook.Add("vScoreboard_PopulatePlayerCard", "Common shenanigans", function(self)
	--[[local btn = vgui.Create("vScoreboard_ImageButton", self.Right)
	btn:SetImage(btn_settings)

	self.PingMeter.x = btn:GetWide()

	self.Right:SetWide(self.PingMeter:GetWide() + btn:GetWide())--]]
end)




vScoreboard.hook.Add("vScoreboard_PopulatePlayerProperties", "Common shenanigans", function(ply, ctrls, add)
	local localply = LocalPlayer()
	local reflected, isBot = localply == ply, ply:IsBot()
	local sid, sid64 = tostring(ply:SteamID() or "none"), tostring(ply:SteamID64() or "none")
	local notReflected, notBot = not reflected, not isBot

	
	--	Top buttons!

	local t = {
		{
			Type = "Button",
			Image = "vscoreboard/steam.png",

			Disabled = isBot,
			ToolTip = isBot and "Cannot view profile of bot!" or "View Steam Profile",

			Click = notBot and function(btn)
				gui.OpenURL("http://steamcommunity.com/profiles/" .. sid64)
			end or nil,
		},
		{
			Type = "Button",
			Image = "vscoreboard/webdings_muter_off.png",

			Disabled = reflected,
			ToolTip = reflected and "Cannot (un)mute self!" or nil,

			Think = notReflected and function(btn)
				local isM = (not IsValid(ply)) and -1 or ply:IsMuted()

				if isM ~= btn.o_isM then
					btn.o_isM = isM

					if isM == -1 then
						btn:SetDisabled(true)

						btn:SetTooltip("Player no longer valid.")
					else
						btn:SetDisabled(false)
						
						btn:SetImage(isM and btn_unmute or btn_mute)
						btn:SetTooltip(isM and "Unmute" or "Mute")
					end
				end
			end or nil,

			Click = notReflected and function(btn)
				ply:SetMuted(not ply:IsMuted())
			end or nil,
		},
	}

	vScoreboard.hook.Run("vScoreboard_PopulatePlayerMainButtonStrip", ply, t, function(tab)
		t[#t+1] = tab
	end)

	add(vScoreboard.ButtonSize)

	add {
		Type = "Strip",
		Contents = t
	}

	add(vScoreboard.ButtonSize)

	if notBot then
		add {
			Type = "Label",
			Font = "Info",
			Text = "Steam IDs:",
			--Alignment = 5,
		}

		add {
			Type = "Button",
			Text = "Copy " .. sid,

			Click = function(btn)
				SetClipboardText(sid)
			end,
		}

		add {
			Type = "Button",
			Text = "Copy " .. sid64,

			Click = function(btn)
				SetClipboardText(sid64)
			end,
		}

		add(vScoreboard.ButtonSize)
	end

	local nao = #ctrls

	vScoreboard.hook.Run("vScoreboard_PopulatePlayerProperties_AddInfo", ply, ctrls, add)

	if #ctrls ~= nao then
		add(vScoreboard.ButtonSize)
	end

	if ULib and ULib.ucl then
		local ULib, ucl = ULib, ULib.ucl

		local Oadd = add
		local uclshizzle = {}
		add = function(t)
			uclshizzle[#uclshizzle+1] = t
		end

		if ucl.query(localply, "ulx kick") then
			add {
				Type = "Ribbon",
				Contents = {
					{
						Type = "Button",
						Text = "Kick quickly",

						Disabled = reflected,
						ToolTip = reflected and "Cannot kick self." or nil,

						Click = notReflected and function(btn)
							RunConsoleCommand("ulx", "kick", "$" .. ULib.getUniqueIDForPlayer(ply), "Quick kick!")
						end or nil,
					},
					{
						Type = "Button",
						Text = "and copy Steam ID",

						Disabled = reflected or isBot,
						ToolTip = reflected and "Cannot kick self." or isBot and "Bots have no Steam ID" or nil,

						Click = notReflected and notBot and function(btn)
							RunConsoleCommand("ulx", "kick", "$" .. ULib.getUniqueIDForPlayer(ply), "Quick kick!")
							SetClipboardText(sid)
						end or nil,
					}
				}
			}
		end

		if ucl.query(localply, "ulx votekick") then
			add {
				Type = "Button",
				Text = "Votekick",

				Disabled = reflected,
				ToolTip = reflected and "Cannot votekick self." or nil,

				Click = notReflected and function(btn)
					RunConsoleCommand("ulx", "votekick", "$" .. ULib.getUniqueIDForPlayer(ply), "Quick votekick!")
				end or nil,
			}
		end

		if ucl.query(localply, "ulx blind") then
			add {
				Type = "Ribbon",
				Contents = {
					{
						Type = "Button",
						WidthGroup = "ULX/ULib cmds",

						Text = "Blind",

						Click = function(btn)
							RunConsoleCommand("ulx", "blind", "$" .. ULib.getUniqueIDForPlayer(ply))
						end,
					},
					{
						Type = "Button",
						WidthGroup = "ULX/ULib cmds",
						
						Text = "Unblind",

						Click = function(btn)
							RunConsoleCommand("ulx", "unblind", "$" .. ULib.getUniqueIDForPlayer(ply))
						end,
					}
				}
			}
		end

		if ucl.query(localply, "ulx cloak") then
			add {
				Type = "Ribbon",
				Contents = {
					{
						Type = "Button",
						WidthGroup = "ULX/ULib cmds",
						
						Text = "Cloak",

						Click = function(btn)
							RunConsoleCommand("ulx", "cloak", "$" .. ULib.getUniqueIDForPlayer(ply))
						end,
					},
					{
						Type = "Button",
						WidthGroup = "ULX/ULib cmds",
						
						Text = "Uncloak",

						Click = function(btn)
							RunConsoleCommand("ulx", "uncloak", "$" .. ULib.getUniqueIDForPlayer(ply))
						end,
					}
				}
			}
		end

		if ucl.query(localply, "ulx ignite") then
			add {
				Type = "Ribbon",
				Contents = {
					{
						Type = "Button",
						WidthGroup = "ULX/ULib cmds",

						Text = "Ignite",

						Click = function(btn)
							RunConsoleCommand("ulx", "ignite", "$" .. ULib.getUniqueIDForPlayer(ply))
						end,
					},
					{
						Type = "Button",
						WidthGroup = "ULX/ULib cmds",
						
						Text = "Unignite",

						Click = function(btn)
							RunConsoleCommand("ulx", "unignite", "$" .. ULib.getUniqueIDForPlayer(ply))
						end,
					}
				}
			}
		end

		local allowedToSlap = ucl.query(localply, "ulx slap")
		local allowedToWhip = ucl.query(localply, "ulx whip")
		local allowedToSpectate = ucl.query(localply, "ulx spectate")

		if allowedToSlap or allowedToWhip or allowedToSpectate then
			add {
				Type = "Ribbon",
				Contents = {
					allowedToSlap and {
						Type = "Button",
						WidthGroup = "ULX/ULib cmds",
						
						Text = "Slap",

						Click = function(btn)
							RunConsoleCommand("ulx", "slap", "$" .. ULib.getUniqueIDForPlayer(ply))
						end,
					} or nil,
					allowedToWhip and {
						Type = "Button",
						WidthGroup = "ULX/ULib cmds",
						
						Text = "Whip",

						Click = function(btn)
							RunConsoleCommand("ulx", "whip", "$" .. ULib.getUniqueIDForPlayer(ply))
						end,
					} or nil,
					allowedToSpectate and {
						Type = "Button",
						WidthGroup = "ULX/ULib cmds",
						
						Text = "Spectate",

						Disabled = reflected,
						ToolTip = reflected and "Cannot target self." or nil,

						Click = notReflected and function(btn)
							RunConsoleCommand("ulx", "spectate", "$" .. ULib.getUniqueIDForPlayer(ply))
						end or nil,
					} or nil
				}
			}
		end

		local allowedToSlay = ucl.query(localply, "ulx slay")
		local allowedToSlaySilently = ucl.query(localply, "ulx sslay")

		if allowedToSlay or allowedToSlaySilently then
			add {
				Type = "Ribbon",
				Contents = {
					allowedToSlay and {
						Type = "Button",
						WidthGroup = "ULX/ULib cmds",
						
						Text = "Slay",

						Click = function(btn)
							RunConsoleCommand("ulx", "slay", "$" .. ULib.getUniqueIDForPlayer(ply))
						end,
					} or nil,
					allowedToSlaySilently and {
						Type = "Button",
						WidthGroup = "ULX/ULib cmds",
						
						Text = allowedToSlay and "Silently" or "Slay silently",

						Click = function(btn)
							RunConsoleCommand("ulx", "sslay", "$" .. ULib.getUniqueIDForPlayer(ply))
						end,
					} or nil
				}
			}
		end

		local allowedToGoto = ucl.query(localply, "ulx goto")
		local allowedToBring = ucl.query(localply, "ulx bring")
		local allowedToTeleport = ucl.query(localply, "ulx teleport")

		if allowedToGoto or allowedToBring or allowedToTeleport then
			add {
				Type = "Ribbon",
				Contents = {
					allowedToGoto and {
						Type = "Button",
						WidthGroup = "ULX/ULib cmds",
						
						Text = "Goto",

						Disabled = reflected,
						ToolTip = reflected and "Cannot target self." or nil,

						Click = notReflected and function(btn)
							RunConsoleCommand("ulx", "goto", "$" .. ULib.getUniqueIDForPlayer(ply))
						end or nil,
					} or nil,
					allowedToBring and {
						Type = "Button",
						WidthGroup = "ULX/ULib cmds",
						
						Text = "Bring",

						Disabled = reflected,
						ToolTip = reflected and "Cannot target self." or nil,

						Click = notReflected and function(btn)
							RunConsoleCommand("ulx", "bring", "$" .. ULib.getUniqueIDForPlayer(ply))
						end or nil,
					} or nil,
					allowedToTeleport and {
						Type = "Button",
						WidthGroup = "ULX/ULib cmds",
						
						Text = "Teleport",

						Click = function(btn)
							RunConsoleCommand("ulx", "teleport", "$" .. ULib.getUniqueIDForPlayer(ply))
						end,
					} or nil
				}
			}
		end

		--add(vScoreboard.ButtonSize)

		if ucl.query(localply, "ulx mute") then
			add {
				Type = "Ribbon",
				Contents = {
					{
						Type = "Button",
						WidthGroup = "ULX/ULib cmds",
						
						Text = "Mute",

						Click = function(btn)
							RunConsoleCommand("ulx", "mute", "$" .. ULib.getUniqueIDForPlayer(ply))
						end,
					},
					{
						Type = "Button",
						WidthGroup = "ULX/ULib cmds",
						
						Text = "Unmute",

						Click = function(btn)
							RunConsoleCommand("ulx", "unmute", "$" .. ULib.getUniqueIDForPlayer(ply))
						end,
					}
				}
			}
		end

		if ucl.query(localply, "ulx gag") then
			add {
				Type = "Ribbon",
				Contents = {
					{
						Type = "Button",
						WidthGroup = "ULX/ULib cmds",
						
						Text = "Gag",

						Click = function(btn)
							RunConsoleCommand("ulx", "gag", "$" .. ULib.getUniqueIDForPlayer(ply))
						end,
					},
					{
						Type = "Button",
						WidthGroup = "ULX/ULib cmds",
						
						Text = "Ungag",

						Click = function(btn)
							RunConsoleCommand("ulx", "ungag", "$" .. ULib.getUniqueIDForPlayer(ply))
						end,
					}
				}
			}
		end

		if ucl.query(localply, "ulx gimp") then
			add {
				Type = "Ribbon",
				Contents = {
					{
						Type = "Button",
						WidthGroup = "ULX/ULib cmds",
						
						Text = "Gimp",

						Click = function(btn)
							RunConsoleCommand("ulx", "gimp", "$" .. ULib.getUniqueIDForPlayer(ply))
						end,
					},
					{
						Type = "Button",
						WidthGroup = "ULX/ULib cmds",
						
						Text = "Ungimp",

						Click = function(btn)
							RunConsoleCommand("ulx", "ungimp", "$" .. ULib.getUniqueIDForPlayer(ply))
						end,
					}
				}
			}
		end

		add(vScoreboard.ButtonSize)

		add = Oadd
		
		if #uclshizzle > 0 then
			add {
				Type = "Label",
				Font = "Info",
				Text = "ULX/ULib commands:",
				--Alignment = 5,
			}

			for i = 1, #uclshizzle do
				add(uclshizzle[i])
			end
		end
	end
end)



vScoreboard.hook.Add("vScoreboard_PopulatePlayerList", "All players", function(plyAdd, plyRemove)
	plyAdd(GetAll())
end)



function vScoreboard.PlayerSorter(a, b)
	local x, y = 0, 0

	if a:IsBot() then x = x - 100 end
	if b:IsBot() then y = y - 100 end

	if a:IsSuperAdmin() then x = x + 10 end
	if a:IsAdmin() then x = x + 6 end

	if b:IsSuperAdmin() then y = y + 10 end
	if b:IsAdmin() then y = y + 6 end

	if x > y then
		return true		--	Player 'a' is of higher rank than 'b'.
	elseif x < y then
		return false	--	The other way around.
	else
		--	Draw.

		return (a:Nick()) < (b:Nick())
		--	Alphabetical!
	end
end



local iSA, iAd, iUs =
	Material("icon16/user_suit.png"),
	Material("icon16/shield.png"),
	nil

local cSA, cAd, cUs =
	Color(255, 106,   0),
	Color(127, 201, 255),
	nil --	Default color.

function vScoreboard.GetRank(ply)
	if ply:IsSuperAdmin() then
		return iSA, "Super Administrator", cSA
	elseif ply:IsAdmin() then
		return iAd, "Administrator", cAd
	else
		return iUs, nil, cUs
	end
end



vScoreboard.DermaSkinName = nil	--	Default. C:
