local grpassoc, grpassoc2 = {}, {}

vScoreboard.hook.Add("vScoreboard_FetchPlayerTeam", "TTT teams", function(ply)
	local grp = ScoreGroup(ply)

	if not grp then return end

	if grpassoc[grp] then
		return grpassoc[grp]
	end

	if not LANG.GetUnsafeLanguageTable() then
		MsgN "FUCKUP OMG"
	end

	if grp == GROUP_TERROR then
		grpassoc[grp] = LANG.GetTranslation("terrorists")
	elseif grp == GROUP_NOTFOUND then
		grpassoc[grp] = LANG.GetTranslation("sb_mia")
	elseif grp == GROUP_FOUND then
		grpassoc[grp] = LANG.GetTranslation("sb_confirmed")
	elseif grp == GROUP_SPEC then
		grpassoc[grp] = LANG.GetTranslation("spectators")
	else
		grpassoc[grp] = "unknown team/group"
	end

	grpassoc2[grpassoc[grp]] = grp

	return grpassoc[grp]
end)

vScoreboard.hook.Add("vScoreboard_FetchTeamColor", "TTT team colors", function(t)
	local tttt = grpassoc2[t]

	if not tttt then return end

	if tttt == GROUP_TERROR then
		return Color(0,200,0,100)
	elseif tttt == GROUP_NOTFOUND then
		return Color(130, 190, 130, 100)
	elseif tttt == GROUP_FOUND then
		return Color(130, 170, 10, 100)
	elseif tttt == GROUP_SPEC then
		return Color(200, 200, 0, 100)
	end
end)



vScoreboard.hook.Add("vScoreboard_PopulateColumns", "TTT shenanigans", function(cols, add)
	add {
		Name = "Rounds left",
		Width = { "Rounds left: 0000" },

		_INFO = true,

		Think = function(lbl)
			local rl = math_max(0, GetGlobalInt("ttt_rounds_left", 6))

			if rl ~= lbl.Orl then
				lbl.Orl = rl

				lbl:SetText("Rounds left: " .. tostring(rl))
				lbl:SizeToContents()
			end
		end
	}

	if KARMA.IsEnabled() then
		add {
			Name = "Karma",
			Width = { "9999", "Karma" },

			Content = function(self)
				local lbl = vgui.Create("DLabel", self)
				lbl:SetText("")
				lbl:SetFont(vScoreboard.ColumnFont)
				lbl:SetContentAlignment(5)

				local check = CurTime()
				function lbl.Think(lbl)
					if CurTime() - check > 1 then
						check = CurTime()

						if IsValid(self.p) then
							lbl:SetText(math.Round(self.p:GetBaseKarma()))
						else
							lbl:SetText("")
						end
					end
				end

				return lbl
			end
		}--]]
	end

	add {
		Name = "Deaths",
		Width = { "9999", "Deaths" },

		Content = function(self)
			local lbl = vgui.Create("DLabel", self)
			lbl:SetText("")
			lbl:SetFont(vScoreboard.ColumnFont)
			lbl:SetContentAlignment(5)

			local check = CurTime()
			function lbl.Think(lbl)
				if CurTime() - check > 1 then
					check = CurTime()

					if IsValid(self.p) then
						lbl:SetText(tostring(self.p:Deaths()))
					else
						lbl:SetText("")
					end
				end
			end

			return lbl
		end
	}

	add {
		Name = "Score",
		Width = { "9999", "Score" },

		Content = function(self)
			local lbl = vgui.Create("DLabel", self)
			lbl:SetText("")
			lbl:SetFont(vScoreboard.ColumnFont)
			lbl:SetContentAlignment(5)

			local check = CurTime()
			function lbl.Think(lbl)
				if CurTime() - check > 1 then
					check = CurTime()

					if IsValid(self.p) then
						lbl:SetText(tostring(self.p:Frags()))
					else
						lbl:SetText("")
					end
				end
			end

			return lbl
		end
	}

	--[[add {
		Name = "Status",
		Width = { "Traitor", "Detective", "Status" },

		Content = function(self)
			local lbl = vgui.Create("DLabel", self)
			lbl:SetText("")
			lbl:SetFont(vScoreboard.ColumnFont)
			lbl:SetContentAlignment(5)

			local check = CurTime()
			function lbl.Think(lbl)
				if CurTime() - check > 1 and IsValid(self.p)then
					check = CurTime()

					if self.p:IsTraitor() then
						lbl:SetText("Traitor")
						lbl:SetTextColor(Color(255, 0, 0))
					elseif self.p:IsDetective() then
						lbl:SetText("Detective")
						lbl:SetTextColor(Color(0, 0, 255))
					else
						lbl:SetText("")
					end
				end
			end

			return lbl
		end
	}--]]
