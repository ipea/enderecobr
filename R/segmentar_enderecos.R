#' Segmentar endereços
#'
#' Separa um vetor de endereços em texto livre nos trechos que o compõem, sem
#' distribuí-los nos campos de um endereço. Veja a seção *Detalhes* para mais
#' informações sobre a segmentação.
#'
#' @param enderecos Um vetor de caracteres. Os endereços em texto livre a serem
#'   segmentados.
#' @param probabilidades Um logical. Se a probabilidade de cada trecho e do
#'   endereço inteiro ter sido corretamente segmentado deve ser calculada.
#'   Custa cerca de 20% a mais de tempo. Por padrão, `FALSE`.
#' @param modelo Um arquivo de modelo (`.crf`) próprio, no lugar do modelo
#'   padrão do pacote. Veja [estruturar_enderecos()].
#'
#' @return Uma lista com um data.frame por endereço de entrada, contendo as
#'   colunas `valor` e `tipo` (e `probabilidade`, quando pedida). Cada
#'   data.frame traz ainda os atributos `probabilidade` e `confianca` da
#'   segmentação do endereço inteiro. Os elementos da lista são nomeados com os
#'   nomes de `enderecos`, quando existirem.
#'
#' @section Detalhes:
#' A segmentação é a etapa que precede a estruturação: cada trecho do endereço
#' recebe um tipo (logradouro, número, complemento, localidade, CEP, entre
#' outros), na ordem em que aparece no texto. Use [tipos_de_segmento()] para
#' listar os tipos possíveis.
#'
#' Endereços repetidos são segmentados uma única vez: os elementos da lista
#' correspondentes a textos iguais compartilham o mesmo data.frame, que é
#' copiado se você o alterar.
#'
#' Os trechos ficam disponíveis do jeito que o modelo os encontrou, sem nenhuma
#' distribuição nos campos do endereço e sem padronização. Para pular
#' diretamente para os campos separados, use [estruturar_enderecos()]; para
#' agrupar segmentos que já existem, use [estruturar_segmentos()].
#'
#' O modelo e as variáveis de ambiente que controlam o seu caminho são os mesmos
#' de [estruturar_enderecos()].
#'
#' @examples
#' \dontrun{
#' enderecos <- c(
#'   "av n sra copacabana, 123, apt 301",
#'   "SQN 404 Bloco A APT 309, Asa Norte"
#' )
#' segmentos <- segmentar_enderecos(enderecos)
#' segmentos[[1]]
#'
#' # guardando o resultado da segmentação para estruturar depois
#' estruturar_segmentos(segmentos)
#' }
#'
#' @export
segmentar_enderecos <- function(enderecos, probabilidades = FALSE, modelo = NULL) {
  checkmate::assert_character(enderecos)
  checkmate::assert_logical(probabilidades, any.missing = FALSE, len = 1)
  checkmate::assert_string(modelo, null.ok = TRUE)

  if (is.null(modelo)) garantir_modelo(NULL, call = rlang::caller_env())

  dedup <- indices_de_unicos(enderecos)

  resultado <- segmentar_enderecos_rs(
    enc2utf8(dedup$unicos),
    probabilidades,
    modelo
  )

  if (!is.null(resultado$erro)) {
    erro_modelo(c("x" = resultado$erro), call = rlang::caller_env())
  }

  segmentos <- Map(
    como_data_frame,
    resultado$segmentos,
    resultado$probabilidade,
    resultado$confianca
  )
  segmentos <- segmentos[dedup$indices]

  nomes <- names(enderecos)
  if (!is.null(nomes)) names(segmentos) <- nomes

  segmentos
}

#' Estruturar segmentos de endereço
#'
#' Distribui trechos de endereço já segmentados nos campos de um endereço, sem
#' rodar o modelo de novo. Veja a seção *Detalhes*.
#'
#' @param segmentos Um data.frame com as colunas `valor` e `tipo`, ou uma lista
#'   desses data.frames, como os devolvidos por [segmentar_enderecos()].
#' @param padronizar Um logical. Se os campos encontrados devem passar pelas
#'   funções de padronização. Por padrão, `TRUE`.
#'
#' @return Um data.frame com as colunas `logradouro`, `numero`, `complemento`,
#'   `bairro` e `cep`, com uma linha por elemento de `segmentos`.
#'
#' @section Detalhes:
#' É a segunda metade do que [estruturar_enderecos()] faz. Serve para quem quer
#' guardar a segmentação (por exemplo, para não rodar o modelo duas vezes) e
#' montar o endereço depois, ou para corrigir um trecho antes de agrupá-los.
#'
#' Os atributos `probabilidade` e `confianca` dos data.frames de entrada são
#' transportados para as colunas de mesmo nome do resultado, quando existirem.
#'
#' @examples
#' \dontrun{
#' segmentos <- segmentar_enderecos("av n sra copacabana, 123, apt 301")
#'
#' # corrigindo um trecho antes de estruturar
#' segmentos[[1]]$valor[1] <- "av nossa senhora de copacabana"
#' estruturar_segmentos(segmentos)
#' }
#'
#' @export
estruturar_segmentos <- function(segmentos, padronizar = TRUE) {
  checkmate::assert_logical(padronizar, any.missing = FALSE, len = 1)

  if (is.data.frame(segmentos)) segmentos <- list(segmentos)

  checkmate::assert_list(
    segmentos,
    types = "data.frame",
    any.missing = FALSE,
    null.ok = TRUE
  )

  resultado <- estruturar_segmentos_rs(segmentos, padronizar)

  if (!is.null(resultado$erro)) erro_endbr(resultado$erro, call = rlang::caller_env())

  como_data_frame(resultado)
}

#' Tipos de trecho de endereço
#'
#' Lista os tipos que um trecho de endereço pode receber na segmentação.
#'
#' @return Um vetor de caracteres com os tipos, na ordem em que o modelo os
#'   emite.
#'
#' @section Detalhes:
#' Os tipos são rótulos em minúsculas e sem acentos. A maioria vai para o campo
#' mais próximo do seu significado — um `"parcela"`, por exemplo, entra no
#' logradouro ou no complemento, dependendo do que vem antes. Só `"denominacao"`,
#' `"referencia"`, `"municipio"`, `"uf"`, `"cadastro"`, `"ruido"` e `"outros"`
#' são descartados na estruturação.
#'
#' @examples
#' tipos_de_segmento()
#'
#' @export
tipos_de_segmento <- function() {
  tipos_de_segmento_rs()
}

# helpers -----------------------------------------------------------------

# Monta o data.frame a partir das colunas devolvidas pelo Rust, sem copiar os
# vetores, e opcionalmente anexa a probabilidade e a confiança do endereço.
como_data_frame <- function(colunas, probabilidade = NULL, confianca = NULL) {
  linhas <- length(colunas[[1]])

  if (all(is.na(colunas$probabilidade))) colunas$probabilidade <- NULL

  estrutura <- structure(
    colunas,
    class = "data.frame",
    row.names = seq_len(linhas)
  )

  if (!is.null(probabilidade)) attr(estrutura, "probabilidade") <- probabilidade
  if (!is.null(confianca)) attr(estrutura, "confianca") <- confianca

  estrutura
}
