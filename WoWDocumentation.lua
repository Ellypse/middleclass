
local MiddleClass_API =
{
	Name = "MiddleClass",
	Type = "System",
	Namespace = "AddOn_Lib_Middleclass",

	Functions =
	{
		{
			Name = "createClass",
			Type = "Function",
			Documentation = { [[Creates a new middleclass Class to use for object oriented programming purposes.]] },

			Arguments =
			{
				{ Name = "name", Type = "string", Nilable = false, Documentation = { [[A name for the new class. It will be used when calling `tostring()` on an instance of the class.]] }, },
				{ Name = "super", Type = "MiddleClass_Class", Nilable = true, Documentation = { [[Another class to inherit from.]] }, },
			},

			Returns =
			{
				{ Name = "NewClass", Type = "MiddleClass_Class", Nilable = false, Documentation = { [[A new class with basic methods of object oriented programming.]] }, },
			},
		},
	},
	Events =
	{
	},
	Tables =
	{
	},
}

if IsAddOnLoaded("Blizzard_APIDocumentation") then
	APIDocumentation:AddDocumentationTable(self.MiddleClass_API)
else
	local f = CreateFrame("FRAME");
	f:RegisterEvent("ADDON_LOADED");
	f:SetScript("OnEvent", function(self, event, loadedAddonName)
		if loadedAddonName == "Blizzard_APIDocumentation" then
			APIDocumentation:AddDocumentationTable(MiddleClass_API);
			f:UnregisterAllEvents();
		end
	end)
end