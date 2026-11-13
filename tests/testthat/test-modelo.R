test_that("obter_caminho_modelo respeita arquivo informado", {
  expect_equal(
    obter_caminho_modelo("/tmp/meu_modelo.crf"),
    "/tmp/meu_modelo.crf"
  )
})

test_that("obter_caminho_modelo acrescenta a versão em um diretório", {
  informacoes <- informacoes_do_modelo()

  expect_equal(
    como_posix(obter_caminho_modelo("/tmp/modelos/")),
    file.path("/tmp/modelos", informacoes$versao, informacoes$arquivo)
  )
})

test_that("obter_caminho_modelo cai no cache sem argumento", {
  informacoes <- informacoes_do_modelo()

  withr::local_envvar(ENDERECOBR_MODELO = NA)

  caminho <- obter_caminho_modelo()

  expect_type(caminho, "character")
  expect_length(caminho, 1)
  expect_true(endsWith(
    como_posix(caminho),
    file.path(informacoes$versao, informacoes$arquivo)
  ))
})

test_that("obter_caminho_modelo prioriza o argumento sobre a variável de ambiente", {
  withr::local_envvar(ENDERECOBR_MODELO = "/tmp/da_variavel/")

  expect_equal(
    obter_caminho_modelo("/tmp/do_argumento.crf"),
    "/tmp/do_argumento.crf"
  )
})

test_that("obter_caminho_modelo usa a variável de ambiente", {
  withr::local_envvar(ENDERECOBR_MODELO = "/tmp/da_variavel/")

  expect_true(startsWith(obter_caminho_modelo(), "/tmp/da_variavel"))
})

test_that("obter_modelo não baixa com o download desligado", {
  withr::local_envvar(
    ENDERECOBR_MODELO = "/tmp/modelo_que_nao_existe.crf",
    ENDERECOBR_MODELO_SEM_DOWNLOAD = "1"
  )

  expect_equal(obter_modelo(), "/tmp/modelo_que_nao_existe.crf")
})

test_that("informacoes_do_modelo descreve o modelo", {
  informacoes <- informacoes_do_modelo()

  expect_type(informacoes, "list")
  expect_equal(
    names(informacoes),
    c(
      "versao",
      "url",
      "diretorio_cache",
      "arquivo",
      "variavel_ambiente",
      "variavel_ambiente_sem_download"
    )
  )
  expect_type(informacoes$versao, "character")
  expect_match(informacoes$url, "^https://")
  expect_equal(informacoes$arquivo, "tagger.crf")
  expect_equal(informacoes$variavel_ambiente, "ENDERECOBR_MODELO")
})

test_that("obter_modelo baixa o arquivo para o diretório configurado", {
  mockar_download()
  withr::local_envvar(ENDERECOBR_MODELO = paste0(tempfile("modelos"), "/"))

  caminho <- obter_modelo()

  expect_true(file.exists(caminho))
  expect_gt(file.size(caminho), 0)
  expect_equal(basename(caminho), informacoes_do_modelo()$arquivo)
})

test_that("obter_modelo não baixa de novo quando o arquivo já existe", {
  registro <- mockar_download()
  withr::local_envvar(ENDERECOBR_MODELO = paste0(tempfile("modelos"), "/"))

  caminho <- obter_modelo()
  modificado <- file.mtime(caminho)

  expect_equal(obter_modelo(), caminho)
  expect_identical(file.mtime(caminho), modificado)
  expect_equal(registro$chamadas, 1)
})

test_that("status diferente de zero vira erro estruturado", {
  # O download.file() sinaliza falha de conexão pelo status, sem dar erro.
  mockar_download(status = 22L)
  withr::local_envvar(ENDERECOBR_MODELO = paste0(tempfile("modelos"), "/"))

  expect_error(obter_modelo(), class = "erro_endbr_modelo")
})

test_that("download que não grava nada vira erro estruturado", {
  mockar_download(status = 0L, gravar = FALSE)
  withr::local_envvar(ENDERECOBR_MODELO = paste0(tempfile("modelos"), "/"))

  expect_error(obter_modelo(), "n\u00e3o gravou nenhum conte\u00fado")
})

test_that("não deixa arquivo temporário para trás quando falha", {
  mockar_download(status = 22L)
  modelo <- paste0(tempfile("modelos"), "/")
  withr::local_envvar(ENDERECOBR_MODELO = modelo)

  expect_error(obter_modelo(), class = "erro_endbr_modelo")
  # O arquivo temporário fica no subdiretório da versão do modelo.
  expect_length(list.files(modelo, pattern = "[.]tmp$", recursive = TRUE), 0)
})

test_that("a variável de ambiente desliga o download com os mesmos valores da crate", {
  withr::local_envvar(ENDERECOBR_MODELO_SEM_DOWNLOAD = "1")
  expect_true(download_desabilitado())

  withr::local_envvar(ENDERECOBR_MODELO_SEM_DOWNLOAD = "true")
  expect_true(download_desabilitado())

  withr::local_envvar(ENDERECOBR_MODELO_SEM_DOWNLOAD = "0")
  expect_false(download_desabilitado())

  withr::local_envvar(ENDERECOBR_MODELO_SEM_DOWNLOAD = "false")
  expect_false(download_desabilitado())

  withr::local_envvar(ENDERECOBR_MODELO_SEM_DOWNLOAD = NA)
  expect_false(download_desabilitado())
})
