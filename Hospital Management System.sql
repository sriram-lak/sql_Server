CREATE DATABASE Hospital;
GO

-- question 1 : Hospital Management

CREATE TABLE Departments (
	departmentId INT IDENTITY(1,1) PRIMARY KEY,
	departmentName VARCHAR(50) NOT NULL
);
GO

CREATE TABLE Doctors (
	doctorId INT IDENTITY(101,1) PRIMARY KEY,
	doctorName VARCHAR(100) NOT NULL,
	specification VARCHAR(100) DEFAULT 'General',
	phone BIGINT NOT NULL,
	CONSTRAINT UC_Doctors UNIQUE(phone),
	email VARCHAR(100) NOT NULL,
	CONSTRAINT UC_Doctors_email UNIQUE(email),
	departmentId INT CONSTRAINT FK_Doctors_Departments FOREIGN KEY REFERENCES Departments(departmentId),
	shiftStartTime DATE NOT NULL,
	shiftEndTime DATE NOT NULL
);
GO

CREATE TABLE Patients (
	patientId INT IDENTITY(1001,1) PRIMARY KEY,
	patientName VARCHAR(100) NOT NULL,
	dateOfBirth DATE NOT NULL,
	gender VARCHAR(10) CHECK (gender = 'Male' OR gender = 'Female'),
	phone BIGINT NOT NULL,
	email VARCHAR(100) NOT NULL
);
GO

CREATE TABLE Appointments (
	patientId INT CONSTRAINT FK_Appointments_Patients FOREIGN KEY REFERENCES Patients(patientId),
	doctorId INT CONSTRAINT FK_Appointments_Doctors FOREIGN KEY REFERENCES Doctors(doctorId),
	appointmentStartTime DATE NOT NULL,
	appointmentEndTime DATE NOT NULL,
	CONSTRAINT PK_Appointments PRIMARY KEY(doctorId,appointmentStartTime)
);
GO