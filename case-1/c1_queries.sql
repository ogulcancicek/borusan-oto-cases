create table CITY (
    CityID INT PRIMARY KEY,
    CityName VARCHAR(20)
);

create table BRAND (
    BrandID INT PRIMARY KEY,
    BrandName VARCHAR(20)
);

create table DEALER (
    DealerID INT PRIMARY KEY,
    FranchiseDealer BOOLEAN,
    CityID INT,
    ZipCode VARCHAR(10),
    Rating INT,
    Foreign Key (CityID) References CITY(CityID)
);

create table MODEL (
    ModelID INT PRIMARY KEY,
    ModelName VARCHAR(20),
    BrandID INT,

    EngineCylinders VARCHAR(10),
    EngineType VARCHAR(20),
    ExteriorColor VARCHAR(20),
    InteriorColor VARCHAR(20),
    FuelTankVolume INT,
    FuelType ENUM('Gasoline', 'Diesel', 'Electric', 'Hybrid'),
    Height INT,
    Width INT,
    BodyLength INT,
    HorsePower INT,
    ModelYear INT,
    Torque INT,
    Transmission VARCHAR(20),
    
    Foreign Key (BrandID) References BRAND(BrandID)
);

create table LISTING (
    ListingID INT PRIMARY KEY,
    
    DealerID INT,
    ModelID INT,
    
    Fleet BOOLEAN,
    HasAccidents BOOLEAN,
    IsCab BOOLEAN,
    IsCertified BOOLEAN,
    IsCpo BOOLEAN,
    IsOemCpo BOOLEAN,
    IsNew BOOLEAN,
    Mileage INT,
    OwnerCount Int,
    ListedDate Date,
    Price INT,

    Foreign Key (DealerID) References DEALER(DealerID),
    Foreign Key (ModelID) References MODEL(ModelID)
);

------------------------------------------------------------------------ Sorgular

-- Şehir bazlı fiyat dağılımı

select
    c.CityID,
    c.CityName,
    count(*) as N_Listings,
    avg(l.price) as Avg_Price,
    max(l.price) as Max_Price,
    min(l.price) as Min_Price
from LISTING l
join DEALER d on l.DealerID = d.DealerID
join CITY c on d.CityID = c.CityID
group by c.CityID, c.CityName;

-- Marka bazlı fiyat dağılımı

select 
    b.BrandID,
    b.BrandName,
    count(*) as N_Listings,
    avg(l.price) as Avg_Price,
    max(l.price) as Max_Price,
    min(l.price) as Min_Price
from LISTING l
join MODEL m on l.modelID = m.modelID
join BRAND b on m.brandID = b.BrandID
group by b.brandID, b.BrandName;