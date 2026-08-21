#' Padronizar complementos
#'
#' Padroniza um vetor de caracteres representando complementos de logradouros.
#' Veja a seção *Detalhes* para mais informações sobre a padronização.
#'
#' @param complementos Um vetor de caracteres. Os complementos a serem
#'   padronizados.
#'
#' @return Um vetor de caracteres com os complementos padronizados.
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
#' complementos <- c("", "QD1 LT2 CS3", "APTO. 405")
#' padronizar_complementos(complementos)
#'
#' @export
padronizar_complementos <- function(complementos) {
  checkmate::assert_character(complementos)
  padronizar_complementos_rs(enc2utf8(complementos))
}
