# Padronizar logradouros completos

Padroniza o logradouro completo a partir de diversos campos (tipo de
logradouro, nome do logradouro e número), garantindo a consistência da
informação.

## Usage

``` r
padronizar_logradouros_completos(
  enderecos,
  campos_do_logradouro = correspondencia_logradouro(),
  manter_cols_extras = TRUE,
  checar_tipos = FALSE
)
```

## Arguments

- enderecos:

  Um dataframe. Os endereços a serem padronizados. Ao menos uma de suas
  colunas deve corresponder a um campo do logradouro.

- campos_do_logradouro:

  Um vetor nomeado de caracteres. A correspondência entre os campos a
  serem padronizados (nomes do vetor) e as colunas que os representam no
  dataframe (valores do vetor). A função
  [`correspondencia_logradouro()`](https://ipeagit.github.io/enderecobr/reference/correspondencia_logradouro.md)
  facilita a criação deste vetor, fazendo também algumas verificações do
  conteúdo imputado. Caso deseje criar o vetor manualmente, note que
  seus nomes devem ser os mesmos nomes dos parâmetros da função
  [`correspondencia_logradouro()`](https://ipeagit.github.io/enderecobr/reference/correspondencia_logradouro.md).

- manter_cols_extras:

  Um logical. Se colunas não especificadas em `campos_do_logradouro`
  devem ser mantidas no output ou não (por exemplo, uma coluna com a
  informação de bairro ou com o id do conjunto de dados sendo
  padronizado). Por padrão, `TRUE`.

- checar_tipos:

  Um logical. Se a ocorrência de duplicatas entre os tipos e nomes dos
  logradouros deve ser verificada ao combiná-los (por exemplo, quando o
  tipo é descrito como "RUA" e o nome é descrito como "RUA BOTAFOGO").
  Por padrão, `FALSE`.

## Value

Caso `manter_cols_extras` seja `TRUE`, o mesmo dataframe de input, mas
sem as colunas descrevendo o logradouro e com uma coluna padronizada
adicional `logradouro_completo`. Caso `manter_cols_extras` seja `FALSE`,
um dataframe de apenas uma coluna, `logradouro_completo`.

## Examples

``` r
enderecos <- data.frame(
  id = 1,
  tipoLogradouro = "r",
  logradouro = "ns sra da piedade",
  nroLogradouro = 20,
  complemento = "qd 20",
  cep = 25220020,
  bairro = "jd botanico",
  codmun_dom = 3304557,
  uf_dom = "rj"
)

campos <- correspondencia_logradouro(
  tipo_de_logradouro = "tipoLogradouro",
  nome_do_logradouro = "logradouro",
  numero = "nroLogradouro"
)

padronizar_logradouros_completos(enderecos, campos)
#>       id tipoLogradouro        logradouro nroLogradouro complemento      cep
#>    <num>         <char>            <char>         <num>      <char>    <num>
#> 1:     1              r ns sra da piedade            20       qd 20 25220020
#>         bairro codmun_dom uf_dom        logradouro_completo_padr
#>         <char>      <num> <char>                          <char>
#> 1: jd botanico    3304557     rj RUA NOSSA SENHORA DA PIEDADE 20

padronizar_logradouros_completos(
  enderecos,
  campos,
  manter_cols_extras = FALSE
)
#>    tipoLogradouro        logradouro nroLogradouro
#>            <char>            <char>         <num>
#> 1:              r ns sra da piedade            20
#>           logradouro_completo_padr
#>                             <char>
#> 1: RUA NOSSA SENHORA DA PIEDADE 20

enderecos <- data.frame(
  tipoLogradouro = "r",
  logradouro = "r ns sra da piedade",
  nroLogradouro = 20
)
padronizar_logradouros_completos(enderecos, campos, checar_tipos = TRUE)
#>    tipoLogradouro          logradouro nroLogradouro
#>            <char>              <char>         <num>
#> 1:              r r ns sra da piedade            20
#>           logradouro_completo_padr
#>                             <char>
#> 1: RUA NOSSA SENHORA DA PIEDADE 20
```
