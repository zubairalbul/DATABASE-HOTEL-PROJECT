Create Database HotelProject
--Part1 of the project:
Use HotelProject

Create Table Hotel(
HotelID INT PRIMARY KEY Identity (1,1),
HName VARCHAR(30) NOT NULL,
Location VARCHAR(30) NOT NULL,
HNumber VARCHAR(30),
HRating Decimal(2, 1)
);

CREATE TABLE Room (
    RoomID INT PRIMARY KEY identity(1, 1),
    RoomNumber VARCHAR(10) NOT NULL,
    Type VARCHAR(50),
    PricePerNight DECIMAL(10, 2),
    AvailabilityStatus VARCHAR(50),
    HotelID INT,
    FOREIGN KEY (HotelID) REFERENCES Hotel(HotelID)
);

CREATE TABLE Guest (
    GuestID INT PRIMARY KEY identity(1, 1),
    Name VARCHAR(100) NOT NULL,
    Contact VARCHAR(15),
    IDProof VARCHAR(50)
);

Alter Table Guest
Add  IDProofType Varchar(30)

CREATE TABLE Booking (
    BookingID INT PRIMARY KEY identity(1, 1),
    BookingDate DATE,
    CheckInDate DATE,
    CheckOutDate DATE,
    Status VARCHAR(50),
    TotalCost DECIMAL(10, 2),
    RoomID INT,
    GuestID INT,
    FOREIGN KEY (RoomID) REFERENCES Room(RoomID),
    FOREIGN KEY (GuestID) REFERENCES Guest(GuestID)
);


CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY identity(1, 1),
    Date DATE,
    Amount DECIMAL(10, 2),
    Method VARCHAR(50),
    BookingID INT,
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID)
);

CREATE TABLE Staff (
    StaffID INT PRIMARY KEY identity(1, 1),
    Name VARCHAR(100) NOT NULL,
    Position VARCHAR(50),
    ContactNumber VARCHAR(15),
    HotelID INT,
    FOREIGN KEY (HotelID) REFERENCES Hotel(HotelID)
);

CREATE TABLE Review (
    ReviewID INT PRIMARY KEY identity(1, 1),
    Rating DECIMAL(2, 1),
    Comments TEXT,
    Date DATE,
    GuestID INT,
    HotelID INT,
    Foreign Key (GuestID) References Guest(GuestID),
    FOREIGN KEY (HotelID) References Hotel(HotelID)
);


--Part 2 of The Project

-- Add a non-clustered index on the Name column
Create NonClustered Index idx_Hotel_Name
ON Hotel (HName);

-- Add a non-clustered index on the Rating column
Create NonClustered Index idx_Hotel_Rating
On Hotel (HRating);

-- Add a non-clustered index on the Name column
Create NonClustered Index idx_RoomNumber
ON Room (RoomNumber, HotelID);

-- Add a non-clustered index on the Rating column
Create NonClustered Index idx_Room_Type
On Room (Type);

-- Add a non-clustered index on GuestID
Create NonClustered Index idx_Booking_GuestID
ON Booking (GuestID);

-- Add a non-clustered index on Status
Create NonClustered Index idx_Booking_Status
ON Booking (Status);

-- Add a composite index on RoomID, CheckInDate, and CheckOutDate
Create NonClustered Index idx_Booking_RoomID
ON Booking (RoomID, CheckInDate, CheckOutDate);
  

-- For Views:

Create View ViewTopRatedHotels As
Select 
    H.HotelId,
    H.HName As HotelName,
    H.HRating,
    Count(R.RoomId) As TotalRooms,
    Avg(R.PricePerNight) As AverageRoomPrice
From 
    Hotel H
Join 
    Room R On H.HotelId = R.HotelId
Where 
    H.HRating > 4.5
Group By 
    H.HotelId, H.HName, H.HRating;

Create View ViewGuestBookings As
Select 
    G.GuestId,
    G.Name As GuestName,
    Count(B.BookingId) As TotalBookings,
    Sum(B.TotalCost) As TotalAmountSpent
From 
    Guest G
Left Join 
    Booking B On G.GuestId = B.GuestId
Group By 
    G.GuestId, G.Name;

Alter View ViewAvailableRooms As
Select 
top 100
    H.HName As HotelName,
    R.Type As RoomType,
    Count(R.RoomId) As NumberOfRooms,
    Avg(R.PricePerNight) As AveragePricePerNight,
    Min(R.RoomId) As MinRoomId  -- Added to maintain stable sorting
From 
    Room R
Join 
    Hotel H On R.HotelId = H.HotelId
Where 
    R.AvailabilityStatus = '1'
Group By 
    H.HName, R.Type
Order By 
    AveragePricePerNight, MinRoomId; -- Stable sort order

Select * from ViewAvailableRooms

Update Room set PricePerNight =90 where RoomNumber =201


--Booking Summary
Create View ViewBookingSummary As
Select 
    H.HotelId,
    H.HName As HotelName,
    Count(B.BookingId) As TotalBookings,
    Sum(Case When B.Status = 'Confirmed' Then 1 Else 0 End) As ConfirmedBookings,
    Sum(Case When B.Status = 'Pending' Then 1 Else 0 End) As PendingBookings,
    Sum(Case When B.Status = 'Canceled' Then 1 Else 0 End) As CanceledBookings
From 
    Hotel H
