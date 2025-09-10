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
    Mileage INT,
    OwnerCount Int,
    ListingDate Date,
    IsActive BOOLEAN,
    ClosingDate Date,
    Price INT,

    Foreign Key (DealerID) References DEALER(DealerID),
    Foreign Key (ModelID) References MODEL(ModelID)
);

-------------------------------------------------------- Queries

-- Stok Devir Suresi (Sadece tamamlanmis listenmeler icin hesaplanmistir)

with stock_turn_rates as (
    select 
        ListingID,
        ntile(10) over (order by Mileage) as KM_Quantile_Group,
        DateDiff(day, ListingDate, ClosingDate) as StockTurnRate
    from LISTING 
    where IsActive = 0 and ClosingDate is not null
),

brand_based_stock_turn_rates as (
    select 
        m.BrandID,
        avg(str.StockTurnRate) as Brand_AVG_STR,
        max(str.StockTurnRate) as Brand_MAX_STR,
    from LISTING l
    join stock_turn_rates str on l.ListingId = str.ListingID
    join MODEL m on l.ModelId = m.ModelID
    where IsActive = 0
    group by m.BrandID
),

brand_and_mileage_group_based_str as (
    select 
        m.BrandID,
        str.KM_Quantile_Group,
        avg(str.StockTurnRate) as Brand_KM_AVG_STR,
        max(str.StockTurnRate) as Brand_KM_MAX_STR,
    from LISTING l
    join stock_turn_rates str on l.ListingId = str.ListingID
    join MODEL m on l.ModelId = m.ModelID
    where IsActive = 0
    group by m.BrandID, str.KM_Quantile_Group
)


-- Marka bazinda ortalama ve maksimum stok devir sureleri 
select * from brand_based_stock_turn_rates;

-- Marka ve KM bazinda olusturulan gruplarin ort. ve maks. stok devir sureleri

    -- Ozet Tablo
    select * from brand_and_mileage_group_based_str;

    -- Her bir listeleme icin join
    select
        l.*,
        m.BrandID,
        bm.Brand_KM_AVG_STR,
        bm.Brand_KM_MAX_STR
    from (
        select 
            *,
            ntile(10) over(order by Mileage) as KM_Quantile_Group
        from Listing
        where IsActive = 0 and ClosingDate is not null
    ) as l
    join MODEL m 
        on l.modelID = m.ModelID
    join brand_and_mileage_group_based_str bm_str 
        on m.BrandID = bm_str.brandID
        and l.KM_Quantile_Group = bm.KM_Quantile_Group