# middleclass

## Important notes

**This is a modified fork** of the [middleclass Lua library](https://github.com/kikito/middleclass) by [Enrique García Cota](https://github.com/kikito) adapted to be used in World of Warcraft's Lua environment and with some added features to specifically suit my needs.

## Description

A simple OOP library for Lua. It has inheritance, metamethods (operators), class variables and weak mixin support.

## Main differences with the original library

### XML file

As a World of Warcraft add-on library, you should include this library using the provided `middleclass.xml` file (which will then load all the necessary files).

### Global namespace declaration

Since `require()` is not implemented in the World of Warcraft environment, the library declares itself as `AddOn_Lib_Middleclass` in the global namespace.

```lua
local MyClass = AddOn_Lib_Middleclass("MyClass")
```

### Private storage for properties

Private class properties can be achieved through a local table indexed by the class instances. This allows to store instance properties that are not accessible outside of the class declaration.

The metatable of this private storage table uses weak keys for proper garbage collection and will automatically create a new table when accessing `private[self]` so you don't have to initialize it using `private[self] = {}` everywhere.

```lua
local MyClass = AddOn_Lib_Middleclass("MyClass")
local private = AddOn_Lib_Middleclass.getPrivateStorage()

function MyClass:new(name) 
    private[self].name = name
end

function MyClass:SayMyName()
    print(private[self].name)
 end
```

### Use `:new()` as a constructor

While you can still override `:initialize()` as the constructor for the class, modifications allows to redefine the `:new()` method instead. This will not actually redefine new but only pass the implementation to `:initialize()` behind the scene. This is so IDE can provide proper code completion and other features when instantiating a new object using `MyClass:new()`

```lua
local MyClass = AddOn_Lib_Middleclass("MyClass")

function MyClass:new(name, age, someTable) end

local instance = MyClass:new("name", 3, {})
```

### Final classes

Classes can be marked as final. When final, they cannot be inherited and methods cannot be added or overridden.

```lua
local MyClass = AddOn_Lib_Middleclass("MyClass")

function MyClass:DoSomething() end

AddOn_Lib_Middleclass.final(MyClass)

function MyClass:DoADifferentThing() end -- This will raise an error
local ChildClass = AddOn_Lib_Middleclass("MyClass", MyClass) -- This will raise an error
 
```

### Protected instances

Instances of a class can be protected against modifications. When protected, their properties and methods cannot be modified.

```lua
local MyClass = AddOn_Lib_Middleclass("MyClass")

function MyClass:DoSomething() end

local a = MyClass()
a.value = 1

AddOn_Lib_Middleclass.protected(a)

function a:DoSomething() end -- This will raise an error
a.value = 0 -- This will raise an error

```

### In game documentation

In game documentation can be accessed either by using the `/api` command or via a GUI addon (like [APIInterface](https://www.curseforge.com/wow/addons/apiinterface)). Public methods are properly documented.