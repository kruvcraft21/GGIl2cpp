# Il2cpp Api for GameGuardian

## About script
This script is only needed to make it easier to work with Il2cpp. This script works through the program [GameGuardian](https://gameguardian.net). The script is completely built on Il2cppApi, you can easily find the necessary information on the interface yourself and create a similar script.


## About Api

This Api has 5 functions :

```Lua
il2cpp()
il2cppfunc()
offsets()
addresspath()
Il2cppClassesInfo()
```
* "il2cpp()" - This function takes several arguments, but the first argument should be the name of the function, and the subsequent arguments should be constructs that should appear in this function.
* "il2cppfunc()" - This function takes several arguments, all of these arguments must be method names. It outputs detailed information about the methods.
>"NameFucntion" - is the name of the method

>"Offset" - Offset of the method

>"AddressInMemory" - The address of the method in memory (libil2cpp.so (start address) + offset)

>"Class" - is the name of the class to which the method belongs

>"ClassAddress" - Class address

* "offsets()" - outputs the same information as "il2cppfunc()", but there must be method offsets in the arguments.
* "addresspath()" - is a function that was created to patch the desired address. The first argument should be an offset, and the subsequent ones should be constructs.
* "Il2cppClassesInfo()" - this function is needed to get information about the classes that you will pass to it.

## How to use

Let's take the class MyClass as an example:

```cs
class MyClass {
    static MyClass instance;
    public int field1;
    public string field2;

    public void Start() {
        instance = this;
        this.field1 = 1;
        this.field2 = "Test";
    }

    public int Method1() {
        return this.field1;
    }

    public void Method2() {
        this.field2 = "Not Test";
    }
}
```

As an example, I want to get information about the class and about the methods "Method2" and "Method1" :

```Lua
require('Il2cppApi')

print(il2cppfunc('Method2', 'Method1'))

--output
--[[
{ -- table(d14b949)
    [1] = { -- table(9bd524e)
        ['AddressInMemory'] = '512AAFFF',
        ['AddressOffset'] = , -- some number
        ['Class'] = 'MyClass',
        ['ClassAddress'] = '',-- some number in hex
        ['NameFucntion'] = 'Method2',
        ['Offset'] = '12AAFFF',
    },
    [2] = { -- table(9bd524e)
        ['AddressInMemory'] = '51234FFF',
        ['AddressOffset'] = , -- some number
        ['Class'] = 'MyClass',
        ['ClassAddress'] = '',-- some number in hex
        ['NameFucntion'] = 'Method1',
        ['Offset'] = '1234FFF',
    },
}     true
]]

print(Il2cppClassesInfo({{ClassName = 'MyClass', MethodsDump = true, FieldsDump = true}}))

--output
--[[
{ -- table(d136ff9)
    [1] = { -- table(fabb3e)
        ['Fields'] = { -- table(3f432bd)
            [ 1] = { -- table(19d60b2)
                ['Class'] = 'MyClass',
                ['ClassAddress'] = '',-- some number in hex
                ['IsStatic'] = true,
                ['NameField'] = 'instance',
                ['Offset'] = '0',
            },
            [ 2] = { -- table(f249803)
                ['Class'] = 'MyClass',
                ['ClassAddress'] = '',-- some number in hex
                ['IsStatic'] = false,
                ['NameField'] = 'field1',
                ['Offset'] = '4',
            },
            [ 3] = { -- table(e37d380)
                ['Class'] = 'MyClass',
                ['ClassAddress'] = '',-- some number in hex
                ['IsStatic'] = false,
                ['NameField'] = 'field2',
                ['Offset'] = 'C',
            },
        },
        ['Methods'] = { -- table(fc2cd9f)
            [ 1] = { -- table(8922eec)
                ['AddressInMemory'] = '51234FFF',
                ['AddressOffset'] = , -- some number
                ['Class'] = 'MyClass',
                ['ClassAddress'] = '',-- some number in hex
                ['NameFucntion'] = 'Method1',
                ['Offset'] = '1234FFF',
            },
            [ 2] = { -- table(71212b5)
                ['AddressInMemory'] = '512AAFFF',
                ['AddressOffset'] = , -- some number
                ['Class'] = 'MyClass',
                ['ClassAddress'] = '',-- some number in hex
                ['NameFucntion'] = 'Method2',
                ['Offset'] = '12AAFFF',
            },
        },
    },
}     true
]]

local Method1 = il2cppfunc('Method1')
for k,v in pairs(Method1) do
    if v.Class == 'MyClass' then 
        addresspath(tonumber(v.AddressInMemory,16),"\x20\x00\x80\x52","\xc0\x03\x5f\xd6")
    end
end

--output
--[[
this code changes will change the method "Method1", so that it constantly returns 1

arm64:

51234FFF 20008052 mov w0,#0x1
51235003 C0035FD6 ret

]]
```