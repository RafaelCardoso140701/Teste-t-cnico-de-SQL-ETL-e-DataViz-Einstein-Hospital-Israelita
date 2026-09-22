USE [TesteEinstein];
GO

IF OBJECT_ID('dbo.MunicipiosIBGE', 'U') IS NOT NULL
    DROP TABLE dbo.MunicipiosIBGE;
GO

CREATE TABLE dbo.MunicipiosIBGE
(
    CodigoUF                    CHAR(2)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    NomeUF                      VARCHAR(30)  COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,

    CodigoRegiaoIntermediaria   CHAR(4)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    NomeRegiaoIntermediaria     VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,

    CodigoRegiaoImediata        CHAR(6)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    NomeRegiaoImediata          VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,

    CodigoMesorregiao           CHAR(2)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    NomeMesorregiao             VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,

    CodigoMicrorregiao          CHAR(3)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    NomeMicrorregiao            VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,

    CodigoMunicipio             CHAR(5)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
    CodigoMunicipioCompleto     CHAR(7)   COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
        CONSTRAINT PK_MunicipiosIBGE PRIMARY KEY,

    NomeMunicipio               VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,

    DataCarga DATETIME2(0) NOT NULL
        CONSTRAINT DF_MunicipiosIBGE_DataCarga DEFAULT SYSDATETIME()
);
GO

-- Apoio às contagens por UF do item 3b
CREATE INDEX IX_MunicipiosIBGE_NomeUF ON dbo.MunicipiosIBGE (NomeUF);
GO
