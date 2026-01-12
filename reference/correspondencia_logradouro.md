# Correspondência entre os campos do logradouro completo e as colunas que os descrevem

Cria um vetor de caracteres que especifica as colunas que representam os
campos de logradouro (tipo, nome e número) em um dataframe de endereços.

## Usage

``` r
correspondencia_logradouro(
  tipo_de_logradouro = NULL,
  nome_do_logradouro = NULL,
  numero = NULL
)
```

## Arguments

- tipo_de_logradouro, nome_do_logradouro, numero:

  Uma string. O nome da coluna que representa o respectivo campo do
  logradouro no dataframe. Pode ser `NULL`, no caso do campo não estar
  listado. Ao menos um dos campos deve receber um valor não nulo.

## Value

Um vetor nomeado de caracteres, em que os nomes representam os campos do
logradouro e os valores as colunas que os descrevem no dataframe.

## Examples

``` r
enderecos <- data.frame(
  tipo = "r",
  log = "ns sra da piedade",
  nroLogradouro = 20
)

# dado o dataframe acima, a seguinte chamada cria a correspondencia entre
# suas colunas e os campos
correspondencia_logradouro(
  tipo_de_logradouro = "tipo",
  nome_do_logradouro = "log",
  numero = "nroLogradouro"
)
#> tipo_de_logradouro nome_do_logradouro             numero 
#>             "tipo"              "log"    "nroLogradouro" 
```
