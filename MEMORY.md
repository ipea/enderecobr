# Project Memory

Corrections and learned facts that persist across sessions for **enderecobr**.
When a mistake is corrected, or a non-obvious approach is confirmed, append a `[LEARN:category]` entry below.

---

<!-- Append new entries below. Most recent at bottom. -->

`[LEARN:enderecobr]` (2026-08-20) **Um `cargo build` limpo em `src/rust/` NÃO
significa que o build do R vai funcionar no Windows.** O `cargo build` direto usa
o target default (`x86_64-pc-windows-msvc`), mas o build do pacote passa por
`tools/config.R` → `src/Makevars.win`, que fixa `TARGET = x86_64-pc-windows-gnu`
(Rtools/gcc). Se esse target não estiver instalado, `devtools::test()` /
`R CMD INSTALL` falham com `error[E0463]: can't find crate for 'core' ... the
x86_64-pc-windows-gnu target may not be installed`, mesmo com o `cargo build`
passando. Errado → confiar no `cargo build` como gate de build no Windows.
Certo → garantir também `rustup target add x86_64-pc-windows-gnu` (e
`aarch64-pc-windows-gnullvm` em ARM64, conforme a lógica de triple em
`tools/config.R`). Checar com `rustup target list --installed`.

`[LEARN:enderecobr]` (2026-08-20) **Todo build do R apaga `src/vendor/` e
`src/.cargo/`.** A regra `rust_clean` do `Makevars(.win)` roda
`rm -Rf $(CARGOTMP) $(VENDOR_DIR) @CLEAN_TARGET@` depois de cada build — e em
build release `@CLEAN_TARGET@` = `$(TARGET_DIR)`, então `src/rust/target/` também
some. Como `src/.cargo/config.toml` redireciona `source.crates-io` para o
diretório `vendor`, um `cargo build` avulso em `src/rust/` passa a falhar logo
após um `devtools::test()` / `R CMD check`, com
`failed to select a version for the requirement ... location searched: directory
source src/vendor`. Errado → tratar `src/vendor/` como estado permanente, ou
achar que o erro indica pin/lock quebrado. Certo → a fonte de verdade é
`src/rust/vendor.tar.xz` (versionado); reextrair com `tar xf rust/vendor.tar.xz`
a partir de `src/`. Regerar o tarball (`cargo vendor ../vendor` em `src/rust/` +
re-tar/xz) sempre que o `Cargo.lock` mudar. Obs.: em disco no Dropbox, o
`cargo vendor` já corrompeu a cópia (arquivo faltando) — apagar o diretório e
revendorar do zero resolve.

