local HttpService = game:GetService("HttpService")

local ConfigManager = {}
local CONFIG_FOLDER = "QwenzyRecode_Configs"

local function normalizeName(Name)
	if type(Name) ~= "string" then
		return nil
	end

	Name = Name:match("^%s*(.-)%s*$")
	Name = Name:gsub("%s+", "_"):gsub("[^%w_-]", "")

	if Name == "" or Name == "." or Name == ".." then
		return nil
	end

	return Name:sub(1, 40)
end

local function ensureFolder()
	if type(writefile) ~= "function" or type(readfile) ~= "function" or type(isfile) ~= "function" then
		return false, "Executor file APIs are unavailable"
	end

	if type(isfolder) == "function" and isfolder(CONFIG_FOLDER) then
		return true
	end

	if type(makefolder) ~= "function" then
		return false, "Folder creation API is unavailable"
	end

	local Ok, Error = pcall(makefolder, CONFIG_FOLDER)
	if not Ok and (type(isfolder) ~= "function" or not isfolder(CONFIG_FOLDER)) then
		return false, tostring(Error)
	end

	return true
end

local function filePath(Name)
	return CONFIG_FOLDER .. "/" .. Name .. ".json"
end

local function getElementValue(Element)
	local Value = Element.Value
	if type(Value) == "table" and Value.Default ~= nil then
		return Value.Default
	end
	return Value
end

function ConfigManager.new()
	local self = {
		Elements = {},
		CurrentName = "default",
	}

	function self:Register(Flag, Element, DefaultValue)
		assert(type(Flag) == "string" and Flag ~= "", "Config flag must be a non-empty string")
		assert(type(Element) == "table" and type(Element.Set) == "function", "Config element must support Set(value)")
		assert(DefaultValue ~= nil, "Config element must have an explicit default value")

		self.Elements[Flag] = {
			Element = Element,
			Default = DefaultValue,
		}
	end

	function self:List()
		local Ok, Error = ensureFolder()
		if not Ok or type(listfiles) ~= "function" then
			return {}, Error or "File listing API is unavailable"
		end

		local Names = {}
		for _, Path in ipairs(listfiles(CONFIG_FOLDER)) do
			local Name = Path:match("([^/\\]+)%.json$")
			if Name then
				table.insert(Names, Name)
			end
		end

		table.sort(Names)
		return Names
	end

	function self:Save(Name)
		Name = normalizeName(Name or self.CurrentName)
		if not Name then
			return false, "Enter a valid config name"
		end

		local Ok, Error = ensureFolder()
		if not Ok then
			return false, Error
		end

		local Values = {}
		for Flag, Entry in pairs(self.Elements) do
			local Value = getElementValue(Entry.Element)
			if type(Value) == "boolean" or type(Value) == "number" or type(Value) == "string" or type(Value) == "table" then
				Values[Flag] = Value
			end
		end

		local OkEncode, Json = pcall(function()
			return HttpService:JSONEncode({ Version = 1, Values = Values })
		end)
		if not OkEncode then
			return false, tostring(Json)
		end

		local OkWrite, WriteError = pcall(writefile, filePath(Name), Json)
		if not OkWrite then
			return false, tostring(WriteError)
		end

		self.CurrentName = Name
		return true
	end

	function self:Load(Name)
		Name = normalizeName(Name or self.CurrentName)
		if not Name then
			return false, "Enter a valid config name"
		end

		local Ok, Error = ensureFolder()
		if not Ok then
			return false, Error
		end

		local Path = filePath(Name)
		if not isfile(Path) then
			for _, Entry in pairs(self.Elements) do
				Entry.Element:Set(Entry.Default)
			end
			return false, "Config file does not exist"
		end

		local OkRead, Json = pcall(readfile, Path)
		if not OkRead then
			return false, tostring(Json)
		end

		local OkDecode, Data = pcall(function()
			return HttpService:JSONDecode(Json)
		end)
		if not OkDecode or type(Data) ~= "table" or type(Data.Values) ~= "table" then
			return false, "Config file is invalid"
		end

		for Flag, Entry in pairs(self.Elements) do
			local Value = Data.Values[Flag]
			if Value == nil or type(Value) ~= type(Entry.Default) then
				Value = Entry.Default
			end

			if type(Entry.Default) == "number" and type(Value) == "number" then
				local Spec = Entry.Element.Value
				if type(Spec) == "table" then
					if type(Spec.Min) == "number" then Value = math.max(Value, Spec.Min) end
					if type(Spec.Max) == "number" then Value = math.min(Value, Spec.Max) end
				end
			end

			Entry.Element:Set(Value)
		end

		self.CurrentName = Name
		return true
	end

	function self:Delete(Name)
		Name = normalizeName(Name or self.CurrentName)
		if not Name then
			return false, "Enter a valid config name"
		end
		if type(delfile) ~= "function" then
			return false, "File deletion API is unavailable"
		end

		local Path = filePath(Name)
		if not isfile(Path) then
			return false, "Config file does not exist"
		end

		local Ok, Error = pcall(delfile, Path)
		if not Ok then
			return false, tostring(Error)
		end

		if self.CurrentName == Name then
			self.CurrentName = "default"
		end
		return true
	end

	function self:BuildUI(Tab)
		local Section = Tab:Section({ Title = "Config Files" })
		local SelectedName = self.CurrentName
		local NameInput
		local ConfigDropdown

		local function RefreshConfigs()
			if not ConfigDropdown then
				return
			end
			local Names = self:List()
			if #Names == 0 then Names = { "default" } end
			ConfigDropdown:Refresh(Names)

			if not table.find(Names, SelectedName) then
				SelectedName = Names[1]
			end
			NameInput:Set(SelectedName)
			ConfigDropdown:Select(SelectedName)
		end

		NameInput = Section:Input({
			Title = "Config name",
			Value = SelectedName,
			Placeholder = "Enter a name",
			Callback = function(Value)
				if type(Value) == "string" then
					SelectedName = Value
				end
			end,
		})

		local Names = self:List()
		if #Names == 0 then Names = { "default" } end
		if not table.find(Names, SelectedName) then
			SelectedName = Names[1]
		end
		ConfigDropdown = Section:Dropdown({
			Title = "Saved configs",
			Values = Names,
			Value = SelectedName,
			AllowNone = false,
			Callback = function(Value)
				if type(Value) == "string" then
					SelectedName = Value
					NameInput:Set(Value)
				end
			end,
		})

		Section:Button({
			Title = "Save config",
			Callback = function()
				local Ok, Error = self:Save(SelectedName)
				if Ok then
				SelectedName = self.CurrentName
					print("[Qwenzy] Saved config: " .. self.CurrentName)
					RefreshConfigs()
				else
					warn("[Qwenzy] Config save failed: " .. tostring(Error))
				end
			end,
		})

		Section:Button({
			Title = "Load config",
			Callback = function()
				local Ok, Error = self:Load(SelectedName)
				if Ok then
					print("[Qwenzy] Loaded config: " .. self.CurrentName)
				else
					warn("[Qwenzy] Config load failed: " .. tostring(Error))
				end
			end,
		})

		Section:Button({
			Title = "Delete config",
			Callback = function()
				local Ok, Error = self:Delete(SelectedName)
				if Ok then
					SelectedName = "default"
					NameInput:Set(SelectedName)
					RefreshConfigs()
					print("[Qwenzy] Deleted config")
				else
					warn("[Qwenzy] Config delete failed: " .. tostring(Error))
				end
			end,
		})
	end

	return self
end

return ConfigManager