end)



vScoreboard.hook.Add("vScoreboard_PopulatePlayerCard", "TTT shenanigans", function(self)
	local oP = self.Paint

	function self:Paint(w, h)
		if IsValid(self.p) then
			if self.p:IsTraitor() then
				surface.SetDrawColor(255, 0, 0, 30)
				surface.DrawRect(0, 0, w, h)
			elseif self.p:IsDetective() then
				surface.SetDrawColor(0, 0, 255, 30)
				surface.DrawRect(0, 0, w, h)
			end

			local t = self.p.sb_tag

			if t then
				local txt = LANG.GetTranslation(t.txt)
				SetFont(vScoreboard.RankFont)
				local tw, th = GetTextSize(txt)

				surface.SetTextPos(self.Right.x - tw - vScoreboard.PlayerLabelMargins, (h - th) / 2)
				surface.SetTextColor(t.color or COLOR_WHITE)
				surface.DrawText(txt)
			end
		end

		oP(self, w, h)
	end
end)



local tags = {
	{txt="sb_tag_friend", color=COLOR_GREEN},
	{txt="sb_tag_susp",   color=COLOR_YELLOW},
	{txt="sb_tag_avoid",  color=Color(255, 150, 0, 255)},
	{txt="sb_tag_kill",   color=COLOR_RED},
	{txt="sb_tag_miss",   color=Color(130, 190, 130, 255)}
}



vScoreboard.hook.Add("vScoreboard_PopulatePlayerProperties_AddInfo", "TTT shenanigans", function(ply, ctrls, add)
	local localply = LocalPlayer()
	local reflected, isBot = localply == ply, ply:IsBot()
	local sid, sid64 = tostring(ply:SteamID() or "none"), tostring(ply:SteamID64() or "none")
	local notReflected, notBot = not reflected, not isBot

	local g, t = ScoreGroup(ply), ply.sb_tag
	
	
	if g == GROUP_TERROR and notReflected then
		add {
			Type = "Label",
			Font = "Info",
			Text = "TTT Tags:",
			--Alignment = 5,
		}

		for i = 1, #tags do
			local tag, name = tags[i], LANG.GetTranslation(tags[i].txt)

			add {
				Type = "Button",
				Text = "  " .. name .. "  ",

				Click = function(btn)
					if ply.sb_tag == tag or (ply.sb_tag and ply.sb_tag.txt == tag.txt) then
						ply.sb_tag = nil
					else
						ply.sb_tag = tag
					end
				end,

				Think = function(btn)
					if not btn.ColorSet then
						btn.customColor = tag.color or COLOR_WHITE
						btn.ColorSet = true
					end

					local selected = ply.sb_tag == tag or (ply.sb_tag and ply.sb_tag.txt == tag.txt)

					if selected ~= btn.Oselected then
						btn.Oselected = selected

						btn:SetText(selected and ("[ " .. name .. " ]") or ("  " .. name .. "  "))
					end
				end,
			}
		end
	elseif g == GROUP_FOUND or g == GROUP_NOTFOUND then
		--	search?
	end
end)



vScoreboard.TeamSorter = function(a, b)
	local a, b = grpassoc2[a], grpassoc2[b]

	if a == GROUP_TERROR then
		return true
	elseif a == GROUP_NOTFOUND and b ~= GROUP_TERROR then
		return true
	elseif a == GROUP_FOUND and b ~= GROUP_TERROR and b ~= GROUP_NOTFOUND then
		return true
	else
		return false
	end
end
