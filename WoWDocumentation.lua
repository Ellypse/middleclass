local MiddleClass_API = {
	Name = "MiddleClass",
	Type = "System",
	Namespace = "AddOn_Lib_Middleclass",

	Functions = {
		{
			Name = "createClass",
			Type = "Function",
			Documentation = {
				[[Creates a new middleclass Class to use for object oriented programming purposes.]]
			},
			Arguments = {
				{
					Name = "name",
					Type = "string",
					Nilable = false,
					Documentation = {
						[[A name for the new class. It will be used when calling `tostring()` on an instance of the class.]]
					},
				},
				{
					Name = "super",
					Type = "MiddleClass_Class",
					Nilable = true,
					Documentation = {
						[[Another class to inherit from.]]
					},
				},
			},
			Returns = {
				{
					Name = "NewClass",
					Type = "MiddleClass_Class",
					Nilable = false,
					Documentation = {
						[[A new class with basic methods of object oriented programming.]]
					},
				},
			},
		},
		{
			Name = "final",
			Type = "Function",
			Documentation = {
				[[Makes a MiddleClass_Class Final. It can no longer be inherited from and no new methods can be added to it.]]
			},
			Arguments = {
				{
					Name = "class",
					Type = "MiddleClass_Class",
					Nilable = true
				},
			},
		},
		{
			Name = "isFinal",
			Type = "Function",
			Documentation = {
				[[Check if a class is final and cannot be modified or inherited.]]
			},
			Arguments = {
				{
					Name = "class",
					Type = "MiddleClass_Class",
					Nilable = true,
				},
			},
			Returns = {
				{
					Name = "isFinal",
					Type = "boolean",
					Nilable = false,
					Documentation = {
						[[Returns true if the class is final.]]
					},
				},
			},
		},
		{
			Name = "protected",
			Type = "Function",
			Documentation = {
				[[Protects a MiddleClass_Class from being modified, its properties and methods cannot be modified.]]
			},
			Arguments = {
				{
					Name = "class",
					Type = "MiddleClass_Class",
					Nilable = true
				},
			},
		},
		{
			Name = "isProtected",
			Type = "Function",
			Documentation = {
				[[Check if an instance of a MiddleClass_Class is protected.]]
			},
			Arguments = {
				{
					Name = "instance",
					Type = "MiddleClass_Class",
					Nilable = true,
				},
			},
			Returns = {
				{
					Name = "isProtected",
					Type = "boolean",
					Nilable = false,
					Documentation = {
						[[Returns true if the instance is protected.]]
					},
				},
			},
		},
		{
			Name = "getPrivateStorage",
			Type = "Function",
			Returns = {
				{
					Name = "privateStorage",
					Type = "table",
					Nilable = false,
					Documentation = {
						[[Private storage table, used to store private properties by indexing the table per instance of a class.
The table has weak indexes which means it will not prevent the objects from being garbage collected.
local privateStore = MiddleClass.getPrivateStorage()
local myClassInstance = MyClass()
privateStore[myClassInstance].privateProperty = someValue]]
					},
				},
			},
		},
	},
	Events = {
	},
	Tables = {
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