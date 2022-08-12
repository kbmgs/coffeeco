Class Library2.LibraryUtils Extends %RegisteredObject
{
/// Description
ClassMethod AddBook() As %Status
{
    //类方法AddBook()中创建了一个Book实例对象
    set book = ##class(Library2.Book).%New()

    //【Get the Book's Title】
    read #!!,"Please enter the book title:",name
    set book.Title = name

    //【Get the Author's Name】
    read #!!,"Please enter the name of the author:",author

    //Check if this author exists and add to the object
    //调用sql 这里Name是Person类的唯一索引，结果唯一
    &sql(Select id into :id from Library2.Person where Name = :author)
    if (id '= ""){
        set book.Author = ##class(Library2.Person).%OpenId(id)
    }
    else{
        //先在Person类中新增实例对象(Person表中新增记录)
        set newAuthor = ##class(Library2.Person).%New()
        set newAuthor.Name = author
        //set book对象实例的Author
        set book.Author = newAuthor

        //Save the newAuthor to the database
        set statusPerson = newAuthor.%Save()
    }

    //【Get the Genre】
    read !,"Please enter a 1 for Non-Fiction or a 2 for Fiction:",genre
    if genre = "1"{
        set book.Genre = "NonFiction"
    }
    else {
        set book.Genre = "Fiction"
    }

    //Save the book to the database
    set status = book.%Save()

    //返回%Status给ClassMethod AddBook()
    return status
}

/// Description
ClassMethod AddFriend() As %Status
{
    //新增Person对象
    set friend = ##class(Library2.Person).%New()

    //Get and store the name
    read #!!,"Please enter then name of your new friend:",name
    set friend.Name = name

    //Get and store the phone number
    read #!!,"Please enter then phone number of your new friend:",phoneNum
    set friend.PhoneNumber = phoneNum

    //Save,对实例对象进行存储
    set status = friend.%Save()
    return status    
}

/// Open the book object with the ID 
/// display the following properties of the opened book to the user: Title, Author, and Genre.
ClassMethod PrintOne(id As %String) As %Status
{
    //Open the book based on the given ID
    set book = ##class(Library2.Book).%OpenId(id)

    //Write the information 
    w !,"This book is called ",book.Title," and was written by ",book.Author.Name,"."
    w !,"This is a ",book.Genre," book."

    //Check if the book is on loan or not and return the result
    if book.Friend = ""{
        w !,"This book is currently in the library."
    }
    else{
        w !,"This book is currently on load to ",book.Friend.Name,"."
    }
    
    //return a simple status of $$$OK
    return $$$OK
}

/// Print all items from the database
/// 无参数
ClassMethod PrintAll() As %Status
{
    //database中book总数(实例总数)
    &sql(select count(*) into :count from Library2.Book)
    //Iterate through all books 迭代获取所有books
    set id = 1
    While (id <= count) {
        w !,"Book at ID ",id,":"
        //传入id参数，循环调用PrintOne()
        do ##class(Library2.LibraryUtils).PrintOne(id)
        set id = id + 1
    }
    //返回成功值
    return $$$OK
}

/// mark a book object as loaned to a friend and return on okay status once complete
/// parameters: a book ID of type %String and a friend's name as type %String
ClassMethod LoanBook(bookID As %String, friend As %String) As %Status
{
    //Open the book object
    set check = ##class(Library2.Book).%OpenId(bookID)

    if (check.Friend '= ""){
        w !,"This book is currently on loan."
        w !,"Please use the ReturnBook method to return the book before loaning it to a new friend."
        quit $$$OK
    }
    else{
        //book的Friend属性为空，查找输入参数friend在Person中的id
        &sql(select id into :id from Library2.Person where Name = :friend)
        if (id = ""){
            w !,"This friend is not registered."
            w !,"Please use the AddFriend method to add a new friend."
            quit $$$OK
        }
        else{
            set friend = ##class(Library2.Person).%OpenId(id)
            set check.Friend = friend
            w !,"Book ",check.Title," loaded to ",friend.Name,"."
            //对database中的Book.Friend进行更新
            set status = check.%Save()
        }
    }
    return $$$OK
}

/// returns a book from a loan to the library
ClassMethod ReturnBook(id As %String) As %Status
{
    //这里取到的Library2.Person类属性的friend，是此friend在Person类中的id？
    &sql(select friend into :friendID from Library2.Book where id = :id)
    set friend = ##class(Library2.Person).%OpenId(friendID)
    set book = ##class(Library2.Book).%OpenId(id)
    if (friend = ""){
        w !,"This book is not loaned."
        w !,"Please use the LoanBook() method to load it to a friend."
        quit $$$OK
    }
    else{
        w !,"Book returned by ",friend.Name,"."
        set book.Friend = ""
        set status = book.%Save()
        set status = friend.%Save()
    }
    return $$$OK
}

/// how many books are out on loan
ClassMethod GetLoanedBooks() As %Status
{
    &sql(select count(id) into :count from Library2.Book where friend is not null)
    w !,count," books are currently on loan."
}

/// how many books are currently on the shelf, not loaned to friends.
ClassMethod GetShelfBooks() As %Status
{
    &sql(select count(id) into :count from Library2.Book where friend is null)
    w !,count," books are currently on the shelves."
}

/// how many books a friend has borrowed
ClassMethod FriendOwe(friend As %String) As %Status
{
    &sql(select id into :id from Library2.Person where Name = :friend)
    &sql(select count(*) into :count from Library2.Book where friend = :id)
    w !,friend," currently has ",count," books on loan."

}

/// which friend a book is currently on loan to.
ClassMethod GetFriend(id As %String) As %Status
{
    set book = ##class(Library2.Book).%OpenId(id)
    set friend = book.Friend.Name
    if (friend = ""){
        set friend = "no one"
    }
    w !,"This book is currently loaned to",friend,"."
}

}