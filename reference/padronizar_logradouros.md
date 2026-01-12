# Padronizar logradouros

Padroniza um vetor de caracteres representando logradouros de municípios
brasileiros. Veja a seção *Detalhes* para mais informações sobre a
padronização.

## Usage

``` r
padronizar_logradouros(logradouros)
```

## Arguments

- logradouros:

  Um vetor de caracteres. Os logradouros a serem padronizados.

## Value

Um vetor de caracteres com os logradouros padronizados.

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
logradouros <- c("r. gen.. glicério")
padronizar_logradouros(logradouros)
#> [1] "RUA GENERAL GLICERIO"
```
