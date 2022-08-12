Class Library2.Person Extends (%Persistent,%Populate,%XML.Adaptor,%ZEN.DataModel.Adaptor)
{
Property Name As %String [ Required ];
Property PhoneNumber As %String;
//index 单独一行指定，不通过parameter关键字
/// Description
Index NameIndex On Name [Unique];
}