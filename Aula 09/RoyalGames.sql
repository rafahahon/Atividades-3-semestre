-- Deletar banco
--DROP DATABASE RoyalGames;

-- Criar o banco
CREATE DATABASE RoyalGames;
GO

-- Acessar o banco
USE RoyalGames;
GO

CREATE TABLE Usuario(
	UsuarioID INT PRIMARY KEY IDENTITY,
	Nome VARCHAR(60) NOT NULL,
	Email VARCHAR(150) UNIQUE NOT NULL,
	Senha VARBINARY(32) NOT NULL,
	StatusUsuario BIT DEFAULT 1
);
GO

CREATE TABLE ClassificacaoIndicativa(
	ClassificacaoIndicativaID INT PRIMARY KEY IDENTITY,
	Classificacao VARCHAR(50)
);
GO

CREATE TABLE Jogo(
	JogoID INT PRIMARY KEY IDENTITY,
	Nome VARCHAR(100) UNIQUE NOT NULL,
	Preco DECIMAL(10,2) NOT NULL,
	Descricao NVARCHAR(MAX) NOT NULL,
	Imagem VARBINARY(MAX) NOT NULL,
	StatusJogo BIT DEFAULT 1,
	-- FOREIGN KEY
	UsuarioID INT FOREIGN KEY REFERENCES Usuario(UsuarioID),
	ClassificacaoIndicativaID INT FOREIGN KEY REFERENCES ClassificacaoIndicativa(ClassificacaoIndicativaID)
);
GO

CREATE TABLE Plataforma(
	PlataformaID INT PRIMARY KEY IDENTITY,
	Nome VARCHAR(50)
);
GO

CREATE TABLE Genero(
	GeneroID INT PRIMARY KEY IDENTITY,
	Nome VARCHAR(50)
);	
GO

-- Tabelas intermediárias
CREATE TABLE JogoPlataforma(
	JogoID INT NOT NULL,
	PlataformaID INT NOT NULL,
	CONSTRAINT PK_JogoPlataforma PRIMARY KEY (JogoID, PlataformaID),
	CONSTRAINT FK_JogoPlataforma_Jogo FOREIGN KEY (JogoID)  
		REFERENCES Jogo(JogoID) ON DELETE CASCADE,
	CONSTRAINT FK_JogoPlataforma_Plataforma  FOREIGN KEY (PlataformaID) 
		REFERENCES Plataforma(PlataformaID) ON DELETE CASCADE
);
GO

CREATE TABLE JogoGenero(
	JogoID INT NOT NULL,
	GeneroID INT NOT NULL,
	CONSTRAINT PK_JogoGenero PRIMARY KEY (JogoID, generoID),
	CONSTRAINT FK_JogoGenero_Jogo FOREIGN KEY (JogoID)  
		REFERENCES Jogo(JogoID) ON DELETE CASCADE,
	CONSTRAINT FK_JogoGenero_Genero  FOREIGN KEY (GeneroID) 
		REFERENCES Genero(GeneroID) ON DELETE CASCADE
);
GO

-- Tabela de log
CREATE TABLE Log_AlteracaoJogo(
	Log_AlteracaoJogoID INT PRIMARY KEY IDENTITY,
	DataAlteracao DATETIME2(0) NOT NULL,
	NomeAnterior VARCHAR(100),
	PrecoAnterior DECIMAL(10,2),
	-- FOREIGN KEY
	JogoID INT FOREIGN KEY REFERENCES Jogo(JogoID)
);
GO

-- Triggers
-- Excluir usuário / StatusUsuario = 0
	CREATE TRIGGER trg_ExclusaoUsuario
	ON Usuario
	INSTEAD OF DELETE
	AS
	BEGIN
		UPDATE a SET StatusUsuario = 0
		FROM Usuario a
		INNER JOIN deleted d 
			ON d.UsuarioID = a.UsuarioID;
	END
	GO

	-- Salvando registro de alteração de jogo na tabela Log
	CREATE TRIGGER trg_AlteracaoJogo
	ON Jogo
	AFTER UPDATE
	AS
	BEGIN
		INSERT INTO Log_AlteracaoJogo(DataAlteracao, JogoID, 
													NomeAnterior, PrecoAnterior)
		SELECT GETDATE(), JogoID, Nome, Preco FROM deleted 
	END
	GO

	-- Excluir / jogo StatusJogo= 0
	CREATE TRIGGER trg_ExclusaoJogo
	ON Jogo
	INSTEAD OF DELETE
	AS
	BEGIN
		UPDATE j SET StatusJogo = 0
		FROM Jogo j
		INNER JOIN deleted d 
			ON d.JogoID = j.JogoID;
	END
	GO

-- Inserindo valores
INSERT INTO Usuario (Nome, Email, Senha)
	VALUES 
	('Rebeca Andrade', 'rebeca@royalgames.com', HASHBYTES('SHA2_256', 'admin@123'));
GO

INSERT INTO Genero (Nome)
	VALUES
	('Ação'),
	('Aventura'),
	('Souls');
GO

INSERT INTO Plataforma (Nome)
	VALUES
	('Xbox'),
	('Playstation'),
	('Windows');
GO

INSERT INTO ClassificacaoIndicativa (Classificacao)
	VALUES
	('14'),
	('16'),
	('18');
GO

INSERT INTO Jogo (Nome, Preco, Descricao, Imagem, UsuarioID, ClassificacaoIndicativaID)
	VALUES
	('Elden Ring',299.99,'Elden Ring é um jogo eletrônico de RPG de ação em terceira pessoa, desenvolvido pela FromSoftware e publicado pela Bandai Namco Entertainment. O jogo é um projeto colaborativo entre o diretor Hidetaka Miyazaki e o romancista de fantasia George R. R. Martin.',CONVERT(VARBINARY(MAX), 'imagem aleatoria'),1,3);
GO

INSERT INTO JogoGenero(JogoID, GeneroID)
	VALUES
	(1, 3);
GO

INSERT INTO JogoPlataforma(JogoID, PlataformaID)
	VALUES
	(1,1),
	(1,2),
	(1,3);
GO

-- SELECT
SELECT * FROM Usuario
SELECT * FROM Jogo
SELECT * FROM Genero
SELECT * FROM Plataforma
SELECT * FROM ClassificacaoIndicativa
SELECT * FROM JogoGenero
SELECT * FROM JogoPlataforma