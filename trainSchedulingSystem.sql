-- --------------- --
-- Create Database --
-- --------------- --
DROP DATABASE IF EXISTS trainScheduleSystem; 
CREATE DATABASE trainScheduleSystem; 
USE trainScheduleSystem;


-- ------------- --
-- Create Tables --
-- ------------- --
CREATE TABLE `Track`(
    `TrackID` INTEGER NOT NULL,
    `Condition` VARCHAR(255) NOT NULL CHECK (`Condition` IN ('available','unavailable')),
    `Length` INTEGER NOT NULL,
    PRIMARY KEY (`TrackID`)
);

CREATE TABLE `Station`(
    `StationID` INTEGER NOT NULL,
    `StationName` VARCHAR(255) NOT NULL,
    `Location` VARCHAR(255) NOT NULL,
    `Description` TEXT,
    PRIMARY KEY (`StationID`)
);

CREATE TABLE `Route`(
    `RouteID` INTEGER NOT NULL,
    `OriginID` INTEGER NOT NULL,
    `DestinationID` INTEGER NOT NULL,
    `TrackID` INTEGER NOT NULL,
    `DepartureTime` TIME NOT NULL CHECK (`DepartureTime` >= '00:00:00' AND `DepartureTime` <= '24:00:00'),
    `ArrivalTime` TIME NOT NULL CHECK (`ArrivalTime` >= '00:00:00' AND `ArrivalTime` <= '24:00:00'),
    PRIMARY KEY (`RouteID`),
    FOREIGN KEY (`OriginID`) REFERENCES `Station` (`StationID`),
	FOREIGN KEY (`DestinationID`) REFERENCES `Station` (`StationID`),
    FOREIGN KEY (`TrackID`) REFERENCES `Track` (`TrackID`)
);

CREATE TABLE `Schedule`(
    `ScheduleID` INTEGER NOT NULL,
    `StartTime` TIME NOT NULL CHECK (`StartTime` >= '00:00:00' AND `StartTime` <= '24:00:00'),
    `EndTime` TIME NOT NULL CHECK (`EndTime` >= '00:00:00' AND `EndTime` <= '24:00:00'),
    PRIMARY KEY (`ScheduleID`)
);

CREATE TABLE `ScheduleRoute`(
	`ScheduleID` INTEGER NOT NULL,
    `RouteID` INTEGER NOT NULL,
    FOREIGN KEY (`ScheduleID`) REFERENCES `Schedule` (`ScheduleID`),
	FOREIGN KEY (`RouteID`) REFERENCES `Route` (`RouteID`)
);

CREATE TABLE `Train`(
	`TrainID` INTEGER NOT NULL,
    `ScheduleID` INTEGER NOT NULL,
    `MaxCapacity` INTEGER NOT NULL CHECK (`MaxCapacity` >= 0),
    `NumOfCarriages` INTEGER NOT NULL CHECK (`NumOfCarriages` >= 0),
    PRIMARY KEY (`TrainID`),
    FOREIGN KEY (`ScheduleID`) REFERENCES `Schedule` (`ScheduleID`)
);

CREATE TABLE `Passenger`(
    `PassengerID` VARCHAR(9) NOT NULL,
    `TrainID` INTEGER NOT NULL,
    `Fname` VARCHAR(255),
    `Lname` VARCHAR(255),
    `BDate` DATE,
    PRIMARY KEY (`PassengerID`),
    FOREIGN KEY (`TrainID`) REFERENCES `Train` (`TrainID`)
);

CREATE TABLE `Conductor`(
    `PPSNo` VARCHAR(9) NOT NULL CHECK (`PPSNo` REGEXP '[1-9][0-9][0-9][0-9][0-9][0-9][0-9][A-Z][A-Z]?'),
    `TrainID` INTEGER NOT NULL,
    `Fname` VARCHAR(255) NOT NULL,
    `Lname` VARCHAR(255) NOT NULL,
    `BDate` DATE NOT NULL,
    `PhoneNo` VARCHAR(15) NOT NULL,
    PRIMARY KEY (`PPSNo`),
    FOREIGN KEY (`TrainID`) REFERENCES `Train` (`TrainID`)
);



-- ----------- --
-- Alter Table --
-- ----------- --
ALTER TABLE `Conductor`
MODIFY COLUMN `PhoneNo` VARCHAR(20);



-- ------------------ --
-- Trigger Operations --
-- ------------------ --
DROP TRIGGER IF EXISTS `PassengerTrigger`;

