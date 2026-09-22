USE [TesteEinstein];
GO

/* ============================================================
   ITEM 3.b.i — Contagem de notificações por UF, com filtro de
   lista de UFs.
   ============================================================ */

DECLARE @UFsFiltro NVARCHAR(MAX) = 'São Paulo, Minas Gerais, Rio de Janeiro, Paraná, Espírito Santo';

SELECT
    m.CodigoUF,
    m.NomeUF,
    COUNT(*) AS QtdNotificacoes,
    COUNT(DISTINCT m.CodigoMunicipioCompleto) AS QtdMunicipiosDistintos
FROM dbo.NotificacoesSindromesGripais AS n
INNER JOIN dbo.MunicipiosIBGE AS m
    ON n.municipioIBGE = m.CodigoMunicipioCompleto
WHERE m.NomeUF IN (SELECT TRIM(value) FROM STRING_SPLIT(@UFsFiltro, ','))
GROUP BY m.CodigoUF, m.NomeUF
ORDER BY m.NomeUF;
GO


/* ============================================================
   ITEM 3.b.ii — Contagem de notificações por cidade, somente as
   que têm mais de 10 notificações.
   ============================================================ */

SELECT
    m.NomeMunicipio,
    m.NomeUF,
    m.NomeMesorregiao,
    m.NomeMicrorregiao,
    m.NomeRegiaoImediata,
    COUNT(*) AS QtdNotificacoes
FROM dbo.NotificacoesSindromesGripais AS n
INNER JOIN dbo.MunicipiosIBGE AS m
    ON n.municipioIBGE = m.CodigoMunicipioCompleto
GROUP BY m.NomeMunicipio, m.NomeUF, m.NomeMesorregiao, m.NomeMicrorregiao, m.NomeRegiaoImediata
HAVING COUNT(*) > 10
ORDER BY QtdNotificacoes DESC;
GO


/* ============================================================
   VARIANTE — Comparação lado a lado: residência do paciente
   x local da notificação, por UF.
   ============================================================ */

DECLARE @UFsFiltroComparacao NVARCHAR(MAX) = NULL; -- ex: 'São Paulo, Minas Gerais' (NULL = sem filtro)

WITH ResidenciaUF AS (
    SELECT m.NomeUF, COUNT(*) AS Qtd
    FROM dbo.NotificacoesSindromesGripais AS n
    INNER JOIN dbo.MunicipiosIBGE AS m ON n.municipioIBGE = m.CodigoMunicipioCompleto
    GROUP BY m.NomeUF
),
NotificacaoUF AS (
    SELECT m.NomeUF, COUNT(*) AS Qtd
    FROM dbo.NotificacoesSindromesGripais AS n
    INNER JOIN dbo.MunicipiosIBGE AS m ON n.municipioNotificacaoIBGE = m.CodigoMunicipioCompleto
    GROUP BY m.NomeUF
)
SELECT
    COALESCE(r.NomeUF, nt.NomeUF) AS UF,
    ISNULL(r.Qtd, 0)  AS QtdResidenciaPaciente,
    ISNULL(nt.Qtd, 0) AS QtdLocalNotificacao
FROM ResidenciaUF AS r
FULL OUTER JOIN NotificacaoUF AS nt
    ON r.NomeUF = nt.NomeUF
WHERE @UFsFiltroComparacao IS NULL
   OR COALESCE(r.NomeUF, nt.NomeUF) IN (SELECT TRIM(value) FROM STRING_SPLIT(@UFsFiltroComparacao, ','))
ORDER BY UF;
GO


/* ============================================================
   ITEM 3.c.i — Segunda tabela contendo apenas os dados de São Paulo
   ============================================================ */

IF OBJECT_ID('dbo.NotificacoesSindromesGripais_SP', 'U') IS NOT NULL
    DROP TABLE dbo.NotificacoesSindromesGripais_SP;
GO

SELECT *
INTO dbo.NotificacoesSindromesGripais_SP
FROM dbo.NotificacoesSindromesGripais
WHERE estado = 'São Paulo';
GO



/* ============================================================
   ITEM 3.c.ii — Atualiza a UF que estiver indefinida (NULL ou
   vazia) para 'ND'.
   Obs.: o campo "estado" (nome por extenso) nunca vem vazio, mas
   o campo "estadoIBGE" (sigla) vem em branco em ~96% dos registros
   de São Paulo (47.777 de 49.567) — é essa a UF indefinida real
   que o comando trata.
   ============================================================ */

UPDATE dbo.NotificacoesSindromesGripais_SP
SET estadoIBGE = 'ND'
WHERE estadoIBGE IS NULL OR LTRIM(RTRIM(estadoIBGE)) = '';
GO


/* ============================================================
   ITEM 3.c.iii — Apaga 10 registros da UF 'ND'
   ============================================================ */

DELETE TOP (10) FROM dbo.NotificacoesSindromesGripais_SP
WHERE estadoIBGE = 'ND';
GO