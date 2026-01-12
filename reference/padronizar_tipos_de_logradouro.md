# Padronizar tipos de logradouro

Padroniza um vetor de caracteres representando tipos de logradouro. Veja
a seção *Detalhes* para mais informações sobre a padronização.

## Usage

``` r
padronizar_tipos_de_logradouro(tipos)
```

## Arguments

- tipos:

  Um vetor de caracteres. Os tipos de logradouro a serem padronizados.

## Value

Um vetor de caracteres com os tipos de logradouro padronizados.

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
tipos <- c("R", "AVE", "QDRA")
padronizar_tipos_de_logradouro(tipos)
#> [1] "RUA"     "AVENIDA" "QUADRA" 
```