delimiter //
    CREATE TRIGGER `PassengerTrigger` BEFORE INSERT ON `Passenger`
    FOR EACH ROW BEGIN
      IF (NEW.`Fname` IS NULL) THEN
            SET NEW.`Fname` = 'Unknown';
      END IF;
      IF (NEW.`Lname` IS NULL) THEN
            SET NEW.`Lname` = 'Unknown';
      END IF;
    END; //
delimiter ;

DROP TRIGGER IF EXISTS `TrainTrigger`;

delimiter //
    CREATE TRIGGER `TrainTrigger` BEFORE INSERT ON `Train`
    FOR EACH ROW BEGIN
      IF (NEW.`MaxCapacity` < 0) THEN
            SET NEW.`MaxCapacity` = 0;
      END IF;
      IF (NEW.`NumOfCarriages` < 0) THEN
            SET NEW.`NumOfCarriages` = 0;
      END IF;
    END; //
delimiter ;

DROP TRIGGER IF EXISTS `TrackTrigger`;

delimiter //
    CREATE TRIGGER `TrackTrigger` BEFORE INSERT ON `Track`
    FOR EACH ROW BEGIN
      IF (NEW.`Length` < 0) THEN
            SET NEW.`Length` = 0;
      END IF;
	  IF (NEW.`Condition` NOT IN ('available','unavailable')) THEN
            SET NEW.`Condition` = 'unavailable';
      END IF; 
    END; //
delimiter ;
    

-- ----------- --
-- Insert Data --
-- ----------- --
INSERT INTO `Track` (`TrackID`, `Condition`, `Length`)
VALUES 
	(1, 'available', 10),
    (2, 'available', 11),
    (3, 'available', 3),
    (4, 'available', 1),
    (5, 'available', 4),
    (6, 'under repair jhkg', 5),
    (7, 'available', 20);
    
INSERT INTO `Station` (`StationID`, `StationName`, `Location`, `Description`)
VALUES
	(1, 'Heuston Station', 'Dublin', 'Very Busy, in the city, near hospital'),
    (2, 'Connolly Station', 'Dublin', 'Very Busy, in the city, near bus station'),
    (3, 'Tara Street Station', 'Dublin', 'Very Busy, in the city centre, near the river liffey'),
    (4, 'Pearse Street Station', 'Dublin', 'Very Busy, in the city, near Trinity College'),
    (5, 'Greystones Station', 'Wicklow', NULL);
    
INSERT INTO `Route` (`RouteID`, `OriginID`, `TrackID`, `DestinationID`, `DepartureTime`, `ArrivalTime`)
VALUES
	(1, 1, 1, 2, '12:00:00','12:12:00'),
    (2, 2, 2, 3, '12:12:00','12:25:00'),
    (3, 3, 3, 4, '12:25:00','12:30:00'),
    (4, 1, 4, 5, '9:00:00', '9:30:00'),
    (5, 4, 3, 3, '12:30:00', '12:35:00'),
    (6, 3, 2, 2, '12:35:00', '12:48:00'),
    (7, 2, 1, 1, '12:48:00', '13:00:00'),
    (8, 4, 5, 1, '20:30:00', '21:00:00'),
    (9, 4, 7 ,2, '16:30:00', '16:50:00');
    
INSERT INTO `Schedule` (`ScheduleID`, `StartTime`, `EndTime`)
VALUES
	(1, '12:00:00', '12:30:00'),
    (2, '9:00:00', '9:30:00'),
    (3, '12:30:00', '13:00:00'),
    (4, '20:30:00', '21:00:00'),
    (5, '16:30:00', '16:50:00');

INSERT INTO `Train` (`TrainID`, `ScheduleID`, `MaxCapacity`, `NumOfCarriages`)
VALUES
	(1, 1, 100, 10),
    (2, 2, 100, 10),
    (3, 3, 100, 10),
    (4, 4, 200, 20),
    (5, 5, 150, 15);
    
INSERT INTO `Conductor` (`PPSNo`, `TrainID`, `Fname`, `Lname`, `BDate`, `PhoneNo`)
VALUES
	('1234567AB', 1, 'John', 'Doe', '2000-10-02', '0831231234'),
    ('7654321BA', 2, 'Tom', 'Cruise', '1980-11-02', '0835432121'),
    ('1111222A', 3, 'Bob', 'Hamilton', '1990-07-23', '0851212984'),
    ('3213213P', 4, 'Tom', 'Hiddleston', '2000-08-20', '0867634512'),
    ('2132435Z', 5, 'Tom', 'Jackson', '1999-01-09', '0879236745');
    
