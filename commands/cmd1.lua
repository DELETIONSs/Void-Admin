return {
	Name = "kill",
	Description = "Kills a player by name",
	Run = function(targetName)
		local Players = game:GetService("Players")
		local lp = Players.LocalPlayer
		local target = nil

		for _, p in ipairs(Players:GetPlayers()) do
			if p.Name:lower():sub(1, #targetName) == targetName:lower() then
				target = p
				break
			end
		end

		if target and target.Character and target.Character:FindFirstChild("Humanoid") then
			target.Character.Humanoid.Health = 0
		else
			warn("[DarkAdmin] Player not found or invalid character.")
		end
	end
}