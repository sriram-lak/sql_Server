CREATE DATABASE TrainingManagementSystem;
go

-- Question Number 15

CREATE TABLE Trainers(
	trainerId INT PRIMARY KEY IDENTITY(1,1),
	trainerName VARCHAR(50)
);
GO

CREATE TABLE SessionsList(
	sessionId  INT PRIMARY KEY IDENTITY(1,1),
	sessionName VARCHAR(50)
);
GO

CREATE TABLE TrainerSession(
	trainerId INT CONSTRAINT FK_TrainerSession_Trainers FOREIGN KEY REFERENCES Trainers(trainerId),
	sessionId INT CONSTRAINT FK_TrainerSession_SessionsList FOREIGN KEY REFERENCES SessionsList(sessionId),
	PRIMARY KEY(trainerId,sessionId)
);
GO

CREATE TABLE Attendance(
	attendanceId INT PRIMARY KEY IDENTITY(101,1),
	sessionId INT UNIQUE CONSTRAINT FK_Attendance_SessionsList FOREIGN KEY REFERENCES SessionsList(sessionId)
);
GO

CREATE TABLE Trainees(
	traineesId INT PRIMARY KEY IDENTITY(1001,1),
	trainerName VARCHAR(50),
);
GO

CREATE TABLE TraineesSessionsList(
	traineesId INT CONSTRAINT FK_TraineesSessionsList_Trainees FOREIGN KEY REFERENCES Trainees(traineesId),
	sessionId INT CONSTRAINT FK_TraineesSessionsList_SessionsList FOREIGN KEY REFERENCES SessionsList(sessionId),
	PRIMARY KEY(traineesId,sessionId)
);
GO