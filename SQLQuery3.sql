Create Database HotelProject

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
    FOREIGN KEY (GuestID) REFERENCES Guest(GuestID),
    FOREIGN KEY (HotelID) REFERENCES Hotel(HotelID)
);


