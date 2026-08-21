#' Padronizar estados
#'
#' Padroniza um vetor de caracteres ou números representando estados
#' brasileiros. Veja a seção *Detalhes* para mais informações sobre a
#' padronização.
#'
#' @param estados Um vetor de caracteres ou números. Os estados a serem
#'   padronizados.
#' @param formato Uma string. Como o resultado padronizado deve ser formatado.
#'   Por padrão, `"por_extenso"`, fazendo com que a função retorne o nome dos
#'   estados por extenso. Se `"sigla"`, a função retorna a sigla dos estados.
#'
#' @return Um vetor de caracteres com os estados padronizados.
#'
#' @section Detalhes:
#' Operações realizadas durante a padronização:
#'
#' - conversão para caracter, se o input for numérico;
#' - remoção de espaços em branco antes e depois dos valores e remoção de
#' espaços em excesso entre palavras;
#' - conversão de caracteres para caixa alta;
#' - remoção de zeros à esquerda;
#' - busca, a partir do código numérico ou da abreviação da UF, do nome
#' completo de cada estado;
#' - caso a busca não tenha encontrado determinado valor, remoção de acentos e
#' caracteres não ASCII.
#'
#' @examples
#' estados <- c("21", "021", "MA", " 21", " MA ", "ma", "", NA)
#' padronizar_estados(estados)
#'
#' estados <- c(21, NA)
#' padronizar_estados(estados)
#' padronizar_estados(estados, formato = "sigla")
#'
#' @export
padronizar_estados <- function(estados, formato = "por_extenso") {
  checkmate::assert(
    checkmate::check_character(estados),
    checkmate::check_numeric(estados),
    combine = "or"
  )
  checkmate::assert(
    checkmate::check_string(formato),
    checkmate::check_names(formato, subset.of = c("por_extenso", "sigla")),
    combine = "and"
  )

  padronizar_estados_rs(enc2utf8(as.character(estados)), formato = formato)
}
