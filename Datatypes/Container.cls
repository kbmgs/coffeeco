Class Datatypes.Container Extends %Persistent
{

/// Description
Property DOB As Datatypes.MyDate;

Storage Default
{
<Data name="ContainerDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>DOB</Value>
</Value>
</Data>
<DataLocation>^Datatypes.ContainerD</DataLocation>
<DefaultData>ContainerDefaultData</DefaultData>
<IdLocation>^Datatypes.ContainerD</IdLocation>
<IndexLocation>^Datatypes.ContainerI</IndexLocation>
<StreamLocation>^Datatypes.ContainerS</StreamLocation>
<Type>%Storage.Persistent</Type>
}

}
