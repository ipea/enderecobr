# Deduplicação antes da fronteira R <-> Rust
#
# Padroniza apenas os valores distintos e reindexa o resultado, de modo que o
# extendr enxergue os únicos em vez dos n elementos. O `mapear_com_cache()` do
# lado Rust já memoiza, mas só *depois* de todos os n elementos cruzarem a
# fronteira — e o custo dominante é justamente o R alocar e internar `CHARSXP`.
#
# APLICADO APENAS A `municipio`, `estado` e `numero`.
#
# Isso não é gratuito: `unique()` + `chmatch()` são duas passadas extras sobre o
# vetor inteiro, mais um vetor de índices do tamanho da entrada. Só compensa
# quando a fração de valores distintos é baixa — e essa fração depende de n.
# Medido no CadÚnico (df_full_data.parquet, 43,9 milhões de linhas; contagem
# exata de valores distintos em 2026-09-21, NA contado como um valor):
#
#   n          logradouro   cep    bairro   numero   municipio   estado
#   100 mil       66,5%    44,1%   26,8%     4,1%       5,2%      0,03%
#   1 milhão      39,8%    24,4%    9,8%     0,9%       0,6%      0,00%
#   10 milhões    16,4%     6,6%    3,2%     0,2%       0,06%     0,00%
#   43,9 milhões   8,7%     2,0%    1,7%     0,1%       0,01%     0,00%
#
# `logradouro`, `cep`, `bairro` e `complemento` são texto de cardinalidade aberta:
# em bases de até alguns milhões de linhas a deduplicação custa mais do que
# economiza (medido: regressão de 2,37 s para 2,98 s em 1 milhão de linhas), além
# de aumentar a rotatividade de memória. Por isso NÃO deduplicam.
#
# Também NÃO deduplicam em bases grandes, embora a fração de distintos caia:
# testamos em 2026-09-21 ligar o dedup para logradouro, cep e bairro acima de
# 10 milhões de linhas e o ganho foi pequeno e de sinal instável (razão
# tempo_sem/tempo_com, mínimo de 2-3 repetições):
#
#   n             logradouro    cep    bairro
#   12 milhões       1,36x     0,86x   0,97x
#   43,9 milhões     0,71x     1,19x   1,13x
#
# Como todos os wrappers Rust já memoizam (`mapear_com_cache`), a função de
# padronização só roda nos distintos de qualquer forma; o dedup em R evita apenas
# a travessia dos n elementos pela fronteira, ao custo de `unique()` + `chmatch()`
# sobre n strings. Para cardinalidade alta (3,8 milhões de logradouros distintos
# em 43,9 milhões de linhas) esse custo supera a economia. Decisão: não aplicar.
#
# `municipio`, `estado` e `numero` têm cardinalidade limitada por construção
# (5.570 municípios, 27 estados, números de logradouro repetem muito): a fração de
# distintos é baixa em qualquer tamanho de base, então a deduplicação ganha sempre.
#
# Ver quality_reports/2026-09-16_benchmark-paralelizacao.md, seções 15 a 17.
#
# IMPORTANTE: esta função devolve os índices *antes* da chamada ao `*_rs()`, sem
# empilhar frames em volta dela. Várias mensagens de erro do pacote dependem da
# profundidade da pilha (`sys.call(-10)`, `sys.frame(-7)`, `rlang::caller_env(n)`),
# e a padronização precisa ser reindexada para o comprimento original ANTES de
# qualquer checagem, para que os índices reportados ao usuário sigam sendo os do
# vetor que ele passou.
indices_de_unicos <- function(x) {
  unicos <- unique(x)

  # chmatch é bem mais rápido que match para caracteres; para os demais tipos
  # (numérico/inteiro) usamos match, que também casa NA com NA
  indices <- if (is.character(x)) {
    data.table::chmatch(x, unicos)
  } else {
    match(x, unicos)
  }

  list(unicos = unicos, indices = indices)
}
