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

### Unit tests

I have created some basic unit tests to assert that the library is functioning as intended after my changes (see the `middleclass_tests.lua` file). The tests suite used is [West](https://github.com/moody/West). The tests are only run when this library is loaded like an add-on by the game (using the .toc file instead of being embedded in another add-on) and only if the [West](https://github.com/moody/West) add-on is also loaded.

### In game documentation

In game documentation can be accessed either by using the `/api MiddleClass list` command or via a GUI add-on (like [APIInterface](https://www.curseforge.com/wow/addons/apiinterface)). Public methods are properly documented.

### TODO

- Proper versioning (using LibStub?)