test_that("da erro com inputs != de caracteres e numeros", {
  expect_error(padronizar_ceps(as.factor(22290140)))
})

test_that("da erro quando cep contem letra", {
  expect_snapshot(padronizar_ceps("botafogo"), error = TRUE, cnd_class = TRUE)

  expect_snapshot(
    padronizar_ceps(c(NA, "oie", NA, "hehe")),
    error = TRUE,
    cnd_class = TRUE
  )

  expect_snapshot(
    padronizar_ceps(base::letters),
    error = TRUE,
    cnd_class = TRUE
  )
})

test_that("da erro quando cep contem mais de 8 digitos", {
  expect_snapshot(padronizar_ceps(100000000), error = TRUE, cnd_class = TRUE)

  expect_snapshot(padronizar_ceps("222290-140"), error = TRUE, cnd_class = TRUE)

  expect_snapshot(
    padronizar_ceps(c(10000000, 100000000, 100000000)),
    error = TRUE,
    cnd_class = TRUE
  )

  expect_snapshot(
    padronizar_ceps(rep(100000000, 20)),
    error = TRUE,
    cnd_class = TRUE
  )
})

test_that("padroniza corretamente", {
  expect_equal(padronizar_ceps("22290-140"), "22290-140")
  expect_equal(padronizar_ceps("22290 140"), "22290-140")
  expect_equal(padronizar_ceps("22290- 140"), "22290-140")
  expect_equal(padronizar_ceps("22.290-140"), "22290-140")
  expect_equal(padronizar_ceps(22290140), "22290-140")
  expect_equal(padronizar_ceps(" 22290  140 "), "22290-140")
  expect_equal(padronizar_ceps("01000-000"), "01000-000")
  expect_equal(padronizar_ceps("1000000"), "01000-000")
  expect_equal(padronizar_ceps(" 1000000"), "01000-000")
  expect_equal(padronizar_ceps(1000000), "01000-000")
  expect_equal(padronizar_ceps(NA_character_), NA_character_)
  expect_equal(padronizar_ceps(NA_integer_), NA_character_)
  expect_equal(padronizar_ceps(""), NA_character_)

  expect_equal(
    padronizar_ceps(c(22290140, 1000000)),
    c("22290-140", "01000-000")
  )
})

test_that("lida com vetores vazios corretamente", {
  expect_equal(padronizar_ceps(character(0)), character(0))
  expect_equal(padronizar_ceps(integer(0)), character(0))
  expect_equal(padronizar_ceps(numeric(0)), character(0))
})

# issue #76 - https://github.com/ipea/enderecobr/issues/76
test_that("padroniza em formato integer", {
  expect_equal(
    padronizar_ceps(c("22290-140", "22.290-140"), formato = "integer"),
    c(22290140L, 22290140L)
  )
  expect_equal(padronizar_ceps("01000-000", formato = "integer"), 1000000L)
  expect_equal(padronizar_ceps(NA_character_, formato = "integer"), NA_integer_)
  expect_equal(padronizar_ceps("", formato = "integer"), NA_integer_)
})

test_that("padroniza entrada numérica em formato integer", {
  expect_equal(
    padronizar_ceps(c(22290140, 1000000), formato = "integer"),
    c(22290140L, 1000000L)
  )
  expect_equal(padronizar_ceps(NA_integer_, formato = "integer"), NA_integer_)
})

test_that("da os mesmos erros nos dois formatos", {
  expect_error(
    padronizar_ceps("botafogo", formato = "integer"),
    class = "erro_endbr_cep_com_letra"
  )
  expect_error(
    padronizar_ceps("222290-140", formato = "integer"),
    class = "erro_endbr_cep_com_digitos_demais"
  )
})

test_that("lida com vetores vazios em formato integer", {
  expect_equal(
    padronizar_ceps(character(0), formato = "integer"),
    integer(0)
  )
})

test_that("valida o formato", {
  expect_error(padronizar_ceps("22290-140", formato = "numeric"))
})

test_that("leniente tolera o que não é dígito", {
  expect_equal(padronizar_ceps("a123b45  6", leniente = TRUE), "00123-456")
  expect_equal(padronizar_ceps("22.290-140", leniente = TRUE), "22290-140")
  expect_equal(padronizar_ceps("", leniente = TRUE), NA_character_)
  expect_equal(padronizar_ceps(NA_character_, leniente = TRUE), NA_character_)
  expect_equal(padronizar_ceps(character(0), leniente = TRUE), character(0))
})

test_that("leniente aceita número sem passar por notação científica", {
  # as.character(1e7) é "1e+07": usar isso deixaria só o "107" do CEP.
  expect_equal(
    padronizar_ceps(c(10000000, 1000000, NA), leniente = TRUE),
    c("10000-000", "01000-000", NA_character_)
  )
})

test_that("leniente respeita o formato", {
  expect_equal(
    padronizar_ceps("123456789", leniente = TRUE, formato = "integer"),
    12345678L
  )
  expect_equal(
    padronizar_ceps(c("a123b45  6", "RUA", NA), leniente = TRUE, formato = "integer"),
    c(123456L, 0L, NA_integer_)
  )
})

test_that("leniente zera o que não tem dígito nenhum", {
  # Comportamento do enderecobr_rs (o mesmo nas outras linguagens): tudo que
  # sobra é preenchido com zeros, então texto sem dígito vira 00000-000.
  expect_equal(
    padronizar_ceps(c("RUA", "-", "0"), leniente = TRUE),
    rep("00000-000", 3)
  )
})

test_that("valida o argumento leniente", {
  expect_error(padronizar_ceps("22290-140", leniente = NA))
  expect_error(padronizar_ceps("22290-140", leniente = "sim"))
})
