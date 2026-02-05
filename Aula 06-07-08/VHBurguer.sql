-- CRIAR O BANCO
CREATE DATABASE VH_Burguer;
GO

-- ACESSAR/USAR O BANCO
USE VH_Burguer;
GO

CREATE TABLE Usuario(
    UsuarioID INT PRIMARY KEY IDENTITY,
    Nome VARCHAR(60) UNIQUE NOT NULL,
    Email VARCHAR(150) UNIQUE NOT NULL,
    Senha VARBINARY(32) NOT NULL,
    StatusUsuario BIT DEFAULT 1 
    --Default 1 -Por padrão ao criar um usuário seu status vem como ativo (sendo 1)
);
GO

CREATE TABLE Produto(
    ProdutoID INT PRIMARY KEY IDENTITY,
    Nome VARCHAR(100) UNIQUE NOT NULL,
    Preco DECIMAL (10,2) NOT NULL,
    Descricao NVARCHAR(MAX) NOT NULL,
    Imagem VARBINARY(MAX) NOT NULL,
    StatusProduto BIT DEFAULT 1, 
    --Default 1 -Por padrão, o produto virá ativo (sendo 1)
    --Chamando a FK de usuario:
    UsuarioID INT FOREIGN KEY REFERENCES Usuario(UsuarioID)
);
GO

CREATE TABLE Categoria(
    CategoriaID INT PRIMARY KEY IDENTITY,
    Nome VARCHAR(50) NOT NULL
);
GO

CREATE TABLE ProdutoCategoria( 
--Chave composta:
    -- 1. Criar os atributos
    ProdutoID INT NOT NULL,
    CategoriaID INT NOT NULl,
    -- 2. Aplicar as constraints
    CONSTRAINT PK_ProdutoCategoria PRIMARY KEY (ProdutoID, CategoriaID),
    CONSTRAINT FK_ProdutoCategoria_Produto FOREIGN KEY (ProdutoID) REFERENCES Produto(ProdutoID) ON DELETE CASCADE,
    CONSTRAINT FK_ProdutoCategoria_Categoria FOREIGN KEY (CategoriaID) REFERENCES Categoria(CategoriaID) ON DELETE CASCADE
);
GO

CREATE TABLE Promocao (
    PromocaoID INT PRIMARY KEY IDENTITY,
    Nome VARCHAR(100) NOT NULL,
    DataExpiracao DATETIME2(0) NOT NULL,
    StatusPromocao BIT DEFAULT 1 NOT NULL
);
GO

CREATE TABLE ProdutoPromocao (
    PromocaoID INT NOT NULL,
    ProdutoID INT NOT NULL,
    PrecoAtual DECIMAL(10,2) NOT NULL,
    CONSTRAINT PK_ProdutoPromocao PRIMARY KEY (PromocaoID, ProdutoID),
    CONSTRAINT FK_ProdutoPromocao_Produto FOREIGN KEY (PromocaoID) REFERENCES Promocao(PromocaoID) ON DELETE CASCADE,
    CONSTRAINT FK_ProdutoPromocao_Categoria FOREIGN KEY (ProdutoID) REFERENCES Produto(ProdutoID) ON DELETE CASCADE
);
GO

-- 05/02

CREATE TABLE Log_AlteracaoProduto(
    Log_AlteracaoProdutoID INT PRIMARY KEY IDENTITY,
    DataAlteracao DATETIME2(0) NOT NULL,
    NomeAnterior VARCHAR(100),
    PrecoAnterior DECIMAL(10,2),
    -- Vínculo com as tabelas que faz a intermediação
    ProdutoID INT FOREIGN KEY REFERENCES Produto(ProdutoID)
);
GO

-- Criando nossas triggers:
    -- Exclusão do usuário / DELETE -> EXCLUIR O USUARIO = INATIVAR O USUARIO!!! StatusUsuario = 0
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

    -- TODA VEZ QUE ALTERARMOS A TABELA PRODUTO = CRIAR UM REGISTRO NA TABELA LOG
    CREATE TRIGGER trg_AlteracaoProduto
    ON Produto
    AFTER UPDATE
    AS
    BEGIN
        INSERT INTO Log_AlteracaoProduto(DataAlteracao,ProdutoID, NomeAnterior, PrecoAnterior)
        SELECT GETDATE(), ProdutoID, Nome, Preco FROM deleted;
    END
    GO

    -- DELETE -> EXCLUIR O PRODUTO = INATIVAR O PRODUTO!!! StatusProduto = 0
    CREATE TRIGGER trg_ExclusaoProduto
    ON Produto
    INSTEAD OF DELETE 
    AS
    BEGIN
        UPDATE p SET StatusProduto= 0
        FROM Produto p 
        INNER JOIN deleted d 
            ON d.ProdutoID = p.ProdutoID;
    END
    GO

-- Inserção de valores
--- DML
INSERT INTO Usuario (Nome, Email, Senha)
	VALUES 
	('Carlos Lima', 'carlos@vhburguer.com', HASHBYTES('SHA2_256', 'admin@123'));
GO

INSERT INTO Categoria (Nome)
	VALUES
	('Vegetariano'),
	('Vegano'),
	('Especial');

GO

INSERT INTO Produto (Nome, Preco, Descricao, Imagem, UsuarioID)
VALUES
('VH Classic Burger', 29.90, 'Hamburguer artesanal com pão brioche, carne e queijo cheddar.', CONVERT(VARBINARY(MAX), 'imagem aleatoria'), 1),
('VH Bacon Supreme', 34.90, 'Hambúrguer bovino, bacon crocante, queijo e molho especial da casa.', CONVERT(VARBINARY(MAX), 'imagem aleatoria'), 1),
('Batata Rústica', 14.90, 'Batatas rústicas temperadas com ervas finas.', CONVERT(VARBINARY(MAX), 'imagem aleatoria'), 1)
GO

INSERT INTO ProdutoCategoria (ProdutoID, CategoriaID)
VALUES
(1, 3), 
(2, 3), 
(3, 1),
(3, 3),
(3, 2);
GO

INSERT INTO Promocao (Nome, DataExpiracao)
VALUES
('Promoção Semana do Hambúrguer', '2026-03-01 23:59:59'),
('Combo Happy Hour', '2026-02-20 23:59:59');
GO

INSERT INTO ProdutoPromocao (ProdutoID, PromocaoID, PrecoAtual)
VALUES
(1, 1, 24.90), -- VH Classic Burger
(2, 1, 29.90), -- VH Bacon Supreme
(3, 2, 9.90); -- Batata Rústica
GO

SELECT * FROM Produto