[LEARN:enderecobr] (2026-09-08) **extendr-api 0.9.0: iterar `Strings`/`Integers`
vazios aborta o processo no Windows.** `Strings::as_slice()` chama
`slice::from_raw_parts(STRING_PTR_RO(...), len)`; para um STRSXP de tamanho 0 o
R (Windows/R.dll) devolve ponteiro NULL, a checagem de pré-condição do Rust
moderno (>=1.80) pânica e o hook do extendr converte em abort ("non-unwinding
panic"), impossível de capturar via R. Sintoma: qualquer `padronizar_*_rs(character(0))`
mata o R. Certo: guard `if x.len() == 0` antes de iterar (feito em
`mapear_com_cache`, `dado_faltante_rs`, `padronizar_ceps_numericos_rs` e
`adicionar_substituicoes` em `src/rust/src/lib.rs`). Para ver o panic real, setar
`EXTENDR_BACKTRACE=1` (o hook default do extendr suprime a mensagem). Linux não
afetado (R devolve ponteiro não-nulo), por isso o CI/r-universe passa.
Instalar Rust local: rustup com `--default-host x86_64-pc-windows-gnu`
(Rtools atende o target; C: em vez de D: por espaço).

[LEARN:enderecobr] (2026-09-11) **Nunca compilar/rodar um binário cargo na
instalação — só `cargo build --lib`.** O scaffold do rextendr 0.5.0 roda
`cargo run --bin document` no `Makevars(.win)` para regerar
`R/extendr-wrappers.R`. Um binário precisa linkar com `-lR`, e as máquinas
Fedora do CRAN (e qualquer R sem `--enable-R-shlib`) não têm `libR.so`:
`ld: cannot find -lR` → `ERROR: compilation failed` (enderecobr 0.6.0, issue
#70). Não é falta de `-L`: o `build.rs` do extendr-ffi já emite
`rustc-link-search=$R_HOME/lib`. Certo → a etapa fica atrás de
`if [ -n "$$ROXYGEN_PKG" ]` (só roda no `devtools::document()`), com as
mesmas `RUSTFLAGS`/`@PROFILE@` do build da lib para reaproveitar fingerprints.

[LEARN:enderecobr] (2026-09-11) **O `document.c` do rextendr de desenvolvimento
não funciona com o extendr-api 0.9.0.** Ele chama
`write__make_<pkg>_wrappers`, símbolo que só existe no extendr do git `main`
(não em nenhuma versão do crates.io até 0.9.0). Errado → copiar o template dev
do rextendr (`$(CC) rust/document.c ... -lR`). Certo → manter
`document.rs` + `[[bin]] document` até sair um extendr-api > 0.9.0 com o símbolo.

[LEARN:enderecobr] (2026-09-16) **Paralelizar a aplicação vetorial não vale a
pena — decidido com benchmark, não com intuição.** Parece tarefa embaraçosamente
paralela, mas não é *compute-bound*. Em 43,9 M de endereços do CadÚnico, a
decomposição por fase (indexar / mapear / scatter) mostrou que a fase
**paralelizável soma 3,78 s de um pipeline de 117,5 s = 3,2%** — teto de Amdahl,
não expectativa. Ganho real medido com rayon: **zero** (mapear 3.494 ms @1 thread
→ 3.507 ms @16); `par_iter` ingênuo fica **3–10× mais lento** (contenção de
alocador). Causa raiz: os dados são quase todos repetidos (logradouro é o pior
caso com só 8,67% de valores únicos; `estado` tem 27 únicos em 43,9 M linhas), e
o cache `FxHashMap` do `mapear_com_cache` já elimina 91–99,99% do trabalho — vale
**11,6×** em `numeros`. O gargalo real é a fronteira R↔Rust (~18 s dos 33,2 s de
`padronizar_logradouros`) e a alocação de `CHARSXP`, que **exige a thread
principal do R**. Não quebrar o cache em nenhuma refatoração. Relatório completo:
`quality_reports/2026-09-16_benchmark-paralelizacao.md`. Revisar a decisão só se
surgir caso de uso com >50% de valores únicos e >5 M de linhas.

[LEARN:enderecobr] (2026-09-16) **Otimizar tempo sem medir memória e sem testar
bases pequenas quase embarcou uma regressão.** O dedup no R foi aplicado às 8
funções e media 1,72× em 43,9 M — mas em 1 M de linhas *regredia* 26% (2,37 s →
2,98 s) e a alocação subia 52% (9,08 → 13,8 GB). Causa: a fração de valores
distintos depende de n (`logradouro` tem 8,7% de únicos em 43,9 M, mas 39,9% em
1 M e 66,9% em 100 mil). Certo → deduplicar **só nos campos de cardinalidade
limitada por construção** (`municipio`, `estado`, `numero`), que têm fração baixa
em qualquer n. Resultado final: 1,26× em 43,9 M, neutro em 1 M, +29% de alocação.
Heurística que NÃO funciona: decidir por amostragem — uma amostra de 100 mil do
próprio CadÚnico diz "66,9% únicos, não deduplique" justamente na base onde ganha.

[LEARN:enderecobr] (2026-09-16) **Deduplicar ANTES da fronteira extendr foi a
otimização real; paralelizar não era.** Implementado em `R/deduplicacao.R`
(`indices_de_unicos()`), aplicado a `padronizar_municipios/estados/numeros`:
`u <- unique(x); idx <- chmatch(x, u); f_rs(enc2utf8(u))[idx]`. Medido em 43,9 M
linhas: `padronizar_enderecos()` de **126,2 s → 100,4 s (1,26×)**, e neutro em
1 M; saída `identical()`, testes 215/215 iguais. Dois cuidados que NÃO podem ser
perdidos:
(1) reindexar para o comprimento original **antes** das checagens
(`checa_se_letra_presente` etc.), senão os índices nas mensagens de erro passam a
ser os do vetor de únicos; (2) o helper devolve os índices e **não embrulha** a
chamada ao `*_rs()` — as mensagens dependem de profundidade de pilha literal
(`sys.call(-10)`, `sys.frame(-7)`, `caller_env(n = 2 ou 8)`), e um wrapper quebraria
a atribuição do erro em silêncio. Arrow foi medido e **descartado**: com
`data.frame` na entrada e saída custa 32 s contra 30 s (19,5 s para entrar no Arrow
+ 9,2 s para sair).

[LEARN:enderecobr] (2026-09-16) **Nunca comparar performance entre
`devtools::load_all()` e o pacote instalado.** O `load_all()` reaproveita o
`src/Makevars.win` existente; se ele estiver apontando para
`$(TARGET_DIR)/$(TARGET)/debug` (resíduo de uma sessão com `DEBUG` setado), o Rust
roda em **build debug** e fica ordens de magnitude mais lento — `.Call` sozinho
consumiu 95 s no `Rprof` e simulou uma regressão de 117 s → 136 s que não existia.
Conferir com `grep LIBDIR src/Makevars.win`. Para comparar versões: instalar a nova
em release numa lib temporária (`R CMD INSTALL --library=/tmp/lib .`) e usar
`library(enderecobr, lib.loc = ...)`, deixando o pacote instalado do usuário intacto.
