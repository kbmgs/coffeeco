Class Library2.Book Extends (%Persistent,%Populate,%XML.Adaptor,%ZEN.DataModel.Adaptor)
{
Property Title As %String [ Required ];
Property Genre As %String;
Property Author As Library2.Person;
Property Friend As Library2.Person;
}