# Padronizar números de logradouros

Padroniza um vetor de caracteres ou números representando números de
logradouros. Veja a seção *Detalhes* para mais informações sobre a
padronização.

## Usage

``` r
padronizar_numeros(numeros, formato = "character")
```

## Arguments

- numeros:

  Um vetor de caracteres ou números. Os números de logradouro a serem
  padronizados.

- formato:

  Uma string. Como o resultado padronizado deve ser formatado. Por
  padrão, `"character"`, fazendo com que a função retorne um vetor de
  caracteres. Se `"integer"`, a função retorna um vetor de números
  inteiros.

## Value

Um vetor de caracteres com os números de logradouros padronizados.

## Detalhes

Operações realizadas durante a padronização:

- conversão para caracter, se o input for numérico;

- remoção de espaços em branco antes e depois dos números e de espaços
  em branco em excesso entre números;

- remoção de zeros à esquerda;

- substituição de números vazios e de variações de SN (SN, S N, S.N.,
  S./N., etc) por S/N.

## Examples

``` r
numeros <- c("0210", "001", "1", "", "S N", "S/N", "SN", "0180  0181")
padronizar_numeros(numeros)
#> [1] "210"     "1"       "1"       "S/N"     "S/N"     "S/N"     "S/N"    
#> [8] "180 181"

numeros <- c(210, 1, 10000, NA)
padronizar_numeros(numeros)
#> [1] "210"   "1"     "10000" "S/N"  
```
