# Il2cpp Api for GameGuardian

## About script
This script is only needed to make it easier to work with Il2cpp. This script works through the program [GameGuardian](https://gameguardian.net). The script is completely built on Il2cppApi, you can easily find the necessary information on the interface yourself and create a similar script.


## About Api

This Api has 4 functions 

```lua
Il2cpp()
Il2cpp.FindMethods()
Il2cpp.FindClass()
addresspath()
```


* "Il2cpp()" - This function takes from 0 to 2 arguments, it is needed to indicate the beginning of global-metadata and libil2cpp. Without it, the function located in the Il2cpp table will not work.
* "Il2cpp.FindMethods()" - Searches for a method, or rather information on the method, by name or by offset, you can also send an address in memory to it.
* "Il2cpp.FindClass()" - Searches for a class, or rather information on a method, by name or by address in memory.
* "addresspath()" - is a function that was created to patch the desired address. The first argument should be an offset, and the subsequent ones should be constructs.

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

As an example, I want to get information about the class and about the methods `Method2` and `Method1` :

```Lua
require('Il2cppApi')

Il2cpp()

print(Il2cpp.FindMethods({'Method2', 'Method1'}))

--output
--[[
{
    [1] = {
        [1] = {
            ['AddressInMemory'] = '512AAFFF',
            ['MethodInfoAddress'] = , -- some number
            ['ClassName'] = 'MyClass',
            ['ClassAddress'] = '',-- some number in hex
            ['MethodName'] = 'Method2',
            ['Offset'] = '12AAFFF',
            ['ParamCount'] = 0,
        },
    },
    [2] = {
        [1] = {
            ['AddressInMemory'] = '51234FFF',
            ['MethodInfoAddress'] = , -- some number
            ['ClassName'] = 'MyClass',
            ['ClassAddress'] = '',-- some number in hex
            ['MethodName'] = 'Method1',
            ['Offset'] = '1234FFF',
            ['ParamCount'] = 0,
        },
    },
}
]]

print(Il2cpp.FindClass({{Class = 'MyClass', MethodsDump = true, FieldsDump = true}}))

--output
--[[
{
    [1] = {
        [1] = {
            ['ClassAddress'] = '',-- some number in hex
            ['ClassName'] = 'MyClass',
            ['Fields'] = {
                [ 1] = { -- table(19d60b2)
                    ['ClassName'] = 'MyClass',
                    ['ClassAddress'] = '',-- some number in hex
                    ['IsStatic'] = true,
                    ['FieldName'] = 'instance',
                    ['Offset'] = '0',
                },
                [ 2] = { -- table(f249803)
                    ['ClassName'] = 'MyClass',
                    ['ClassAddress'] = '',-- some number in hex
                    ['IsStatic'] = false,
                    ['FieldName'] = 'field1',
                    ['Offset'] = '4',
                },
                [ 3] = { -- table(e37d380)
                    ['ClassName'] = 'MyClass',
                    ['ClassAddress'] = '',-- some number in hex
                    ['IsStatic'] = false,
                    ['FieldName'] = 'field2',
                    ['Offset'] = 'C',
                },
            },
            ['Methods'] = {
                [ 1] = { -- table(8922eec)
                    ['AddressInMemory'] = '51234FFF',
                    ['MethodInfoAddress'] = , -- some number
                    ['ClassName'] = 'MyClass',
                    ['ClassAddress'] = '',-- some number in hex
                    ['MethodName'] = 'Method1',
                    ['Offset'] = '1234FFF',
                    ['ParamCount'] = 0,
                },
                [ 2] = { -- table(71212b5)
                    ['AddressInMemory'] = '512AAFFF',
                    ['MethodInfoAddress'] = , -- some number
                    ['ClassName'] = 'MyClass',
                    ['ClassAddress'] = '',-- some number in hex
                    ['MethodName'] = 'Method2',
                    ['Offset'] = '12AAFFF',
                    ['ParamCount'] = 0,
                },
            },
        }
    },
}
]]

local Method1 = Il2cpp.FindMethods({'Method1'})[1]
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
Without the `Il2cpp()` function, some functions will not work, since this function remembers or finds the location `libil2cpp.so` and `global-metadata.dat`.

Example of using this function:

```lua
Il2cpp() -- in this case, "Il2cpp()" will find itself "libil2cpp.so" and "global-metadata.dat".

local libil2cpp = {start = 0x1234, ['end'] = 0x8888}

Il2cpp(libil2cpp) -- in this case, "Il2cpp()" will find "global-metadata.dat" itself and remember the location"libil2cpp.so ", which was given to him.

local globalmetadata = {start = 0x9888, ['end'] = 0x14888}

Il2cpp(libil2cpp, globalmetadata) -- in this case, "Il2cpp()" and will remember the location "libil2cpp.so " and "global-metadata.dat", which was passed to him.
```