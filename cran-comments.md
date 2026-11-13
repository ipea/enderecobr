## Submissão: enderecobr 0.6.1.0001 (rascunho)

── R CMD check results ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── enderecobr 0.6.1.0001 ────

0 errors | 0 warnings | 1 note

Note justificado: "Compilation used the following non-portable flag(s):
'-mno-omit-leaf-frame-pointer'". A flag vem do perfil de release do Rust
(`src/rust/Cargo.toml`) e não é escolhida pelo `configure`: é o ajuste de
desempenho documentado pelo rustc. O mesmo note aparece desde a 0.6.0 e não
tem efeito sobre portabilidade em nenhuma das plataformas do CRAN.

## Notas desta versão

- Passa a usar a crate `enderecobr_rs` v0.7.4, o que traz a segmentação de
  endereços (modelo CRF) para o R. As dependências Rust são compiladas sem o
  cliente HTTP da crate (o pacote declara `features = ["separador"]`), porque o
  download do modelo é feito no R; isso também reduz o `vendor.tar.xz` para 2,9
  MB (39 crates).
- O modelo (`tagger.crf`) NÃO faz parte do pacote: é baixado pelo próprio R
  (`utils::download.file()`) na primeira chamada e guardado no cache do
  sistema. Por isso todos os exemplos que dependem dele estão em `\dontrun` e
  nenhum teste acessa a rede: o download é substituído por um mock. O download
  pode ser desligado com `ENDERECOBR_MODELO_SEM_DOWNLOAD=1`.

## Resubmission: enderecobr 0.6.1

── R CMD check results ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────── enderecobr 0.6.1 ────
Duration: 1m 39.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔


This is a patch release that fixes the installation failure of 0.6.0 reported
by the CRAN checks on `r-devel-linux-x86_64-fedora-clang` and
`r-devel-linux-x86_64-fedora-gcc` ("Installation failed",
`ld: cannot find -lR`).

Cause: the build scaffold used by 0.6.0 compiled and ran a small Rust helper
binary during installation to regenerate the R wrapper file. That binary
links against `libR`, which does not exist on R builds configured without
`--enable-R-shlib` (as on the Fedora check machines). The step was
unnecessary at install time (the wrapper file ships with the package) and
is now only run during development, never by `R CMD INSTALL`. Installation
now performs a single `cargo build --lib` and links nothing against R
outside the usual shared-object step.

No changes to the R API, documentation, or behaviour of any function.

## Test environments

- Local Windows 11 (R 4.6.0, Rust 1.87): `R CMD build`, `R CMD INSTALL`
  of the tarball, and `R CMD check --as-cran`
- GitHub Actions (`.github/workflows/check.yaml`):
  - windows-latest (release), windows-11-arm (release)
  - macOS-latest (release)
  - Ubuntu 24.04 (devel, release, oldrel)
  - Fedora 44 container (R-devel, R-hub `gcc16` image) with gcc and with clang
- R-hub v2 containers, including the Fedora-based `gcc16` (Fedora 44,
  GCC 16, matching the failing CRAN flavor) and `atlas` (Fedora 42)
- win-builder (devel)


