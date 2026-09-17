# enderecobr dev

## Notas

- Pequena melhora de performance na função `padronizar_enderecos()` para 
bases  de dados grandes (acima de 1 milhão). Performance ganha por fazer 
dedup  ainda dentro do R nos campos de estado, municipio e numero.

# enderecobr 0.6.1

## Notas

- Corrigida falha de instalação nas plataformas Fedora do CRAN
  (`r-devel-linux-x86_64-fedora-clang` e `r-devel-linux-x86_64-fedora-gcc`):
  o gerador de wrappers do extendr (binário `document`) era compilado e
  executado durante a instalação e precisava linkar com a `libR.so`,
  inexistente em builds do R sem `--enable-R-shlib`. A geração de wrappers
  agora ocorre apenas durante `devtools::document()` ([issue
  #70](https://github.com/ipea/enderecobr/issues/70)).

# enderecobr 0.6.0

## Notas

- Atualização do pacote para utilizar a nova crate v0.2.0 do 
[enderecobr_rs](https://github.com/ipea/enderecobr_rs).
- A compilação do pacote requer Rust >= 1.81.0, conforme o requisito do
  `enderecobr_rs` v0.2.0.
- Corrigida a compilação do gerador de wrappers no Windows com Rtools e evitada
  a recompilação desnecessária das dependências Rust nessa etapa.
- Repositório migrado de `ipeaGIT/enderecobr` para `ipea/enderecobr` ([issue
  #67](https://github.com/ipea/enderecobr/issues/67)).
- Mudança de mantenedo do pacote, que passou do Daniel Herszenhut para o Rafel H. M. Pereira.


## Adições e mudanças de padronização

- Novos casos de NA e de "S/N" passaram a ser reconhecidos na padronização de
  números ([issue #68](https://github.com/ipea/enderecobr/issues/68)).
- A `padronizar_numeros()` agora trata números negativos ([issue
  #55](https://github.com/ipea/enderecobr/issues/55)).
- A `padronizar_numeros()` agora reconhece "S/NR" como "S/N" ([issue
  #45](https://github.com/ipea/enderecobr/issues/45)).
- A `padronizar_numeros()` agora trata casos em que "NO" é usado no lugar de
  "nº", como em "LOTE NO 07" ([issue
  #48](https://github.com/ipea/enderecobr/issues/48)).
- A `padronizar_ceps()` agora corrige a presença de caracteres especiais no CEP
  ([issue #53](https://github.com/ipea/enderecobr/issues/53)).
- Na padronização de logradouros e campos afins, barras invertidas (`\`) agora
  são convertidas em barras (`/`) ([issue
  #43](https://github.com/ipea/enderecobr/issues/43)).
- Corrigida a falta de espaço no número de rodovias, como em "RODOVIA RJ216" e
  "RODOVIA BR393" ([issue #47](https://github.com/ipea/enderecobr/issues/47)).
- Corrigidas grafias erradas de "Campos Elíseos" ([issue
  #24](https://github.com/ipea/enderecobr/issues/24)) e variações incorretas de
  "presidente", como "PREZIDENTE", "PRSIDENTE" e "PESIDENTE" ([issue
  #19](https://github.com/ipea/enderecobr/issues/19)).
- A `padronizar_estados()` agora sinaliza erros em inputs de estado inválidos
  ([issue #46](https://github.com/ipea/enderecobr/issues/46)).
- Ajustes no tratamento de municípios de mesmo nome e na documentação do
  `cod_municipio` ([issue
  #7](https://github.com/ipea/enderecobr/issues/7)).
- Incluído o município de "Boa Esperança do Norte" na tabela de códigos
  municipais ([issue
  #45](https://github.com/ipea/enderecobr_rs/issues/45)).




# enderecobr 0.5.0

## Novas funcionalidades

- Novas regras foram adicionadas às funções `padronizar_bairros()` e
  `padronizar_logradouros()`.

## Notas

- As funções de padronização foram [reescritas em Rust](https://github.com/ipea/enderecobr_rs), tornando-as muito mais
  rápidas. Ganho de performance documentado [aqui](https://github.com/ipea/enderecobr/issues/65#issuecomment-3738525612).
  
# enderecobr 0.4.1

## Correção de bugs

- Corrigido bug na `padronizar_enderecos()` (quando chamada via
`enderecobr::padronizar_enderecos()`) em que a função resultava num erro quando,
internamente, a `padronizar_numeros()` lançava um warning. Relacionado ao [issue
#38](https://github.com/ipea/enderecobr/issues/38).
- Corrigido bug na `padronizar_enderecos()` (quando chamada via
`enderecobr::padronizar_enderecos()`) em que a função resultava num erro quando,
internamente, a `padronizar_ceps()` identificava um CEP inválido.

# enderecobr 0.4.0

## Correção de bugs

- Corrigido bug na `padronizar_numeros()` em que zeros após o separador de
milhares eram suprimidos. Por exemplo, "1.028" virava "1.28". Relacionado ao
[issue #37](https://github.com/ipea/enderecobr/issues/37).
- Corrigido bug na `padronizar_numeros()` em que zeros de vetores numéricos não
eram adequadamente transformados em "S/N". Relacionado ao [issue
#38](https://github.com/ipea/enderecobr/issues/38).

## Novas funcionalidades

- Novo argumento na `padronizar_numeros()`, `formato`, responsável por controlar
como o resultado deve ser padronizado: se como um vetor de caracteres ou de
inteiros.
- Novo argumento na `padronizar_numeros()`, `formato_numeros`, que controla como
deve ser feita a padronização de números dentro dessa função.

# enderecobr 0.3.0

## Novas funcionalidades

- Novo argumento na `padronizar_estados()`, `formato`, responsável por controlar
como o resultado deve ser padronizado: se usando o nome por extenso de cada
estado ou sua sigla.
- Novo argumento na `padronizar_enderecos()`, `formato_estados`, que controla
como deve ser feita a padronização de estados dentro dessa função.

# enderecobr 0.2.1

## Notas

- Lucas Mation adicionado como autor do pacote.

# enderecobr 0.2.0

## Correção de bugs

- Ajuste na exportação dos dados dos códigos de estados e municípios, que
impedia que o pacote fosse usado sem ser explicitamente carregado com
`library(enderecopadrao)`.
- Ajuste na `padronizar_estados()`, evitando casos em que um valor padronizado
  poderia acabar sendo erroneamente atribuído a um estado de input (relacionado
  ao [issue #26](https://github.com/ipea/enderecobr/issues/26)).

## Novas funcionalidades

- Diversos ajustes nas padronizações.
- Novas funções: `padronizar_tipos_de_logradouro()` e
  `padronizar_logradouros_completos()`.
- Novos argumentos na `padronizar_enderecos()`: `manter_cols_extras`,
  `combinar_logradouro` e `checar_tipos`. A função agora mantém as
  colunas de input no resultado e retorna o output em colunas nomeadas no padrão
  `<campo>_padr`.
- A verbosidade das funções agora pode ser controlada pela opção
  `enderecobr.verbose`, que recebe os valores `"quiet"` ou `"verbose"`.

## Notas

- Primeira versão no CRAN.
- Mudança do nome do pacote, de `{enderecopadrao}` para `{enderecobr}`.
- Diversos ajustes na documentação.

# enderecopadrao 0.1.0

Primeira versão estável.
