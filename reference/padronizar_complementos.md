# Padronizar complementos

Padroniza um vetor de caracteres representando complementos de
logradouros. Veja a seção *Detalhes* para mais informações sobre a
padronização.

## Usage

``` r
padronizar_complementos(complementos)
```

## Arguments

- complementos:

  Um vetor de caracteres. Os complementos a serem padronizados.

## Value

Um vetor de caracteres com os complementos padronizados.

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
complementos <- c("", "QD1 LT2 CS3", "APTO. 405")
padronizar_complementos(complementos)
#> [1] NA                       "QUADRA 1 LOTE 2 CASA 3" "APARTAMENTO 405"       
```
