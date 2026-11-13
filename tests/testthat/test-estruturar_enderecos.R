test_that("estrutura os campos de um endereço", {
  pular_sem_modelo()

  resultado <- estruturar_enderecos("av n sra copacabana, 123, apt 301")

  expect_s3_class(resultado, "data.frame")
  expect_equal(nrow(resultado), 1)
  expect_equal(
    names(resultado),
    c("logradouro", "numero", "complemento", "bairro", "cep")
  )
  expect_equal(resultado$logradouro, "AVENIDA NOSSA SENHORA COPACABANA")
  expect_equal(resultado$numero, "123")
  expect_equal(resultado$complemento, "APARTAMENTO 301")
})

test_that("devolve uma linha por endereço", {
  pular_sem_modelo()

  enderecos <- c(
    "r das flores 45, jd botanico, 20040-020",
    "SQN 404 Bloco A APT 309, Asa Norte"
  )

  resultado <- estruturar_enderecos(enderecos)

  expect_equal(nrow(resultado), 2)
  expect_equal(resultado$logradouro, c("RUA DAS FLORES", "SQN 404"))
  expect_equal(resultado$cep, c("20040-020", NA_character_))
})

test_that("mantém os campos como vieram quando padronizar = FALSE", {
  pular_sem_modelo()

  resultado <- estruturar_enderecos(
    "av n sra copacabana, 123",
    padronizar = FALSE
  )

  expect_equal(resultado$logradouro, "av n sra copacabana")
})

test_that("devolve NA para endereços vazios ou faltantes", {
  pular_sem_modelo()

  resultado <- estruturar_enderecos(c(NA, ""))

  expect_equal(nrow(resultado), 2)
  expect_true(all(is.na(resultado[1, ])))
  expect_true(all(is.na(resultado[2, ])))
})

test_that("funciona com vetor vazio", {
  resultado <- estruturar_enderecos(character())

  expect_s3_class(resultado, "data.frame")
  expect_equal(nrow(resultado), 0)
  expect_equal(
    names(resultado),
    c("logradouro", "numero", "complemento", "bairro", "cep")
  )
})

test_that("acrescenta as colunas de probabilidade quando pedidas", {
  pular_sem_modelo()

  resultado <- estruturar_enderecos("r das flores 45", probabilidades = TRUE)

  expect_true(all(c("probabilidade", "confianca") %in% names(resultado)))
  expect_true(resultado$probabilidade > 0 && resultado$probabilidade <= 1)
  expect_true(resultado$confianca > 0 && resultado$confianca <= 1)
})

test_that("reaproveita endereços repetidos sem mudar o resultado", {
  pular_sem_modelo()

  enderecos <- c("r das flores 45", "av brasil 500", "r das flores 45", NA)

  resultado <- estruturar_enderecos(enderecos)

  expect_equal(nrow(resultado), 4)
  expect_equal(
    resultado$logradouro,
    c("RUA DAS FLORES", "AVENIDA BRASIL", "RUA DAS FLORES", NA)
  )
})

test_that("manda só os endereços únicos para a segmentação", {
  recebidos <- NULL
  testthat::local_mocked_bindings(
    estruturar_enderecos_rs = function(enderecos, ...) {
      recebidos <<- enderecos
      list(
        logradouro = rep("RUA X", length(enderecos)),
        numero = rep(NA_character_, length(enderecos)),
        complemento = rep(NA_character_, length(enderecos)),
        bairro = rep(NA_character_, length(enderecos)),
        cep = rep(NA_character_, length(enderecos))
      )
    }
  )

  resultado <- estruturar_enderecos(c("a", "b", "a", "a"), modelo = "irrelevante.crf")

  expect_equal(recebidos, c("a", "b"))
  expect_equal(nrow(resultado), 4)
  expect_equal(resultado$logradouro, rep("RUA X", 4))
})

test_that("da erro com modelo inexistente", {
  expect_error(
    estruturar_enderecos("r das flores 45", modelo = "/caminho/inexistente.crf"),
    class = "erro_endbr_modelo"
  )
})

test_that("da erro com inputs inválidos", {
  expect_error(estruturar_enderecos(1))
  expect_error(estruturar_enderecos("rua a", padronizar = "sim"))
  expect_error(estruturar_enderecos("rua a", probabilidades = NA))
  expect_error(estruturar_enderecos("rua a", modelo = 1))
})
