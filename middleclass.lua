----------------------------------------------------------------------------------
--- Middleclass for World of Warcraft
---
--- An adaptation of Enrique García Cota's middleclass for World of Warcraft
--- and to better suit some specific needs I have from an OOP framework.
---
--- See <https://github.com/kikito/middleclass>
---	---------------------------------------------------------------------------
---     MIT LICENSE
---
---    Copyright 2018 Renaud "Ellypse" Parize <ellypse@totalrp3.info> @EllypseCelwe
---    Copyright (c) 2011 Enrique García Cota
---
---    Permission is hereby granted, free of charge, to any person obtaining a
---    copy of this software and associated documentation files (the
---    "Software"), to deal in the Software without restriction, including
---    without limitation the rights to use, copy, modify, merge, publish,
---    distribute, sublicense, and/or sell copies of the Software, and to
---    permit persons to whom the Software is furnished to do so, subject to
---    the following conditions:
---
---    The above copyright notice and this permission notice shall be included
---    in all copies or substantial portions of the Software.
---
---    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
---    OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
---    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
---    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
---    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
---    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
---    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
----------------------------------------------------------------------------------

if AddOn_Lib_Middleclass then
	return
end

---@class AddOn_Lib_Middleclass
local MiddleClass = {};

--{{{ Final classes
-- Table of weak keys, for proper garbage collection when instances no longer exists
local finalClasses = setmetatable({}, { __mode = "k" });

--- Makes a MiddleClass_Class Final. It can no longer be inherited from and no new methods can be added to it.
---@param class MiddleClass_Class
function MiddleClass.final(class)
	finalClasses[class] = true;
end

--- Check if a class is Final.
---@param class MiddleClass_Class
---@return boolean isFinal Returns true if the class is Final
local function isFinal(class)
	return finalClasses[class] == true;
end
MiddleClass.isFinal = isFinal;
--}}}

--{{{ Protected instances
local protectedInstances = setmetatable({}, { __mode = "k" });

function MiddleClass.protected(instance)
	protectedInstances[instance] = true;
end

local function isProtected(instance)
	return protectedInstances[instance] == true;
end
MiddleClass.isProtected = isProtected;
--}}}

--{{{ Helpers
local function _createIndexWrapper(aClass, f)
	if f == nil then
		return aClass.__instanceDict
	else
		return function(self, name)
			local value = aClass.__instanceDict[name]

			if value ~= nil then
				return value
			elseif type(f) == "function" then
				return (f(self, name))
			else
				return f[name]
			end
		end
	end
end

local function _propagateInstanceMethod(aClass, name, f)
	f = name == "__index" and _createIndexWrapper(aClass, f) or f
	aClass.__instanceDict[name] = f

	for subclass in pairs(aClass.subclasses) do
		if rawget(subclass.__declaredMethods, name) == nil then
			_propagateInstanceMethod(subclass, name, f)
		end
	end
end

local function _declareInstanceMethod(aClass, name, f)
	if isFinal(aClass) then
		error("Cannot modify final class: [" .. tostring(aClass) .. "]", 2)
	end

	-- Allow redefinition of `:new()` as a constructor (redirect to `:initialize()`) for better IDE code completion
	if name == "new" then
		name = "initialize"
	end

	aClass.__declaredMethods[name] = f

	if f == nil and aClass.super then
		f = aClass.super.__instanceDict[name]
	end

	_propagateInstanceMethod(aClass, name, f)
end

local function _tostring(self)
	return "MiddleClass " .. self.name
end
local function _call(self, ...)
	return self:new(...)
end

local function _createClass(name, super)
	local dict = {}
	local proxy = {}
	dict.__index = function(_, field)
		return dict[field] or proxy[field]
	end
	dict.__newindex = function(self, field, value)
		if isProtected(self) then
			error("Cannot modify protected instance: [" .. tostring(self) .. "]", 2)
		end
		rawset(proxy, field, value)
	end

	local aClass = { name = name, super = super, static = {},
					 __instanceDict = dict, __declaredMethods = {},
					 subclasses = setmetatable({}, {__mode='k'})  }

	if super then
		setmetatable(aClass.static, {
			__index = function(_,k)
				local result = rawget(dict,k)
				if result == nil then
					return super.static[k]
				end
				return result
			end
		})
	else
		setmetatable(aClass.static, { __index = function(_,k) return rawget(dict,k) end })
	end

	setmetatable(aClass, { __index = aClass.static, __tostring = _tostring,
						   __call = _call, __newindex = _declareInstanceMethod })

	return aClass
end

local function _includeMixin(aClass, mixin)
	assert(type(mixin) == 'table', "mixin must be a table")

	for name,method in pairs(mixin) do
		if name ~= "included" and name ~= "static" then aClass[name] = method end
	end

	for name,method in pairs(mixin.static or {}) do
		aClass.static[name] = method
	end

	if type(mixin.included)=="function" then mixin:included(aClass) end
	return aClass
end
--}}} Helpers

