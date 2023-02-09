# Code snippets for example

## `"Sacrifice"` for the test.

All tests are carried out on the example of [1.apk](/test/1.apk). You can download it in the `test` folder

Class for the test:

```cs
using UnityEngine;
using TMPro;
using System;
using ForTwoClass;

public class TestClass : TestVirtual
{
    public int Field1;
    public float Field2;
    public static int Field3;
    private const int field6 = 679;
    private const float field7 = 23.345f;
    private const string field8 = "Isn't Const";
    private const uint field9 = 414141412;
    private const bool field10 = true;
    private const int field11 = -12414;
    private const int field12 = 5;
    public TestStruct Field13 = new TestStruct(2345, 1234);
    private ForTwoClass.TestClass field14 = new ForTwoClass.TestClass(1);
    private TestGenericClass<int> field15 = new TestGenericClass<int>();

    private System.Random random = new System.Random(DateTime.UtcNow.GetHashCode());

    private GameObject[] textFields;
    private GameObject[] textFieldsMethods;
    private void Start()
    {
        Field1 = 1;
        Field2 = 2;
        Field3 = 3;

        textFields = GameObject.FindGameObjectsWithTag("Field");
        textFieldsMethods = GameObject.FindGameObjectsWithTag("FieldMethod");

        UpdateTextField();
    }

    public int GetField4()
    {
        return random.Next(0, 30) + GetOne() + GetTwo();
    }

    private static int GetTwo()
    {
        return TestClass.field12;
    }

    public override int GetOne()
    {
        return 100;
    }

    public int GetField5()
    {
        return (int)TestEnum.var4;
    }

    public string GetField13()
    {
        TestStruct testStruct = this.Field13;
        return $"[{testStruct.field1}, {testStruct.field2}]";
    }

    public void UpdateTextField()
    {
        Debug.Log(textFields.Length);

        Type testClass = GetType();

        foreach(GameObject textField in textFields)
        {
            string nameField = textField.name;
            Debug.Log(nameField);
            textField.GetComponent<TextMeshProUGUI>().text = nameField + " = " + testClass.GetField(nameField).GetValue(this).ToString();
        }

        foreach (GameObject textField in textFieldsMethods)
        {
            string nameField = textField.name;
            Debug.Log(nameField);
            textField.GetComponent<TextMeshProUGUI>().text = nameField + " = " + testClass.GetMethod("Get" + nameField).Invoke((object)this, null);
        }
    }
}

public enum TestEnum:int
{
    var1,
    var2,
    var3,
    var4,
}


public struct TestStruct
{
    public int field1;
    public float field2;
    public TestStruct(
        int Field1,
        float Field2)
    {
        this.field1 = Field1;
        this.field2 = Field2;
    }
}


namespace ForTwoClass
{
    public class TestClass
    {
        private int field1;

        public TestClass(int Field1)
        {
            field1 = Field1;
        }
    }

    public class TestVirtual : MonoBehaviour
    {
        public virtual int GetOne()
        {
            return 1;
        }
    }
}

public abstract class TestAbstractClass<T>
{
    public abstract T GetValue();

    public abstract void TestAbstractMethod();

    private void SetValue()
    {
        return;
    }
}
public class TestGenericClass<T> : TestAbstractClass<T>
{
    public override T GetValue()
    {
        return default(T);
    }

    public override void TestAbstractMethod()
    {
        return;
    }
}
```

By pressing the `Update` button, the application updates the text on the screen.


## An example of how you can change the fields of a certain Test Class object

My code for changing class fields :

