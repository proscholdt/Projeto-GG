-- Criação do banco de dados
CREATE DATABASE Universidade_Proscholdt;

-- Uso do banco de dados
USE Universidade_Proscholdt;

-- Criação de Tabelas Dimensão

-- Criação da dimensão "curso"
CREATE TABLE dim_curso (
    curso_id INT PRIMARY KEY,
    nome_curso VARCHAR(100),
    area_conhecimento VARCHAR(50)
);

-- Criação da dimensão "aluno"
CREATE TABLE dim_aluno (
    aluno_id INT PRIMARY KEY,
    nome_aluno VARCHAR(100),
    idade INT,
    genero VARCHAR(10)
);

-- Criação da dimensão "campus"
CREATE TABLE dim_campus (
    campus_id INT PRIMARY KEY,
    nome_campus VARCHAR(100),
    cidade VARCHAR(50),
    estado VARCHAR(50)
);

-- Criação da dimensão "modalidade"
CREATE TABLE dim_modalidade (
    modalidade_id INT PRIMARY KEY,
    nome_modalidade VARCHAR(50)
);

-- Inserção de dados nas tabelas Dimensão

-- Inserção de dados na dimensão "curso"
-- Aqui inserimos dados fictícios de cursos com suas respectivas áreas de conhecimento
INSERT INTO dim_curso (curso_id, nome_curso, area_conhecimento) VALUES
(1, 'Engenharia Mecânica', 'Engenharia'),
(2, 'Ciência da Computação', 'Tecnologia'),
(3, 'Administração de Empresas', 'Administração'),
(4, 'Direito', 'Jurídico'),
(5, 'Medicina', 'Saúde'),
(6, 'Economia', 'Economia'),
(7, 'Psicologia', 'Ciências Humanas'),
(8, 'Arquitetura', 'Arquitetura'),
(9, 'Nutrição', 'Saúde'),
(10, 'Design Gráfico', 'Design'),
(11, 'Engenharia Elétrica', 'Engenharia'),
(12, 'Letras', 'Humanidades'),
(13, 'Biologia', 'Ciências Biológicas'),
(14, 'Marketing', 'Marketing'),
(15, 'Fisioterapia', 'Saúde'),
(16, 'História', 'Ciências Humanas');

-- Inserção de dados na dimensão "aluno"
-- Aqui inserimos dados fictícios de alunos com nomes, idades e gêneros aleatórios
DECLARE @i INT = 1;
WHILE @i <= 4000
BEGIN
    INSERT INTO dim_aluno (aluno_id, nome_aluno, idade, genero) VALUES
    (@i, 'Aluno ' + CAST(@i AS VARCHAR(10)), CAST(ROUND(RAND() * 10 + 18, 0) AS INT), CASE WHEN RAND() > 0.5 THEN 'Masculino' ELSE 'Feminino' END);
    SET @i = @i + 1;
END;

-- Inserção de dados na dimensão "campus"
-- Aqui inserimos dados fictícios de campi com seus respectivos nomes, cidades e estados
INSERT INTO dim_campus (campus_id, nome_campus, cidade, estado) VALUES
(1, 'Campus São Paulo', 'São Paulo', 'São Paulo'),      -- Sudeste
(2, 'Campus Rio de Janeiro', 'Rio de Janeiro', 'Rio de Janeiro'),  -- Sudeste
(3, 'Campus Belo Horizonte', 'Belo Horizonte', 'Minas Gerais'),   -- Sudeste
(4, 'Campus Porto Alegre', 'Porto Alegre', 'Rio Grande do Sul'),  -- Sul
(5, 'Campus Recife', 'Recife', 'Pernambuco'),         -- Nordeste
(6, 'Campus Salvador', 'Salvador', 'Bahia'),            -- Nordeste
(7, 'Campus Curitiba', 'Curitiba', 'Paraná'),           -- Sul
(8, 'Campus Fortaleza', 'Fortaleza', 'Ceará'),           -- Nordeste
(9, 'Campus Goiânia', 'Goiânia', 'Goiás'),             -- Centro-Oeste
(10, 'Campus Manaus', 'Manaus', 'Amazonas');          -- Norte

-- Inserção de dados na dimensão "modalidade"
-- Aqui inserimos dados fictícios de modalidades de ensino
INSERT INTO dim_modalidade (modalidade_id, nome_modalidade) VALUES
(1, 'Presencial'),
(2, 'EAD'),
(3, 'Semi_Presencial');

-- Criação da tabela fato "matricula" e distribuição de dados fictícios de forma aleatória.
CREATE TABLE fato_matricula (
    matricula_id INT PRIMARY KEY,
    aluno_id INT,
    curso_id INT,
    campus_id INT,
    modalidade_id INT,
    data_matricula DATE,
    FOREIGN KEY (aluno_id) REFERENCES dim_aluno(aluno_id),
    FOREIGN KEY (curso_id) REFERENCES dim_curso(curso_id),
    FOREIGN KEY (campus_id) REFERENCES dim_campus(campus_id),
    FOREIGN KEY (modalidade_id) REFERENCES dim_modalidade(modalidade_id)
);

