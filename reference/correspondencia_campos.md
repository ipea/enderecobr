# Correspondência entre os campos do endereço e as colunas que os descrevem

Cria um vetor de caracteres que especifica as colunas que representam
cada campo de endereço em um dataframe.

## Usage

``` r
correspondencia_campos(
  tipo_de_logradouro = NULL,
  logradouro = NULL,
  numero = NULL,
  complemento = NULL,
  cep = NULL,
  bairro = NULL,
  municipio = NULL,
  estado = NULL
)
```

## Arguments

- tipo_de_logradouro, logradouro, numero, complemento, cep, bairro,
  municipio, estado:

  Uma string. O nome da coluna que representa o respectivo campo de
  endereço no dataframe. Pode ser `NULL`, no caso do campo não estar
  listado. Ao menos um dos campos deve receber um valor não nulo.

## Value

Um vetor nomeado de caracteres, em que os nomes representam os campos do
endereço e os valores as colunas que os descrevem no dataframe.

## Examples

``` r
enderecos <- data.frame(
  id = 1,
  tipo = "r",
  log = "ns sra da piedade",
  nroLogradouro = 20,
  compl = "qd 20",
  cep = 25220020,
  bairro = "jd botanico",
  codmun_dom = 3304557,
  uf_dom = "rj"
)

# dado o dataframe acima, a seguinte chamada cria a correspondencia entre
# suas colunas e os campos
correspondencia_campos(
  tipo_de_logradouro = "tipo",
  logradouro = "log",
  numero = "nroLogradouro",
  complemento = "compl",
  cep = "cep",
  bairro = "bairro",
  municipio = "codmun_dom",
  estado = "uf_dom"
)
#> tipo_de_logradouro         logradouro             numero        complemento 
#>             "tipo"              "log"    "nroLogradouro"            "compl" 
#>                cep             bairro          municipio             estado 
#>              "cep"           "bairro"       "codmun_dom"           "uf_dom" 
```