```Lua
io.open('il2cppapi.lua',"w+"):write(gg.makeRequest("https://raw.githubusercontent.com/kruvcraft21/GGIl2cpp/master/build/Il2cppApi.lua").content):close()
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
    if v.Parent and v.Parent.ClassName ~= "ValueType" and #v.ClassNameSpace == 0 then
        for i = 1, #TestClassObject do
            ChangeTestClasses[#ChangeTestClasses + 1] = {
                address = TestClassObject[i].address + tonumber(v:GetFieldWithName("Field1").Offset, 16),
                flags = gg.TYPE_DWORD,
                value = 40
            }
            ChangeTestClasses[#ChangeTestClasses + 1] = {
                address = TestClassObject[i].address + tonumber(v:GetFieldWithName("Field2").Offset, 16),
                flags = gg.TYPE_FLOAT,
                value = 33
            }
        end
    
        ChangeTestClasses[#ChangeTestClasses + 1] = {
            address = v.StaticFieldData + tonumber(v:GetFieldWithName("Field3").Offset, 16),
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
{ -- table(6afd241)
	[1] = { -- table(a3283e6)
		['ClassAddress'] = '6E08412650',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = 'ForTwoClass',
		['Fields'] = { -- table(5966d27)
			[1] = { -- table(9788bd4)
				['Access'] = 'private',
				['ClassAddress'] = '6E08412650',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field1',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '10',
				['Type'] = 'int',
			},
		},
		['InstanceSize'] = 24,
		['IsEnum'] = false,
		['Parent'] = { -- table(ce6517d)
			['ClassAddress'] = '6E083AC050',
			['ClassName'] = 'Object',
		},
		['Token'] = '0x2000047',
		['TypeMetadataHandle'] = 466714879152,
	},
	[2] = { -- table(e92f872)
		['ClassAddress'] = '6E08414950',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(672b4c3)
			[1] = { -- table(3bc9140)
				['Access'] = '',
				['ClassAddress'] = '0',
				['ClassName'] = 'TestClass',
				['FieldName'] = '',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = '(not support type -> 0x0)',
			},
		},
		['InstanceSize'] = 20,
		['IsEnum'] = false,
		['Parent'] = { -- table(30b8879)
			['ClassAddress'] = '6E083AC3D0',
			['ClassName'] = 'ValueType',
		},
		['Token'] = '0x20000D1',
		['TypeMetadataHandle'] = 466714807168,
	},
	[3] = { -- table(61429be)
		['ClassAddress'] = '6E0841D8D0',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(241da1f)
			[ 1] = { -- table(979816c)
				['Access'] = 'public',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field1',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '18',
				['Type'] = 'int',
			},
			[ 2] = { -- table(3b33335)
				['Access'] = 'public',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field2',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '1C',
				['Type'] = 'float',
			},
			[ 3] = { -- table(ce523ca)
				['Access'] = 'public',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field3',
				['IsConst'] = false,
				['IsStatic'] = true,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[ 4] = { -- table(6b3f93b)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field6',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[ 5] = { -- table(f334858)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field7',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'float',
			},
			[ 6] = { -- table(4f0cdb1)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field8',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'string',
			},
			[ 7] = { -- table(119b296)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field9',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'uint',
			},
			[ 8] = { -- table(25eee17)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field10',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'bool',
			},
			[ 9] = { -- table(bc09204)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field11',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[10] = { -- table(9393ed)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field12',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[11] = { -- table(c366222)
				['Access'] = 'public',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field13',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '20',
				['Type'] = 'TestStruct',
			},
			[12] = { -- table(d5a54b3)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field14',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '28',
				['Type'] = 'TestClass',
			},
			[13] = { -- table(ab6ca70)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field15',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '30',
				['Type'] = 'TestGenericClass`1',
			},
			[14] = { -- table(42281e9)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'random',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '38',
				['Type'] = 'Random',
			},
			[15] = { -- table(97c7e6e)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'textFields',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '40',
				['Type'] = 'GameObject[]',
			},
			[16] = { -- table(f9b890f)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'textFieldsMethods',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '48',
				['Type'] = 'GameObject[]',
			},
		},
		['InstanceSize'] = 80,
		['IsEnum'] = false,
		['Parent'] = { -- table(9961d9c)
			['ClassAddress'] = '6E0841EC10',
			['ClassName'] = 'TestVirtual',
		},
		['StaticFieldData'] = 468826422000,
		['Token'] = '0x2000002',
		['TypeMetadataHandle'] = 466714873080,
	},
}

