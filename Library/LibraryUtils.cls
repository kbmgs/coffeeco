Class Library.LibraryUtils Extends %RegisteredObject
{

ClassMethod AddBook() As %Status
{
	// Create an object in which to store the book
    set book = ##class(Library.Book).%New()

	// Get the Book's Title
	read #!!,"Please enter the book title: ",name
	set book.Title = name
	
	// Get the Author's Name
	read !,"Please enter the name of the author: ",author
	// Check if this author exists and add to the object
	&sql(SELECT id INTO :id FROM library.person WHERE Name = :author)
	if (id '= ""){
		set book.Author = ##class(Library.Person).%OpenId(id)
	}
	else{
		// If not, create  this object's Author
		set newAuthor = ##class(Library.Person).%New()
		set newAuthor.Name = author
		set statusPerson = newAuthor.%Save()
		set book.Author = newAuthor
		set status = book.%Save()
	}

    // Get the Genre
	read !,"Please enter a 1 for Non-Fiction or a 2 for Fiction: ",genre
	if genre = "1" {
		set book.Genre = "NonFiction"
	}
	else{
		set book.Genre = "Fiction"
	}

	// Save the book to the database
	set status = book.%Save()
	
	// Return a status message of OK once complete
	return status
}

// This Method, AddFriend adds a friend 

ClassMethod AddFriend() As %Status
{
	// Create an object in which to store the name
	set friend = ##class(Library.Person).%New()
	
	// Get and store the name
	read #!!,"Please enter the name of your new friend: ",name
	set friend.Name = name
	
	// Get and store the phone number
	read #!!,"Please enter the phone number of your new friend: ",phoneNum
	set friend.PhoneNumber = phoneNum

	// Save the object and return the status
	set status = friend.%Save()
	return status
}

// This Method prints out one item in the database

// This Method prints out one item in the database

ClassMethod PrintOne(id As %String) As %Status
{
	// Open the book based on the ID given
	set book = ##class(Library.Book).%OpenId(id)

	// Write information about the book using the opened object
	write !,"This book is called ", book.Title," and was written by ", book.Author.Name,"."
	write !,"This is a ",book.Genre," book."

	// Check if the book is on loan or not and return that to the user
	if book.Friend = ""{
		write !,"This book is currently in the library."
	}
	else{
		write !,"This book is currently on loan to ",book.Friend.Name,"." 
	}

	// Return a simple status of $$$OK 
	return $$$OK
}

// This method prints all items from teh database

ClassMethod PrintAll() As %Status
{
	&sql(select count(*) INTO :count from library.book)
	// Iterate through all books
	set id = 1
	WHILE (id <= count) {
		// This write will create a separator and give the user a correlation between book and ID
		write !,"Book at ID ",id, ": "
		do ##class(Library.LibraryUtils).PrintOne(id)
		set id = id + 1
	}
	return $$$OK
}

// This Method, LoanBook, loans a book to a friend

ClassMethod LoanBook(bookID As %String, friend As %String) As %Status
{
	// Open the book object
	set check = ##class(Library.Book).%OpenId(bookID)
	
	// If not empty, tell the user it is currently on loan and point them to ReturnBook.  Quit.
	if (check.Friend '= ""){
		write !,"This book is currently on loan.",!,"Please use the ReturnBook method to return the book before loaning it to a new friend."
		quit $$$OK
	}
	else{
		&sql(SELECT id INTO :id FROM library.person WHERE name = :friend)
		if (id = ""){
			write !,"This friend is not registered.",!,"Please use the AddFriend method to add a new friend."
		quit $$$OK
		}
		
		else{
			set friend = ##class(Library.Person).%OpenId(id)
			set check.Friend = friend  
			write !,"Book loaned to ",friend.Name,"."
			set status = check.%Save()
		}
	}
	return $$$OK
}

// This Method, ReturnBook, returns a book from a loan to the library

ClassMethod ReturnBook(id As %String) As %Status
{
	&sql(SELECT friend into :friendID FROM library.book WHERE id=:id)
	set friend = ##class(Library.Person).%OpenId(friendID)
	set book = ##class(Library.Book).%OpenId(id)
	if friend = ""{
		write !,"This book is not loaned.",!,"Please use the LoanBook() method to loan it to a friend."
		quit $$$OK
	}
	else{
		write !, "Book returned by ", friend.Name, "."
		set book.Friend = ""
		set status = book.%Save()
		set status = friend.%Save()
	}
	return $$$OK
}

// This Method, GetLoanedBooks, will tell you how many books are out on loan

ClassMethod GetLoanedBooks() As %Status
{
	&sql(SELECT count(id) INTO :count FROM library.book WHERE friend IS NOT NULL)
	write !, count, " books are currently on loan."
}

// This Method, GetShelfBooks, will return how many books are currently on the shelf, not loaned to friends.

ClassMethod GetShelfBooks() As %Status
{
	&sql(SELECT count(id) INTO :count FROM library.book WHERE friend IS NULL)
	write !, count, " books are currently on the shelves."
}

// This Method, FriendOwe, tells you how many books a friend has borrowed

ClassMethod FriendOwe(friend As %String) As %Status
{
	&sql(SELECT id INTO :id FROM library.person WHERE Name = :friend)
	&sql(SELECT count(*) INTO :count FROM library.book WHERE friend = :id)
	write !, friend, " currently has ", count, " books on loan."
}

// This Method, GetFriend, will return which friend a book is currently on loan to.

ClassMethod GetFriend(id As %String) As %Status
{
	set book = ##class(Library.Book).%OpenId(id)
	set friend = book.Friend.Name
	if (friend = ""){
		set friend = "no one"
	}
	write !,"This book is currently loaned to ",friend,"."
}

}
