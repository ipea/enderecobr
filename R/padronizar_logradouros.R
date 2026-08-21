#' Padronizar logradouros
#'
#' Padroniza um vetor de caracteres representando logradouros de municípios
#' brasileiros. Veja a seção *Detalhes* para mais informações sobre a
#' padronização.
#'
#' @param logradouros Um vetor de caracteres. Os logradouros a serem
#'   padronizados.
#'
#' @return Um vetor de caracteres com os logradouros padronizados.
#'
#' @section Detalhes:
#' Operações realizadas durante a padronização:
#'
#' - remoção de espaços em branco antes e depois das strings e remoção de
#' espaços em excesso entre palavras;
#' - conversão de caracteres para caixa alta;
#' - remoção de acentos e caracteres não ASCII;
#' - adição de espaços após abreviações sinalizadas por pontos;
#' - expansão de abreviações frequentemente utilizadas através de diversas
#' [expressões regulares
#' (regexes)](https://en.wikipedia.org/wiki/Regular_expression);
#' - correção de alguns pequenos erros ortográficos.
#'
#' @examples
#' logradouros <- c("r. gen.. glicério")
#' padronizar_logradouros(logradouros)
#'
#' @export
padronizar_logradouros <- function(logradouros) {
  checkmate::assert_character(logradouros)

  padronizar_logradouros_rs(enc2utf8(logradouros))
}