Left Join 
    Room R On H.HotelId = R.HotelId
Left Join 
    Booking B On R.RoomId = B.RoomId
Group By 
    H.HotelId, H.HName;

--PaymentHistory
Create View ViewPaymentHistory As
Select 
    P.PaymentId,
    P.Date As PaymentDate,
    P.Amount,
    P.Method As PaymentMethod,
    G.Name As GuestName,
    H.HName As HotelName,
    B.Status As BookingStatus,
    Sum(P.Amount) Over (Partition By B.BookingId) As TotalPayment
From 
    Payment P
Join 
    Booking B On P.BookingId = B.BookingId
Join 
    Guest G On B.GuestId = G.GuestId
Join 
    Room R On B.RoomId = R.RoomId
Join 
    Hotel H On R.HotelId = H.HotelId;



--Functions 
Create Function AverageRating (@HotelId Int)
Returns Decimal(3, 2)
As
Begin
    Declare @AverageRating Decimal(3, 2)

    Select @AverageRating = Avg(Rating)
    From Review
    Where HotelId = @HotelId

    Return @AverageRating
End

Create Function GetNextAvailableRoom (@HotelId Int, @RoomType VarChar(50))
Returns Int
As
Begin
    Declare @RoomId Int

    Select Top 1 @RoomId = RoomId
    From Room
    Where HotelId = @HotelId And Type = @RoomType And AvailabilityStatus = 'Available'
    Order By RoomNumber

    Return @RoomId
End

Create Function CalculateOccupancyRate (@HotelId Int)
Returns Decimal(5, 2)
As
Begin
    Declare @TotalRooms Int
    Declare @OccupiedRooms Int
    Declare @OccupancyRate Decimal(5, 2)

    Select @TotalRooms = Count(*)
    From Room
    Where HotelId = @HotelId

    Select @OccupiedRooms = Count(Distinct B.RoomId)
    From Booking B
    Join Room R On B.RoomId = R.RoomId
    Where R.HotelId = @HotelId And B.CheckInDate >= DateAdd(Day, -30, GetDate())

    If @TotalRooms = 0
    Begin
        Return 0
    End

    Set @OccupancyRate = Cast(@OccupiedRooms As Decimal(5, 2)) / @TotalRooms * 100

    Return @OccupancyRate
End

--Storing

Create Procedure sp_UnavailableRoom
    @BookingId Int
As
Begin
    Declare @RoomId Int;

    -- Get the RoomId associated with the booking
    Select @RoomId = RoomId
    From Booking
    Where BookingId = @BookingId;

    -- Update the Room's availability status to 'Unavailable'
    Update Room
    Set AvailabilityStatus = 'Unavailable'
    Where RoomId = @RoomId;
End;

Create Procedure sp_UpdateStatus
    @BookingId Int,
    @NewStatus VarChar(50)
As
Begin
    -- Update the Booking status
    Update Booking
    Set Status = @NewStatus
    Where BookingId = @BookingId;

    -- Additional logic to handle status updates can be added here
    -- For example, updating room availability if status is 'Check-in' or 'Canceled'
    If @NewStatus = 'Check-in'
    Begin
        Update Room
        Set AvailabilityStatus = 'Unavailable'
        Where RoomId = (Select RoomId From Booking Where BookingId = @BookingId);
    End
    Else If @NewStatus = 'Canceled'
    Begin
        Update Room
        Set AvailabilityStatus = 'Available'
        Where RoomId = (Select RoomId From Booking Where BookingId = @BookingId);
    End;
End;


Create Procedure sp_RankGuests
As
Begin
    Select 
        G.GuestId,
        G.Name As GuestName,
        Sum(B.TotalCost) As TotalSpending,
        Rank() Over (Order By Sum(B.TotalCost) Desc) As SpendingRank
    From 
        Guest G
    Join 
        Booking B On G.GuestId = B.GuestId
    Group By 
        G.GuestId, G.Name
    Order By 
        TotalSpending Desc;
End;


--Triggers

Create Trigger UpdateRoomAvailability
On Booking
After Insert
As
Begin
    Update Room
    Set AvailabilityStatus = 'Unavailable'
    From Room R
    Join Inserted I On R.RoomId = I.RoomId;
End;


Alter Table Hotel
Add TotalRevenue Decimal(10, 2) Default 0;
Create Trigger TotalRevenue
On Payment
After Insert
As
Begin
    Update Hotel
    Set TotalRevenue = TotalRevenue + I.Amount
    From Hotel H
    Join Room R On H.HotelId = R.HotelId
    Join Booking B On R.RoomId = B.RoomId
    Join Inserted I On B.BookingId = I.BookingId;
End;


Alter Table Hotel
Add TotalRevenue Decimal(10, 2) Default 0;



Alter Trigger CheckInDateValidation
On Booking
Instead Of Insert
As
Begin
    If Exists (Select 1 From Inserted Where CheckInDate > CheckOutDate)
    Begin
        RaisError ('Check-in date cannot be greater than check-out date.', 16, 1);
        Rollback Transaction;
    End
    Else
    Begin
        -- Insert the valid records into the Booking table
        Insert Into Booking (BookingID, BookingDate, CheckInDate, CheckOutDate, Status, TotalCost, RoomID, GuestID)
        Select BookingID, BookingDate, CheckInDate, CheckOutDate, Status, TotalCost, RoomID, GuestID
        From Inserted;
    End
End;