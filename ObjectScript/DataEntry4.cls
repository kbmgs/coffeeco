Class ObjectScript.DataEntry4
{
    /// Main loop section
    ClassMethod Main()
    {
        while ..Prompt(.answers){
            do ..Display(answers)
            do ..Store(answers)
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
            // is phone already taken?
            if $DATA(^PersonI("Phone",phone)) {
                w !,"Phone number already in use."
                return 0
            }

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

    /// store the data
    ClassMethod Store(answers as %String)
    {
        read !,"Store? (y/n)",yn //ask if store
        if ((yn '= "y") && (yn '="Y")){
            w "..not stored."
            quit  //作用域:classmethod
        }

        set id = $INCREMENT(^PersonD) // $increment to generate a new ID
        set ^PersonD(id) = answers // store the answers
        
        set $LISTBUILD(name,phone,intdob) = answers
        //split name into last and first for storage in index
        set last = $PIECE(name,",",1),first = $PIECE(name,",",2)

        set ^PersonI("name",last,first,id) = "" //index last and first name
        set ^PersonI("Phone",phone) = id        //index the UNIQUE phone
        set ^PersonI("DOB",intdob,id) = ""      //index the internal DOB

        //turn the id into a "chunk #" and a "position #"
        //and set a bit into the bitmap index
        //id\64000: id被64000整除
        //id#64000: id被整除后的余数
        set chunk = (id\64000) + 1 ,position = (id#64000) + 1
        set $BIT(^PersonI("Bitmap-ID",chunk),position) = 1

        w "...stored"
  
    }



}