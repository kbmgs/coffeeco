Class ObjectScript.DataEntry2
{
/// Main loop section
ClassMethod Main()
{
    while ..Prompt(){
        do ..Display()
    }
}
/// prompt until user doesn't enter a name
ClassMethod Prompt() As %Boolean [publiclist = (name,phone,dob)]
{
    read !,"Name:",name
    return:(name = "") 0 //不输入则返回0
    read !,"Phone:",phone
    read !,"DOB:",dob
    return 1 //返回true
}

/// display the data
ClassMethod Display() [publiclist=(name,phone,dob)]
{
    w !!,"================================="
    w !,"Name:",?20,name
    w !,"Phone:",?20,phone
    w !,"DOB:",?20,dob
    w !,"=================================",!
}

}