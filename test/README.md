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