Завершено.

Скрипт записал 124 КБ в 2 файлов.
```

![Example](/test/img/TestModule.gif)


## Example of how you can change the method


My code for changing class method:

```Lua
io.open('il2cppapi.lua',"w+"):write(gg.makeRequest("https://raw.githubusercontent.com/kruvcraft21/GGIl2cpp/master/build/Il2cppApi.lua").content):close()
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
{ -- table(5e68309)
	[1] = { -- table(108b90e)
		['ClassAddress'] = '6E08412650',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = 'ForTwoClass',
		['Fields'] = { -- table(5eb46c5)
			[1] = { -- table(61b581a)
				['Access'] = 'private',
				['ClassAddress'] = '6E08412650',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field1',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '10',
				['Type'] = 'int',
			},
		},
		['InstanceSize'] = 24,
		['IsEnum'] = false,
		['Methods'] = { -- table(7ed3f2f)
			[1] = { -- table(69e693c)
				['Access'] = 'public',
				['AddressInMemory'] = '6CC3687DB8',
				['ClassAddress'] = '6E08412650',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 476347239824,
				['MethodName'] = '.ctor',
				['Offset'] = '1355A0DB8',
				['ParamCount'] = 1,
				['ReturnType'] = 'void',
			},
		},
		['Parent'] = { -- table(c989f4b)
			['ClassAddress'] = '6E083AC050',
			['ClassName'] = 'Object',
		},
		['Token'] = '0x2000047',
		['TypeMetadataHandle'] = 466714879152,
	},
	[2] = { -- table(c86dd28)
		['ClassAddress'] = '6E08414950',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(1be8a41)
			[1] = { -- table(b86dbe6)
				['Access'] = '',
				['ClassAddress'] = '0',
				['ClassName'] = 'TestClass',
				['FieldName'] = '',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = '(not support type -> 0x0)',
			},
		},
		['InstanceSize'] = 20,
		['IsEnum'] = false,
		['Parent'] = { -- table(94fe527)
			['ClassAddress'] = '6E083AC3D0',
			['ClassName'] = 'ValueType',
		},
		['Token'] = '0x20000D1',
		['TypeMetadataHandle'] = 466714807168,
	},
	[3] = { -- table(200a3d4)
		['ClassAddress'] = '6E0841D8D0',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(689fbca)
			[ 1] = { -- table(bb3f13b)
				['Access'] = 'public',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field1',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '18',
				['Type'] = 'int',
			},
			[ 2] = { -- table(dbfe058)
				['Access'] = 'public',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field2',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '1C',
				['Type'] = 'float',
			},
			[ 3] = { -- table(d1d85b1)
				['Access'] = 'public',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field3',
				['IsConst'] = false,
				['IsStatic'] = true,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[ 4] = { -- table(c340a96)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field6',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[ 5] = { -- table(3666617)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field7',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'float',
			},
			[ 6] = { -- table(27eaa04)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field8',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'string',
			},
			[ 7] = { -- table(ad3cbed)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field9',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'uint',
			},
			[ 8] = { -- table(a9e3a22)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field10',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'bool',
			},
			[ 9] = { -- table(3614cb3)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field11',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[10] = { -- table(b3e6270)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field12',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[11] = { -- table(e2e39e9)
				['Access'] = 'public',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field13',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '20',
				['Type'] = 'TestStruct',
			},
			[12] = { -- table(289d66e)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field14',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '28',
				['Type'] = 'TestClass',
			},
			[13] = { -- table(b1a010f)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field15',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '30',
				['Type'] = 'TestGenericClass`1',
			},
			[14] = { -- table(6ff359c)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'random',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '38',
				['Type'] = 'Random',
			},
			[15] = { -- table(fa78ba5)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'textFields',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '40',
				['Type'] = 'GameObject[]',
			},
			[16] = { -- table(d80eb7a)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'textFieldsMethods',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '48',
				['Type'] = 'GameObject[]',
			},
		},
		['InstanceSize'] = 80,
		['IsEnum'] = false,
		['Methods'] = { -- table(628897d)
			[1] = { -- table(cd4d072)
				['Access'] = 'private',
				['AddressInMemory'] = '6CC3674CCC',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 476346294000,
				['MethodName'] = 'Start',
				['Offset'] = '13558DCCC',
				['ParamCount'] = 0,
				['ReturnType'] = 'void',
			},
			[2] = { -- table(84bacc3)
				['Access'] = 'public',
				['AddressInMemory'] = '6CC36750A4',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 476346294088,
				['MethodName'] = 'GetField4',
				['Offset'] = '13558E0A4',
				['ParamCount'] = 0,
				['ReturnType'] = 'int',
			},
			[3] = { -- table(8ae2940)
				['Access'] = 'private',
				['AddressInMemory'] = '6CC36750F8',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = true,
				['MethodInfoAddress'] = 476346294176,
				['MethodName'] = 'GetTwo',
				['Offset'] = '13558E0F8',
				['ParamCount'] = 0,
				['ReturnType'] = 'int',
			},
			[4] = { -- table(a394079)
				['Access'] = 'public',
				['AddressInMemory'] = '6CC3675100',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 476346294264,
				['MethodName'] = 'GetOne',
				['Offset'] = '13558E100',
				['ParamCount'] = 0,
				['ReturnType'] = 'int',
			},
			[5] = { -- table(29b81be)
				['Access'] = 'public',
				['AddressInMemory'] = '6CC3675108',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 476346294352,
				['MethodName'] = 'GetField5',
				['Offset'] = '13558E108',
				['ParamCount'] = 0,
				['ReturnType'] = 'int',
			},
			[6] = { -- table(4b2521f)
				['Access'] = 'public',
				['AddressInMemory'] = '6CC3675110',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 476346294440,
				['MethodName'] = 'GetField13',
				['Offset'] = '13558E110',
				['ParamCount'] = 0,
				['ReturnType'] = 'string',
			},
			[7] = { -- table(7ec996c)
				['Access'] = 'public',
				['AddressInMemory'] = '6CC3674D94',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 476346294528,
				['MethodName'] = 'UpdateTextField',
				['Offset'] = '13558DD94',
				['ParamCount'] = 0,
				['ReturnType'] = 'void',
			},
			[8] = { -- table(c046b35)
				['Access'] = 'public',
				['AddressInMemory'] = '6CC36751C8',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 476346294616,
				['MethodName'] = '.ctor',
				['Offset'] = '13558E1C8',
				['ParamCount'] = 0,
				['ReturnType'] = 'void',
			},
		},
		['Parent'] = { -- table(1ff9f2b)
			['ClassAddress'] = '6E0841EC10',
			['ClassName'] = 'TestVirtual',
		},
		['StaticFieldData'] = 468826422000,
		['Token'] = '0x2000002',
		['TypeMetadataHandle'] = 466714873080,
	},
}

