# Code snippets for example

## `"Sacrifice"` for the test.

All tests are carried out on the example of [1.apk](/test/1.apk). You can download it in the `test` folder

Class for the test:

```cs
using UnityEngine;
using TMPro;
using System;

public class TestClass : MonoBehaviour
{
    public int field1;
    public float field2;
    public static int field3;
    private const int field6 = 679;
    private const float field7 = 23.345f;
    private const string field8 = "Isn't Const";
    private const uint field9 = 414141412;
    private const bool field10 = true;
    private const int field11 = -12414;
    private const int field12 = 5;

    private System.Random random = new System.Random(DateTime.UtcNow.GetHashCode());

    private GameObject[] textFields;
    private GameObject[] textFieldsMethods;
    private void Start()
    {
        field1 = 1;
        field2 = 2;
        field3 = 3;

        textFields = GameObject.FindGameObjectsWithTag("Field");
        textFieldsMethods = GameObject.FindGameObjectsWithTag("FieldMethod");

        UpdateTextField();
    }

    public int GetField4()
    {
        return random.Next(0, 30);
    }

    public int GetField5()
    {
        return (int)TestEnum.var4;
    }

    public void UpdateTextField()
    {
        Debug.Log(textFields.Length);

        Type testClass = GetType();

        foreach(GameObject textField in textFields)
        {
            string nameField = textField.name;
            Debug.Log(nameField);
            textField.GetComponent<TextMeshProUGUI>().text = nameField + " = " + testClass.GetField(nameField.ToLower()).GetValue(this).ToString();
        }

        foreach (GameObject textField in textFieldsMethods)
        {
            string nameField = textField.name;
            Debug.Log(nameField);
            textField.GetComponent<TextMeshProUGUI>().text = nameField + " = " + testClass.GetMethod("Get" + nameField).Invoke((object)this, null);
        }
    }
}

public enum TestEnum : int
{
    var1,
    var2,
    var3,
    var4,
}

```

By pressing the `Update` button, the application updates the text on the screen.


## An example of how you can change the fields of a certain Test Class object

My code for changing class fields :

```Lua
io.open('il2cppapi.lua',"w+"):write(gg.makeRequest("https://raw.githubusercontent.com/kruvcraft21/GGIl2cpp/master/Il2cppApi.lua").content):close()
require('il2cppapi')
os.remove('il2cppapi.lua')

Il2cpp()

---@type ClassConfig
local TestClassConfig = {}

TestClassConfig.Class = "TestClass"
TestClassConfig.FieldsDump = true

local TestClasses = Il2cpp.FindClass({TestClassConfig})[1]

local ChangeTestClasses = {}

print(TestClasses)

for k,v in ipairs(TestClasses) do
    local TestClassObject = Il2cpp.FindObject({tonumber(v.ClassAddress, 16)})[1]
    if v.Parent and v.Parent.ClassName ~= "ValueType" then
        for i = 1, #TestClassObject do
            ChangeTestClasses[#ChangeTestClasses + 1] = {
                address = TestClassObject[i].address + tonumber(v:GetFieldWithName("field1").Offset, 16),
                flags = gg.TYPE_DWORD,
                value = 40
            }
            ChangeTestClasses[#ChangeTestClasses + 1] = {
                address = TestClassObject[i].address + tonumber(v:GetFieldWithName("field2").Offset, 16),
                flags = gg.TYPE_FLOAT,
                value = 33
            }
        end
    
        ChangeTestClasses[#ChangeTestClasses + 1] = {
            address = v.StaticFieldData + tonumber(v:GetFieldWithName("field3").Offset, 16),
            flags = gg.TYPE_DWORD,
            value = 12
        }
    end

end

gg.setValues(ChangeTestClasses)
```

Result of code execution:
```Lua
Скрипт завершен:
{ -- table(fe74874)
	[1] = { -- table(b45619d)
		['ClassAddress'] = '77C07F7300',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(cb69612)
			[1] = { -- table(f6391e3)
				['ClassAddress'] = '77C07F7300',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field1',
				['IsStatic'] = false,
				['Offset'] = '18',
				['Type'] = 'int',
			},
			[2] = { -- table(c6a77e0)
				['ClassAddress'] = '77C07F7300',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field2',
				['IsStatic'] = false,
				['Offset'] = '1C',
				['Type'] = 'float',
			},
			[3] = { -- table(11b7a99)
				['ClassAddress'] = '77C07F7300',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field3',
				['IsStatic'] = true,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[4] = { -- table(364015e)
				['ClassAddress'] = '77C07F7300',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'textFields',
				['IsStatic'] = false,
				['Offset'] = '20',
				['Type'] = 'GameObject[]',
			},
		},
		['Parent'] = { -- table(6b3693f)
			['ClassAddress'] = '790CC92000',
			['ClassName'] = 'MonoBehaviour',
		},
		['StaticFieldData'] = 519907732208,
	},
	[2] = { -- table(a2f320c)
		['ClassAddress'] = '790CD0D180',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(8a02755)
			[1] = { -- table(8ead56a)
				['ClassAddress'] = '0',
				['ClassName'] = '',
				['FieldName'] = '',
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'not support type -> 0x0',
			},
		},
		['Parent'] = { -- table(2ff5a5b)
			['ClassAddress'] = '790CC53880',
			['ClassName'] = 'ValueType',
		},
	},
}

Завершено.

Скрипт записал 53,31 КБ в 2 файлов.
```

