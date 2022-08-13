Class ObjectScript.Lookup2
{
/// main loop section
ClassMethod Main()
{
    do ..CurrentCount()
    while ..GetInput(.type, .search){
        if (type = "help"){ do ..Help() set id = ""}
        elseif (type = "phone"){ do ..Phone(search,.id)}
        elseif (type = "name"){ do ..Name(search,.id)}
        elseif (type = "dob"){ do ..DOB(search,.id)}

        if ((type '= "") && (id '= "")) {do ..TakeAction(id)}
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
    // 1.phone number accepts ###- or ###-###-#### only
    elseif $match(lookup, "\d{3}-(\d{3}-\d{4})?") {
        set type = "phone",search = lookup
    }

    elseif ($zconvert(lookup, "W")?1U.L.1(1","1U.L)){
        set type = "name",search = $zconvert(lookup,"W")  //$zconvert(,"W") ==> 首字母大写
    }

    // 2.DOB accepts date only
    elseif (##class(ObjectScript.DataEntry4).ValidDOB(lookup,.convdate)){
        set type = "dob",search = convdate
    }
    else {
        w ",name,or phone number."
        set (type,search) = "" 
    }
    return 1         
}

/// display lookup options
ClassMethod Help()
{
    w !,"You can enter:",
      !?10,"* date of birth",
      !?10,"* full phone number or area code only ""617-""",
      !?10,"* full name: Smith,John",
      !?10,"* last name: Smith",
      !?10,"* partial name:Sm,J or Smith,J or Sm,John",
      !

}

/// DOB
ClassMethod DOB(intdob as %Date,output id as %Integer)
{
    set id = ""
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
        //************新增一行************
        set matches(count) = id  // keep track of matches
        //*******************************
        w !!,count,")",!
        do ..DisplayLine(id)
    }
    do ..Select(.matches,.id)
}

/// lookup names in these forms: Smith; Smith,John; Smith,J; Sm,John; Sm,J
ClassMethod Name(name as %String,output id as %Integer)
{
    set id = ""
    set count = 0
    set last = $piece(name,",",1),first = $piece(name,",",2)
    set ln = $order(^PersonI("name",last),-1) //找到输入的lastname的上一位
    // 可支持部分名称查询 Sm(Smith)
    // loop through last names
    for {
        set ln = $order(^PersonI("name",ln))
        // quit as soon as last name doesn't match original
        quit:($extract(ln,1,$length(last)) '= last)
        if (first="") {set fn = ""}
        else {set fn = $order(^PersonI("name",ln,first),-1)}

        //loop through first names
        for {
            set fn = $order(^PersonI("name",ln,fn))
            quit:($extract(fn,1,$length(first)) '= first || (fn = ""))
            set id = ""

            for {
                set id = $order(^PersonI("name",ln,fn,id))
                quit:(id = "")
                w:(count = 0) "...finding name matches"
                set count = count + 1
                //************新增一行************
                set matches(count) = id  // keep track of matches
                //*******************************
                w !,count,")",!
                do ..DisplayLine(id)
            }
        }
        if (count = 0) {w "...no matches"}
        else {do ..Select(.matches,.id)}
    }
}

/// lookup phone or area code
ClassMethod Phone(phone as %String,output id as %Integer)
{
    set id = ""
    set count = 0
    // exact match first
    set id = $get(^PersonI("Phone",phone))
    if (id '= ""){
        set count = 1
        //************新增一行************
        set matches(1) = id  // keep track of exact match
        //*******************************
        w !,"1)"
        do ..DisplayLine(id)
        quit
    }
    
    // area code matches next  "XXX-"
    elseif (phone?3n1"-"){
        set ph = $order(^PersonI("Phone",phone),1,id)
        while ($extract(ph,1,$length(phone)) = phone){
            w:(count = 0) "...finding area code matches"
            set count = count + 1 
            //************新增一行************
            set matches(count) = id  // keep track of matches
            //*******************************
            w !,count,")",!
            do ..DisplayLine(id)
            set ph = $order(^PersonI("Phone",ph),1,id)
        }
    }
    if (count = 0) {w "...no matches"}
    else {do ..Select(.matches,.id)}
}

/// given an ID, 将信息合并为一行展示
ClassMethod DisplayLine(id as %Integer)
{
    set $LISTBUILD(name,phone,intdob) = ^PersonD(id)
    w "=============================",!
    w name,?20,phone,?35,$zdate(intdob,2),!
    w "=============================",!
}

/// count the "1" bits from the chunks of the Bitmap-ID index
ClassMethod CurrentCount()
{
    set records = 0,chunk = ""
    for {
        //3-argument $order
        set chunk = $order(^PersonI("Bitmap-ID",chunk),1,bits)
        quit:(chunk = "")
        // add the "1" bits to the count
        set records = records + $bitcount(bits,1)
    }
    w !,"There are ",records," records in the database."
}

/// user makes a choice from the matches array, return the corresponding ID or ""
ClassMethod Select(ByRef matches as %Integer, output id as %Integer)
{
    set id = ""
    for {
        read !!,"Choose by number: ",choice
        quit:(choice = "")
        set id = $get(matches(choice))
        quit:(id '= "") //stop looping if user makes a valid choice
        w "...Invalid choice"
    }
}

/// display chosen record
ClassMethod TakeAction(id as %Integer)
{
    set record = ^PersonD(id)
    do ##class(ObjectScript.DataEntry4).Display(record)
}

}