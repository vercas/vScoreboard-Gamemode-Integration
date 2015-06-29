if SERVER then
	return
end



local doNothing = function() end



hook.Add("ScoreboardShow", "FAdmin_scoreboard", function()
	--	Nope.
end)

hook.Add("ScoreboardHide", "FAdmin_scoreboard", function()
	--	Nope!
end)



vScoreboard.hook.Add("vScoreboard_PopulateColumns", "DarkRP shenanigans", function(cols, add)
	add {
		Name = "Wanted",
		Width = { "Wanted", "WANTED", "wanted" },

		Content = function(self)
			local lbl = vgui.Create("DLabel", self)
			lbl:SetText("")
			lbl:SetTextColor(Color(255, 0, 0))
			lbl:SetFont(vScoreboard.RankFont)
			lbl:SetContentAlignment(5)

			local check = CurTime()
			function lbl.Think(lbl)
				if CurTime() - check > 1 then
					check = CurTime()

					if IsValid(self.p) and self.p.DarkRPVars and self.p.DarkRPVars.wanted then
						lbl:SetText("WANTED")
					else
						lbl:SetText("")
					end
				end
			end

			return lbl
		end
	}
end)



vScoreboard.hook.Add("vScoreboard_PopulatePlayerProperties_AddInfo", "DarkRP shenanigans", function(ply, ctrls, add)
	local localply = LocalPlayer()
	local reflected, isBot = localply == ply, ply:IsBot()
	local sid, sid64 = tostring(ply:SteamID() or "none"), tostring(ply:SteamID64() or "none")
	local notReflected, notBot = not reflected, not isBot

	

	if not localply:IsAdmin() then return end

	--	DarkRP moneyz

	local moneyThingie = nil

	local infoz = FAdmin.ScoreBoard.Player.Information

	for i = 1, #infoz do
		if infoz[i].name == "Money" then
			moneyThingie = infoz[i]
			break
		end
	end

	if not moneyThingie then return end
	
	add {
		Type = "Label",
		Font = "Info",
		Text = "Money:",
	}
	add {
		Type = "Button",
		Text = "Copy $-------------",

		Think = function(btn)
			local plymoneyz = moneyThingie.func(ply)

			if plymoneyz ~= btn.Oval then
				btn.Oval = plymoneyz

				btn:SetText("Copy " .. plymoneyz)
			end
		end,

		Click = function(btn)
			SetClipboardText(moneyThingie.func(ply))
		end
	}
end)



vScoreboard.hook.Add("vScoreboard_PopulatePlayerProperties", "DarkRP shenanigans", function(ply, ctrls, add)
	local localply = LocalPlayer()
	local reflected, isBot = localply == ply, ply:IsBot()
	local sid, sid64 = tostring(ply:SteamID() or "none"), tostring(ply:SteamID64() or "none")
	local notReflected, notBot = not reflected, not isBot

	
	--	DarkRP/FAdmin shit

	local fadminshizzle = {}
	local add2 = function(t)
		fadminshizzle[#fadminshizzle+1] = t
		return t
	end

	local laststrip = nil

	for k, v in ipairs(FAdmin.ScoreBoard.Player.ActionButtons) do
		if v.Visible == true or (type(v.Visible) == "function" and v.Visible(ply) == true) then
			local name = v.Name
			if type(name) == "function" then name = name(ply) end

			local btn = {
				Type = "Button",
				WidthGroup = "FAdmin/DarkRP cmds",

				Text = name,

				Click = function(btn)
					btn.SetImage2 = doNothing
					v.Action(ply, btn)
				end,
			}

			if laststrip then
				laststrip.Contents[#laststrip.Contents + 1] = btn

				laststrip = nil
			else
				laststrip = add2 {
					Type = "Ribbon",
					Contents = {
						btn
					},
				}
			end
		end
	end

	if #fadminshizzle > 0 then
		add {
			Type = "Label",
			Font = "Info",
			Text = "DarkRP/FAdmin commands:",
			--Alignment = 5,
		}

		for i = 1, #fadminshizzle do
			add(fadminshizzle[i])
		end
	end
end)



vScoreboard.hook.Add("vScoreboard_PopulatePlayerCard", "DarkRP_Wanted", function(self)
	--[[local lbl = vgui.Create("DLabel", self.Bottom)
	lbl:Dock(RIGHT)
	lbl:SetFont(vScoreboard.RankFont)
	lbl:SetText("")
	lbl:SizeToContents()
	lbl:SetTextColor(Color(255,0,0))

	local last = false
	local check = CurTime()
	function lbl.Think(lbl)
		if CurTime() - check > 1 then
			if IsValid(self.p) then
				local new = self.p.DarkRPVars and self.p.DarkRPVars.wanted

				if last ~= new then
					last = new

					if new then
						lbl:SetText("WANTED")
					else
						lbl:SetText("")
					end
					
					lbl:SizeToContents()
				end
			end
		end
	end--]]
end)
