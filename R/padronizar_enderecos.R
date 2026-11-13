#' Padronizar endereços
#'
#' Padroniza simultaneamente os diversos campos de um endereço listados em um
#' dataframe.
#'
#' @param enderecos Um dataframe. Os endereços a serem padronizados. Cada uma de
#'   suas colunas deve corresponder a um campo do endereço (e.g. logradouro,
#'   cidade, bairro, etc).
#' @param campos_do_endereco Um vetor nomeado de caracteres. A correspondência
#'   entre os campos a serem padronizados (nomes do vetor) e as colunas que os
#'   representam no dataframe (valores em si). A função
#'   `correspondencia_campos()` facilita a criação deste vetor, fazendo também
#'   algumas verificações do conteúdo imputado. Argumentos dessa função com
#'   valor `NULL` são ignorados, e ao menos um valor diferente de nulo deve ser
#'   fornecido. Caso deseje criar o vetor manualmente, note que seus nomes devem
#'   ser os mesmos nomes dos parâmetros da função `correspondencia_campos()`.
#' @param formato_estados Uma string. Como o estado padronizado deve ser
#'   formatado. Por padrão, `"por_extenso"`, fazendo com que a função retorne o
#'   nome dos estados por extenso. Se `"sigla"`, a função retorna a sigla dos
#'   estados. Se `"codigo"`, a função retorna o código numérico do estado no
#'   IBGE.
#' @param formato_numeros Uma string. Como o número padronizado deve ser
#'   formatado. Por padrão, `"character"`, fazendo com que a função retorne o
#'   número como caractere. Se `"integer"`, a função retorna o número como
#'   inteiro.
#' @param manter_cols_extras Um logical. Se colunas não especificadas em
#'   `campos_do_endereco` devem ser mantidas ou não (por exemplo, uma coluna de
#'   id do conjunto de dados sendo padronizado). Por padrão, `TRUE`.
#' @param combinar_logradouro Um logical. Se os campos que descrevem o
#'   logradouro (tipo, nome e número, por exemplo) devem ser combinados em um
#'   único campo de logradouro completo. Nesse caso, o parâmetro `logradouro` da
#'   `correspondencia_campos()` deve ser interpretado como o nome do logradouro.
#'   Por padrão, `FALSE`.
#' @param checar_tipos Um logical. Apenas tem efeito quando
#'   `combinar_logradouro` é `TRUE`. Se a ocorrência de duplicatas entre os
#'   tipos e nomes dos logradouros deve ser verificada ao combiná-los (por
#'   exemplo, quando o tipo é descrito como "RUA" e o nome é descrito como "RUA
#'   BOTAFOGO"). Por padrão, `FALSE`.
#'
#' @return Um dataframe com colunas adicionais, representando os campos de
#'   endereço padronizados.
#'
#' @examples
#' enderecos <- data.frame(
#'   id = 1,
#'   logradouro = "r ns sra da piedade",
#'   nroLogradouro = 20,
#'   complemento = "qd 20",
#'   cep = 25220020,
#'   bairro = "jd botanico",
#'   codmun_dom = 3304557,
#'   uf_dom = "rj"
#' )
#'
#' campos <- correspondencia_campos(
#'   logradouro = "logradouro",
#'   numero = "nroLogradouro",
#'   complemento = "complemento",
#'   cep = "cep",
#'   bairro = "bairro",
#'   municipio = "codmun_dom",
#'   estado = "uf_dom"
#' )
#'
#' padronizar_enderecos(enderecos, campos)
#'
#' padronizar_enderecos(enderecos, campos, manter_cols_extras = FALSE)
#'
#' padronizar_enderecos(enderecos, campos, combinar_logradouro = TRUE)
#'
#' ends_tipo_duplicado <- data.frame(tipo = "r", nome = "r ns sra da piedade")
#'
#' padronizar_enderecos(
#'   ends_tipo_duplicado,
#'   campos_do_endereco = correspondencia_campos(
#'     tipo_de_logradouro = "tipo",
#'     logradouro = "nome"
#'   ),
#'   combinar_logradouro = TRUE,
#'   checar_tipos = TRUE
#' )
#'
#' @export
padronizar_enderecos <- function(
  enderecos,
  campos_do_endereco = correspondencia_campos(),
  formato_estados = "por_extenso",
  formato_numeros = "character",
  manter_cols_extras = TRUE,
  combinar_logradouro = FALSE,
  checar_tipos = FALSE
) {
  checkmate::assert_data_frame(enderecos)
  checkmate::assert(
    checkmate::check_string(formato_estados),
    checkmate::check_names(
      formato_estados,
      subset.of = c("por_extenso", "sigla", "codigo")
    ),
    combine = "and"
  )
  checkmate::assert(
    checkmate::check_string(formato_numeros),
    checkmate::check_names(
      formato_numeros,
      subset.of = c("character", "integer")
    ),
    combine = "and"
  )
  checkmate::assert_logical(manter_cols_extras, any.missing = FALSE, len = 1)
  checkmate::assert_logical(combinar_logradouro, any.missing = FALSE, len = 1)
  checkmate::assert_logical(checar_tipos, any.missing = FALSE, len = 1)
  checa_campos_do_endereco(campos_do_endereco, enderecos)

  enderecos_padrao <- data.table::as.data.table(enderecos)

  relacao_campos <- tibble::tribble(
    ~nome_campo,          ~nome_formatado,       ~funcao,                        ~args_extra,
    "tipo_de_logradouro", "tipos de logradouro", padronizar_tipos_de_logradouro, NULL,
    "logradouro",         "logradouros",         padronizar_logradouros,         NULL,
    "numero",             "n\u00fameros",        padronizar_numeros,             list(formato = formato_numeros),
    "complemento",        "complementos",        padronizar_complementos,        NULL,
    "cep",                "CEPs",                padronizar_ceps,                NULL,
    "bairro",             "bairros",             padronizar_bairros,             NULL,
    "municipio",          "munic\u00edpios",     padronizar_municipios,          NULL,
    "estado",             "estados",             padronizar_estados,             list(formato = formato_estados)
  )

  if (combinar_logradouro) {
    campos_do_logradouro <- c("tipo_de_logradouro", "logradouro", "numero")

    enderecos_padrao <- int_padronizar_ends_com_log_compl(
      enderecos_padrao,
      campos_do_endereco,
      campos_do_logradouro,
      checar_tipos
    )

    relacao_campos <- subset(
      relacao_campos,
      ! nome_campo %in% campos_do_logradouro
    )
  }

  invisible(
    mapply(
      relacao_campos$nome_campo,
      relacao_campos$nome_formatado,
      relacao_campos$funcao,
      relacao_campos$args_extra,
      FUN = function(nome_campo, nome_formatado, funcao, args_extra) {
        if (nome_campo %in% names(campos_do_endereco)) {
          col_orig <- campos_do_endereco[nome_campo]
          col_padr <- paste0(nome_campo, "_padr")

          prog <- mensagem_progresso_endbr(
            paste0("Padronizando ", nome_formatado, "...")
          )

          enderecos_padrao[
            ,
            c(col_padr) := do.call(
              funcao,
              args = append(list(enderecos[[col_orig]]), args_extra)
            )
          ]

          cli::cli_progress_done(id = prog)
        }
      }
    )
  )

  campos_extras <- setdiff(names(enderecos), campos_do_endereco)

  if (!manter_cols_extras) {
    enderecos_padrao[, (campos_extras) := NULL]
  } else {
    data.table::setcolorder(enderecos_padrao, campos_extras)
  }

  return(enderecos_padrao[])
}

