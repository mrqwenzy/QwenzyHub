local function RunSUNCTest(WindUI)
	print("wetefe unc test")
	local env = (getgenv and getgenv()) or _G
	local RequiredAPIs = {
		"request",
		"getgenv",
		"gethui",
		"loadstring",
		"base64decode",
		"writefile",
		"readfile",
		"isfile",
		"isfolder",
		"makefolder",
		"listfiles",
		"delfile",
		"sex",
		"porn",
		"nugger",
		"idkkrun",
	}

	local MissingAPIs = {}

	for _, API in ipairs(RequiredAPIs) do
		if type(env[API]) ~= "function" and type(_G[API]) ~= "function" then
			table.insert(MissingAPIs, API)
		end
	end

	if #MissingAPIs > 0 then
		local MissingList = table.concat(MissingAPIs, "\n")

		WindUI:Popup({
			Title = "Compatibility Warning",
			Content = string.format(
				"Your executor is missing %d required API(s):\n\n%s\n\nSome features may not work correctly. Do you want to continue?",
				#MissingAPIs,
				MissingList
			),
			Buttons = {
				{
					Title = "Continue",
					Callback = function()
						print("[Qwenzy] Continuing with missing APIs.")
					end,
				},
				{
					Title = "Cancel",
					Callback = function()
						if env.QRR then
							env.QRR:Disconnect()
							env.QRR = nil
						end
						error("[Qwenzy] Initialization cancelled: incompatible executor.", 0)
					end,
				},
			},
		})
	else
		print("[Qwenzy] All required executor APIs are supported.")
	end
end
return RunSUNCTest