INSERT INTO `Passenger` (`PassengerID`, `TrainID`, `Fname`, `Lname`, `BDate`)
VALUES
	(1, 1, NULL, NULL, NULL),
    (2, 1, NULL, NULL, NULL),
    (3, 1, NULL, NULL, NULL),
    (4, 2, 'Tom', 'Thomson', NULL),
    (5, 2, 'Mary', NULL, NULL),
    (6, 3, NULL, NULL, NULL),
    (7, 4, 'Jack', 'Thomson', NULL),
    (8, 4, 'Lisa', 'Thomson', NULL),
    (9, 5, 'Maria', 'Gonzalez', NULL),
    (10, 5, NULL, NULL, NULL),
    (11, 5, NULL, NULL, NULL);

INSERT INTO `ScheduleRoute` (`ScheduleID`,`RouteID`)
VALUES
	(1,1),(1,2),(1,3),
    (2,4),
    (3,5),(3,6),(3,7),
    (4,8),
    (5,9);


-- ------------ --
-- Create Views --
-- ------------ --
CREATE VIEW `StartStations` AS
SELECT DISTINCT `StationID`,`StationName`
FROM `Station`, `Route`
WHERE `StationID` = `Route`.`OriginID`;

CREATE VIEW `EndStations` AS
SELECT DISTINCT `StationID`,`StationName`
FROM `Station`, `Route`
WHERE `StationID` = `Route`.`DestinationID`;

CREATE VIEW `TrainSchedules` AS
SELECT `Train`.`TrainID`, `Schedule`.`StartTime` AS `ScheduleStartTime`, 
		`Schedule`.`EndTime` AS `ScheduleEndTime`, 
		`StartStations`.`StationName` AS `FromStation`, `Route`.`DepartureTime`, 
        `EndStations`.`StationName` AS `ToStation`, `Route`.`ArrivalTime` 
FROM `Train`, `Schedule`, `StartStations`, `EndStations`, `Route`, `ScheduleRoute`
WHERE `Train`.`ScheduleID` = `Schedule`.`ScheduleID` AND
		`Schedule`.`ScheduleID` = `ScheduleRoute`.`ScheduleID` AND
        `ScheduleRoute`.`RouteID` = `Route`.`RouteID` AND
        `Route`.`OriginID` = `StartStations`.`StationID` AND
        `Route`.`DestinationID` = `EndStations`.`StationID`
ORDER BY `TrainID` ASC, `DepartureTime` ASC;
        
        
-- ---------------------- --
-- Retrieving Information --
-- ---------------------- --
-- The following 5 selects get the schedule for a given train
SELECT *
FROM `TrainSchedules`
WHERE `TrainSchedules`.`TrainID` = 1
ORDER BY `TrainID` ASC, `DepartureTime` ASC;

SELECT *
FROM `TrainSchedules`
WHERE `TrainSchedules`.`TrainID` = 2
ORDER BY `TrainID` ASC, `DepartureTime` ASC;

SELECT *
FROM `TrainSchedules`
WHERE `TrainSchedules`.`TrainID` = 3
ORDER BY `TrainID` ASC, `DepartureTime` ASC;

SELECT *
FROM `TrainSchedules`
WHERE `TrainSchedules`.`TrainID` = 4
ORDER BY `TrainID` ASC, `DepartureTime` ASC;

SELECT *
FROM `TrainSchedules`
WHERE `TrainSchedules`.`TrainID` = 5
ORDER BY `TrainID` ASC, `DepartureTime` ASC;


-- -------- --
-- Security --
-- -------- --
DROP ROLE IF EXISTS 'sys_admin', 'conductor', 'passenger';
CREATE ROLE 'sys_admin', 'conductor', 'passenger';

GRANT SELECT ON `trainScheduleSystem`.`TrainSchedules` TO 'passenger', 'conductor';
GRANT SELECT ON `trainScheduleSystem`.`Train` TO 'conductor';
GRANT ALL ON `trainScheduleSystem` TO 'sys_admin';

DROP USER IF EXISTS 'sys_admin1', 'sys_admin2', 'conductor1', 'passenger1';
CREATE USER 'sys_admin1' IDENTIFIED BY '1000';
CREATE USER 'sys_admin2' IDENTIFIED BY '1001';
CREATE USER 'conductor1' IDENTIFIED BY '1002';
CREATE USER 'passenger1' IDENTIFIED BY '1003';

GRANT 'passenger' to 'passenger1';
GRANT 'conductor' to 'conductor1';
GRANT 'sys_admin' to 'sys_admin1';
GRANT 'sys_admin' to 'sys_admin2';

REVOKE ALL PRIVILEGES, GRANT OPTION FROM 'sys_admin';