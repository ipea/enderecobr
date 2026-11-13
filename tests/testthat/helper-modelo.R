# As funções de segmentação baixam um modelo de ~700 kB na primeira chamada. Sem
# rede (ou com o download desligado), os testes que dependem dele são pulados em
# vez de falhar: o modelo não faz parte do pacote.
modelo_disponivel <- function() {
  caminho <- tryCatch(
    suppressWarnings(obter_modelo()),
    error = function(cnd) NULL
  )

  !is.null(caminho) && file.exists(caminho)
}

# O Rust monta o caminho com o separador da plataforma (`\` no Windows);
# comparar caminhos com `file.path()`, que usa `/`, exige alinhar os dois lados.
como_posix <- function(caminho) gsub("\\\\", "/", caminho)

pular_sem_modelo <- function() {
  # O download do modelo é acesso à rede: fica fora do CRAN e do R CMD check.
  testthat::skip_on_cran()

  if (!modelo_disponivel()) {
    testthat::skip("modelo de segmentação indisponível")
  }
}

# Troca o download real por uma gravação local: os testes do modelo deixam de
# depender de rede. O objeto devolvido conta quantas vezes o download foi
# tentado. Precisa ser chamado do corpo do teste, com o `.env` do teste, para o
# mock valer até o fim dele.
mockar_download <- function(status = 0L, gravar = TRUE, .env = parent.frame()) {
  registro <- new.env(parent = emptyenv())
  registro$chamadas <- 0L

  testthat::local_mocked_bindings(
    download.file = function(url, destfile, ...) {
      registro$chamadas <- registro$chamadas + 1L
      if (gravar) writeLines("modelo", destfile)
      status
    },
    .package = "utils",
    .env = .env
  )

  registro
}
