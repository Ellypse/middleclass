----------------------------------------------------------------------------------
--- These tests are using the West testing suite.
--- West has to be installed and running in parallel for the tests to run.
--- More info: https://github.com/moody/West
----------------------------------------------------------------------------------
if not __WEST_LIB__ then
    return
end
local West = __WEST_LIB__()

West.describe("AddOn_Lib_Middleclass", function(it)

    it("Creates a new class when called", function(expect)
        local MyClass = AddOn_Lib_Middleclass("MyClass")

        expect(MyClass).toBeDefined()
        expect(MyClass():__tostring()).toBe("instance of class MyClass")
    end)

    it("Can check instance type, with inheritance", function(expect)
        local ClassA = AddOn_Lib_Middleclass("ClassA")
        local ClassB = AddOn_Lib_Middleclass("ClassB")
        local ClassC = AddOn_Lib_Middleclass("ClassC", ClassA)
        local instanceOfC = ClassC()

        expect(instanceOfC:isInstanceOf(ClassC)).toBeTruthy()
        expect(instanceOfC:isInstanceOf(ClassB)).toBeFalsy()
        expect(instanceOfC:isInstanceOf(ClassA)).toBeTruthy()

    end)

    it("Invokes custom :initialize() when creating an instance", function(expect)
        local MyClass = AddOn_Lib_Middleclass("MyClass")

        function MyClass:initialize()
            self.wentThroughCustomInitializer = true
        end

        local myInstance = MyClass()

        expect(myInstance.wentThroughCustomInitializer).toBeTruthy()
    end)

    it("Allows redefining instance methods, without altering the class itself", function(expect)
        local MyClass = AddOn_Lib_Middleclass("MyClass")

        function MyClass:myMethod()
            self.wentThroughMethodRedefinedOnInstance = false
        end

        local myInstance = MyClass()

        function myInstance:myMethod()
            self.wentThroughMethodRedefinedOnInstance = true
        end

        local myUntouchedInstance = MyClass()

        myInstance:myMethod()
        myUntouchedInstance:myMethod()

        expect(myInstance.wentThroughMethodRedefinedOnInstance).toBeTruthy()
        expect(myUntouchedInstance.wentThroughMethodRedefinedOnInstance).toBeFalsy()
    end)

    it("Can include mixins", function(expect)
        local MyMixin = { mixinField = true }
        local MySecondMixin = { otherMixinField = 3 }
        local MyClass = AddOn_Lib_Middleclass("MyClass"):include(MyMixin):include(MySecondMixin)
        local instanceOfMyClass = MyClass()

        expect(MyClass.mixinField).toBeTruthy()
        expect(instanceOfMyClass.mixinField).toBeTruthy()
        expect(MyClass.otherMixinField).toBe(3)
        expect(instanceOfMyClass.otherMixinField).toBe(3)
    end)

    it("Can define specific behavior when subclassing", function(expect)
        local ClassA = AddOn_Lib_Middleclass("ClassA")

        function ClassA.static:subclassed(otherClass)
            otherClass.wentThroughCustomSubclassedMethod = true
        end

        local ClassB = AddOn_Lib_Middleclass("ClassB", ClassA)

        expect(ClassB.wentThroughCustomSubclassedMethod).toBeTruthy()
    end)
end)

West.runAndPrint()