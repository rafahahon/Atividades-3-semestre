-- Criação do banco
CREATE DATABASE PlataformaCursos;
GO

USE PlataformaCursos;
GO

-- Criação de tabelas

CREATE TABLE Instrutor (
	InstrutorID			INT PRIMARY KEY IDENTITY,
	NomeInstrutor		VARCHAR(60) NOT NULL,
	Especializacao		VARCHAR(100) NOT NULL
); 
GO

CREATE TABLE Curso (
	CursoID				INT PRIMARY KEY IDENTITY,
	NomeCurso			VARCHAR(100) NOT NULL,
	CargaHoraria		INT NOT NULL,
	StatusCurso			BIT DEFAULT 1 NOT NULL,
	InstrutorID			INT FOREIGN KEY REFERENCES Instrutor(InstrutorID)
);
GO

CREATE TABLE Aluno (
	AlunoID				INT PRIMARY KEY IDENTITY,
	NomeAluno			VARCHAR(60) NOT NULL,
	Email				VARCHAR(150) NOT NULL
);
GO

CREATE TABLE Matricula (
	MatriculaID			INT PRIMARY KEY IDENTITY,
	AlunoID				INT FOREIGN KEY REFERENCES Aluno(AlunoID),
	CursoID				INT FOREIGN KEY REFERENCES Curso(CursoID)
);
GO

-- Inserção de valores
INSERT INTO Instrutor (NomeInstrutor, Especializacao)
VALUES 
('Amanda Silva','Inteligência Artificial e Machine Learning'),
('Bruno Alvez','Big Data e Analytics'),
('Fred Moreira','Segurança da Informação e Cibersegurança')
GO

INSERT INTO Curso (NomeCurso, CargaHoraria, StatusCurso, InstrutorID)
VALUES 
('Machine Learning', 60, 1, 1),
('Big Data', 120, 1 ,2),
('Cibersegurança', 160, 1, 3)
GO

INSERT INTO Aluno (NomeAluno, Email)
VALUES 
('Bruna Soares','brunaS@gmail.com'),
('Rebeca Oliveira','rebecaO@gmail.com'),
('Zoe Brandão','zoeB@gmail.com')
GO

INSERT INTO Matricula (AlunoID, CursoID)
VALUES 
(1, 1),
(1, 2),
(2, 2),
(3, 3)
GO