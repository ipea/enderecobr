test_that("devolve uma lista de data.frames, um por endereço", {
  pular_sem_modelo()

  segmentos <- segmentar_enderecos(c("av atlantica, 123, apto 301", "r das flores"))

  expect_type(segmentos, "list")
  expect_length(segmentos, 2)
  expect_s3_class(segmentos[[1]], "data.frame")
  expect_equal(segmentos[[1]]$valor, c("av atlantica", "123", "apto 301"))
  expect_equal(
    segmentos[[1]]$tipo,
    c("logradouro", "numero", "complemento")
  )
})

test_that("nomeia os elementos com os nomes da entrada", {
  pular_sem_modelo()

  segmentos <- segmentar_enderecos(c(primeiro = "r das flores 45", segundo = "av brasil"))

  expect_equal(names(segmentos), c("primeiro", "segundo"))
})

test_that("acrescenta a probabilidade de cada trecho quando pedida", {
  pular_sem_modelo()

  segmentos <- segmentar_enderecos("r das flores 45", probabilidades = TRUE)

  expect_true("probabilidade" %in% names(segmentos[[1]]))
  expect_true(all(segmentos[[1]]$probabilidade > 0))
  expect_true(!is.na(attr(segmentos[[1]], "probabilidade")))
  expect_true(!is.na(attr(segmentos[[1]], "confianca")))
})

test_that("funciona com vetor vazio", {
  segmentos <- segmentar_enderecos(character())

  expect_type(segmentos, "list")
  expect_length(segmentos, 0)
})

test_that("estruturar_segmentos reagrupa os trechos", {
  pular_sem_modelo()

  enderecos <- c("av atlantica, 123, apto 301", "r das flores 45")
  segmentos <- segmentar_enderecos(enderecos)

  expect_equal(estruturar_segmentos(segmentos), estruturar_enderecos(enderecos))
})

test_that("estruturar_segmentos aceita um data.frame só", {
  pular_sem_modelo()

  segmentos <- segmentar_enderecos("r das flores 45")

  resultado <- estruturar_segmentos(segmentos[[1]])

  expect_equal(nrow(resultado), 1)
  expect_equal(resultado$logradouro, "RUA DAS FLORES")
})

test_that("estruturar_segmentos reflete edições nos trechos", {
  pular_sem_modelo()

  segmentos <- segmentar_enderecos("r das flores 45")
  segmentos[[1]]$valor[1] <- "r das rosas"

  expect_equal(estruturar_segmentos(segmentos)$logradouro, "RUA DAS ROSAS")
})

test_that("reaproveita a segmentação de endereços repetidos", {
  recebidos <- NULL
  testthat::local_mocked_bindings(
    segmentar_enderecos_rs = function(enderecos, ...) {
      recebidos <<- enderecos
      list(
        segmentos = lapply(enderecos, function(x) {
          list(valor = x, tipo = "logradouro", probabilidade = NA_real_)
        }),
        probabilidade = rep(NA_real_, length(enderecos)),
        confianca = rep(NA_real_, length(enderecos))
      )
    }
  )

  segmentos <- segmentar_enderecos(c("a", "b", "a"), modelo = "irrelevante.crf")

  expect_equal(recebidos, c("a", "b"))
  expect_length(segmentos, 3)
  # os repetidos compartilham o mesmo data.frame
  expect_identical(segmentos[[1]], segmentos[[3]])
})

test_that("da erro com modelo inexistente", {
  expect_error(
    segmentar_enderecos("r das flores 45", modelo = "/caminho/inexistente.crf"),
    class = "erro_endbr_modelo"
  )
})

test_that("tipos_de_segmento lista os tipos do modelo", {
  tipos <- tipos_de_segmento()

  expect_type(tipos, "character")
  expect_length(tipos, 18)
  expect_false(anyNA(tipos))
  expect_equal(unique(tipos), tipos)
  expect_true(all(tipos == tolower(tipos)))
  expect_true(all(c("logradouro", "numero", "complemento", "localidade", "cep") %in% tipos))
})

test_that("estruturar_segmentos lida com data.frame sem linhas", {
  # Iterar um data.frame vazio no Rust abortava o processo (extendr 0.9.0).
  resultado <- estruturar_segmentos(
    data.frame(valor = character(), tipo = character())
  )

  expect_equal(nrow(resultado), 1)
  expect_true(all(is.na(resultado[1, ])))
})

test_that("estruturar_segmentos aceita lista vazia", {
  expect_equal(nrow(estruturar_segmentos(list())), 0)
})
