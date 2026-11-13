#' Caminho do modelo de segmentação
#'
#' Descobre qual arquivo de modelo (`.crf`) a segmentação usaria, sem baixar nem
#' ler nada do disco.
#'
#' @param modelo Um arquivo ou diretório de modelo. `NULL`, o padrão, segue a
#'   ordem de prioridade descrita em *Detalhes*.
#'
#' @return Uma string com o caminho do arquivo que seria usado. O arquivo pode
#'   não existir.
#'
#' @section Detalhes:
#' O caminho é resolvido nesta ordem de prioridade:
#'
#' 1. o argumento `modelo`, quando informado e não vazio;
#' 2. a variável de ambiente `ENDERECOBR_MODELO`, quando definida e não vazia;
#' 3. o cache do sistema operacional (`~/.cache/enderecobr_rs/...` no Linux,
#'    `~/Library/Caches/...` no macOS e `%LOCALAPPDATA%\...` no Windows).
#'
#' Se o valor resolvido for um diretório (ou terminar em `/`), o subdiretório
#' com a versão do modelo e o nome do arquivo são acrescentados; se for um
#' arquivo, ele é usado como está.
#'
#' A resolução é feita pelo `enderecobr_rs`, então é a mesma das outras
#' linguagens. Use [obter_modelo()] quando quiser o arquivo pronto para uso,
#' baixando-o se necessário.
#'
#' @examples
#' obter_caminho_modelo("/tmp/modelos/")
#' obter_caminho_modelo("/tmp/meu_modelo.crf")
#'
#' @export
obter_caminho_modelo <- function(modelo = NULL) {
  checkmate::assert_string(modelo, null.ok = TRUE)

  resolver_caminho_do_modelo(modelo, call = rlang::caller_env())
}

#' Obter o modelo de segmentação
#'
#' Resolve o caminho do modelo padrão e garante que o arquivo exista, baixando-o
#' na primeira chamada. Veja a seção *Detalhes*.
#'
#' @param modelo Um arquivo ou diretório de modelo. `NULL`, o padrão, usa a
#'   variável de ambiente `ENDERECOBR_MODELO` ou o cache do sistema, na ordem
#'   descrita em [obter_caminho_modelo()].
#'
#' @return Uma string com o caminho do arquivo `.crf`, já existente.
#'
#' @section Detalhes:
#' O download só acontece quando o arquivo está ausente ou vazio, e é feito pelo
#' próprio R (`utils::download.file()`) a partir da página de releases do
#' `enderecobr_rs`. Um download interrompido não deixa modelo corrompido no
#' cache.
#'
#' Em ambientes sem rede, a variável de ambiente `ENDERECOBR_MODELO_SEM_DOWNLOAD`
#' (com `1`, `true`, `TRUE` etc.) impede a tentativa de download, e aí o caminho
#' é devolvido mesmo que o arquivo não exista.
#'
#' Não é preciso chamar esta função antes de [estruturar_enderecos()] ou
#' [segmentar_enderecos()]: elas fazem a mesma verificação internamente. Ela é
#' útil para baixar o modelo antes (por exemplo, no começo de um script longo)
#' ou para inspecionar qual arquivo está sendo usado.
#'
#' @examples
#' \dontrun{
#' obter_modelo()
#'
#' # baixando o modelo para um diretório próprio
#' obter_modelo("/tmp/modelos/")
#' }
#'
#' @export
obter_modelo <- function(modelo = NULL) {
  checkmate::assert_string(modelo, null.ok = TRUE)

  garantir_modelo(modelo, call = rlang::caller_env())
}

#' Informações sobre o modelo de segmentação
#'
#' Descreve o modelo padrão: versão, origem do download, nome do arquivo,
#' diretório de cache e as variáveis de ambiente que controlam o seu caminho.
#'
#' @return Uma lista com os elementos `versao`, `url`, `diretorio_cache`,
#'   `arquivo`, `variavel_ambiente` e `variavel_ambiente_sem_download`.
#'
#' @examples
#' informacoes_do_modelo()
#'
#' @export
informacoes_do_modelo <- function() {
  informacoes_do_modelo_rs()
}

# helpers -----------------------------------------------------------------

resolver_caminho_do_modelo <- function(modelo, call) {
  resultado <- obter_caminho_modelo_rs(modelo)

  if (!is.null(resultado$erro)) erro_modelo(c("x" = resultado$erro), call = call)

  resultado$caminho
}

# Resolve o caminho e, quando o arquivo ainda não está no disco, baixa. Um
# caminho informado pelo usuário nunca é sobrescrito: se ele não existir, o
# erro aparece na hora de carregar o modelo.
garantir_modelo <- function(modelo, call) {
  caminho <- resolver_caminho_do_modelo(modelo, call = call)

  if (arquivo_de_modelo_completo(caminho) || download_desabilitado()) {
    return(caminho)
  }

  baixar_modelo(informacoes_do_modelo()$url, caminho, call = call)

  caminho
}

arquivo_de_modelo_completo <- function(caminho) {
  isTRUE(file.exists(caminho)) && isTRUE(file.size(caminho) > 0)
}

# Mesma regra da crate: a variável só vale como desligada quando presente e
# diferente de "0" e "false".
download_desabilitado <- function() {
  valor <- Sys.getenv(
    informacoes_do_modelo()$variavel_ambiente_sem_download,
    unset = ""
  )

  nzchar(valor) && !tolower(valor) %in% c("0", "false")
}

baixar_modelo <- function(url, destino, call) {
  diretorio <- dirname(destino)

  if (!dir.exists(diretorio)) {
    dir.create(diretorio, recursive = TRUE, showWarnings = FALSE)
  }

  origem <- paste0("A origem \u00e9 ", url, ".")
  temporario <- paste0(destino, ".", Sys.getpid(), ".tmp")

  # `download.file()` avisa e devolve status != 0 quando a conexão falha, em vez
  # de dar erro: os dois casos precisam virar o mesmo erro estruturado.
  status <- suppressWarnings(
    tryCatch(
      utils::download.file(url, temporario, mode = "wb", quiet = TRUE),
      error = function(cnd) conditionMessage(cnd)
    )
  )

  falhou <- !is.numeric(status) || status != 0

  if (falhou || !arquivo_de_modelo_completo(temporario)) {
    unlink(temporario)

    detalhe <- if (is.character(status)) {
      status
    } else if (status != 0) {
      paste0("O download retornou o status ", status, ".")
    } else {
      "O download n\u00e3o gravou nenhum conte\u00fado."
    }

    erro_modelo(c("x" = detalhe, "i" = origem), call = call)
  }

  if (!file.rename(temporario, destino)) {
    unlink(temporario)
    erro_modelo(
      c(
        "x" = paste0("N\u00e3o foi poss\u00edvel gravar o arquivo em ", destino, "."),
        "i" = origem
      ),
      call = call
    )
  }

  invisible(destino)
}
