# Padronizar bairros

Padroniza um vetor de caracteres representando bairros de municípios
brasileiros. Veja a seção *Detalhes* para mais informações sobre a
padronização.

## Usage

``` r
padronizar_bairros(bairros)
```

## Arguments

- bairros:

  Um vetor de caracteres. Os bairros a serem padronizados.

## Value

Um vetor de caracteres com os bairros padronizados.

## Detalhes

Operações realizadas durante a padronização:

- remoção de espaços em branco antes e depois das strings e remoção de
  espaços em excesso entre palavras;

- conversão de caracteres para caixa alta;

- remoção de acentos e caracteres não ASCII;

- adição de espaços após abreviações sinalizadas por pontos;

- expansão de abreviações frequentemente utilizadas através de diversas
  [expressões regulares
  (regexes)](https://en.wikipedia.org/wiki/Regular_expression);

- correção de alguns pequenos erros ortográficos.

## Examples

``` r
bairros <- c("PRQ IND", "NSA SEN DE FATIMA", "ILHA DO GOV")
padronizar_bairros(bairros)
#> [1] "PARQUE INDUSTRIAL"       "NOSSA SENHORA DE FATIMA"
#> [3] "ILHA DO GOVERNADOR"     
```
