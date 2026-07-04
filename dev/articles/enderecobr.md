# enderecobr: padronizador de endereços brasileiros

**enderecobr** é um pacote de R que permite padronizar endereços
brasileiros a partir de diferentes critérios. Os métodos de padronização
atualmente incluem apenas manipulações de strings, não oferecendo
suporte a correspondências probabilísticas entre strings.

## Instalação

A última versão estável pode ser baixada do CRAN com o comando a seguir:

``` r

install.packages("enderecobr")
```

Caso prefira, a versão em desenvolvimento também pode ser usada. Para
isso, use o seguinte comando:

``` r

# install.packages("remotes")
remotes::install_github("ipeaGIT/enderecobr")
```

## Utilização

O **enderecobr** disponibiliza funções para padronizar os diversos
campos de um endereço. Essas funções agem tanto sobre campos individuais
quanto sobre um conjunto de campos. Vamos ver, primeiro, como funcionam
as funções que agem sobre múltiplos campos simultaneamente.

### Padronização de múltiplos campos simultaneamente

A
[`padronizar_enderecos()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_enderecos.md),
carro-chefe do pacote, atua de forma simultânea sobre os vários campos
que podem compor um endereço. Para isso, ela recebe um dataframe e a
correspondência entre suas colunas e os campos a serem padronizados:

``` r

library(enderecobr)

enderecos <- data.frame(
  id = 1,
  tipo = "r",
  logradouro = "ns sra da piedade",
  nroLogradouro = 20,
  complemento = "qd 20",
  cep = 25220020,
  bairro = "jd botanico",
  codmun_dom = 3304557,
  uf_dom = "rj"
)

campos <- correspondencia_campos(
  tipo_de_logradouro = "tipo",
  logradouro = "logradouro",
  numero = "nroLogradouro",
  complemento = "complemento",
  cep = "cep",
  bairro = "bairro",
  municipio = "codmun_dom",
  estado = "uf_dom"
)

padronizar_enderecos(enderecos, campos_do_endereco = campos)
#>       id   tipo        logradouro nroLogradouro complemento      cep
#>    <num> <char>            <char>         <num>      <char>    <num>
#> 1:     1      r ns sra da piedade            20       qd 20 25220020
#>         bairro codmun_dom uf_dom tipo_de_logradouro_padr
#>         <char>      <num> <char>                  <char>
#> 1: jd botanico    3304557     rj                     RUA
#>             logradouro_padr numero_padr complemento_padr  cep_padr
#>                      <char>      <char>           <char>    <char>
#> 1: NOSSA SENHORA DA PIEDADE          20        QUADRA 20 25220-020
#>        bairro_padr municipio_padr    estado_padr
#>             <char>         <char>         <char>
#> 1: JARDIM BOTANICO RIO DE JANEIRO RIO DE JANEIRO
```

Note que no exemplo acima nós também utiliza a função
[`correspondencia_campos()`](https://ipeagit.github.io/enderecobr/dev/reference/correspondencia_campos.md),
que facilita o processo de especificação de correspondência entre as
colunas do dataframe e os campos do endereço a serem padronizados. Com
ela, nós especificamos que a coluna que contém a informação de tipo de
logradouro se chama `"tipo"`, que a coluna de número do logradouro se
chama `"nroLogradouro"`, etc. Na prática, no entanto, essa função é
opcional, e poderíamos simplesmente passar um vetor de caracteres no
formato
`c(tipo_de_logradouro = "tipo", logradouro = "logradouro", ...)`. A
[`correspondencia_campos()`](https://ipeagit.github.io/enderecobr/dev/reference/correspondencia_campos.md),
no entanto, realiza alguns testes no input, garantindo que o vetor a ser
passado pra
[`padronizar_enderecos()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_enderecos.md)
esteja corretamente formatado.

