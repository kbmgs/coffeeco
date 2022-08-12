Class Demo.MyClass Extends %RegisteredObject
{
/// Description
Property Property1 As %String;
/// Description
Property Property2 As %Numeric;

/// Description
Method MyMethod() As %String
{
    Set ReturnValue = ..Property1_..Property2
    quit ReturnValue
}

}