# Notificações de Síndrome Gripal — ETL, SQL Server e Power BI

Projeto de engenharia e análise de dados sobre notificações de Síndrome Gripal
do **e-SUS Notifica (OpenDataSUS)**, cruzadas com a **Divisão Territorial
Brasileira do IBGE**.

O trabalho percorre o ciclo completo: carga com SSIS, modelagem e consultas em
SQL Server, e um dashboard em Power BI com hierarquia geográfica, parâmetros e
relacionamentos de modelo.

`SQL Server` `SSIS` `Power BI` `ETL` `Modelagem de Dados` `Qualidade de Dados`

---

## O desafio

Construir uma solução ponta a ponta a partir de arquivos brutos de notificação:

| # | Entrega |
|---|---|
| 1 | Carga em SSIS consolidando múltiplos arquivos numa tabela, com tipagem adequada e tolerância a nomes de arquivo variáveis |
| 2 | Carga da tabela de municípios do IBGE |
| 3 | Consultas SQL Server cruzando as duas tabelas, com filtro por lista de UFs e recorte de cidades acima de 10 notificações |
| 4 | Dashboard em Power BI com hierarquia de municípios, parâmetros e filtros |

---

## Dados

| Fonte | Arquivo | Volume |
|---|---|---|
| e-SUS Notifica — Paraná, 2023 | `data/esus-notifica/notificacoes-pr-2023.csv` | 59.095 notificações |
| e-SUS Notifica — Espírito Santo, 2023 | `data/esus-notifica/notificacoes-es-2023.csv` | 5.244 notificações |
| DTB / IBGE | `data/municipios-ibge-dtb.csv` | 5.570 municípios |

Os arquivos de notificação chegam com 60+ colunas, delimitador `;`, encoding
Latin-1 e aspas envolvendo tanto os nomes de coluna quanto o conteúdo das
células — tratamentos que a carga precisou absorver.

Dicionário de dados oficial em [`docs/dicionario-de-dados-esus-notifica.pdf`](docs/dicionario-de-dados-esus-notifica.pdf).

---

## O que foi encontrado

A parte mais interessante do trabalho não foi construir o pipeline, e sim o que
os dados revelaram ao serem cruzados. Nove inconsistências foram identificadas e
documentadas:

| Achado | Implicação |
|---|---|
| São Paulo sem código IBGE de município e estado | Impede o join com a tabela de municípios; exige tratamento específico |
| Espírito Santo concentra notificações em municípios-sede de laboratório | O município de notificação não representa onde o paciente reside |
| Goiás e Maranhão com inconsistência sistemática na data de início de sintomas | Padrão de erro na origem, não ruído aleatório |
| Notificações com data invertida | Data de notificação anterior ao início dos sintomas |
| Códigos não documentados em resultado de teste e em doses de vacina | Valores presentes nos dados mas ausentes do dicionário oficial |
| Alto percentual sem informação de vacinação e de local de testagem | Limita a confiabilidade dos recortes correspondentes |

A distinção entre **município de residência** e **município de notificação** se
mostrou central: tratá-los como equivalentes produz conclusões erradas sobre
distribuição geográfica dos casos.

O relatório técnico completo, com a análise de cada ponto, está em
[`docs/relatorio-tecnico.pdf`](docs/relatorio-tecnico.pdf). As decisões de
tratamento aplicadas na carga estão em
[`docs/tratamentos-da-carga.pdf`](docs/tratamentos-da-carga.pdf).

---

## Estrutura

```
├── README.md
├── etl/                                    # Projeto SSIS
│   ├── PKG_01_Carga_Notificacoes.dtsx      # Carga das notificações
│   ├── PKG_02_Carga_Municipios.dtsx        # Carga da DTB/IBGE
│   ├── CM_TesteEinstein_OLEDB.conmgr       # Gerenciador de conexão
│   └── TesteEinstein_ETL.dtproj
├── sql/
│   ├── 01_criar_tabela_notificacoes.sql    # DDL das notificações
│   ├── 02_criar_tabela_municipios.sql      # DDL dos municípios
│   └── 03_consultas_analiticas.sql         # Consultas, tabela de SP e DML
├── powerbi/
│   └── dashboard-sindrome-gripal.pbix
├── docs/
│   ├── relatorio-tecnico.pdf               # Documentação completa
│   ├── tratamentos-da-carga.pdf            # Decisões de tratamento no ETL
│   └── dicionario-de-dados-esus-notifica.pdf
└── data/
    ├── municipios-ibge-dtb.csv
    └── esus-notifica/
        ├── notificacoes-pr-2023.csv
        └── notificacoes-es-2023.csv
```

Os pacotes `.dtsx` e o `.pbix` estão versionados: o projeto SSIS pode ser aberto
no Visual Studio e o dashboard no Power BI Desktop, permitindo inspecionar o
fluxo de dados, o modelo e as medidas — não apenas o resultado.

---

## Decisões técnicas

### Carga (SSIS)

**Conversão de codepage.** Os CSVs de origem vêm em UTF-8 e a tabela de destino
usa collation `SQL_Latin1_General_CP1_CI_AS` (codepage 1252). Sem conversão,
caracteres acentuados seriam corrompidos na gravação. Resolvido por coluna
derivada, com `(DT_STR, <comprimento>, 1252)` em cada coluna de texto.

**Literal `"None"` antes da conversão de tipo.** Colunas de data e numéricas
chegam como texto, e parte dos registros traz `"None"` ou string vazia no lugar
de ausência. Cada uma foi tratada para virar `NULL` antes do cast — preservando
a ausência real do dado em vez de descartar a linha ou zerar o valor.

**Booleanos como BIT.** Campos `"true"`/`"false"` vêm como texto e foram
convertidos para `BIT`, tipo mais adequado para filtros e lógica condicional no
SQL e no Power BI.

**Remoção de aspas residuais.** Alguns arquivos trazem aspas tanto no cabeçalho
quanto dentro dos valores. Sem tratamento, `São Paulo` e `"São Paulo"` seriam
armazenados como valores distintos.

**Truncamento sem abortar a carga.** Colunas de texto ocasionalmente excedem o
tamanho do destino. Em vez de interromper a carga inteira por poucas linhas, a
saída de erro do Data Flow é redirecionada e contabilizada numa variável — o
problema fica registrado sem travar o processamento.

**Nomes de arquivo variáveis.** O pacote percorre o diretório de origem em vez
de apontar para arquivos fixos, atendendo ao requisito de absorver novas cargas
sem alteração.

### Modelagem e consultas

**Hierarquia geográfica do IBGE preservada.** A DTB traz região intermediária,
região imediata, mesorregião e microrregião. Manter essa cadeia no modelo é o
que viabiliza a navegação hierárquica no dashboard.

**Residência separada de notificação.** As consultas contemplam as duas visões
explicitamente, porque agregá-las distorce a leitura geográfica — o município
que notifica frequentemente não é onde o paciente reside.

## Fontes

- [Notificações de Síndrome Gripal — OpenDataSUS](https://opendatasus.saude.gov.br/dataset/notificacoes-de-sindrome-gripal-leve-2023)
- [Divisão Territorial Brasileira — IBGE](https://www.ibge.gov.br/geociencias/organizacao-do-territorio/estrutura-territorial/23701-divisao-territorial-brasileira.html)

---

**Rafael Cardoso Nascimento** · [GitHub](https://github.com/RafaelCardoso140701)
