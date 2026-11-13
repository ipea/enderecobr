erro_endbr <- function(message, call, .envir = parent.frame()) {
  chamada_erro <- sys.call(-1)
  funcao_atribuida <- as.name(chamada_erro[[1]])

  classes_erro <- c(
    paste0("erro_endbr_", sub("^erro_", "", funcao_atribuida)),
    "erro_endbr"
  )

  cli::cli_abort(
    message,
    class = classes_erro,
    call = call,
    .envir = .envir
  )
}

# Erro de obten\u00e7\u00e3o ou leitura do modelo de segmenta\u00e7\u00e3o, compartilhado pelas
# fun\u00e7\u00f5es que dependem dele. `mensagem` s\u00e3o os bullets do detalhe (nomeados
# "x"/"i"), n\u00e3o um texto solto: um vetor interpolado vira lista inline.
erro_modelo <- function(mensagem, call) {
  erro_endbr(
    c(
      "N\u00e3o foi poss\u00edvel usar o modelo de segmenta\u00e7\u00e3o.",
      mensagem,
      "i" = paste0(
        "Confira o caminho do modelo com {.fn obter_caminho_modelo} e a ",
        "vari\u00e1vel de ambiente {.envvar ENDERECOBR_MODELO}."
      )
    ),
    call = call,
    .envir = environment()
  )
}
