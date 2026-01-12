# Padronizar endereços

Padroniza simultaneamente os diversos campos de um endereço listados em
um dataframe.

## Usage

``` r
padronizar_enderecos(
  enderecos,
  campos_do_endereco = correspondencia_campos(),
  formato_estados = "por_extenso",
  formato_numeros = "character",
  manter_cols_extras = TRUE,
  combinar_logradouro = FALSE,
  checar_tipos = FALSE
)
```

## Arguments

- enderecos:

  Um dataframe. Os endereços a serem padronizados. Cada uma de suas
  colunas deve corresponder a um campo do endereço (e.g. logradouro,
  cidade, bairro, etc).

- campos_do_endereco:

  Um vetor nomeado de caracteres. A correspondência entre os campos a
  serem padronizados (nomes do vetor) e as colunas que os representam no
  dataframe (valores em si). A função
  [`correspondencia_campos()`](https://ipeagit.github.io/enderecobr/reference/correspondencia_campos.md)
  facilita a criação deste vetor, fazendo também algumas verificações do
  conteúdo imputado. Argumentos dessa função com valor `NULL` são
  ignorados, e ao menos um valor diferente de nulo deve ser fornecido.
  Caso deseje criar o vetor manualmente, note que seus nomes devem ser
  os mesmos nomes dos parâmetros da função
  [`correspondencia_campos()`](https://ipeagit.github.io/enderecobr/reference/correspondencia_campos.md).

- formato_estados:

  Uma string. Como o estado padronizado deve ser formatado. Por padrão,
  `"por_extenso"`, fazendo com que a função retorne o nome dos estados
  por extenso. Se `"sigla"`, a função retorna a sigla dos estados.

- formato_numeros:

  Uma string. Como o número padronizado deve ser formatado. Por padrão,
  `"character"`, fazendo com que a função retorne o número como
  caractere. Se `"integer"`, a função retorna o número como inteiro.

- manter_cols_extras:

  Um logical. Se colunas não especificadas em `campos_do_endereco` devem
  ser mantidas ou não (por exemplo, uma coluna de id do conjunto de
  dados sendo padronizado). Por padrão, `TRUE`.

- combinar_logradouro:

  Um logical. Se os campos que descrevem o logradouro (tipo, nome e
  número, por exemplo) devem ser combinados em um único campo de
  logradouro completo. Nesse caso, o parâmetro `logradouro` da
  [`correspondencia_campos()`](https://ipeagit.github.io/enderecobr/reference/correspondencia_campos.md)
  deve ser interpretado como o nome do logradouro. Por padrão, `FALSE`.

- checar_tipos:

  Um logical. Apenas tem efeito quando `combinar_logradouro` é `TRUE`.
  Se a ocorrência de duplicatas entre os tipos e nomes dos logradouros
  deve ser verificada ao combiná-los (por exemplo, quando o tipo é
  descrito como "RUA" e o nome é descrito como "RUA BOTAFOGO"). Por
  padrão, `FALSE`.

## Value

Um dataframe com colunas adicionais, representando os campos de endereço
padronizados.

## Examples

``` r
enderecos <- data.frame(
  id = 1,
  logradouro = "r ns sra da piedade",
  nroLogradouro = 20,
  complemento = "qd 20",
  cep = 25220020,
  bairro = "jd botanico",
  codmun_dom = 3304557,
  uf_dom = "rj"
)

campos <- correspondencia_campos(
  logradouro = "logradouro",
  numero = "nroLogradouro",
  complemento = "complemento",
  cep = "cep",
  bairro = "bairro",
  municipio = "codmun_dom",
  estado = "uf_dom"
)

padronizar_enderecos(enderecos, campos)
#>       id          logradouro nroLogradouro complemento      cep      bairro
#>    <num>              <char>         <num>      <char>    <num>      <char>
#> 1:     1 r ns sra da piedade            20       qd 20 25220020 jd botanico
#>    codmun_dom uf_dom              logradouro_padr numero_padr complemento_padr
#>         <num> <char>                       <char>      <char>           <char>
#> 1:    3304557     rj RUA NOSSA SENHORA DA PIEDADE          20        QUADRA 20
#>     cep_padr     bairro_padr municipio_padr    estado_padr
#>       <char>          <char>         <char>         <char>
#> 1: 25220-020 JARDIM BOTANICO RIO DE JANEIRO RIO DE JANEIRO

padronizar_enderecos(enderecos, campos, manter_cols_extras = FALSE)
#>             logradouro nroLogradouro complemento      cep      bairro
#>                 <char>         <num>      <char>    <num>      <char>
#> 1: r ns sra da piedade            20       qd 20 25220020 jd botanico
#>    codmun_dom uf_dom              logradouro_padr numero_padr complemento_padr
#>         <num> <char>                       <char>      <char>           <char>
#> 1:    3304557     rj RUA NOSSA SENHORA DA PIEDADE          20        QUADRA 20
#>     cep_padr     bairro_padr municipio_padr    estado_padr
#>       <char>          <char>         <char>         <char>
#> 1: 25220-020 JARDIM BOTANICO RIO DE JANEIRO RIO DE JANEIRO

padronizar_enderecos(enderecos, campos, combinar_logradouro = TRUE)
#>       id          logradouro nroLogradouro complemento      cep      bairro
#>    <num>              <char>         <num>      <char>    <num>      <char>
#> 1:     1 r ns sra da piedade            20       qd 20 25220020 jd botanico
#>    codmun_dom uf_dom        logradouro_completo_padr complemento_padr  cep_padr
#>         <num> <char>                          <char>           <char>    <char>
#> 1:    3304557     rj RUA NOSSA SENHORA DA PIEDADE 20        QUADRA 20 25220-020
#>        bairro_padr municipio_padr    estado_padr
#>             <char>         <char>         <char>
#> 1: JARDIM BOTANICO RIO DE JANEIRO RIO DE JANEIRO

ends_tipo_duplicado <- data.frame(tipo = "r", nome = "r ns sra da piedade")

padronizar_enderecos(
  ends_tipo_duplicado,
  campos_do_endereco = correspondencia_campos(
    tipo_de_logradouro = "tipo",
    logradouro = "nome"
  ),
  combinar_logradouro = TRUE,
  checar_tipos = TRUE
)
#>      tipo                nome     logradouro_completo_padr
#>    <char>              <char>                       <char>
#> 1:      r r ns sra da piedade RUA NOSSA SENHORA DA PIEDADE
```
