USE [TrackTheMove]
GO

drop table if exists tblEvent
drop table if exists tblTripInSection
drop table if exists tblSectionOfRoad
drop table if exists tblRoad
drop table if exists tblDatum
drop table if exists tblTrip
drop table if exists tblAssociateTo
drop table if exists tblDriver
drop table if exists tblFuelVehicle
drop table if exists tblElectricVehicle 
drop table if exists tblSensor
drop table if exists tblVehicle
drop table if exists tblOilType
drop table if exists tblManufacturer
drop table if exists tblVehicleFleet
go



create table tblVehicleFleet(
fleetNo smallint identity (1,1) primary key, 
establishDate date default getdate(),
--(N-צפון, H-חיפה, T-תל אביב, C-מרכז, J-ירושלים, S-דרום, Y-יהודה ושומרון)
district char(1) not null check (district in ('N', 'H', 'T', 'C', 'J', 'S', 'Y'))
)

create table tblManufacturer(
manufacturerNo int primary key, 
manufacturerName varchar(30) not null)

create table tblOilType(
oilName varchar(20) primary key)

create table tblVehicle(
licensePlate char(8) primary key check  (licensePlate like replicate('[0-9]',8)),
manufactureYear smallint check (manufactureYear>1950 and manufactureYear<=year(getdate())), 
airPressure float check (airPressure>0), 
noOfSeats tinyint check (noOfSeats>0), 
--(A-אופנועים , B-רכב עד 3.5 טון ועד 8 נוסעים , C-רכב משא עד 12 טון , D-הסעת נוסעים מוניות ואוטובוסים) 
licenseType char(1) check (licenseType in('A', 'B', 'C', 'D')),
fleeNo smallint not null foreign key references tblVehicleFleet(fleetNo) on update cascade, 
manufacturerNo int foreign key references tblManufacturer(manufacturerNo) on update cascade)

create table tblSensor(
sensorNo int primary key check (sensorNo>0), 
producationDate date check (year(producationDate)>1980 and producationDate<=getdate()), 
licensePlate char(8) foreign key references tblVehicle (licensePlate),
installationDate date check (installationDate<=getdate()), 
check (producationDate<installationDate))

create table tblElectricVehicle (
licensePlate char(8) primary key foreign key references tblVehicle (licensePlate) on delete cascade on update cascade,
batterySize smallint check (batterySize>0),
KMperBattary smallint check (KMperBattary>0))

create table tblFuelVehicle (
licensePlate char(8) primary key foreign key references tblVehicle (licensePlate) on delete cascade on update cascade,
--(G-אוקטן05-95, אוקטן06-96, אוקטן08-98, גז)
fuelType char(2) check (fuelType in('G','O8', 'O6', 'O5')), 
oilName varchar(20) foreign key references tblOilType(oilName))

create table tblDriver(
ID char(9) primary key  check  (ID like replicate('[0-9]',9)), 
drivingLicense int unique not null check(drivingLicense>0), 
firstName varchar(30) not null, 
lastName varchar(30) not null,
--(A-אופנועים , B-רכב עד 3.5 טון ועד 8 נוסעים , C-רכב משא עד 12 טון , D-הסעת נוסעים מוניות ואוטובוסים)
licenseType char(1) check (licenseType in('A', 'B', 'C', 'D')), 
dateOfbirth date check (year(dateOfbirth)>1920 and datediff(year, dateOfbirth, getdate())>=18), 
picture varbinary)

create table tblAssociateTo(
licensePlate char(8) foreign key references tblVehicle (licensePlate) on delete cascade on update cascade,
ID char(9) foreign key references tblDriver(ID) on delete cascade on update cascade,
associationDate date check (year(associationDate)>1980 and associationDate<=getdate()), 
primary key (licensePlate, ID))

create table tblTrip(
tripNo int primary key,
startDate datetime not null default getdate(), 
EndDate datetime, 
NoOfKM smallint check (NoOfKM>0), 
avgSpeed float check (avgSpeed>0),
licensePlate char(8), 
ID char(9), 
check ((startDate<=EndDate) or endDate is null),
foreign key (licensePlate, ID) references tblAssociateTo(licensePlate, ID))

create table tblDatum(
datumNo bigint primary key,
speed float check (speed>0),
longitude float, 
latitude float, 
airPressure float check (airPressure>0), 
engineTemp tinyint check (engineTemp>0),
powerPrecentage float check (powerPrecentage>0), 
noOfKm smallint check (noOfKm>0), 
outsideTemp smallint,
tripNo int not null foreign key references tblTrip(tripNo) on delete cascade on update cascade)

create table tblRoad(
roadNo int primary key,
roadName varchar(30) not null, 
--(C-כביש ארצי ראשי , M-כביש ראשי , D-כביש מחוזי , L-כביש מקומי)
roadType char(1) check (roadType in('C', 'M', 'D', 'L')))

create table tblSectionOfRoad(
roadNo int foreign key references tblRoad(roadNo) on delete cascade on update cascade, 
sectionNo tinyint check (sectionNo>=0), 
speedLimit smallint check (speedLimit>=0), 
startPoinLongitude float,
startPointLatitude float, 
endPointLongitude float, 
endPointLatitude float, 
primary key(roadNo, sectionNo))

create table tblTripInSection(
tripNo int foreign key references tblTrip(tripNo) on delete cascade on update cascade,
roadNo int , 
sectionNo tinyint,
foreign key (roadNo, sectionNo) references tblSectionOfRoad (roadNo,sectionNo) on update cascade on delete cascade, 
primary key(tripNo,roadNo, sectionNo))

create table tblEvent(
eventNo bigint primary key,
eventDateTime datetime check (year(eventDateTime)>1980 and eventDateTime<=getdate()) default getdate(), 
longitude float, 
latitude float,
--(A-תאונה , D-סטייה מנתיב , S-האצה רגעית ,B-עצירת פתע )
eventType char(1) check (eventType in ('A', 'D', 'S', 'B')),
severityGrade tinyint check(severityGrade between 1 and 5), 
tripNo int not null,
roadNo int not null,
sectionNo tinyint not null, 
foreign key (tripNo, roadNo, sectionNo) references tblTripInSection(tripNo,roadNo,sectionNo) on update cascade on delete cascade)

go