A
[`padronizar_enderecos()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_enderecos.md)
contém, ainda, cinco parâmetros adicionais. O `formato_estados` e o
`formato_numeros` controlam como os estados e números padronizados,
respectivamente, devem ser formatados. Caso `formato_estados` seja
`"por_extenso"` (valor padrão), a função retorna o nome dos estados por
extenso; caso seja `"sigla"`, os estados são padronizados conforme suas
respectivas siglas. Por sua vez, caso `formato_numeros` seja
`"character"`, a função retorna os números padronizados como caracteres,
preservando valores como `"S/N"`, que possuem letras e outros dígitos
que não podem ser convertidos para valores numéricos; caso seja
`"integer"`, no entanto, os números são retornados como valores
inteiros. Caso algum valor não possa ser convertido para inteiro, a
função o substitui por `NA` e lança um warning alertando sobre a
situação. Os exemplos a seguir demonstram esses parâmetros
detalhadamente:

``` r

campos <- correspondencia_campos(
  numero = "nroLogradouro",
  estado = "uf_dom"
)

padronizar_enderecos(
  enderecos[, c("nroLogradouro", "uf_dom")],
  campos,
  formato_estados = "por_extenso",
  formato_numeros = "character"
)
#>    nroLogradouro uf_dom numero_padr    estado_padr
#>            <num> <char>      <char>         <char>
#> 1:            20     rj          20 RIO DE JANEIRO

padronizar_enderecos(
  enderecos[, c("nroLogradouro", "uf_dom")],
  campos,
  formato_estados = "sigla",
  formato_numeros = "integer"
)
#>    nroLogradouro uf_dom numero_padr estado_padr
#>            <num> <char>       <int>      <char>
#> 1:            20     rj          20          RJ

# o exemplo abaixo gera um warning, pois o número não pode ser convertido para
# inteiro de forma adequada

padronizar_enderecos(
  data.table::data.table(numero = "12A 13B"),
  correspondencia_campos(numero = "numero"),
  formato_numeros = "integer"
)
#> Warning in padronizar_enderecos(data.table::data.table(numero = "12A 13B"), : Alguns números não puderam ser convertidos para integer, introduzindo NAs no
#> resultado.
#>     numero numero_padr
#>     <char>       <int>
#> 1: 12A 13B          NA
```

O `manter_cols_extras` determina as colunas incluídas no output da
função. Caso seja `TRUE` (valor padrão), todas as colunas do dataframe
original são mantidas; caso seja `FALSE`, apenas as colunas usadas na
padronização e seus respectivos resultados são preservados. O bloco
abaixo demonstra essa funcionalidade:

``` r

campos <- correspondencia_campos(
  tipo_de_logradouro = "tipo",
  logradouro = "logradouro"
)

padronizar_enderecos(enderecos, campos, manter_cols_extras = TRUE)
#>       id nroLogradouro complemento      cep      bairro codmun_dom uf_dom
#>    <num>         <num>      <char>    <num>      <char>      <num> <char>
#> 1:     1            20       qd 20 25220020 jd botanico    3304557     rj
#>      tipo        logradouro tipo_de_logradouro_padr          logradouro_padr
#>    <char>            <char>                  <char>                   <char>
#> 1:      r ns sra da piedade                     RUA NOSSA SENHORA DA PIEDADE

padronizar_enderecos(enderecos, campos, manter_cols_extras = FALSE)
#>      tipo        logradouro tipo_de_logradouro_padr          logradouro_padr
#>    <char>            <char>                  <char>                   <char>
#> 1:      r ns sra da piedade                     RUA NOSSA SENHORA DA PIEDADE
```

O `combinar_logradouro`, por sua vez, determina se os campos que compõem
o logradouro (tipo, nome e número) devem ser combinados em um único
campo padronizado de logradouro completo. Caso seja `FALSE`(valor
padrão), os campos permanecem separados; se for `TRUE`, são combinados.
Nesse caso, o parâmetro `logradouro` da
[`correspondencia_campos()`](https://ipeagit.github.io/enderecobr/dev/reference/correspondencia_campos.md)
deve ser interpretado como o *nome* do logradouro. A seguir,
demonstramos essa funcionalidade:

``` r

enderecos <- data.frame(
  tipo = "r",
  logradouro = "ns sra da piedade",
  nroLogradouro = 20
)

campos <- correspondencia_campos(
  tipo_de_logradouro = "tipo",
  logradouro = "logradouro",
  numero = "nroLogradouro"
)

padronizar_enderecos(enderecos, campos, combinar_logradouro = FALSE)
#>      tipo        logradouro nroLogradouro tipo_de_logradouro_padr
#>    <char>            <char>         <num>                  <char>
#> 1:      r ns sra da piedade            20                     RUA
#>             logradouro_padr numero_padr
#>                      <char>      <char>
#> 1: NOSSA SENHORA DA PIEDADE          20

padronizar_enderecos(enderecos, campos, combinar_logradouro = TRUE)
#>      tipo        logradouro nroLogradouro        logradouro_completo_padr
#>    <char>            <char>         <num>                          <char>
#> 1:      r ns sra da piedade            20 RUA NOSSA SENHORA DA PIEDADE 20
```

O quinto parâmetro, `checar_tipos`, tem efeito apenas quando
`combinar_logradouro` é `TRUE`, e deve ser usado para sinalizar se a
ocorrência de duplicatas entre os tipos e nomes de logradouros deve ser
verificada ao combiná-los (por exemplo, quando o tipo é descrito como
“RUA” e o nome como “RUA BOTAFOGO”). Caso seja `FALSE` (valor padrão), a
verificação não é feita; se for `TRUE`, a verificação é realizada e
valores duplicados são removidos, como apresentado a seguir:

``` r

enderecos <- data.frame(
  tipo = "r",
  logradouro = "r ns sra da piedade",
  nroLogradouro = 20
)

padronizar_enderecos(
  enderecos,
  campos,
  combinar_logradouro = TRUE,
  checar_tipos = FALSE
)
#>      tipo          logradouro nroLogradouro            logradouro_completo_padr
#>    <char>              <char>         <num>                              <char>
#> 1:      r r ns sra da piedade            20 RUA RUA NOSSA SENHORA DA PIEDADE 20

padronizar_enderecos(
  enderecos,
  campos,
  combinar_logradouro = TRUE,
  checar_tipos = TRUE
)
#>      tipo          logradouro nroLogradouro        logradouro_completo_padr
#>    <char>              <char>         <num>                          <char>
#> 1:      r r ns sra da piedade            20 RUA NOSSA SENHORA DA PIEDADE 20
```

Os parâmetros `combinar_logradouro` e `checar_tipos` acionam, de forma
oculta, outra função que lida com múltiplos campos simultaneamente: a
[`padronizar_logradouros_completos()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_logradouros_completos.md).
Essa função também pode ser usada de forma separada e, de forma similiar
à
[`padronizar_enderecos()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_enderecos.md),
recebe um dataframe com as informações do logradouro (tipo, nome e
número) e a correspondência entre suas colunas e os campos a serem
padronizados:

``` r

campos <- correspondencia_logradouro(
  tipo_de_logradouro = "tipo",
  nome_do_logradouro = "logradouro",
  numero = "nroLogradouro"
)

padronizar_logradouros_completos(enderecos, campos_do_logradouro = campos)
#>      tipo          logradouro nroLogradouro            logradouro_completo_padr
#>    <char>              <char>         <num>                              <char>
#> 1:      r r ns sra da piedade            20 RUA RUA NOSSA SENHORA DA PIEDADE 20
```

Note que, nesse caso, usamos a função `campos_do_logradouro()` para
estabelecer a correspondência entre colunas e campos do endereço, mas
também poderíamos passar um vetor de caracteres no argumento
`campos_do_logradouro`. A
[`padronizar_logradouros_completos()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_logradouros_completos.md)
também inclui os parâmetros `manter_cols_extras` e `checar_tipos`, que
funcionam de forma idêntica aos parâmetros de mesmo nome da
[`padronizar_enderecos()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_enderecos.md).

### Padronização de campos individuais

Por trás dos panos, tanto a
[`padronizar_enderecos()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_enderecos.md)
quanto a
[`padronizar_logradouros_completos()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_logradouros_completos.md)
utilizam diversas outras funções que padronizam campos de forma
individual. Cada uma delas recebe um vetor com valores não padronizados
e retorna um vetor de mesmo tamanho com os respectivos valores
padronizados. As funções atualmente disponíveis são:

- [`padronizar_estados()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_estados.md)
- [`padronizar_municipios()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_municipios.md)
- [`padronizar_bairros()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_bairros.md)
- [`padronizar_ceps()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_ceps.md)
- [`padronizar_logradouros()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_logradouros.md)
- [`padronizar_numeros()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_numeros.md)
- [`padronizar_tipos_de_logradouro()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_tipos_de_logradouro.md)
- [`padronizar_complementos()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_complementos.md)

A
[`padronizar_estados()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_estados.md)
aceita vetores de strings e números. Caso numérico, o vetor deve conter
o [código do
IBGE](https://www.ibge.gov.br/explica/codigos-dos-municipios.php) de
cada estado. Caso seja composto de strings, o vetor pode conter a sigla
do estado, seu código ou seu nome por extenso. O parâmetro `formato`
controla como o output deve ser padronizado, se conforme a sigla de cada
estado (`"sigla"`) ou se conforme seu nome por extenso (`"por_extenso"`,
valor padrão). Quando recebe um vetor de strings, a função aplica
diversas manipulações para chegar a um valor padronizado, como a
conversão de caracteres para caixa alta, remoção de acentos e caracteres
não ASCII e remoção de espaços em branco antes e depois dos valores e de
espaços em excesso entre palavras. O código abaixo apresenta exemplos de
aplicação da função.

``` r

estados <- c("21", " 21", "MA", " MA ", "ma", "MARANHÃO")
padronizar_estados(estados)
#> [1] "MARANHAO" "MARANHAO" "MARANHAO" "MARANHAO" "MARANHAO" "MARANHAO"

padronizar_estados(estados, formato = "sigla")
#> [1] "MA" "MA" "MA" "MA" "MA" "MA"

estados <- c(21, 32)
padronizar_estados(estados)
#> [1] "MARANHAO"       "ESPIRITO SANTO"
```

A função de padronização de campos de município,
[`padronizar_municipios()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_municipios.md),
funciona de forma muito semelhante, aceitando também valores numéricos
representando os códigos dos municípios e strings. As mesmas
manipulações de remoção de espaços, conversão para caixa alta e
conversão para caracteres são aplicadas (assim como nos demais
tratamentos de vetores de strings que serão apresentados a seguir), mas
a função também verifica erros ortográficos frequentemente observados
nos nomes dos municípios (e.g. Moji Mirim -\> Mogi Mirim, Parati -\>
Paraty).

``` r

municipios <- c(
  "3304557", "003304557", " 3304557 ", "RIO DE JANEIRO", "rio de janeiro",
  "SÃO PAULO"
)
padronizar_municipios(municipios)
#> [1] "RIO DE JANEIRO" "RIO DE JANEIRO" "RIO DE JANEIRO" "RIO DE JANEIRO"
#> [5] "RIO DE JANEIRO" "SAO PAULO"

municipios <- 3304557
padronizar_municipios(municipios)
#> [1] "RIO DE JANEIRO"

municipios <- c("PARATI", "MOJI MIRIM")
padronizar_municipios(municipios)
#> [1] "PARATY"     "MOGI MIRIM"
```

A
[`padronizar_bairros()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_bairros.md)
trabalha exclusivamente com vetores de strings. Como os nomes de bairros
são muito mais variados e, consequentemente, menos rigidamente
controlados do que os de estados e municípios, a função se atém a
corrigir erros ortográficos e a expandir abreviações frequentemente
utilizadas através de diversas [expressões regulares
(regexes)](https://en.wikipedia.org/wiki/Regular_expression). O exemplo
abaixo mostra algumas das muitas abreviações usualmente empregadas no
preenchimento de endereços.

``` r

bairros <- c(
  "PRQ IND",
  "NSA SEN DE FATIMA",
  "ILHA DO GOV",
  "VL OLIMPICA",
  "NUC RES"
)
padronizar_bairros(bairros)
#> [1] "PARQUE INDUSTRIAL"       "NOSSA SENHORA DE FATIMA"
#> [3] "ILHA DO GOVERNADOR"      "VILA OLIMPICA"          
#> [5] "NUCLEO RESIDENCIAL"
```

A
[`padronizar_ceps()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_ceps.md)
é outro exemplo de função que trabalha com strings e números. Caso o
input seja numérico, a função verifica se os valores possuem
comprimentos compatíveis com um CEP, adicionando zeros à esquerda se
necessário (é muito comum que leitores de CSV, por exemplo, erroneamente
leiam valores de CEP como números e excluam zeros à esquerda por
considerá-los redundantes). Caso o input seja formado por strings, a
função remove caracteres que frequentemente são usados para separar
partes do CEP (e.g. pontos, vírgulas, espaços em branco) e verifica se o
hífen separando os cinco primeiros dígitos dos três últimos está
presente, adicionando-o caso contrário. A função ainda produz erros se
recebe como input valores que não podem ser corretamente convertidos em
CEPs, como no caso de strings contendo caracteres não numéricos e de
strings com caracteres em excesso.

``` r

ceps <- c("22290-140", "22.290-140", "22290 140", "22290140")
padronizar_ceps(ceps)
#> [1] "22290-140" "22290-140" "22290-140" "22290-140"

ceps <- c(22290140, 1000000)
padronizar_ceps(ceps)
#> [1] "22290-140" "01000-000"

padronizar_ceps("2229014a")
#> Error in `padronizar_ceps()`:
#> ! CEP não deve conter letras.
#> ℹ O elemento com índice 1 possui letras.

padronizar_ceps("022290140")
#> Error in `padronizar_ceps()`:
#> ! CEP não deve conter mais que 8 dígitos.
#> ℹ O elemento com índice 1 possui mais que 8 dígitos após padronização.
```

A tarefa de padronizar logradouros é a mais complexa dentre as
apresentadas até aqui, uma vez que o campo de logradouro é o que
apresenta maior variabilidade de input. A
[`padronizar_logradouros()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_logradouros.md),
portanto, assim como a função de padronização de bairros, se limita a
expandir abreviações frequentemente utilizadas e a corrigir alguns
poucos erros de digitação, fora o tratamento usual dado a strings, como
conversão para caixa alta, remoção de espaços em excesso e antes e
depois das strings, etc.

``` r

logradouros <- c(
  "r. gen.. glicério, 137",
  "cond pres j. k., qd 05 lt 02 1",
  "av d pedro I, 020"
)
padronizar_logradouros(logradouros)
#> [1] "RUA GENERAL GLICERIO, 137"                                    
#> [2] "CONDOMINIO PRESIDENTE JUSCELINO KUBITSCHEK, QUADRA 5 LOTE 2 1"
#> [3] "AVENIDA DOM PEDRO I, 20"
```

A
[`padronizar_numeros()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_numeros.md)
tem como objetivo padronizar o número do logradouro, caso este esteja em
um campo separado do logradouro propriamente dito. A função aceita
vetores de números e strings e retorna um vetor de strings ou inteiros,
a depender do parâmetro `formato` (que pode receber os valores
`"character"` e `"integer"`, auto-explicativos). Os tratamentos incluem
a remoção de zeros à esquerda, remoção de espaços em branco em excesso e
a substituição de variações de SN (sem número) por “S/N”. Note que o
equivalente de “S/N” quando o output é numérico é `NA`. Valores que não
puderem ser adequadamente convertidos para inteiro também são
substituídos por `NA`, o que é sinalizado por um warning.

``` r

numeros <- c("0210", "001", "1", "S N", "S/N", "SN", "0180  0181")
padronizar_numeros(numeros)
#> [1] "210"     "1"       "1"       "S/N"     "S/N"     "S/N"     "180 181"

# o exemplo abaixo gera um warning, pois "0180 0181" não pode ser adequadamente
# convertido para um único valor inteiro - as variações de S/N, por sua vez, já
# seriam convertidas para NA
numeros <- c("0210", "001", "1", "S N", "S/N", "SN", "0180  0181")
padronizar_numeros(numeros, formato = "integer")
#> Warning in padronizar_numeros(numeros, formato = "integer"): Alguns números não puderam ser convertidos para integer, introduzindo NAs no
#> resultado.
#> [1] 210   1   1  NA  NA  NA  NA

numeros <- c(210, 1, 10000)
padronizar_numeros(numeros)
#> [1] "210"   "1"     "10000"
```

Outra função que atua sobre uma informação específica do logradouro,
caso essa seja fornecida separadamente, é a
[`padronizar_tipos_de_logradouro()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_tipos_de_logradouro.md).
Fora o tratamento usual dado a strings, a função também expande
abreviações frequentemente observadas no campo de tipo de logradouro.

``` r

tipos <- c("r", "R.", "AVN", "AVE", "JDM", "QD")
padronizar_tipos_de_logradouro(tipos)
#> [1] "RUA"     "RUA"     "AVENIDA" "AVENIDA" "JARDIM"  "QUADRA"
```

Por fim, a
[`padronizar_complementos()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_complementos.md)
age de forma similar às funções de padronização de logradouros e
bairros, porém agindo de forma mais específica em abreviações e
observações frequentemente observados na especificação de complementos
de logradouros.

``` r

complementos <- c("QD1 LT2 CS3", "APTO. 405", "PRX CX POST 450")
padronizar_complementos(complementos)
#> [1] "QUADRA 1 LOTE 2 CASA 3"   "APARTAMENTO 405"         
#> [3] "PROXIMO CAIXA POSTAL 450"
```

### Controle de verbosidade

O disparo de mensagens com informações sobre a execução das funções pode
ser controlado pela opção `enderecobr.verbose`, que recebe os valores
`"quiet"` ou `"verbose"`, como demonstrado a seguir:

``` r

campos <- correspondencia_logradouro(
  nome_do_logradouro = "logradouro",
  numero = "nroLogradouro"
)

# quieto, por padrão
res <- padronizar_logradouros_completos(enderecos, campos)

# verboso, se desejado
rlang::local_options("enderecobr.verbose" = "verbose")
res <- padronizar_logradouros_completos(enderecos, campos)
#> ✔ Padronizando nomes dos logradouros... [130ms]
#> ✔ Padronizando números... [111ms]
#> ✔ Trazendo números para o logradouro completo... [107ms]
```
