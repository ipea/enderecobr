# Padronizar CEPs

Padroniza um vetor de caracteres ou números representando CEPs. Veja a
seção *Detalhes* para mais informações sobre a padronização.

## Usage

``` r
padronizar_ceps(ceps)
```

## Arguments

- ceps:

  Um vetor de caracteres ou números. Os CEPs a serem padronizados.

## Value

Um vetor de caracteres com os CEPs padronizados.

## Detalhes

Operações realizadas durante a padronização:

- conversão para caracter, se o input for numérico;

- adição de zeros à esquerda, se o input contiver menos de 8 dígitos;

- remoção de espaços em branco, pontos e vírgulas;

- adição de traço separando o radical (5 primeiros dígitos) do sufixo (3
  últimos digitos).

## Examples

``` r
ceps <- c("22290-140", "22.290-140", "22290 140", "22290140")
padronizar_ceps(ceps)
#> [1] "22290-140" "22290-140" "22290-140" "22290-140"

ceps <- c(22290140, 1000000, NA)
padronizar_ceps(ceps)
#> [1] "22290-140" "01000-000" NA         
```
