# Il2cpp Module for GameGuardian

## About script
This script is only needed to make it easier to work with Il2cpp. This script works through the program [GameGuardian](https://gameguardian.net). With the help of the module, you can get information about the method or class that interests you. 

The module has support for the [Lua](https://marketplace.visualstudio.com/items?itemName=yinfei.luahelper) plugin for [VS Code](https://code.visualstudio.com/), that is, some functions have a description that this plugin can display.


## About Module

This Module has 6 functions 

```lua
Il2cpp()
Il2cpp.FindMethods()
Il2cpp.FindClass()
Il2cpp.PatchesAddress()
Il2cpp.FindObject()
```


* "Il2cpp()" - This function takes from 0 to 2 arguments, it is needed to indicate the beginning of global-metadata and libil2cpp. Without it, the function located in the Il2cpp table will not work.
* "Il2cpp.FindMethods()" - Searches for a method, or rather information on the method, by name or by offset, you can also send an address in memory to it.
* "Il2cpp.FindClass()" - Searches for a class, by name, or by address in memory.
* "Il2cpp.PatchesAddress()" - Patch `Bytescodes` to `add`
* "Il2cpp.FindObject()" - Searches for an object by name or by class address, in memory. In some cases, the function may return an incorrect result for certain classes. For example, sometimes the garbage collector may not have time to remove an object from memory and then a `fake object` will appear or for a turnover, the object may still be `not implemented` or `not created`.

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
            ['ReturnType'] = 'void',
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
            ['ReturnType'] = 'int',
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
            ['ClassNameSpace'] = '',
            ['StaticFieldData'] = , -- some number
            ['Fields'] = {
                [ 1] = { -- table(19d60b2)
                    ['ClassName'] = 'MyClass',
                    ['ClassAddress'] = '',-- some number in hex
                    ['IsStatic'] = true,
                    ['FieldName'] = 'instance',
                    ['Offset'] = '0',
                    ['Type'] = 'MyClass',
                },
                [ 2] = { -- table(f249803)
                    ['ClassName'] = 'MyClass',
                    ['ClassAddress'] = '',-- some number in hex
                    ['IsStatic'] = false,
                    ['FieldName'] = 'field1',
                    ['Offset'] = '4',
                    ['Type'] = 'int',
                },
                [ 3] = { -- table(e37d380)
                    ['ClassName'] = 'MyClass',
                    ['ClassAddress'] = '',-- some number in hex
                    ['IsStatic'] = false,
                    ['FieldName'] = 'field2',
                    ['Offset'] = 'C',
                    ['Type'] = 'string',
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
                    ['ReturnType'] = 'int',
                },
                [ 2] = { -- table(71212b5)
                    ['AddressInMemory'] = '512AAFFF',
                    ['MethodInfoAddress'] = , -- some number
                    ['ClassName'] = 'MyClass',
                    ['ClassAddress'] = '',-- some number in hex
                    ['MethodName'] = 'Method2',
                    ['Offset'] = '12AAFFF',
                    ['ParamCount'] = 0,
                    ['ReturnType'] = 'void',
                },
                [ 3] = { -- table(71212b5)
                    ['AddressInMemory'] = '512A1435',
                    ['MethodInfoAddress'] = , -- some number
                    ['ClassName'] = 'MyClass',
                    ['ClassAddress'] = '',-- some number in hex
                    ['MethodName'] = 'Start',
                    ['Offset'] = '12A1435',
                    ['ParamCount'] = 0,
                    ['ReturnType'] = 'void',
                },
            },
        }
    },
}
]]

local Method1 = Il2cpp.FindMethods({'Method1'})[1]
for k,v in ipairs(Method1) do
    if v.ClassName == 'MyClass' then 
        Il2cpp.PatchesAddress(tonumber(v.AddressInMemory,16),"\x20\x00\x80\x52\xc0\x03\x5f\xd6")
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
Without the `Il2cpp()` function, some functions will not work, since this function remembers or finds the location `libil2cpp.so` and `global-metadata.dat`. You can also specify the version of `Il2cpp`, this will be required in cases where the module cannot determine the version itself.

Example of using this function:

```lua
Il2cpp() -- in this case, "Il2cpp()" will find itself "libil2cpp.so" and "global-metadata.dat".

local libil2cpp = {start = 0x1234, ['end'] = 0x8888}

Il2cpp(libil2cpp) -- in this case, "Il2cpp()" will find "global-metadata.dat" itself and remember the location"libil2cpp.so ", which was given to him.

local globalmetadata = {start = 0x9888, ['end'] = 0x14888}

Il2cpp(libil2cpp, globalmetadata) -- in this case, "Il2cpp()" and will remember the location "libil2cpp.so " and "global-metadata.dat", which was passed to him.

Il2cpp(nil, nil, 27) -- in this case , the method will find "libil2cpp.so" and "global-metadata.dat" and will remember the "Il2cpp" version

Il2cpp(nil, nil, nil, globalmetadata.start) -- in this case , the method will find "libil2cpp.so ", and "global-metadata.dat", and the "Il2cpp" version, and will remember "globalMetadataHeader"
```

It is worth talking about processing the results of the module.

If the search fails, the functions will return a table with an error. Therefore, I recommend using `ipairs` to work with search results, but `pairs` can also be used, only you will have to check the key coming for processing. Otherwise, you may get a missing field error.

Example:
```Lua
local searchResult = Il2cpp.FindMethods({'Method2', 'Method1', 'method does not exist'})

for k,v in ipairs(searchResult[1]) do
    print(v.ClassName)
end

-- output
--[[
    MyClass
]]

for k,v in pairs(searchResult[2]) do
    if k ~= 'Error' then print(v.ClassName) end
end

-- output
--[[
    MyClass
]]

for k,v in pairs(searchResult[3]) do
    print(v.ClassName)
end

-- output
--[[
    nil
]]

```

I will also make some [snippets](/test/) of the code to make it easier to figure out how everything works.


## Memorizing Il2cpp Search Result

`Memorizing Il2cpp Search Result` is a special simple system to speed up the module. It remembers the search results.

It is worth noting that any call to the `Il2cpp()` function will reset this system.