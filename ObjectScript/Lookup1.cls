Class ObjectScript.Lookup2
{

/// count the "1" bits from the chunks of the bitmap-ID index
/// CurrentCount
ClassMethod CurrentCount()
{
    set records = 0,chunk = ""
    for{
        set chunk = $order(^PersonI("Bitmap-ID",chunk),1,bits)
        quit:(chunk="")
        // add the "1" bits to the count
        set records = records + $bitcount(bits,1) 
    }
    write !,"There are ",records," records in the database."
}

/// / given an ID, retrieve data and write it on a line
ClassMethod DisplayLine(id As %Integer)
{
    set $listbuild(name, phone, intdob) = ^PersonD(id)
    /* the line above is equivalent to
       set answers = ^PersonD(id),
           name = $list(answers, 1),
           phone = $list(answers, 2),
           intdob = $list(answers, 3) */
    write name, ?20, phone, ?35, $zdate(intdob, 2)
}

/// look up phone or area code
/// Phone
ClassMethod Phone(phone As %String)
{
    set count = 0
    // first: exact matched
    // $get 访问变量或者数组位置，可设置为空时返回的字符串
    set id = $get(^PersonI("Phone",phone))
    if (id '= ""){ // $get找到对应号码则退出Phone()方法
        set count = 1
        write !,"1)"
        do ..DisplayLine(id)
        quit 
    }
    // then: area code matched 仅前三位匹配，列出所有匹配前三位的号码
    elseif (phone?3n1"-") {
        set ph = $order(^PersonI("phone",phone),1,id)  //将$order()到的phone的下一条记录的id存入id参数中，下一条phone记录存入ph
        //开始遍历  
        while ($extract(ph,1,$length(phone)) = phone ){
            write:(count = 0) "...finding area code matches"
            set count = count + 1 
            write !,count,")"
            do ..DisplayLine(id)
            set ph = $order(^PersonI("phone",ph),1,id)  //下一条号码存入ph中

        }
    }
}

/// exact date of birth lookup
ClassMethod DOB(intdob As %Date)
{
    // is the date of birth in the index?
    if '$data(^PersonI("DOB", intdob) ) {
        write "...no matches"
        quit
    }
    
    write "...finding birthday matches"
    // loop through IDs, and number them
    set id = ""
    for count = 1:1 {
        set id = $order(^PersonI("DOB", intdob, id))
        quit:(id = "")
        write !, count, ") "
        do ..DisplayLine(id) 
        }
}

ClassMethod Help()
{
    write !, "You can enter:",
          !?10, "* date of birth", !,
          !?20, "* full phone number or area code only ""617-"" ", !
}

/// prompt user for a lookup string, return search type and search string
ClassMethod GetInput(Output type As %String, Output search As %String) As %Boolean
{
    read !, "Lookup: ", lookup
    return:(lookup = "") 0  // user entered nothing so return FALSE
    if (lookup = "?") {
        set type = "help", search = ""
    }
    //增加是否匹配为phone格式的判断
    elseif $match(lookup,"\d{3}-(\d{3}-\d(4))?"){
        set type = "phone",search = lookup
    }
    // 增加判断逻辑
    elseif ($zconvert(lookup,"W")?1U.L.1(1","1U.L) ){
        set type = "name",search = $zconvert(lookup,"W") // $zconvert(name,"W") 参数字符转为首字母大写
    }
    elseif (##class(ObjectScript.DataEntry4).ValidDOB(lookup, .convdate)) {
        set type = "dob", search = convdate 
    }
    else {
        write ",name,or phone"
        set (type, search) = "" 
    }
    return 1
}

/// main loop section, dispatch to different methods based on user input
/// main函数
ClassMethod Main()
{
    do ..CurrentCount()
    while ..GetInput(.type, .search) {  
        if (type = "help") { do ..Help() }
        elseif (type = "phone") {do ..Phone(search)}
        elseif (type = "dob") { do ..DOB(search) } 
    }
}

}
