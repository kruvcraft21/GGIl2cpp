# Code snippets for example

## `"Sacrifice"` for the test.

All tests are carried out on the example of [1.apk](/test/1.apk). You can download it in the `test` folder

Class for the test:

```cs
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using System;

public class TestClass : MonoBehaviour
{
    public int field1;
    public float field2;
    public static int field3;

    private GameObject[] textFields;
    private void Start()
    {
        field1 = 1;
        field2 = 2;
        field3 = 3;

        textFields = GameObject.FindGameObjectsWithTag("Field");

        UpdateTextField();
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
    if #v.Fields > 1 then
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