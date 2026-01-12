# Padronizar estados

Padroniza um vetor de caracteres ou números representando estados
brasileiros. Veja a seção *Detalhes* para mais informações sobre a
padronização.

## Usage

``` r
padronizar_estados(estados, formato = "por_extenso")
```

## Arguments

- estados:

  Um vetor de caracteres ou números. Os estados a serem padronizados.

- formato:

  Uma string. Como o resultado padronizado deve ser formatado. Por
  padrão, `"por_extenso"`, fazendo com que a função retorne o nome dos
  estados por extenso. Se `"sigla"`, a função retorna a sigla dos
  estados.

## Value

Um vetor de caracteres com os estados padronizados.

## Detalhes

Operações realizadas durante a padronização:

- conversão para caracter, se o input for numérico;

- remoção de espaços em branco antes e depois dos valores e remoção de
  espaços em excesso entre palavras;

- conversão de caracteres para caixa alta;

- remoção de zeros à esquerda;

- busca, a partir do código numérico ou da abreviação da UF, do nome
  completo de cada estado;

- caso a busca não tenha encontrado determinado valor, remoção de
  acentos e caracteres não ASCII.

## Examples

``` r
estados <- c("21", "021", "MA", " 21", " MA ", "ma", "", NA)
padronizar_estados(estados)
#> [1] "MARANHAO" "MARANHAO" "MARANHAO" "MARANHAO" "MARANHAO" "MARANHAO" NA        
#> [8] NA        

estados <- c(21, NA)
padronizar_estados(estados)
#> [1] "MARANHAO" NA        
padronizar_estados(estados, formato = "sigla")
#> [1] "MA" NA  
```