--{{{ MiddleClass_Class
---@class MiddleClass_Class
local ClassMixin = {
	static = {
		allocate = function(self)
			assert(type(self) == 'table', "Make sure that you are using 'Class:allocate' instead of 'Class.allocate'")
			return setmetatable({ class = self }, self.__instanceDict)
		end,

		new = function(self, ...)
			assert(type(self) == 'table', "Make sure that you are using 'Class:new' instead of 'Class.new'")
			local instance = self:allocate()
			instance:initialize(...)
			return instance
		end,

		subclass = function(self, name)
			assert(type(self) == 'table', "Make sure that you are using 'Class:subclass' instead of 'Class.subclass'")
			assert(type(name) == "string", "You must provide a name(string) for your class")
			if isFinal(self) then
				error("Cannot subclass final class: [" .. tostring(self) .. "]", 3)
			end

			local subclass = _createClass(name, self)

			for methodName, f in pairs(self.__instanceDict) do
				_propagateInstanceMethod(subclass, methodName, f)
			end
			subclass.initialize = function(instance, ...) return self.initialize(instance, ...) end

			self.subclasses[subclass] = true
			self:subclassed(subclass)

			return subclass
		end,

		subclassed = function(self, other) end,

		isSubclassOf = function(self, other)
			return type(other)      == 'table' and
					type(self.super) == 'table' and
					( self.super == other or self.super:isSubclassOf(other) )
		end,

		include = function(self, ...)
			assert(type(self) == 'table', "Make sure you that you are using 'Class:include' instead of 'Class.include'")
			for _,mixin in ipairs({...}) do _includeMixin(self, mixin) end
			return self
		end
	}
}

--[[ override ]] function ClassMixin:initialize(...)
	print("Unredefined initializer")
end

function ClassMixin:__tostring()
	return "instance of " .. tostring(self.class)
end

--- Check if an object is an instance of the given class.
---@param aClass MiddleClass_Class A MiddleClass Class to check.
---@return boolean isAnInstanceOfTheClass Returns true if it is a instance of the given class.
function ClassMixin:IsInstanceOf(aClass)
	return type(aClass) == 'table'
			and type(self) == 'table'
			and (self.class == aClass
			or type(self.class) == 'table'
			and type(self.class.isSubclassOf) == 'function'
			and self.class:isSubclassOf(aClass))
end
--}}}

--{{{ Private storage
local privateStorage = setmetatable({},{
	__index = function(class, instance) -- Remove need to initialize the private table for each instance, we lazy instantiate it
		class[instance] = {}
		return class[instance]
	end,
	__mode = "k", -- Weak table keys: allow stored instances to be garbage collected
	__metatable = "You are not allowed to access the metatable of this private storage",
})

--- Private storage table, used to store private properties by indexing the table per instance of a class.
--- The table has weak indexes which means it will not prevent the objects from being garbage collected.
--- Example:
--- > `local privateStore = Ellyb.getPrivateStorage()`
--- > `local myClassInstance = MyClass()`
--- > `privateStore[myClassInstance].privateProperty = someValue`
---@return table
function MiddleClass.getPrivateStorage()
	return privateStorage
end
--}}}

--{{{ Create Class
--- Creates a new middleclass Class to use for object oriented programming purposes.
---@param name string A name for the new class. It will be used when calling `tostring()` on an instance of the class.
---@param super MiddleClass_Class Another class to inherit from.
---@return MiddleClass_Class class A new class with basic methods of object oriented programming.
---@overload fun(name:string):MiddleClass_Class
function MiddleClass.createClass(name, super)
	assert(type(name) == 'string', "A name (string) is needed for the new class")
	return super and super:subclass(name) or _includeMixin(_createClass(name), ClassMixin)
end

-- Make global table callable as a shortcut
setmetatable(MiddleClass, {
	__call = function(_, ...)
		return MiddleClass.createClass(...);
	end
});
--}}}

---@type AddOn_Lib_Middleclass|fun(name:string, super:MiddleClass_Class):MiddleClass_Class
AddOn_Lib_Middleclass = MiddleClass;
