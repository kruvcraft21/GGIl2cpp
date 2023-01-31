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
{ -- table(715f1d9)
	[1] = { -- table(ade479e)
		['ClassAddress'] = '6FEC94C0D0',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = 'ForTwoClass',
		['Fields'] = { -- table(caad27f)
			[1] = { -- table(e18824c)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC94C0D0',
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
		['Parent'] = { -- table(aead295)
			['ClassAddress'] = '6FEC934C10',
			['ClassName'] = 'Object',
		},
		['TypeMetadataHandle'] = 475139499184,
	},
	[2] = { -- table(6633faa)
		['ClassAddress'] = '6FEC96DF50',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(d24179b)
			[1] = { -- table(4717738)
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
		['Parent'] = { -- table(3f30311)
			['ClassAddress'] = '6FEC935F50',
			['ClassName'] = 'ValueType',
		},
		['TypeMetadataHandle'] = 475139427200,
	},
	[3] = { -- table(98dac76)
		['ClassAddress'] = '6FEC9A15D0',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(5229277)
			[ 1] = { -- table(762cee4)
				['Access'] = 'public',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field1',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '18',
				['Type'] = 'int',
			},
			[ 2] = { -- table(873bf4d)
				['Access'] = 'public',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field2',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '1C',
				['Type'] = 'float',
			},
			[ 3] = { -- table(201a02)
				['Access'] = 'public',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field3',
				['IsConst'] = false,
				['IsStatic'] = true,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[ 4] = { -- table(523df13)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field6',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[ 5] = { -- table(9eff550)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field7',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'float',
			},
			[ 6] = { -- table(3ca0349)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field8',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'string',
			},
			[ 7] = { -- table(d79d44e)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field9',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'uint',
			},
			[ 8] = { -- table(de3596f)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field10',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'bool',
			},
			[ 9] = { -- table(9e7167c)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field11',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[10] = { -- table(268b05)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field12',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[11] = { -- table(9a2e75a)
				['Access'] = 'public',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field13',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '20',
				['Type'] = 'TestStruct',
			},
			[12] = { -- table(6761d8b)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field14',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '28',
				['Type'] = 'TestClass',
			},
			[13] = { -- table(1cd1e68)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field15',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '30',
				['Type'] = 'TestGenericClass`1',
			},
			[14] = { -- table(9d281)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'random',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '38',
				['Type'] = 'Random',
			},
			[15] = { -- table(3181f26)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'textFields',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '40',
				['Type'] = 'GameObject[]',
			},
			[16] = { -- table(8270767)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
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
		['Parent'] = { -- table(d89b914)
			['ClassAddress'] = '6FEC99FD50',
			['ClassName'] = 'TestVirtual',
		},
		['StaticFieldData'] = 476991683312,
		['TypeMetadataHandle'] = 475139493112,
	},
}

Завершено.

Скрипт записал 122 КБ в 2 файлов.
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
{ -- table(c1bab19)
	[1] = { -- table(43fa7de)
		['ClassAddress'] = '6FEC94C0D0',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = 'ForTwoClass',
		['Fields'] = { -- table(eb2dfd5)
			[1] = { -- table(61a63ea)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC94C0D0',
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
		['Methods'] = { -- table(7f44dbf)
			[1] = { -- table(36f7c8c)
				['Access'] = 'public',
				['AddressInMemory'] = '6EA568DDB8',
				['ClassAddress'] = '6FEC94C0D0',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 484473195920,
				['MethodName'] = '.ctor',
				['Offset'] = '1020D3DB8',
				['ParamCount'] = 1,
				['ReturnType'] = 'void',
			},
		},
		['Parent'] = { -- table(4aa06db)
			['ClassAddress'] = '6FEC934C10',
			['ClassName'] = 'Object',
		},
		['TypeMetadataHandle'] = 475139499184,
	},
	[2] = { -- table(2ddd578)
		['ClassAddress'] = '6FEC96DF50',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(24ea451)
			[1] = { -- table(932d4b6)
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
		['Parent'] = { -- table(23835b7)
			['ClassAddress'] = '6FEC935F50',
			['ClassName'] = 'ValueType',
		},
		['TypeMetadataHandle'] = 475139427200,
	},
	[3] = { -- table(4d6d124)
		['ClassAddress'] = '6FEC9A15D0',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(48b9b9a)
			[ 1] = { -- table(bf65ccb)
				['Access'] = 'public',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field1',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '18',
				['Type'] = 'int',
			},
			[ 2] = { -- table(82d8ca8)
				['Access'] = 'public',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field2',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '1C',
				['Type'] = 'float',
			},
			[ 3] = { -- table(e3043c1)
				['Access'] = 'public',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field3',
				['IsConst'] = false,
				['IsStatic'] = true,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[ 4] = { -- table(777d766)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field6',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[ 5] = { -- table(8bfaa7)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field7',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'float',
			},
			[ 6] = { -- table(622cb54)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field8',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'string',
			},
			[ 7] = { -- table(dbc5afd)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field9',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'uint',
			},
			[ 8] = { -- table(99a03f2)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field10',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'bool',
			},
			[ 9] = { -- table(2f39a43)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field11',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[10] = { -- table(d8b48c0)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field12',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[11] = { -- table(8f8a9f9)
				['Access'] = 'public',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field13',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '20',
				['Type'] = 'TestStruct',
			},
			[12] = { -- table(5406d3e)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field14',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '28',
				['Type'] = 'TestClass',
			},
			[13] = { -- table(9ab979f)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field15',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '30',
				['Type'] = 'TestGenericClass`1',
			},
			[14] = { -- table(a3c30ec)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'random',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '38',
				['Type'] = 'Random',
			},
			[15] = { -- table(510ecb5)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'textFields',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '40',
				['Type'] = 'GameObject[]',
			},
			[16] = { -- table(9521f4a)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
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
		['Methods'] = { -- table(908348d)
			[1] = { -- table(a8f8642)
				['Access'] = 'private',
				['AddressInMemory'] = '6EA567ACCC',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 484472250096,
				['MethodName'] = 'Start',
				['Offset'] = '1020C0CCC',
				['ParamCount'] = 0,
				['ReturnType'] = 'void',
			},
			[2] = { -- table(3107653)
				['Access'] = 'public',
				['AddressInMemory'] = '6EA567B0A4',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 484472250184,
				['MethodName'] = 'GetField4',
				['Offset'] = '1020C10A4',
				['ParamCount'] = 0,
				['ReturnType'] = 'int',
			},
			[3] = { -- table(941db90)
				['Access'] = 'private',
				['AddressInMemory'] = '6EA567B0F8',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = true,
				['MethodInfoAddress'] = 484472250272,
				['MethodName'] = 'GetTwo',
				['Offset'] = '1020C10F8',
				['ParamCount'] = 0,
				['ReturnType'] = 'int',
			},
			[4] = { -- table(3508c89)
				['Access'] = 'public',
				['AddressInMemory'] = '6EA567B100',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 484472250360,
				['MethodName'] = 'GetOne',
				['Offset'] = '1020C1100',
				['ParamCount'] = 0,
				['ReturnType'] = 'int',
			},
			[5] = { -- table(f13c48e)
				['Access'] = 'public',
				['AddressInMemory'] = '6EA567B108',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 484472250448,
				['MethodName'] = 'GetField5',
				['Offset'] = '1020C1108',
				['ParamCount'] = 0,
				['ReturnType'] = 'int',
			},
			[6] = { -- table(52224af)
				['Access'] = 'public',
				['AddressInMemory'] = '6EA567B110',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 484472250536,
				['MethodName'] = 'GetField13',
				['Offset'] = '1020C1110',
				['ParamCount'] = 0,
				['ReturnType'] = 'string',
			},
			[7] = { -- table(51120bc)
				['Access'] = 'public',
				['AddressInMemory'] = '6EA567AD94',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 484472250624,
				['MethodName'] = 'UpdateTextField',
				['Offset'] = '1020C0D94',
				['ParamCount'] = 0,
				['ReturnType'] = 'void',
			},
			[8] = { -- table(dac6845)
				['Access'] = 'public',
				['AddressInMemory'] = '6EA567B1C8',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 484472250712,
				['MethodName'] = '.ctor',
				['Offset'] = '1020C11C8',
				['ParamCount'] = 0,
				['ReturnType'] = 'void',
			},
		},
		['Parent'] = { -- table(abc0ebb)
			['ClassAddress'] = '6FEC99FD50',
			['ClassName'] = 'TestVirtual',
		},
		['StaticFieldData'] = 476991683312,
		['TypeMetadataHandle'] = 475139493112,
	},
}

Завершено.

Скрипт записал 122 КБ в 2 файлов.
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
{ -- table(88e3eb7)
	[1] = { -- table(436a624)
		['ClassAddress'] = '6FEC94C0D0',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = 'ForTwoClass',
		['Fields'] = { -- table(5bbe58d)
			[1] = { -- table(8ffe342)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC94C0D0',
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
		['Parent'] = { -- table(33e0f53)
			['ClassAddress'] = '6FEC934C10',
			['ClassName'] = 'Object',
		},
		['TypeMetadataHandle'] = 475139499184,
	},
	[2] = { -- table(74a0090)
		['ClassAddress'] = '6FEC96DF50',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(60e4d89)
			[1] = { -- table(acf18e)
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
		['Parent'] = { -- table(d104daf)
			['ClassAddress'] = '6FEC935F50',
			['ClassName'] = 'ValueType',
		},
		['TypeMetadataHandle'] = 475139427200,
	},
	[3] = { -- table(bf695bc)
		['ClassAddress'] = '6FEC9A15D0',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(5053945)
			[ 1] = { -- table(b0a989a)
				['Access'] = 'public',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field1',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '18',
				['Type'] = 'int',
			},
			[ 2] = { -- table(f1e15cb)
				['Access'] = 'public',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field2',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '1C',
				['Type'] = 'float',
			},
			[ 3] = { -- table(7551a8)
				['Access'] = 'public',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field3',
				['IsConst'] = false,
				['IsStatic'] = true,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[ 4] = { -- table(c524c1)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field6',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[ 5] = { -- table(369a466)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field7',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'float',
			},
			[ 6] = { -- table(f643a7)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field8',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'string',
			},
			[ 7] = { -- table(ba1e054)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field9',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'uint',
			},
			[ 8] = { -- table(b3e4bfd)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field10',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'bool',
			},
			[ 9] = { -- table(75ba0f2)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field11',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[10] = { -- table(a397343)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field12',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[11] = { -- table(466adc0)
				['Access'] = 'public',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field13',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '20',
				['Type'] = 'TestStruct',
			},
			[12] = { -- table(b28aaf9)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field14',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '28',
				['Type'] = 'TestClass',
			},
			[13] = { -- table(9feda3e)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field15',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '30',
				['Type'] = 'TestGenericClass`1',
			},
			[14] = { -- table(1f6009f)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'random',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '38',
				['Type'] = 'Random',
			},
			[15] = { -- table(3e8e5ec)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'textFields',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '40',
				['Type'] = 'GameObject[]',
			},
			[16] = { -- table(bffdb5)
				['Access'] = 'private',
				['ClassAddress'] = '6FEC9A15D0',
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
		['Parent'] = { -- table(a5c4a)
			['ClassAddress'] = '6FEC99FD50',
			['ClassName'] = 'TestVirtual',
		},
		['StaticFieldData'] = 476991683312,
		['TypeMetadataHandle'] = 475139493112,
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

Скрипт записал 122 КБ в 2 файлов.
```