![Example](/test/img/TestModule.gif)


## Example of how you can change the method


My code for changing class method:

```Lua
io.open('il2cppapi.lua',"w+"):write(gg.makeRequest("https://raw.githubusercontent.com/kruvcraft21/GGIl2cpp/master/Il2cppApi.lua").content):close()
require('il2cppapi')
os.remove('il2cppapi.lua')

Il2cpp()

---@type ClassConfig
local TestClassConfig = {}

TestClassConfig.Class = "TestClass"
TestClassConfig.FieldsDump = true
TestClassConfig.MethodsDump = true

local TestClasses = Il2cpp.FindClass({TestClassConfig})[1]

print(TestClasses)

for k,v in ipairs(TestClasses) do
    local Methods = v:GetMethodsWithName("GetField4")
    if #Methods > 0 then
        for i = 1, #Methods do
            Il2cpp.PatchesAddress(tonumber(Methods[i].AddressInMemory, 16), Il2cpp.MainType == gg.TYPE_QWORD and "\x40\x02\x80\x52\xc0\x03\x5f\xd6" or "\x12\x00\xa0\xe3\x1e\xff\x2f\xe1")
        end
    end
end
```

Result of code execution:

```Lua
Скрипт завершен:
{ -- table(e4f3080)
	[1] = { -- table(b7ed6b9)
		['ClassAddress'] = 'A9CC97E0',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(d72d57b)
			[1] = { -- table(f128f98)
				['ClassAddress'] = 'A9CC97E0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field1',
				['IsStatic'] = false,
				['Offset'] = 'C',
				['Type'] = 'int',
			},
			[2] = { -- table(a37a3f1)
				['ClassAddress'] = 'A9CC97E0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field2',
				['IsStatic'] = false,
				['Offset'] = '10',
				['Type'] = 'float',
			},
			[3] = { -- table(b0a6bd6)
				['ClassAddress'] = 'A9CC97E0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field3',
				['IsStatic'] = true,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[4] = { -- table(dcf4e57)
				['ClassAddress'] = 'A9CC97E0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'random',
				['IsStatic'] = false,
				['Offset'] = '14',
				['Type'] = 'Random',
			},
			[5] = { -- table(96d0d44)
				['ClassAddress'] = 'A9CC97E0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'textFields',
				['IsStatic'] = false,
				['Offset'] = '18',
				['Type'] = 'GameObject[]',
			},
			[6] = { -- table(4118e2d)
				['ClassAddress'] = 'A9CC97E0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'textFieldsMethods',
				['IsStatic'] = false,
				['Offset'] = '1C',
				['Type'] = 'GameObject[]',
			},
		},
		['Methods'] = { -- table(683fafe)
			[1] = { -- table(b1f725f)
				['AddressInMemory'] = '62EACC0',
				['ClassAddress'] = 'A9CC97E0',
				['ClassName'] = 'TestClass',
				['MethodInfoAddress'] = 2848833752,
				['MethodName'] = 'Start',
				['Offset'] = '2EACC0',
				['ParamCount'] = 0,
				['ReturnType'] = 'void',
			},
			[2] = { -- table(5b6d4ac)
				['AddressInMemory'] = '62EB430',
				['ClassAddress'] = 'A9CC97E0',
				['ClassName'] = 'TestClass',
				['MethodInfoAddress'] = 2848833800,
				['MethodName'] = 'GetField4',
				['Offset'] = '2EB430',
				['ParamCount'] = 0,
				['ReturnType'] = 'int',
			},
			[3] = { -- table(cad2575)
				['AddressInMemory'] = '62EAEA0',
				['ClassAddress'] = 'A9CC97E0',
				['ClassName'] = 'TestClass',
				['MethodInfoAddress'] = 2848833848,
				['MethodName'] = 'UpdateTextField',
				['Offset'] = '2EAEA0',
				['ParamCount'] = 0,
				['ReturnType'] = 'void',
			},
			[4] = { -- table(4a0c90a)
				['AddressInMemory'] = '62EB45C',
				['ClassAddress'] = 'A9CC97E0',
				['ClassName'] = 'TestClass',
				['MethodInfoAddress'] = 2848833896,
				['MethodName'] = '.ctor',
				['Offset'] = '2EB45C',
				['ParamCount'] = 0,
				['ReturnType'] = 'void',
			},
		},
		['Parent'] = { -- table(8996f62)
			['ClassAddress'] = 'B5A439A0',
			['ClassName'] = 'MonoBehaviour',
		},
		['StaticFieldData'] = 2946715040,
	},
	[2] = { -- table(11078f3)
		['ClassAddress'] = 'B5AEA040',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(7cfb9b0)
			[1] = { -- table(c25e029)
				['ClassAddress'] = '0',
				['ClassName'] = 'TestClass',
				['FieldName'] = '',
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'not support type -> 0x0',
			},
		},
		['Parent'] = { -- table(f231fae)
			['ClassAddress'] = 'D2E5E040',
			['ClassName'] = 'ValueType',
		},
	},
}

Завершено.

Скрипт записал 54,40 КБ в 2 файлов.
```

