USE [TesteEinstein];
GO

IF OBJECT_ID('dbo.NotificacoesSindromesGripais', 'U') IS NOT NULL
    DROP TABLE dbo.NotificacoesSindromesGripais;
GO

CREATE TABLE dbo.NotificacoesSindromesGripais
(
    idNotificacao BIGINT IDENTITY(1,1) NOT NULL
        CONSTRAINT PK_NotificacoesSindromesGripais PRIMARY KEY,

    sintomas                          VARCHAR(500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    profissionalSaude                 VARCHAR(3)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    racaCor                           VARCHAR(20)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    outrosSintomas                    VARCHAR(500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    outrasCondicoes                   VARCHAR(500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    profissionalSeguranca             VARCHAR(3)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    cbo                               VARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    condicoes                         VARCHAR(500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    sexo                              VARCHAR(20)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,

    estado                            VARCHAR(30)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    estadoIBGE                        VARCHAR(2)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL, 
    municipio                         VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    municipioIBGE                     CHAR(7)      COLLATE SQL_Latin1_General_CP1_CI_AS NULL, 
    origem                            VARCHAR(50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,

    estadoNotificacao                 VARCHAR(30)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    municipioNotificacao              VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    municipioNotificacaoIBGE          CHAR(7)      COLLATE SQL_Latin1_General_CP1_CI_AS NULL, 

    evolucaoCaso                      VARCHAR(50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    classificacaoFinal                VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,

    codigoEstrategiaCovid             VARCHAR(2)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    codigoBuscaAtivaAssintomatico     VARCHAR(2)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    outroBuscaAtivaAssintomatico      VARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    codigoTriagemPopulacaoEspecifica  VARCHAR(2)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    outroTriagemPopulacaoEspecifica   VARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    codigoLocalRealizacaoTestagem     VARCHAR(2)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    outroLocalRealizacaoTestagem      VARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,

    codigoRecebeuVacina               VARCHAR(2)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    codigoLaboratorioPrimeiraDose     VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    codigoLaboratorioSegundaDose      VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    lotePrimeiraDose                  VARCHAR(50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    loteSegundaDose                   VARCHAR(50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    codigoContemComunidadeTradicional VARCHAR(2)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,

    source_id                         VARCHAR(50)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    excluido                          BIT NULL,
    validado                          BIT NULL,
    codigoDosesVacina                 VARCHAR(30)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    estadoNotificacaoIBGE             VARCHAR(2)   COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    totalTestesRealizados             SMALLINT NULL,

    dataNotificacao                   DATE NULL,
    dataInicioSintomas                DATE NULL,
    dataEncerramento                  DATE NULL,
    dataPrimeiraDose                  DATE NULL,
    dataSegundaDose                   DATE NULL,

    codigoEstadoTeste1                VARCHAR(2)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    codigoTipoTeste1                  VARCHAR(2)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    codigoFabricanteTeste1            VARCHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    codigoResultadoTeste1             VARCHAR(2)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,

    codigoEstadoTeste2                VARCHAR(2)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    codigoTipoTeste2                  VARCHAR(2)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    codigoFabricanteTeste2            VARCHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    codigoResultadoTeste2             VARCHAR(2)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,

    codigoEstadoTeste3                VARCHAR(2)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    codigoTipoTeste3                  VARCHAR(2)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    codigoFabricanteTeste3            VARCHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    codigoResultadoTeste3             VARCHAR(2)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,

    codigoEstadoTeste4                VARCHAR(2)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    codigoTipoTeste4                  VARCHAR(2)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    codigoFabricanteTeste4            VARCHAR(20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    codigoResultadoTeste4             VARCHAR(2)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,

    dataColetaTeste1                  DATE NULL,
    dataColetaTeste2                  DATE NULL,
    dataColetaTeste3                  DATE NULL,
    dataColetaTeste4                  DATE NULL,

    idade                             SMALLINT NULL,

    nomeArquivoOrigem                 VARCHAR(260) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
    dataCarga DATETIME2(0) NOT NULL
        CONSTRAINT DF_Notificacoes_DataCarga DEFAULT SYSDATETIME()
);
GO

-- Índices de apoio ao JOIN / agrupamento dos itens 3b e 3c
CREATE INDEX IX_NotificacoesSindromesGripais_MunicipioIBGE
    ON dbo.NotificacoesSindromesGripais (municipioIBGE);
GO

CREATE INDEX IX_NotificacoesSindromesGripais_MunicipioNotificacaoIBGE
    ON dbo.NotificacoesSindromesGripais (municipioNotificacaoIBGE);
GO

CREATE INDEX IX_NotificacoesSindromesGripais_EstadoIBGE
    ON dbo.NotificacoesSindromesGripais (estadoIBGE);
GO
