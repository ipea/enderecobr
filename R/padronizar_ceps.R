#' Padronizar CEPs
#'
#' Padroniza um vetor de caracteres ou números representando CEPs. Veja a seção
#' *Detalhes* para mais informações sobre a padronização.
#'
#' @param ceps Um vetor de caracteres ou números. Os CEPs a serem padronizados.
#' @param formato Uma string. Como o resultado padronizado deve ser formatado.
#'   Por padrão, `"character"`, fazendo com que a função retorne os CEPs
#'   separados por traço (`"22290-140"`). Se `"integer"`, a função retorna os
#'   CEPs como números inteiros, sem o traço (`22290140`), o que ocupa menos
#'   memória em bases grandes.
#' @param leniente Um logical. Se os CEPs devem ser padronizados tolerando
#'   caracteres inválidos, em vez de reportar erro. Muda apenas a tolerância da
#'   leitura: o `formato` continua valendo. Por padrão, `FALSE`.
#'
#' @return Um vetor de caracteres com os CEPs padronizados ou, quando
#'   `formato = "integer"`, um vetor de inteiros.
#'
#' @section Detalhes:
#' Operações realizadas durante a padronização:
#'
#' - conversão para caracter, se o input for numérico;
#' - adição de zeros à esquerda, se o input contiver menos de 8 dígitos;
#' - remoção de espaços em branco, pontos e vírgulas;
#' - adição de traço separando o radical (5 primeiros dígitos) do sufixo (3
#' últimos digitos), apenas quando `formato = "character"`.
#'
#' Com `leniente = TRUE` a função nunca reporta erro: tudo o que não for dígito é
#' descartado, os dígitos que passarem de 8 são descartados do fim e o que faltar
#' é preenchido com zeros à esquerda. Use quando a fonte dos dados é sabidamente
#' suja e o objetivo é aproveitar o que der, em vez de garantir que todo CEP seja
#' válido. Como o preenchimento é com zeros, um valor sem nenhum dígito vira
#' `"00000-000"` — vale conferir esses casos depois.
#'
#' @examples
#' ceps <- c("22290-140", "22.290-140", "22290 140", "22290140")
#' padronizar_ceps(ceps)
#' padronizar_ceps(ceps, formato = "integer")
#'
#' ceps <- c(22290140, 1000000, NA)
#' padronizar_ceps(ceps)
#'
#' # tolerando caracteres inválidos
#' padronizar_ceps(c("a123b45  6", "RUA"), leniente = TRUE)
#'
#' @export
padronizar_ceps <- function(ceps, formato = "character", leniente = FALSE) {
  checkmate::assert(
    checkmate::check_character(ceps),
    checkmate::check_numeric(ceps),
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
  checkmate::assert_logical(leniente, any.missing = FALSE, len = 1)

  if (leniente) {
    ceps_padrao <- padronizar_ceps_lenientes_rs(enc2utf8(texto_do_cep(ceps)))

    if (formato == "integer") return(cep_para_inteiro(ceps_padrao))

    return(ceps_padrao)
  }

  if (is.numeric(ceps)) {
    ceps_padrao <- padronizar_ceps_numericos_rs(as.integer(ceps))
    checa_se_digitos_demais(ceps_padrao)
  } else {
    ceps_padrao <- padronizar_ceps_rs(enc2utf8(ceps))

    checa_se_letra_presente(ceps_padrao)
    checa_se_digitos_demais(ceps_padrao)
  }

  if (formato == "integer") return(cep_para_inteiro(ceps_padrao))

  ceps_padrao
}

# checks ------------------------------------------------------------------

# `as.character()` escreve números redondos em notação científica ("1e+07"), o
# que faria o modo leniente aproveitar só o "107". Também mantém o `NA` como
# `NA`, em vez de virar o texto "NA".
texto_do_cep <- function(ceps) {
  if (!is.numeric(ceps)) return(ceps)

  ifelse(is.na(ceps), NA_character_, sprintf("%.0f", trunc(ceps)))
}

cep_para_inteiro <- function(ceps_padrao) {
  as.integer(gsub("-", "", ceps_padrao, fixed = TRUE))
}

checa_se_letra_presente <- function(ceps) {
  possui_letras <- ceps == "Erro: CEP com caracteres inv\u00e1lidos"

  if (any(possui_letras[!is.na(possui_letras)])) {
    erro_cep_com_letra(possui_letras)
  }
}

checa_se_digitos_demais <- function(ceps_padrao) {
  possui_digitos_demais <- ceps_padrao == "Erro: CEP com muitos d\u00edgitos"

  if (any(possui_digitos_demais[!is.na(possui_digitos_demais)])) {
    erro_cep_com_digitos_demais(possui_digitos_demais)
  }
}

# erros -------------------------------------------------------------------

erro_cep_com_letra <- function(possui_letras) {
  # a padronizar_ceps() pode tanto ser chamada individualmente ou como parte da
  # função padronizar_enderecos(). nesse caso, precisamos que o erro aponte pra
  # chamada da padronizar_enderecos(), já que o usuário não sabe que a
  # padronizar_ceps é chamada internamente. pra isso, verificamos as chamadas
  # feitas na stack e, caso seja feita pela função interna usada na
  # padronizar_enderecos(), mudamos o caller_env do erro

  n_caller_env <- 2

  chamada_upstream <- tryCatch(sys.call(-10), error = function(cnd) NULL)
  if (!is.null(chamada_upstream)) {
    funcao_upstream <- as.character(chamada_upstream[[1]])
    funcao_upstream <- setdiff(funcao_upstream, c("::", "enderecobr"))

    if (funcao_upstream == "padronizar_enderecos") n_caller_env <- 8
  }

  indice_com_letras <- which(possui_letras)
  indice_com_letras <- as.character(indice_com_letras)

  lista_indices <- cli::cli_vec(
    indice_com_letras,
    list("vec-trunc" = 5, "vec-last" = " e ", "vec-sep2" = " e ")
  )

  erro_endbr(
    c(
      "CEP n\u00e3o deve conter letras.",
      "i" = paste0(
        "O{?s} elemento{?s} com \u00edndice{?s} ",
        "{lista_indices} possu{?i/em} letras."
      )
    ),
    call = rlang::caller_env(n = n_caller_env),
    .envir = environment()
  )
}

erro_cep_com_digitos_demais <- function(possui_digitos_demais) {
  # a padronizar_ceps() pode tanto ser chamada individualmente ou como parte da
  # função padronizar_enderecos(). nesse caso, precisamos que o erro aponte pra
  # chamada da padronizar_enderecos(), já que o usuário não sabe que a
  # padronizar_ceps é chamada internamente. pra isso, verificamos as chamadas
  # feitas na stack e, caso seja feita pela função interna usada na
  # padronizar_enderecos(), mudamos o caller_env do erro

  n_caller_env <- 2

  chamada_upstream <- tryCatch(sys.call(-10), error = function(cnd) NULL)
  if (!is.null(chamada_upstream)) {
    funcao_upstream <- as.character(chamada_upstream[[1]])
    funcao_upstream <- setdiff(funcao_upstream, c("::", "enderecobr"))

    if (funcao_upstream == "padronizar_enderecos") n_caller_env <- 8
  }

  indice_muitos_digitos <- which(possui_digitos_demais)
  indice_muitos_digitos <- as.character(indice_muitos_digitos)

  lista_indices <- cli::cli_vec(
    indice_muitos_digitos,
    list("vec-trunc" = 5, "vec-last" = " e ", "vec-sep2" = " e ")
  )

  erro_endbr(
    c(
      "CEP n\u00e3o deve conter mais que 8 d\u00edgitos.",
      "i" = paste0(
        "O{?s} elemento{?s} com \u00edndice{?s} ",
        "{lista_indices} possu{?i/em} mais que 8 d\u00edgitos ",
        "ap\u00f3s padroniza\u00e7\u00e3o."
      )
    ),
    call = rlang::caller_env(n = n_caller_env),
    .envir = environment()
  )
}
