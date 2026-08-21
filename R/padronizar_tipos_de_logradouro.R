#' Padronizar tipos de logradouro
#'
#' Padroniza um vetor de caracteres representando tipos de logradouro. Veja a
#' seção *Detalhes* para mais informações sobre a padronização.
#'
#' @param tipos Um vetor de caracteres. Os tipos de logradouro a serem
#'   padronizados.
#'
#' @return Um vetor de caracteres com os tipos de logradouro padronizados.
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
#' tipos <- c("R", "AVE", "QDRA")
#' padronizar_tipos_de_logradouro(tipos)
#'
#' @export
padronizar_tipos_de_logradouro <- function(tipos) {
  checkmate::assert_character(tipos)

  padronizar_tipos_de_logradouros_rs(enc2utf8(tipos))
}
