Class ObjectScript.DataEntry3
{
/// Main loop section
ClassMethod Main()
{
    while ..Prompt(.answers){
        do ..Display(answers)
    }
}

/// prompt until user doesn't enter a name
/// ByRef:需要传递至方法外的参数,在这里是List型
ClassMethod Prompt(ByRef answers as %String) As %Boolean
{
    do {
        read !,"Name:",name
        return:(name = "") 0 //return FALSE and exit method
    }
    while '..ValidName(name)

    do {
        read !,"Phone(617):",phone
    }
    while '..ValidPhone(.phone)

    do {
        read !,"DOB:",dob
    }
    while '..ValidDOB(dob,.intdob)
    
    set answers = $LISTBUILD(name,phone,intdob)

    return 1 // at last return true

}

//模式匹配 
/// 对name进行模式匹配判断
ClassMethod ValidName(name as %String) As %Boolean
{
    if (name?1U.L1","1U.L) {
        return 1
    }
    else {
        w !,"Last,First"
        return 0
    }
}

/// "###-####" or "###-###-####" format.
ClassMethod ValidPhone(ByRef phone as %String) As %Boolean
{
    if $MATCH(phone,"(\d{3}-)?\d{3}-\d{4}") {
        set:($match(phone, "\d{3}-\d{4}")) phone = "617-" _ phone  // add default area code
        return 1 
    }
    else {
        w !,"###-###-#### or ###-####"
        return 0
    }
}

/// validate a date of birth using $zdateh and $horolog
ClassMethod ValidDOB(date as %String,Output convdate as %Date) As %Boolean
{
    set convdate = $ZDATEH(date,5,,,,,,,-1)
    if (convdate = -1){
        w !,"Must be a valid past date"
        return 0 //not a valid date
    }
    elseif (convdate>$PIECE($HOROLOG,".",1)){
        w !,"Must be a valid past date"
        return 0 //also not a valid date
    }
    else {
        return 1 //valid date
    }
}

/// display the data
/// 使用Prompt()方法传入的参数answers
ClassMethod Display(answers as %String) 
{
    set $LISTBUILD(name,phone,intdob) = answers
    w !!,"================================="
    w !,"Name:",?20,name
    w !,"Phone:",?20,phone
    w !,"DOB:",?20,$zdate(intdob,2) //13 Aug 2022
    w !,"=================================",!
}
}