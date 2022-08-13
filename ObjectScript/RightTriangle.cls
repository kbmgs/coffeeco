Class ObjectScript.RightTriangle
{

/// 计算直角三角形的面积和斜边
ClassMethod Main() 
{
    w !,"Compute the area and hypotenuse of a right triangle",
      !,"given the lengths of its 2 sides."
    read !!,"First, choose a unit of measurement: ",
          !,"1) inches", !, "2) feet", !, "3) miles", !,
            "4) centimeters", !, "5) meters", !, "6) kilometers ", !!, 
            "Option? ", units
    // 将输入units变量的序号转换为单位
    set units = $case(units,1:"inches",
                            2:"feet",
                            3:"miles",
                            4:"centimeters",
                            5:"meters",
                            6:"kilometers",
                             :"units"    
    )
    //do loop
    do {
        read !!,"Length of side 1:",side1
        quit:(side1="")  //exit the do loop
    }
    while ..IsNegative(side1)
    quit:(side1="") //exit the method

    do {
        read !!,"Length of side 2:",side2
        quit:(side2="")  //exit the do loop
    }
    while ..IsNegative(side2)
    quit:(side2="") //exit the method

    do ..Compute(units,side1,side2)
    w !!,"Current date: "
    do ^%D
    w !,"Current time: "
    do ^%T
}

/// Is num negative?
/// 默认返回boolean?
ClassMethod IsNegative(num As %Numeric)
{
    if (num'>0){
        w " Enter a positive number"
        return 1 //Return true
    }
    else {
        w " Accepted."
        return 0 //Return false
    }
}

/// Compute and display area and hypotenuse
ClassMethod Compute(units As %String, A As %Numeric, B As %Numeric) [ Private ]
{
    set area = (A*B)/2,
        area = $JUSTIFY(area,0,2) , //Round hypot to 2 places
        squareSides = (A**2)+(B**2)
    set hypot = $zsqr(squareSides), //$zsqr function computes square root  
        hypot = $JUSTIFY(hypot,0,2) //Round hypot to 2 places

    w !!,"The area of this triangle is ",area," square",units,".",
      !!,"The hypotenuse is ",hypot," ",units,"."
}

}