Завершено.

Скрипт записал 124 КБ в 2 файлов.
```

![Exapmle](/test/img/Screenshot_20220712-090652.png)


## An example of how you can get constants

```lua
Il2cpp()

local TestClass = Il2cpp.FindClass({{Class ="TestClass", FieldsDump = true}})[1]

print(TestClass)

for k,v in ipairs(TestClass[3].Fields) do
    print(v.FieldName, v:GetConstValue())
end
```

Result of code execution:

```lua
Скрипт завершен:
{ -- table(b869691)
	[1] = { -- table(f5479f6)
		['ClassAddress'] = '6E08412650',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = 'ForTwoClass',
		['Fields'] = { -- table(e6511f7)
			[1] = { -- table(88c1864)
				['Access'] = 'private',
				['ClassAddress'] = '6E08412650',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field1',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '10',
				['Type'] = 'int',
			},
		},
		['InstanceSize'] = 24,
		['IsEnum'] = false,
		['Parent'] = { -- table(46d0acd)
			['ClassAddress'] = '6E083AC050',
			['ClassName'] = 'Object',
		},
		['Token'] = '0x2000047',
		['TypeMetadataHandle'] = 466714879152,
	},
	[2] = { -- table(3463f82)
		['ClassAddress'] = '6E08414950',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(cced693)
			[1] = { -- table(22456d0)
				['Access'] = '',
				['ClassAddress'] = '0',
				['ClassName'] = 'TestClass',
				['FieldName'] = '',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = '(not support type -> 0x0)',
			},
		},
		['InstanceSize'] = 20,
		['IsEnum'] = false,
		['Parent'] = { -- table(cc86c9)
			['ClassAddress'] = '6E083AC3D0',
			['ClassName'] = 'ValueType',
		},
		['Token'] = '0x20000D1',
		['TypeMetadataHandle'] = 466714807168,
	},
	[3] = { -- table(9cd1ce)
		['ClassAddress'] = '6E0841D8D0',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(e0648ef)
			[ 1] = { -- table(ac00ffc)
				['Access'] = 'public',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field1',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '18',
				['Type'] = 'int',
			},
			[ 2] = { -- table(18dc685)
				['Access'] = 'public',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field2',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '1C',
				['Type'] = 'float',
			},
			[ 3] = { -- table(bb83cda)
				['Access'] = 'public',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field3',
				['IsConst'] = false,
				['IsStatic'] = true,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[ 4] = { -- table(a98850b)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field6',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[ 5] = { -- table(cfc2fe8)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field7',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'float',
			},
			[ 6] = { -- table(3694601)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field8',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'string',
			},
			[ 7] = { -- table(ced4ca6)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field9',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'uint',
			},
			[ 8] = { -- table(cc866e7)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field10',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'bool',
			},
			[ 9] = { -- table(e586294)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field11',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[10] = { -- table(c23413d)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field12',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[11] = { -- table(b118d32)
				['Access'] = 'public',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field13',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '20',
				['Type'] = 'TestStruct',
			},
			[12] = { -- table(62a8a83)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field14',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '28',
				['Type'] = 'TestClass',
			},
			[13] = { -- table(aa31400)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field15',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '30',
				['Type'] = 'TestGenericClass`1',
			},
			[14] = { -- table(f87b439)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'random',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '38',
				['Type'] = 'Random',
			},
			[15] = { -- table(2c74a7e)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'textFields',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '40',
				['Type'] = 'GameObject[]',
			},
			[16] = { -- table(3014bdf)
				['Access'] = 'private',
				['ClassAddress'] = '6E0841D8D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'textFieldsMethods',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '48',
				['Type'] = 'GameObject[]',
			},
		},
		['InstanceSize'] = 80,
		['IsEnum'] = false,
		['Parent'] = { -- table(a25702c)
			['ClassAddress'] = '6E0841EC10',
			['ClassName'] = 'TestVirtual',
		},
		['StaticFieldData'] = 468826422000,
		['Token'] = '0x2000002',
		['TypeMetadataHandle'] = 466714873080,
	},
}
Field1 	nil
Field2 	nil
Field3 	nil
field6 	679
field7 	23.344999313354492
field8 	Isn't Const
field9 	414141412
field10 	1
field11 	-12414
field12 	5
Field13 	nil
field14 	nil
field15 	nil
random 	nil
textFields 	nil
textFieldsMethods 	nil

Завершено.

Скрипт записал 124 КБ в 2 файлов.
```