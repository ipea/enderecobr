test_that("da erro com inputs incorretos", {
  expect_error(padronizar_estados(as.factor(21)))

  expect_error(padronizar_estados("21", formato = 1))
  expect_error(padronizar_estados("21", formato = "oie"))
  expect_error(padronizar_estados("21", formato = c("sigla", "sigla")))
})

test_that("padroniza corretamente segundo o parametro formato", {
  # por padrão, por extenso

  expect_equal(padronizar_estados("21"), "MARANHAO")
  expect_equal(padronizar_estados("021"), "MARANHAO")
  expect_equal(padronizar_estados(" 21 "), "MARANHAO")
  expect_equal(padronizar_estados("ma"), "MARANHAO")
  expect_equal(padronizar_estados(NA_character_), NA_character_)
  expect_equal(padronizar_estados(""), NA_character_)

  expect_equal(padronizar_estados(21), "MARANHAO")
  expect_equal(padronizar_estados(NA_integer_), NA_character_)
  expect_equal(padronizar_estados(c(21, NA)), c("MARANHAO", NA_character_))

  expect_equal(padronizar_estados("MARANHÃO"), "MARANHAO")

  # ou só a sigla, se especificado

  expect_equal(padronizar_estados("21", formato = "sigla"), "MA")
  expect_equal(padronizar_estados("021", formato = "sigla"), "MA")
  expect_equal(padronizar_estados(" 21 ", formato = "sigla"), "MA")
  expect_equal(padronizar_estados("ma", formato = "sigla"), "MA")
  expect_equal(
    padronizar_estados(NA_character_, formato = "sigla"),
    NA_character_
  )
  expect_equal(padronizar_estados("", formato = "sigla"), NA_character_)

  expect_equal(padronizar_estados(21, formato = "sigla"), "MA")
  expect_equal(
    padronizar_estados(NA_integer_, formato = "sigla"),
    NA_character_
  )
  expect_equal(
    padronizar_estados(c(21, NA), formato = "sigla"),
    c("MA", NA_character_)
  )

  expect_equal(padronizar_estados("MARANHÃO", formato = "sigla"), "MA")
})

test_that("lida com vetores vazios corretamente", {
  expect_equal(padronizar_estados(character(0)), character(0))
  expect_equal(padronizar_estados(integer(0)), character(0))
  expect_equal(padronizar_estados(numeric(0)), character(0))
})

# issue #26 - https://github.com/ipeaGIT/enderecobr/issues/26
test_that("não recicla valores do vetor de estados original", {
  estados <- c(rep("RIO DE JANEIRO", 2), "ACRE")

  resultado <- padronizar_estados(estados)
  expect_false(identical(resultado, rep("RIO DE JANEIRO", 3)))
  expect_equal(resultado, c(rep("RIO DE JANEIRO", 2), "ACRE"))
})

test_that("padroniza em formato codigo", {
  expect_equal(padronizar_estados("MA", formato = "codigo"), "21")
  expect_equal(padronizar_estados(21, formato = "codigo"), "21")
  expect_equal(padronizar_estados("MARANHÃO", formato = "codigo"), "21")
  expect_equal(padronizar_estados(NA, formato = "codigo"), NA_character_)
})

test_that("formato codigo lida com vetores vazios", {
  expect_equal(padronizar_estados(character(0), formato = "codigo"), character(0))
})
