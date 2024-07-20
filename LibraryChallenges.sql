/******************* In the Library *********************/

/*******************************************************/
/* find the number of availalbe copies of the book (Dracula)      */
/*******************************************************/

"""
SELECT ( 
(SELECT COUNT(*) as "Num copies of the book (Dracula)" FROM books
WHERE Title = "Dracula")
-
(SELECT count(*) FROM loans as L
INNER JOIN books as b ON L.BookID = b.BookID
WHERE b.Title = "Dracula" AND ReturnedDate IS NULL)
) AS "availalbe copies of the book (Dracula)";

"""

/* check total copies of the book */

"""
use library;
SELECT COUNT(*) as "Num copies of the book (Dracula)" FROM books
WHERE Title = "Dracula"

"""

/* current total loans of the book */
"""
use library;
SELECT COUNT(*) as Total_Loans  FROM loans as L
INNER JOIN books as b ON L.BookID = b.BookID
WHERE b.Title = "Dracula"

"""

/* total available books of dracula */

"""
SELECT ( 
(SELECT COUNT(*) as "Num copies of the book (Dracula)" FROM books
WHERE Title = "Dracula")
-
(SELECT count(*) FROM loans as L
INNER JOIN books as b ON L.BookID = b.BookID
WHERE b.Title = "Dracula" AND ReturnedDate IS NULL)
) AS "availalbe copies of the book (Dracula)";

"""


/*******************************************************/
/* Add new books to the library                        */
/*******************************************************/

"""
INSERT INTO books (BookID ,Title , Author , Published , Barcode ) Values
(201,"to infinity and beyond","Eslam","1996","45645623415")
(202,"Bedtime Stories For Stressed Out Adults","Lucy Mangan","2001","455645648558")

"""

/*******************************************************/
/* Check out Books: books(4043822646, 2855934983) whose patron_email(jvaan@wisdompets.com), loandate=2020-08-25, duedate=2020-09-08, loanid=by_your_choice                            */
/*******************************************************/
"""

INSERT INTO loans (LoanID, BookID, PatronID , loandate , duedate) VALUES 
(20001, 
(SELECT BookID FROM books
WHERE Barcode = 4043822646),
(SELECT PatronID FROM patrons
WHERE Email = 'jvaan@wisdompets.com'),
"2020-08-25",
"2020-09-08"
),
(
20002, 
(SELECT BookID FROM books
WHERE Barcode = 2855934983),
(SELECT PatronID FROM patrons
WHERE Email = 'jvaan@wisdompets.com'),
"2020-08-25",
"2020-09-08"
)


"""


/********************************************************/
/* Check books for Due back                             */
/* generate a report of books due back on July 13, 2020 */
/* with patron contact information                      */
/********************************************************/
"""

SELECT * FROM Loans AS l
INNER JOIN patrons AS p ON l.PatronID = p.PatronID
WHERE l.DueDate = "2020-07-13"

"""

/*******************************************************/
/* Return books to the library (which have barcode=6435968624) and return this book at this date(2020-07-05)                    */
/*******************************************************/
"""
CREATE VIEW Target_Loanid AS (
SELECT LoanID as lon_id FROM loans 
WHERE ReturnedDate Is NULL And BookID = (
SELECT BookID FROM books
WHERE barcode = 6435968624
)
);

UPDATE loans as l
INNER JOIN Target_Loanid AS t
SET l.ReturnedDate = "2020-07-05"
WHERE l.LoanID = t.lon_id



"""


/*******************************************************/
/* Encourage Patrons to check out books                */
/* generate a report of showing 10 patrons who have
checked out the fewest  .                          */
/*******************************************************/
"""
SELECT l.PatronID , p.FirstName , p.LastName , p.Email , Count(l.PatronID) as TimesOfVisits FROM loans as l
INNER JOIN patrons as p ON l.PatronID = p.PatronID
GROUP BY l.PatronID
order by TimesOfVisits
LIMIT 10

"""

/*******************************************************/
/* Find books to feature for an event                  
 create a list of books from 1890s that are
 currently available                                    */
/*******************************************************/
"""
CREATE VIEW NumpberOFCopies AS (
SELECT Title  , COUNT(Title) as "Num_copies" FROM books
GROUP BY Title
);

CREATE VIEW NumOFNonReturnedC AS (
SELECT b.Title ,Count(b.Title) as CountofNon FROM books AS b
INNER JOIN loans AS l ON b.BookID = l.BookID
INNER JOIN NumpberOFCopies AS n on n.Title = b.Title
WHERE (Published between 1890 and 1899)  AND ReturnedDate IS NULL
group by b.Title
);

SELECT distinct(b.Title) as ListOFBooks , b.Author , b.Published FROM books AS b
INNER JOIN loans AS l ON b.BookID = l.BookID
INNER JOIN NumpberOFCopies AS n ON n.Title = b.Title
INNER JOIN NumOFNonReturnedC AS non ON non.Title = b.Title
WHERE (Published between 1890 and 1899) and n.Num_copies > non.CountofNon 
"""

/*******************************************************/
/* Book Statistics                                      */
/* create a report to show how many books were 
published each year.                                    */
/*******************************************************/

"""
SELECT Published, COUNT(DISTINCT(Title)) AS TotalNumberOfPublishedBooks
FROM Books
GROUP BY Published
ORDER BY TotalNumberOfPublishedBooks DESC;
"""

/*************************************************************/
/* Book Statistics                                           */
/* create a report to show 5 most popular Books to check out */
/*************************************************************/
"""
SELECT b.Title , COUNT(l.LoanID) AS TotalTimesOfLoans FROM books as b
INNER JOIN loans as l ON l.BookID = b.BookID
GROUP BY b.Title 
ORDER BY TotalTimesOfLoans DESC
LIMIT 5;

"""