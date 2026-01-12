# Changelog

## enderecobr 0.5.0

CRAN release: 2026-01-10

### Novas funcionalidades

- Novas regras foram adicionadas às funções
  [`padronizar_bairros()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_bairros.md)
  e
  [`padronizar_logradouros()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_logradouros.md).

### Notas

- As funções de padronização foram reescritas em Rust, tornando-as muito
  mais rápidas.

## enderecobr 0.4.1

CRAN release: 2025-02-18

### Correção de bugs

- Corrigido bug na
  [`padronizar_enderecos()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_enderecos.md)
  (quando chamada via
  [`enderecobr::padronizar_enderecos()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_enderecos.md))
  em que a função resultava num erro quando, internamente, a
  [`padronizar_numeros()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_numeros.md)
  lançava um warning. Relacionado ao
  [issue](https://github.com/ipeagit/enderecobr/issues/38)
  [\#38](https://github.com/ipeaGIT/enderecobr/issues/38).
- Corrigido bug na
  [`padronizar_enderecos()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_enderecos.md)
  (quando chamada via
  [`enderecobr::padronizar_enderecos()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_enderecos.md))
  em que a função resultava num erro quando, internamente, a
  [`padronizar_ceps()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_ceps.md)
  identificava um CEP inválido.

## enderecobr 0.4.0

CRAN release: 2025-01-14

### Correção de bugs

- Corrigido bug na
  [`padronizar_numeros()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_numeros.md)
  em que zeros após o separador de milhares eram suprimidos. Por
  exemplo, “1.028” virava “1.28”. Relacionado ao
  [issue](https://github.com/ipeaGIT/enderecobr/issues/37)
  [\#37](https://github.com/ipeaGIT/enderecobr/issues/37).
- Corrigido bug na
  [`padronizar_numeros()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_numeros.md)
  em que zeros de vetores numéricos não eram adequadamente transformados
  em “S/N”. Relacionado ao
  [issue](https://github.com/ipeaGIT/enderecobr/issues/38)
  [\#38](https://github.com/ipeaGIT/enderecobr/issues/38).

### Novas funcionalidades

- Novo argumento na
  [`padronizar_numeros()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_numeros.md),
  `formato`, responsável por controlar como o resultado deve ser
  padronizado: se como um vetor de caracteres ou de inteiros.
- Novo argumento na
  [`padronizar_numeros()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_numeros.md),
  `formato_numeros`, que controla como deve ser feita a padronização de
  números dentro dessa função.

## enderecobr 0.3.0

CRAN release: 2024-12-12

### Novas funcionalidades

- Novo argumento na
  [`padronizar_estados()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_estados.md),
  `formato`, responsável por controlar como o resultado deve ser
  padronizado: se usando o nome por extenso de cada estado ou sua sigla.
- Novo argumento na
  [`padronizar_enderecos()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_enderecos.md),
  `formato_estados`, que controla como deve ser feita a padronização de
  estados dentro dessa função.

## enderecobr 0.2.1

CRAN release: 2024-11-18

### Notas

- Lucas Mation adicionado como autor do pacote.

## enderecobr 0.2.0

CRAN release: 2024-10-28

### Correção de bugs

- Ajuste na exportação dos dados dos códigos de estados e municípios,
  que impedia que o pacote fosse usado sem ser explicitamente carregado
  com [`library(enderecopadrao)`](https://rdrr.io/r/base/library.html).
- Ajuste na
  [`padronizar_estados()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_estados.md),
  evitando casos em que um valor padronizado poderia acabar sendo
  erroneamente atribuído a um estado de input (relacionado ao
  [issue](https://github.com/ipeaGIT/enderecobr/issues/26)
  [\#26](https://github.com/ipeaGIT/enderecobr/issues/26)).

### Novas funcionalidades

- Diversos ajustes nas padronizações.
- Novas funções:
  [`padronizar_tipos_de_logradouro()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_tipos_de_logradouro.md)
  e
  [`padronizar_logradouros_completos()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_logradouros_completos.md).
- Novos argumentos na
  [`padronizar_enderecos()`](https://ipeagit.github.io/enderecobr/dev/reference/padronizar_enderecos.md):
  `manter_cols_extras`, `combinar_logradouro` e `checar_tipos`. A função
  agora mantém as colunas de input no resultado e retorna o output em
  colunas nomeadas no padrão `<campo>_padr`.
- A verbosidade das funções agora pode ser controlada pela opção
  `enderecobr.verbose`, que recebe os valores `"quiet"` ou `"verbose"`.

### Notas

- Primeira versão no CRAN.
- Mudança do nome do pacote, de `{enderecopadrao}` para
  [enderecobr](https://github.com/ipeaGIT/enderecobr).
- Diversos ajustes na documentação.
