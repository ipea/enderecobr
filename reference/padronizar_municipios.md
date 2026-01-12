# Padronizar municípios

Padroniza um vetor de caracteres ou números representando municípios
brasileiros. Veja a seção *Detalhes* para mais informações sobre a
padronização.

## Usage

``` r
padronizar_municipios(municipios)
```

## Arguments

- municipios:

  Um vetor de caracteres ou números. Os municípios a serem padronizados.

## Value

Um vetor de caracteres com os municípios padronizados.

## Detalhes

Operações realizadas durante a padronização:

- conversão para caracter, se o input for numérico;

- remoção de espaços em branco antes e depois dos valores e remoção de
  espaços em excesso entre palavras;

- conversão de caracteres para caixa alta;

- remoção de zeros à esquerda;

- busca, a partir do código numérico, do nome completo de cada
  município;

- caso a busca não tenha encontrado determinado valor, remoção de
  acentos e caracteres não ASCII, correção de erros ortográficos
  frequentes e atualização de nomes conforme listagem de municípios do
  IBGE de 2022.

## Examples

``` r
municipios <- c(
  "3304557", "003304557", " 3304557 ", "RIO DE JANEIRO", "rio de janeiro",
  "SÃO PAULO",
  "", NA
)
padronizar_municipios(municipios)
#> [1] "RIO DE JANEIRO" "RIO DE JANEIRO" "RIO DE JANEIRO" "RIO DE JANEIRO"
#> [5] "RIO DE JANEIRO" "SAO PAULO"      NA               NA              

municipios <- c(3304557, NA)
padronizar_municipios(municipios)
#> [1] "RIO DE JANEIRO" NA              

municipios <- c("PARATI", "AUGUSTO SEVERO", "SAO VALERIO DA NATIVIDADE")
padronizar_municipios(municipios)
#> [1] "PARATY"       "CAMPO GRANDE" "SAO VALERIO" 
```
