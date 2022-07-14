Class testPkg.Person Extends %Persistent
{

Property Name As %String;

Property Memo As %Stream.GlobalCharacter;

Storage Default
{
<Data name="PersonDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>Name</Value>
</Value>
<Value name="3">
<Value>Memo</Value>
</Value>
</Data>
<DataLocation>^testPkg.PersonD</DataLocation>
<DefaultData>PersonDefaultData</DefaultData>
<IdLocation>^testPkg.PersonD</IdLocation>
<IndexLocation>^testPkg.PersonI</IndexLocation>
<StreamLocation>^testPkg.PersonS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
