# Project Memory

Corrections and learned facts that persist across sessions for
**enderecobr**. When a mistake is corrected, or a non-obvious approach
is confirmed, append a `[LEARN:category]` entry below.

------------------------------------------------------------------------

`[LEARN:enderecobr]` (2026-08-20) **Um `cargo build` limpo em
`src/rust/` NÃO significa que o build do R vai funcionar no Windows.** O
`cargo build` direto usa o target default (`x86_64-pc-windows-msvc`),
mas o build do pacote passa por `tools/config.R` → `src/Makevars.win`,
que fixa `TARGET = x86_64-pc-windows-gnu` (Rtools/gcc). Se esse target
não estiver instalado, `devtools::test()` / `R CMD INSTALL` falham com
`error[E0463]: can't find crate for 'core' ... the x86_64-pc-windows-gnu target may not be installed`,
mesmo com o `cargo build` passando. Errado → confiar no `cargo build`
como gate de build no Windows. Certo → garantir também
`rustup target add x86_64-pc-windows-gnu` (e
`aarch64-pc-windows-gnullvm` em ARM64, conforme a lógica de triple em
`tools/config.R`). Checar com `rustup target list --installed`.

`[LEARN:enderecobr]` (2026-08-20) **Todo build do R apaga `src/vendor/`
e `src/.cargo/`.** A regra `rust_clean` do `Makevars(.win)` roda
`rm -Rf $(CARGOTMP) $(VENDOR_DIR) @CLEAN_TARGET@` depois de cada build —
e em build release `@CLEAN_TARGET@` = `$(TARGET_DIR)`, então
`src/rust/target/` também some. Como `src/.cargo/config.toml`
redireciona `source.crates-io` para o diretório `vendor`, um
`cargo build` avulso em `src/rust/` passa a falhar logo após um
`devtools::test()` / `R CMD check`, com
`failed to select a version for the requirement ... location searched: directory source src/vendor`.
Errado → tratar `src/vendor/` como estado permanente, ou achar que o
erro indica pin/lock quebrado. Certo → a fonte de verdade é
`src/rust/vendor.tar.xz` (versionado); reextrair com
`tar xf rust/vendor.tar.xz` a partir de `src/`. Regerar o tarball
(`cargo vendor ../vendor` em `src/rust/` + re-tar/xz) sempre que o
`Cargo.lock` mudar. Obs.: em disco no Dropbox, o `cargo vendor` já
corrompeu a cópia (arquivo faltando) — apagar o diretório e revendorar
do zero resolve.
