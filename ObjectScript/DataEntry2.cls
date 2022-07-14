Class ObjectScript.DataEntry2
{

/// Description
ClassMethod Prompt() As %Boolean [ PublicList = (name, phone, dob) ]
{
    read !,"Name: ",name
    return:(name="") 0
    read !,"Phone: ",phone
    read !,"DOB: ",dob
    return 1 //return true
}

/// Description
ClassMethod Display() [ PublicList = (name, phone, dob) ]
{
    write !!, "========================================"
    write !, "Name:", ?20, name
    write !, "Phone:", ?20, phone
    write !, "DOB:", ?20, dob
    write !, "========================================", !
}

/// The loop should quit when Prompt() returns false.
ClassMethod Main()
{
    While (..Prompt() /* condition */) {
        do ..Display()
    }
}

}
