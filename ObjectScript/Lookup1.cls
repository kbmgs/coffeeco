Class ObjectScript.Lookup1
{
/// main loop section
ClassMethod Main()
{
    while ..GetInput(.type, .search){
        if (type = "help"){ do ..Help()}
        elseif (type = "dob"){ do ..DOB(search)}
    }
}

/// prompt user for a lookup string, return search type and search string
ClassMethod GetInput(output type as %String, output search as %String) As %Boolean
{
    read !,"Lookup:",lookup
    return:(lookup = "") 0 //user entered nothing,return FALSE
    if (lookup = "?"){
        set type = "help",search = ""
    }
    elseif (##class(ObjectScript.DataEntry4).ValidDOB(lookup,.convdate)){
        set type = "dob",search = convdate
    }
    else {
        set (type,search) = "" 
    }
    return 1         
}

/// display lookup options
ClassMethod Help()
{
    w !,"You can enter:",
      !?10,"* date of birth",!
}

/// DOB
ClassMethod DOB(intdob as %Date)
{
    // is the date of birth in the index?
    if '$DATA(^PersonI("DOB",intdob)){
        w "..no matches"
        quit  //这里退出的是DOB方法还是MAIN方法?
    }

    w "...finding birthday matches"
    //loop through IDs,and number them
    //use $order() to do loop
    set id = ""
    for count = 1:1 {
        set id = $order(^PersonI("DOB",intdob,id)) // set id = id + ?
        quit:(id = "")
        w !!,count,")",!
        do ..DisplayLine(id)
    }
}

/// given an ID, 将信息合并为一行展示
ClassMethod DisplayLine(id as %Integer)
{
    set $LISTBUILD(name,phone,intdob) = ^PersonD(id)
    w "=============================",!
    w name,?20,phone,?35,$zdate(intdob,2),!
    w "=============================",!
}

}