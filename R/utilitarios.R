#' Normalizar textos
#'
#' Aplica o pré-processamento comum a todas as funções de padronização do
#' pacote: remoção de espaços em branco sobrando, conversão para caixa alta e
#' remoção de acentos e caracteres não ASCII.
#'
#' @param textos Um vetor de caracteres. Os textos a serem normalizados.
#'
#' @return Um vetor de caracteres com os textos normalizados. Textos vazios
#'   viram `NA`.
#'
#' @section Detalhes:
#' É a base sobre a qual as demais padronizações operam: `normalizar("Olá,
#' mundo")` devolve `"OLA, MUNDO"`. Textos que já estão em caixa alta e sem
#' acentos são devolvidos sem alteração.
#'
#' @examples
#' normalizar(c("Olá, mundo", "  r. do açaí 15º  ", NA))
#'
#' @export
normalizar <- function(textos) {
  checkmate::assert_character(textos)

  normalizar_rs(enc2utf8(textos))
}

#' Identificar dados faltantes
#'
#' Identifica quais valores de um vetor indicam que a informação não foi
#' fornecida, como `"SI"`, `"NA"`, `"SEM INFORMACAO"`, `"NAO CONSTA"`,
#' `"DESCONHECIDO"` e `"SIGILOSO"`.
#'
#' @param valores Um vetor de caracteres. Os valores a serem verificados.
#'
#' @return Um vetor de logicals, com `TRUE` nos valores que representam dados
#'   faltantes e `FALSE` nos demais. Valores `NA` viram `TRUE`.
#'
#' @section Detalhes:
#' A identificação é feita por expressões regulares sobre o texto normalizado,
#' então variações de caixa, acentuação e pontuação não atrapalham. `"S/N"` não
#' é considerado um dado faltante, e sim um número de logradouro válido.
#'
#' @examples
#' e_dado_faltante(c("SI", "SEM INFORMACAO", "NAO CONSTA", "RUA B", NA))
#'
#' @export
e_dado_faltante <- function(valores) {
  checkmate::assert_character(valores)

  dado_faltante_rs(enc2utf8(valores))
}

#' Zerar dados faltantes
#'
#' Substitui por `NA` os valores que representam ausência de informação,
#' conforme identificados por [e_dado_faltante()], e normaliza os demais.
#'
#' @param valores Um vetor de caracteres. Os valores a serem zerados.
#'
#' @return Um vetor de caracteres, com `NA` no lugar dos dados faltantes e os
#'   demais valores normalizados.
#'
#' @examples
#' zerar_dado_faltante(c("SI", "RUA B", "  São Gonçalo "))
#'
#' @export
zerar_dado_faltante <- function(valores) {
  checkmate::assert_character(valores)

  zerar_dado_faltante_rs(enc2utf8(valores))
}

#' Padronizar com Metaphone
#'
#' Codifica um vetor de nomes conforme o algoritmo Metaphone, que aproxima
#' nomes com grafias parecidas a uma mesma representação fonética.
#'
#' @param valores Um vetor de caracteres. Os nomes a serem codificados.
#'
#' @return Um vetor de caracteres com a codificação Metaphone dos nomes.
#'
#' @section Detalhes:
#' Serve para comparar nomes que soariam parecidos (`"Silva"` e `"Sylva"`), já
#' que a codificação é a mesma. A codificação parte do texto normalizado, sem
#' acentos e em caixa alta.
#'
#' @examples
#' padronizar_metaphone(c("Silva", "Sylva", "João"))
#'
#' @export
padronizar_metaphone <- function(valores) {
  checkmate::assert_character(valores)

  padronizar_metaphone_rs(enc2utf8(valores))
}

#' Escrever números por extenso
#'
#' Escreve números inteiros por extenso, em português.
#'
#' @param numeros Um vetor de números inteiros. Os números a serem escritos.
#'
#' @return Um vetor de caracteres com os números por extenso, em caixa alta e
#'   sem acentos.
#'
#' @examples
#' numero_por_extenso(c(1, 21, 405, 1000))
#'
#' @export
numero_por_extenso <- function(numeros) {
  checkmate::assert_integerish(numeros)

  numero_por_extenso_rs(as.integer(numeros))
}

#' Converter números romanos em inteiros
#'
#' Converte números romanos escritos em algarismos para inteiros.
#'
#' @param romanos Um vetor de caracteres. Os números romanos a serem
#'   convertidos.
#'
#' @return Um vetor de inteiros.
#'
#' @section Detalhes:
#' É o inverso da escrita de números romanos por extenso. Valores que não são
#' números romanos são devolvidos como `0`.
#'
#' @examples
#' romano_para_inteiro(c("XIV", "MMXXVI", "IV"))
#'
#' @export
romano_para_inteiro <- function(romanos) {
  checkmate::assert_character(romanos)

  romano_para_inteiro_rs(enc2utf8(romanos))
}