DECLARE @matricula_id INT = 1;
DECLARE @aluno_id INT;
DECLARE @curso_id INT;
DECLARE @campus_id INT;
DECLARE @modalidade_id INT;
DECLARE @data_matricula DATE;

-- Criação de uma tabela temporária para controlar os alunos já matriculados
CREATE TABLE #alunos_matriculados (
    aluno_id INT PRIMARY KEY
);

-- Loop para inserir dados fictícios de matrícula de alunos
WHILE @matricula_id <= 4000
BEGIN
    -- Geração de um aluno não matriculado anteriormente
    SET @aluno_id = (SELECT TOP 1 aluno_id FROM dim_aluno WHERE aluno_id NOT IN (SELECT aluno_id FROM #alunos_matriculados) ORDER BY NEWID());
    -- Inserção do aluno na tabela temporária de controle
    INSERT INTO #alunos_matriculados (aluno_id) VALUES (@aluno_id);
    
    -- Geração de um curso aleatório ponderado para distribuir os alunos de forma mais equilibrada
    SET @curso_id = (
        CASE 
            WHEN RAND() < 0.19 THEN 1   -- Engenharia Mecânica
            WHEN RAND() < 0.24 THEN 2   -- Ciência da Computação
            WHEN RAND() < 0.15 THEN 3   -- Administração de Empresas
            WHEN RAND() < 0.09 THEN 4   -- Direito
            WHEN RAND() < 0.22 THEN 5   -- Medicina
            WHEN RAND() < 0.25 THEN 6   -- Economia
            WHEN RAND() < 0.1 THEN 7   -- Psicologia
            WHEN RAND() < 0.025 THEN 8   -- Arquitetura
            WHEN RAND() < 0.022 THEN 9  -- Nutrição
            WHEN RAND() < 0.13 THEN 10  -- Design Gráfico
            WHEN RAND() < 0.07 THEN 11 -- Engenharia Elétrica
            WHEN RAND() < 0.04 THEN 12 -- Letras
            WHEN RAND() < 0.063 THEN 13 -- Biologia
            WHEN RAND() < 0.05 THEN 14 -- Marketing
            WHEN RAND() < 0.11 THEN 15 -- Fisioterapia
            ELSE 16                     -- História
        END
    );
    
    -- Geração de um campus aleatório ponderado para distribuir os alunos de forma mais equilibrada
    SET @campus_id = (
        CASE 
            WHEN @curso_id IN (1, 5, 10, 11, 12, 13, 14, 15, 16) THEN ROUND(RAND(CHECKSUM(NEWID())) * 9, 0) + 1  -- Campus variando de 1 a 9
            WHEN @curso_id IN (2, 3, 6, 7, 8, 9) THEN ROUND(RAND(CHECKSUM(NEWID())) * 4, 0) + 1  -- Campus variando de 1 a 4
            WHEN @curso_id = 4 THEN ROUND(RAND(CHECKSUM(NEWID())) * 3, 0) + 1  -- Campus variando de 1 a 3
            ELSE ROUND(RAND(CHECKSUM(NEWID())) * 2, 0) + 1  -- Campus variando de 1 a 2
        END
    );
    
    -- Definindo a modalidade como 1 (presencial), 2 (EAD) ou 3 (Semi_Presencial)
    SET @modalidade_id = ( 
        CASE 
            WHEN RAND() < 0.47 THEN 1   -- presencial
            WHEN RAND() < 0.38 THEN 2   -- EAD
            ELSE 3  -- Semi_Presencial
        END        
    );

    -- Geração de uma data de matrícula aleatória entre '2022-01-01' e '2023-01-01'
    SET @data_matricula = DATEADD(day, (CAST(RAND() * 365 AS INT)), '2022-01-01');

    -- Inserção dos dados de matrícula na tabela fato
    INSERT INTO fato_matricula (matricula_id, aluno_id, curso_id, campus_id, modalidade_id, data_matricula) 
    VALUES (@matricula_id, @aluno_id, @curso_id, @campus_id, @modalidade_id, @data_matricula);

    SET @matricula_id = @matricula_id + 1;
END;

-- Remoção da tabela temporária
DROP TABLE #alunos_matriculados;

/*OBSERVAÇÕES IMPORTANTES !!! /*

/*O objetivo desse script é simular um ambiente universitário com informações de cursos, alunos, campus e 
matrículas. É importante notar que os dados fictícios são gerados de forma aleatória com base em distribuições 
específicas para os cursos, campus e modalidades de ensino. */

/*Como a carga de dados foi feita de forma aleatória alguns campus podem apresentar um número total de cursos menor
em relação aos outros campus */