int_padronizar_ends_com_log_compl <- function(enderecos_padrao,
                                              campos_do_endereco,
                                              campos_do_logradouro,
                                              checar_tipos) {
  campos_do_log_listados <- campos_do_endereco[
    which(names(campos_do_endereco) %in% campos_do_logradouro)
  ]

  if (length(campos_do_log_listados) > 0) {
    names(campos_do_log_listados) <- sub(
      "^logradouro$",
      "nome_do_logradouro",
      names(campos_do_log_listados)
    )

    enderecos_padrao <- padronizar_logradouros_completos(
      enderecos_padrao,
      campos_do_logradouro = campos_do_log_listados,
      checar_tipos = checar_tipos
    )
  }

  return(enderecos_padrao)
}

checa_campos_do_endereco <- function(campos_do_endereco, enderecos) {
  col <- checkmate::makeAssertCollection()
  checkmate::assert_character(
    campos_do_endereco,
    any.missing = FALSE,
    add = col
  )
  checkmate::assert_names(
    names(campos_do_endereco),
    type = "unique",
    subset.of = c(
      "tipo_de_logradouro",
      "logradouro",
      "numero",
      "complemento",
      "cep",
      "bairro",
      "municipio",
      "estado"
    ),
    add = col
  )
  checkmate::assert_names(
    campos_do_endereco,
    subset.of = names(enderecos),
    add = col
  )
  checkmate::reportAssertions(col)

  # a função retorna os valores padronizados em colunas de nome "<campo>_padr".
  # a seguir, checamos se colunas com esse nome existem e lançamos um warning
  # caso positivo

  campos_padr <- paste0(names(campos_do_endereco), "_padr")

  campos_padr_existentes <- campos_padr[campos_padr %in% names(enderecos)]

  if (length(campos_padr_existentes) > 0) {
    warning_coluna_existente(campos_padr_existentes)
  }

  return(invisible(TRUE))
}

warning_coluna_existente <- function(campos_padr_existentes) {
  lista_campos <- cli::cli_vec(
    campos_padr_existentes,
    list("vec-last" = " e ", "vec-sep2" = " e ")
  )

  warning_endbr(
    c(
      paste0(
        "A{?s} seguinte{?s} coluna{?s} fo{?i/ram} encontrada{?s} no input e ",
        "ser{?\u00e1/\u00e3o} sobrescrita{?s} no output: ",
        "{.var {lista_campos}}."
      )
    ),
    call = rlang::caller_env(n = 2),
    .envir = environment()
  )
}
