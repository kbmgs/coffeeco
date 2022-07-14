Class ObjectScript.DataEntry1
{

/// Main
ClassMethod Main() As %Status
{
    read !, "Name: " , name
    if name = "" { quit }  // user entered nothing
    read !, "Phone: ", phone
    read !, "DOB: ", dob

    // display the data
    write !!!, "Name:", ?20, name
    write !, "Phone:", ?20, phone
    write !, "DOB:", ?20, dob
}

}
