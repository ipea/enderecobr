#' Estruturar endereços
#'
#' Separa um vetor de endereços em texto livre nos campos que o compõem:
#' logradouro, número, complemento, bairro e CEP. Veja a seção *Detalhes* para
#' mais informações sobre a estruturação.
#'
#' @param enderecos Um vetor de caracteres. Os endereços em texto livre a serem
#'   estruturados.
#' @param padronizar Um logical. Se os campos encontrados devem passar pelas
#'   funções de padronização (`padronizar_logradouros()`,
#'   `padronizar_numeros()`, `padronizar_complementos()`,
#'   `padronizar_bairros()` e `padronizar_ceps()`). Por padrão, `TRUE`.
#' @param probabilidades Um logical. Se a probabilidade de cada endereço ter
#'   sido corretamente segmentado deve ser devolvida nas colunas
#'   `probabilidade` e `confianca`. Custa cerca de 20% a mais de tempo. Por
#'   padrão, `FALSE`.
#' @param modelo Um arquivo de modelo (`.crf`) próprio, no lugar do modelo
#'   padrão do pacote. Use [obter_caminho_modelo()] para descobrir qual arquivo
#'   seria usado. Por padrão, `NULL`, que usa o modelo padrão.
#'
#' @return Um data.frame com as colunas `logradouro`, `numero`, `complemento`,
#'   `bairro` e `cep`, com uma linha por endereço de entrada. Campos que não
#'   aparecem no texto ficam como `NA`. Quando `probabilidades` é `TRUE`, o
#'   data.frame ganha também as colunas `probabilidade` e `confianca`.
#'
#' @section Detalhes:
#' A coluna `bairro` guarda o que o modelo chama de localidade: bairro, distrito,
#' vila ou zona.
#' A estruturação é feita em quatro etapas:
#'
#' - o texto é quebrado em tokens (sequências de letras, sequências de números e
#' caracteres de pontuação);
#' - um modelo probabilístico (CRF) atribui a cada token o tipo de informação que
#' ele representa e o seu papel dentro do trecho;
#' - os tokens são agrupados em trechos, na ordem em que aparecem;
#' - os trechos são distribuídos nos campos do endereço.
#'
#' Endereços repetidos são segmentados uma única vez e o resultado é
#' reaproveitado, o que é o que faz a função ser viável em bases grandes. A
#' padronização dos campos também roda só sobre os valores únicos.
#'
#' O modelo é o mesmo usado em [segmentar_enderecos()] e é distribuído como um
#' arquivo `.crf`, baixado na primeira chamada e guardado no cache do sistema. O
#' caminho pode ser controlado de três formas, nesta ordem de prioridade: o
#' argumento `modelo`; a variável de ambiente `ENDERECOBR_MODELO` (um arquivo ou
#' um diretório); e o cache do sistema. A variável de ambiente
#' `ENDERECOBR_MODELO_SEM_DOWNLOAD=1` impede o download, o que é útil em
#' ambientes sem rede.
#'
#' A coluna `probabilidade` é a probabilidade de a segmentação inteira estar
#' correta, e cai conforme o endereço fica mais longo: para comparar endereços de
#' tamanhos diferentes, use `confianca`, que é a média geométrica das
#' probabilidades de cada token e não depende do tamanho.
#'
#' @examples
#' \dontrun{
#' enderecos <- c(
#'   "av n sra copacabana, 123, apt 301",
#'   "r das flores 45, jd botanico, 20040-020",
#'   "SQN 404 Bloco A APT 309, Asa Norte"
#' )
#' estruturar_enderecos(enderecos)
#'
#' # sem passar os campos pela padronização
#' estruturar_enderecos(enderecos, padronizar = FALSE)
#'
#' # com as probabilidades de acerto de cada endereço
#' estruturar_enderecos(enderecos, probabilidades = TRUE)
#' }
#'
#' @export
estruturar_enderecos <- function(
  enderecos,
  padronizar = TRUE,
  probabilidades = FALSE,
  modelo = NULL
) {
  checkmate::assert_character(enderecos)
  checkmate::assert_logical(padronizar, any.missing = FALSE, len = 1)
  checkmate::assert_logical(probabilidades, any.missing = FALSE, len = 1)
  checkmate::assert_string(modelo, null.ok = TRUE)

  if (is.null(modelo)) garantir_modelo(NULL, call = rlang::caller_env())

  dedup <- indices_de_unicos(enderecos)

  resultado <- estruturar_enderecos_rs(
    enc2utf8(dedup$unicos),
    padronizar,
    probabilidades,
    modelo
  )

  if (!is.null(resultado$erro)) {
    erro_modelo(c("x" = resultado$erro), call = rlang::caller_env())
  }

  como_data_frame(lapply(resultado, `[`, dedup$indices))
}
