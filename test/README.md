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
    public string Field16;

    private System.Random random = new System.Random(DateTime.UtcNow.GetHashCode());

    private GameObject[] textFields;
    private GameObject[] textFieldsMethods;
    private void Start()
    {
        Field1 = 1;
        Field2 = 2;
        Field3 = 3;
        Field16 = "For String api";

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
        return this.Field13.ToString();
    }

    public void UpdateTextField()
    {
        Debug.Log(textFields.Length);

        Type testClass = GetType();

        foreach(GameObject textField in textFields)
        {
            string nameField = textField.name;
            Debug.Log(nameField);
            textField.GetComponent<TextMeshProUGUI>().text = String.Format("{0} = {1}", nameField, testClass.GetField(nameField).GetValue(this));
        }

        foreach (GameObject textField in textFieldsMethods)
        {
            string nameField = textField.name;
            Debug.Log(nameField);
            textField.GetComponent<TextMeshProUGUI>().text = String.Format("{0} = {1}", nameField, testClass.GetMethod("Get" + nameField).Invoke((object)this, null));
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
    private int field1;
    private float field2;
    private string field3;
    public TestStruct(
        int Field1,
        float Field2)
    {
        this.field1 = Field1;
        this.field2 = Field2;
        this.field3 = "Test String";
    }

    public override string ToString()
    {
        return $"[{this.field1}, {this.field2}, {this.field3}]";
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
{ -- table(245dc4)
	[1] = { -- table(da5d4ad)
		['ClassAddress'] = '79A5C56290',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(13673e2)
			[1] = { -- table(e4a6373)
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
		['ImageName'] = 'UnityEngine.CoreModule.dll',
		['InstanceSize'] = 20,
		['IsEnum'] = false,
		['Parent'] = { -- table(deb9230)
			['ClassAddress'] = '79A5BF0710',
			['ClassName'] = 'ValueType',
		},
		['Token'] = '0x20000D1',
		['TypeMetadataHandle'] = 516749687788,
	},
	[2] = { -- table(4f80ea9)
		['ClassAddress'] = '79A5C61C10',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(1cbec2e)
			[ 1] = { -- table(f5dc3cf)
				['Access'] = 'public',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field1',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '18',
				['Type'] = 'int',
			},
			[ 2] = { -- table(dafa15c)
				['Access'] = 'public',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field2',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '1C',
				['Type'] = 'float',
			},
			[ 3] = { -- table(19ec65)
				['Access'] = 'public',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field3',
				['IsConst'] = false,
				['IsStatic'] = true,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[ 4] = { -- table(c2e9d3a)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field6',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[ 5] = { -- table(89ccdeb)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field7',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'float',
			},
			[ 6] = { -- table(437748)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field8',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'string',
			},
			[ 7] = { -- table(4c1e9e1)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field9',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'uint',
			},
			[ 8] = { -- table(d95306)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field10',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'bool',
			},
			[ 9] = { -- table(785dc7)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field11',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[10] = { -- table(ebcbff4)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field12',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[11] = { -- table(392431d)
				['Access'] = 'public',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field13',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '20',
				['Type'] = 'TestStruct',
			},
			[12] = { -- table(b279992)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field14',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '30',
				['Type'] = 'TestClass',
			},
			[13] = { -- table(9930f63)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field15',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '38',
				['Type'] = 'TestGenericClass`1',
			},
			[14] = { -- table(bdfe760)
				['Access'] = 'public',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field16',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '40',
				['Type'] = 'string',
			},
			[15] = { -- table(b14f419)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'random',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '48',
				['Type'] = 'Random',
			},
			[16] = { -- table(ea1bcde)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'textFields',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '50',
				['Type'] = 'GameObject[]',
			},
			[17] = { -- table(41d3ebf)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'textFieldsMethods',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '58',
				['Type'] = 'GameObject[]',
			},
		},
		['ImageName'] = 'Assembly-CSharp.dll',
		['InstanceSize'] = 96,
		['IsEnum'] = false,
		['Parent'] = { -- table(4c198c)
			['ClassAddress'] = '79A5C5E250',
			['ClassName'] = 'TestVirtual',
		},
		['StaticFieldData'] = 518487849712,
		['Token'] = '0x2000002',
		['TypeMetadataHandle'] = 516749753700,
	},
	[3] = { -- table(e77b8d5)
		['ClassAddress'] = '79A5C8C310',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = 'ForTwoClass',
		['Fields'] = { -- table(d08c8ea)
			[1] = { -- table(8f107db)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C8C310',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field1',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '10',
				['Type'] = 'int',
			},
		},
		['ImageName'] = 'Assembly-CSharp.dll',
		['InstanceSize'] = 24,
		['IsEnum'] = false,
		['Parent'] = { -- table(d674278)
			['ClassAddress'] = '79A5BEF590',
			['ClassName'] = 'Object',
		},
		['Token'] = '0x2000047',
		['TypeMetadataHandle'] = 516749759772,
	},
}

Завершено.

Скрипт записал 130 КБ в 2 файлов.
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
{ -- table(8751783)
	[1] = { -- table(9571d00)
		['ClassAddress'] = '79A5C56290',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(2ed8939)
			[1] = { -- table(a08fb7e)
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
		['ImageName'] = 'UnityEngine.CoreModule.dll',
		['InstanceSize'] = 20,
		['IsEnum'] = false,
		['Parent'] = { -- table(3e7a8df)
			['ClassAddress'] = '79A5BF0710',
			['ClassName'] = 'ValueType',
		},
		['Token'] = '0x20000D1',
		['TypeMetadataHandle'] = 516749687788,
	},
	[2] = { -- table(a91092c)
		['ClassAddress'] = '79A5C61C10',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(ea687e2)
			[ 1] = { -- table(51ae773)
				['Access'] = 'public',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field1',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '18',
				['Type'] = 'int',
			},
			[ 2] = { -- table(4ebc630)
				['Access'] = 'public',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field2',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '1C',
				['Type'] = 'float',
			},
			[ 3] = { -- table(7e632a9)
				['Access'] = 'public',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field3',
				['IsConst'] = false,
				['IsStatic'] = true,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[ 4] = { -- table(829402e)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field6',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[ 5] = { -- table(cb287cf)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field7',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'float',
			},
			[ 6] = { -- table(67f155c)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field8',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'string',
			},
			[ 7] = { -- table(dc65065)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field9',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'uint',
			},
			[ 8] = { -- table(d0d313a)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field10',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'bool',
			},
			[ 9] = { -- table(79d1eb)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field11',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[10] = { -- table(8962b48)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field12',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[11] = { -- table(ad08de1)
				['Access'] = 'public',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field13',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '20',
				['Type'] = 'TestStruct',
			},
			[12] = { -- table(30d2706)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field14',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '30',
				['Type'] = 'TestClass',
			},
			[13] = { -- table(321a1c7)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field15',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '38',
				['Type'] = 'TestGenericClass`1',
			},
			[14] = { -- table(b86b3f4)
				['Access'] = 'public',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field16',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '40',
				['Type'] = 'string',
			},
			[15] = { -- table(5e7271d)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'random',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '48',
				['Type'] = 'Random',
			},
			[16] = { -- table(ec4ad92)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'textFields',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '50',
				['Type'] = 'GameObject[]',
			},
			[17] = { -- table(78c9363)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'textFieldsMethods',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '58',
				['Type'] = 'GameObject[]',
			},
		},
		['ImageName'] = 'Assembly-CSharp.dll',
		['InstanceSize'] = 96,
		['IsEnum'] = false,
		['Methods'] = { -- table(4947ff5)
			[1] = { -- table(eb5518a)
				['Access'] = 'private',
				['AddressInMemory'] = '785626ADF0',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 526233612016,
				['MethodName'] = 'Start',
				['Offset'] = '45CDF0',
				['ParamCount'] = 0,
				['ReturnType'] = 'void',
			},
			[2] = { -- table(cc7f3fb)
				['Access'] = 'public',
				['AddressInMemory'] = '785626B1B4',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 526233612104,
				['MethodName'] = 'GetField4',
				['Offset'] = '45D1B4',
				['ParamCount'] = 0,
				['ReturnType'] = 'int',
			},
			[3] = { -- table(c9b8c18)
				['Access'] = 'private',
				['AddressInMemory'] = '785626B208',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = true,
				['MethodInfoAddress'] = 526233612192,
				['MethodName'] = 'GetTwo',
				['Offset'] = '45D208',
				['ParamCount'] = 0,
				['ReturnType'] = 'int',
			},
			[4] = { -- table(57a2671)
				['Access'] = 'public',
				['AddressInMemory'] = '785626B210',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 526233612280,
				['MethodName'] = 'GetOne',
				['Offset'] = '45D210',
				['ParamCount'] = 0,
				['ReturnType'] = 'int',
			},
			[5] = { -- table(91efc56)
				['Access'] = 'public',
				['AddressInMemory'] = '785626B218',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 526233612368,
				['MethodName'] = 'GetField5',
				['Offset'] = '45D218',
				['ParamCount'] = 0,
				['ReturnType'] = 'int',
			},
			[6] = { -- table(397d4d7)
				['Access'] = 'public',
				['AddressInMemory'] = '785626B220',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 526233612456,
				['MethodName'] = 'GetField13',
				['Offset'] = '45D220',
				['ParamCount'] = 0,
				['ReturnType'] = 'string',
			},
			[7] = { -- table(fc951c4)
				['Access'] = 'public',
				['AddressInMemory'] = '785626AEE4',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 526233612544,
				['MethodName'] = 'UpdateTextField',
				['Offset'] = '45CEE4',
				['ParamCount'] = 0,
				['ReturnType'] = 'void',
			},
			[8] = { -- table(139b8ad)
				['Access'] = 'public',
				['AddressInMemory'] = '785626B2E8',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 526233612632,
				['MethodName'] = '.ctor',
				['Offset'] = '45D2E8',
				['ParamCount'] = 0,
				['ReturnType'] = 'void',
			},
		},
		['Parent'] = { -- table(d551b60)
			['ClassAddress'] = '79A5C5E250',
			['ClassName'] = 'TestVirtual',
		},
		['StaticFieldData'] = 518487849712,
		['Token'] = '0x2000002',
		['TypeMetadataHandle'] = 516749753700,
	},
	[3] = { -- table(7d41819)
		['ClassAddress'] = '79A5C8C310',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = 'ForTwoClass',
		['Fields'] = { -- table(5e08d8c)
			[1] = { -- table(2051cd5)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C8C310',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field1',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '10',
				['Type'] = 'int',
			},
		},
		['ImageName'] = 'Assembly-CSharp.dll',
		['InstanceSize'] = 24,
		['IsEnum'] = false,
		['Methods'] = { -- table(fc10de)
			[1] = { -- table(22b02bf)
				['Access'] = 'public',
				['AddressInMemory'] = '785627DF60',
				['ClassAddress'] = '79A5C8C310',
				['ClassName'] = 'TestClass',
				['IsAbstract'] = false,
				['IsStatic'] = false,
				['MethodInfoAddress'] = 526234557840,
				['MethodName'] = '.ctor',
				['Offset'] = '46FF60',
				['ParamCount'] = 1,
				['ReturnType'] = 'void',
			},
		},
		['Parent'] = { -- table(cb45cea)
			['ClassAddress'] = '79A5BEF590',
			['ClassName'] = 'Object',
		},
		['Token'] = '0x2000047',
		['TypeMetadataHandle'] = 516749759772,
	},
}

Завершено.

Скрипт записал 130 КБ в 2 файлов.
```

![Exapmle](/test/img/Screenshot_20220712-090652.png)


## An example of how you can get constants

```lua
Il2cpp()

local TestClass = Il2cpp.FindClass({{Class ="TestClass", FieldsDump = true}})[1]

print(TestClass)

for indexClass, ClassInfo in ipairs(TestClass) do
    if ClassInfo.Parent and ClassInfo.Parent.ClassName ~= "ValueType" and #ClassInfo.ClassNameSpace == 0 then
        for indexField, FieldInfo in ipairs(ClassInfo.Fields) do
            print(FieldInfo.FieldName, FieldInfo:GetConstValue())
        end
    end
end
```

Result of code execution:

```lua
Скрипт завершен:
{ -- table(90af80b)
	[1] = { -- table(4c126e8)
		['ClassAddress'] = '79A5C56290',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(f887101)
			[1] = { -- table(74c9ba6)
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
		['ImageName'] = 'UnityEngine.CoreModule.dll',
		['InstanceSize'] = 20,
		['IsEnum'] = false,
		['Parent'] = { -- table(b6f09e7)
			['ClassAddress'] = '79A5BF0710',
			['ClassName'] = 'ValueType',
		},
		['Token'] = '0x20000D1',
		['TypeMetadataHandle'] = 516749687788,
	},
	[2] = { -- table(2f5c994)
		['ClassAddress'] = '79A5C61C10',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = '',
		['Fields'] = { -- table(28a1c3d)
			[ 1] = { -- table(d96cc32)
				['Access'] = 'public',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field1',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '18',
				['Type'] = 'int',
			},
			[ 2] = { -- table(c185d83)
				['Access'] = 'public',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field2',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '1C',
				['Type'] = 'float',
			},
			[ 3] = { -- table(92feb00)
				['Access'] = 'public',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field3',
				['IsConst'] = false,
				['IsStatic'] = true,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[ 4] = { -- table(5013f39)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field6',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[ 5] = { -- table(1e1797e)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field7',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'float',
			},
			[ 6] = { -- table(5794edf)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field8',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'string',
			},
			[ 7] = { -- table(a28b72c)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field9',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'uint',
			},
			[ 8] = { -- table(32d95f5)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field10',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'bool',
			},
			[ 9] = { -- table(e97af8a)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field11',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[10] = { -- table(ccdf9fb)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field12',
				['IsConst'] = true,
				['IsStatic'] = false,
				['Offset'] = '0',
				['Type'] = 'int',
			},
			[11] = { -- table(9001a18)
				['Access'] = 'public',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field13',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '20',
				['Type'] = 'TestStruct',
			},
			[12] = { -- table(38e9c71)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field14',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '30',
				['Type'] = 'TestClass',
			},
			[13] = { -- table(7c93a56)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field15',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '38',
				['Type'] = 'TestGenericClass`1',
			},
			[14] = { -- table(4f83ad7)
				['Access'] = 'public',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'Field16',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '40',
				['Type'] = 'string',
			},
			[15] = { -- table(8e8bfc4)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'random',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '48',
				['Type'] = 'Random',
			},
			[16] = { -- table(b1f8ead)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'textFields',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '50',
				['Type'] = 'GameObject[]',
			},
			[17] = { -- table(b6a5e2)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C61C10',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'textFieldsMethods',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '58',
				['Type'] = 'GameObject[]',
			},
		},
		['ImageName'] = 'Assembly-CSharp.dll',
		['InstanceSize'] = 96,
		['IsEnum'] = false,
		['Parent'] = { -- table(31bad73)
			['ClassAddress'] = '79A5C5E250',
			['ClassName'] = 'TestVirtual',
		},
		['StaticFieldData'] = 518487849712,
		['Token'] = '0x2000002',
		['TypeMetadataHandle'] = 516749753700,
	},
	[3] = { -- table(b941430)
		['ClassAddress'] = '79A5C8C310',
		['ClassName'] = 'TestClass',
		['ClassNameSpace'] = 'ForTwoClass',
		['Fields'] = { -- table(95368a9)
			[1] = { -- table(e1d3e2e)
				['Access'] = 'private',
				['ClassAddress'] = '79A5C8C310',
				['ClassName'] = 'TestClass',
				['FieldName'] = 'field1',
				['IsConst'] = false,
				['IsStatic'] = false,
				['Offset'] = '10',
				['Type'] = 'int',
			},
		},
		['ImageName'] = 'Assembly-CSharp.dll',
		['InstanceSize'] = 24,
		['IsEnum'] = false,
		['Parent'] = { -- table(f9adcf)
			['ClassAddress'] = '79A5BEF590',
			['ClassName'] = 'Object',
		},
		['Token'] = '0x2000047',
		['TypeMetadataHandle'] = 516749759772,
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
Field16 	nil
random 	nil
textFields 	nil
textFieldsMethods 	nil

Завершено.

Скрипт записал 130 КБ в 2 файлов.
```

## An example of how you can change a string field

```lua
Il2cpp()

---@type ClassConfig
local TestClassConfig = {}

TestClassConfig.Class = "TestClass"
TestClassConfig.FieldsDump = true

local TestClasses = Il2cpp.FindClass({TestClassConfig, {Class = "TestStruct", FieldsDump = true}})

local field3 = tonumber(TestClasses[2][1]:GetFieldWithName("field3").Offset, 16) - tonumber(TestClasses[2][1]:GetFieldWithName("field1").Offset, 16)

for k,v in ipairs(TestClasses[1]) do
    local TestClassObject = Il2cpp.FindObject({tonumber(v.ClassAddress, 16)})[1]
    if v.Parent and v.Parent.ClassName ~= "ValueType" and #v.ClassNameSpace == 0 then
        for i = 1, #TestClassObject do
            local str = Il2cpp.String.From(TestClassObject[i].address + tonumber(v:GetFieldWithName("Field16").Offset, 16))
            local str1 = Il2cpp.String.From(TestClassObject[i].address + tonumber(v:GetFieldWithName("Field13").Offset, 16) + field3)
            if str and str1 then
                print(str:ReadString())
                print(str.ReadString(str))
                str:EditString("New string, new life, new test")
                print(str:ReadString())

                print('------------')
                print(str1:ReadString())
                str1:EditString("New text, new string, new test")
                print(str1:ReadString())
            else
                print('Error')
            end
        end
    
    end
end

os.exit()
```

Result of code execution:

```lua
Скрипт завершен:
For String api 
For String api 
New string, new life, new test 
------------
Test String 
New text, new string, new test 

Завершено.

Скрипт записал 130 КБ в 2 файлов.
```

![Exapmle](/test/img/photo_2023-03-17_22-35-52.jpg)