![Exapmle](/test/img/Screenshot_20220712-090652.png)


## An example of how you can get constants

```lua
Il2cpp()

local TestClass = Il2cpp.FindClass({{Class ="TestClass", FieldsDump = true}})[1]

print(TestClass)

for k,v in ipairs(TestClass[1].Fields) do
    print(v.FieldName, v:GetConstValue())
end
```

Result of code execution:

```lua
Скрипт завершен:
{ -- table(2fac388)
	[1] = { -- table(f88e121)
		['ClassAddress'] = '7A473A2780',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(2661946)
			[ 1] = { -- table(3504707)
				['ClassAddress'] = '7A473A2780',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field1',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '18',
				['Type'] = 'int',
			},
			[ 2] = { -- table(53c9034)
				['ClassAddress'] = '7A473A2780',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field2',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '1C',
				['Type'] = 'float',
			},
			[ 3] = { -- table(af16e5d)
				['ClassAddress'] = '7A473A2780',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field3',
				['IsConst'] = false,
				['IsStatic'] = true,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[ 4] = { -- table(15a83d2)
				['ClassAddress'] = '7A473A2780',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field6',
				['IsConst'] = true,
				['IsStatic'] = true,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[ 5] = { -- table(e204ca3)
				['ClassAddress'] = '7A473A2780',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field7',
				['IsConst'] = true,
				['IsStatic'] = true,
				['Offset'] = '0',
				['Type'] = 'float',
			},
			[ 6] = { -- table(42c7ba0)
				['ClassAddress'] = '7A473A2780',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field8',
				['IsConst'] = true,
				['IsStatic'] = true,
				['Offset'] = '0',
				['Type'] = 'string',
			},
			[ 7] = { -- table(25b9359)
				['ClassAddress'] = '7A473A2780',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field9',
				['IsConst'] = true,
				['IsStatic'] = true,
				['Offset'] = '0',
				['Type'] = 'uint',
			},
			[ 8] = { -- table(7b90b1e)
				['ClassAddress'] = '7A473A2780',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field10',
				['IsConst'] = true,
				['IsStatic'] = true,
				['Offset'] = '0',
				['Type'] = 'bool',
			},
			[ 9] = { -- table(2610fff)
				['ClassAddress'] = '7A473A2780',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field11',
				['IsConst'] = true,
				['IsStatic'] = true,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[10] = { -- table(46db1cc)
				['ClassAddress'] = '7A473A2780',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field12',
				['IsConst'] = true,
				['IsStatic'] = true,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[11] = { -- table(ea90c15)
				['ClassAddress'] = '7A473A2780',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'random',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '20',
				['Type'] = 'Random',
			},
			[12] = { -- table(ce6bb2a)
				['ClassAddress'] = '7A473A2780',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'textFields',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '28',
				['Type'] = 'GameObject[]',
			},
			[13] = { -- table(7c0ad1b)
				['ClassAddress'] = '7A473A2780',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'textFieldsMethods',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '30',
				['Type'] = 'GameObject[]',
			},
		},
		['IsEnum'] = false,
		['Parent'] = { -- table(faa1eb8)
			['ClassAddress'] = '7B172EF700',
			['ClassName'] = 'MonoBehaviour',
		},
		['StaticFieldData'] = 530552838896,
		['TypeMetadataHandle'] = 529091445172,
	},
	[2] = { -- table(b1b5491)
		['ClassAddress'] = '7B174B0280',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(78d5ff6)
			[1] = { -- table(8b2fff7)
				['ClassAddress'] = '0',
				['ClassName'] = 'TestClass',
				['FieldName'] = '',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'not support type -> 0x0',
			},
		},
		['IsEnum'] = false,
		['Parent'] = { -- table(e3e6e64)
			['ClassAddress'] = '7B87CABF80',
			['ClassName'] = 'ValueType',
		},
		['TypeMetadataHandle'] = 529091377148,
	},
}
field1 	nil
field2 	nil
field3 	nil
field6 	679
field7 	23.344999313354492
field8 	Isn't Const
field9 	414141412
field10 	1
field11 	-12414
field12 	5
random 	nil
textFields 	nil
textFieldsMethods 	nil

Завершено.

Скрипт записал 93,98 КБ в 2 файлов.
```