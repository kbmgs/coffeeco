Class ObjectScript.DataEntry1
{
/// Main
ClassMethod Main()
{
    read !,"Name: ",name
    //if name = ""{quit}
    quit:(name = "")
    read !,"Phone: ",phone
    read !,"DOB: ",dob

    //display
    w !!!,"Name:",?20,name
    w !,"Phone:",?20,phone
    w !,"DOB:",?20,dob
}
}