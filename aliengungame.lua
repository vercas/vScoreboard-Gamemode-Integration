local GetGlobalFloat, GetConVarNumber = GetGlobalFloat, GetConVarNumber



local msg_name = "vScoreboard - Alien Gun Game Max Round Fix"

if SERVER then
	util.AddNetworkString(msg_name)

	local o = -1

	local function sync(target)
		net.Start(msg_name)
		net.WriteInt(o, 32)

		if target == true then
			net.Broadcast()
		else
			net.Send(target)
		end
	end

	net.Receive(msg_name, function(len, ply)
		sync(ply, o)
	end)



	local lastCheck = 0

	hook.Add("Think", "vScoreboard - Alien Gun Game Max Round Sync", function()
		local now = CurTime()

		if now - lastCheck > 1 then
			lastCheck = now

			local rm = GetConVarNumber("gg_maxrounds")

			if rm ~= o then
				o = rm

				sync(true)
			end
		end
	end)

	hook.Add("PlayerAuthed", "vScoreboard - Alien Gun Game Max Round Sync", function(ply)
		sync(ply)
	end)
else
	local rmax = -1

	net.Receive(msg_name, function(len)
		rmax = net.ReadInt(32)
	end)

	if vScoreboard.Reloading then
		net.Start(msg_name)
		net.SendToServer()
	end



	vScoreboard.hook.Add("vScoreboard_PopulateColumns", "TTT shenanigans", function(cols, add)
		add {
			Name = "Round",
			Width = { "Round: 100/100" },

			_INFO = true,

			Think = function(lbl)
				local r = GetGlobalFloat("rounds")
				local rm = tonumber(rmax)

				if not (r and rm) then return end

				local rl = tostring(r) .. "/" .. tostring(rm)

				if rl ~= lbl.Orl then
					lbl.Orl = rl

					lbl:SetText("Round: " .. rl)
					lbl:SizeToContents()
				end
			end
		}

		add {
			Name = "K/D Ratio",
			Width = { "100.00", "K/D Ratio" },

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
							if self.p:Deaths() == 0 then
								lbl:SetText("-")
							else
								local rat = tostring(self.p:Frags() / self.p:Deaths())

								local a, b, bef, aft = string.find(rat, "(%d*)([%.,]?%d?%d?)")

								lbl:SetText(a and (bef .. aft) or rat)
								--lbl:SetText(string.format("%.2f", self.p:Frags() / self.p:Deaths()))
							end
						else
							lbl:SetText("")
						end
					end
				end

				return lbl
			end
		}

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
	end)



	local ops = vScoreboard.PlayerSorter or function(a, b)
		return (a:Nick()) < (b:Nick())
	end

	function vScoreboard.PlayerSorter(a, b)
		if a:Frags() > b:Frags() then
			return true
		elseif a:Frags() < b:Frags() then
			return false
		end

		return ops(a, b)
	end
end
