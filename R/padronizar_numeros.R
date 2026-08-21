#' Padronizar números de logradouros
#'
#' Padroniza um vetor de caracteres ou números representando números de
#' logradouros. Veja a seção *Detalhes* para mais informações sobre a
#' padronização.
#'
#' @param numeros Um vetor de caracteres ou números. Os números de logradouro a
#'   serem padronizados.
#' @param formato Uma string. Como o resultado padronizado deve ser formatado.
#'   Por padrão, `"character"`, fazendo com que a função retorne um vetor de
#'   caracteres. Se `"integer"`, a função retorna um vetor de números inteiros.
#'
#' @return Um vetor de caracteres com os números de logradouros padronizados.
#'
#' @section Detalhes:
#' Operações realizadas durante a padronização:
#'
#' - conversão para caracter, se o input for numérico;
#' - remoção de espaços em branco antes e depois dos números e de espaços em
#' branco em excesso entre números;
#' - remoção de zeros à esquerda;
#' - substituição de números vazios e de variações de SN (SN, S N, S.N., S./N.,
#' etc) por S/N.
#'
#' @examples
#' numeros <- c("0210", "001", "1", "", "S N", "S/N", "SN", "0180  0181")
#' padronizar_numeros(numeros)
#'
#' numeros <- c(210, 1, 10000, NA)
#' padronizar_numeros(numeros)
#'
#' @export
padronizar_numeros <- function(numeros, formato = "character") {
  checkmate::assert(
    checkmate::check_character(numeros),
    checkmate::check_numeric(numeros),
    combine = "or"
  )
  checkmate::assert(
    checkmate::check_string(formato),
    checkmate::check_names(
      formato,
      subset.of = c("character", "integer")
    ),
    combine = "and"
  )

  if (is.numeric(numeros)) {
    numeros_padrao <- data.table::fifelse(numeros == 0, NA_integer_, numeros)

    if (formato == "integer") {
      numeros_padrao <- as.integer(numeros_padrao)
      return(numeros_padrao)
    }

    numeros_padrao <- formatC(numeros_padrao, format = "d")
    numeros_padrao[numeros_padrao == "NA"] <- "S/N"

    return(numeros_padrao)
  }

  numeros_padrao <- padronizar_numeros_rs(enc2utf8(numeros))

  if (formato == "character") {
    numeros_padrao[is.na(numeros_padrao) | numeros_padrao == ""] <- "S/N"
  } else {
    numeros_padrao[numeros_padrao == "S/N"] <- NA_character_

    # warning_conversao_invalida()
    numeros_padrao <- withCallingHandlers(
      as.integer(numeros_padrao),
      warning = function(cnd) {
        warning_conversao_invalida()
        rlang::cnd_muffle(cnd)
      }
    )
  }

  return(numeros_padrao)
}

warning_conversao_invalida <- function() {
  # a padronizar_numeros() pode tanto ser chamada individualmente ou como parte
  # da função padronizar_enderecos(). nesse caso, precisamos que o erro aponte
  # pra chamada da padronizar_enderecos(), já que o usuário não sabe que a
  # padronizar_numeros é chamada internamente. pra isso, verificamos as chamadas
  # feitas na stack e, caso seja feita pela função interna usada na
  # padronizar_enderecos(), mudamos a chamada do erro

  chamada_upstream <- tryCatch(sys.call(-15), error = function(cnd) NULL)

  # rlang::parent_env() pula direto do function(cnd) pro GlobalEnv, não sei por
  # quê, então usando sys.frame()
  funcao_chamada <- as.character(chamada_upstream[[1]])
  funcao_chamada <- setdiff(funcao_chamada, c("::", "enderecobr"))
  if (is.null(chamada_upstream) || funcao_chamada != "padronizar_enderecos") {
    n_frame <- -7
  } else {
    n_frame <- -15
  }

  warning_endbr(
    paste0(
      "Alguns n\u00fameros n\u00e3o puderam ser convertidos para integer, ",
      "introduzindo NAs no resultado."
    ),
    call = sys.frame(n_frame)
  )
}
