
# devtools::load_all('.')
# library(enderecobr)
library(ipeadatalake)
library(dplyr)

set.seed(42)

2+2

# cad unico --------------------------------------------------------------------
sample_size <- 1000000


cad_con <- ipeadatalake::ler_cadunico(
  data = 202312,
  base = 'familia',
  as_data_frame = F,
  colunas = c("co_familiar_fam", "co_uf", "cd_ibge_cadastro",
              "no_localidade_fam", "no_tip_logradouro_fam",
              "no_tit_logradouro_fam", "no_logradouro_fam",
              "nu_logradouro_fam", "ds_complemento_fam",
              "ds_complemento_adic_fam",
              "nu_cep_logradouro_fam", "co_unidade_territorial_fam",
              "no_unidade_territorial_fam", "co_local_domic_fam")
  )


# compose address fields
df <- cad_con |>
  mutate(no_tip_logradouro_fam = ifelse(is.na(no_tip_logradouro_fam), '', no_tip_logradouro_fam),
         no_tit_logradouro_fam = ifelse(is.na(no_tit_logradouro_fam), '', no_tit_logradouro_fam),
         no_logradouro_fam = ifelse(is.na(no_logradouro_fam), '', no_logradouro_fam)
         ) |>
  mutate(abbrev_state = co_uf,
          code_muni = cd_ibge_cadastro,
          logradouro = paste(no_tip_logradouro_fam, no_tit_logradouro_fam, no_logradouro_fam),
          numero = nu_logradouro_fam,
          cep = nu_cep_logradouro_fam,
          bairro = no_localidade_fam) |>
  select(co_familiar_fam,
         abbrev_state,
         code_muni,
         logradouro,
         numero,
         cep,
         bairro) |>
  dplyr::compute() |>
  dplyr::slice_sample(n = sample_size) |> # sample 20K
  dplyr::collect()

df$id <- 1:nrow(df)


nrow(df)


# benchmark ------------------------------------------------------------------------

campos <- correspondencia_campos(
  logradouro = 'logradouro',
  numero = 'numero',
  cep = 'cep',
  bairro = 'bairro',
  municipio = 'code_muni',
  estado = 'abbrev_state'
)



gc(T,T,T)


# bench::system_time(
bench::mark(iterations = 5,
  df_pdr <- padronizar_enderecos(
    enderecos = df,
    campos_do_endereco = campos,
    formato_estados = "sigla",
    formato_numeros = 'integer'
    )
  )

# 43 milhoes
# expression       min median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time result memory     time       gc      
# V0.5.0         2.28m  2.28m   0.00731    9.08GB   0.0365     1     5      2.28m <dt>   <Rprofmem> <bench_tm> <tibble>
# V0.6.1         1.83m  1.83m   0.00910    9.08GB   0.0364     1     4      1.83m <dt>   <Rprofmem> <bench_tm> <tibble>
# dev dedup      1.42m  1.77m   0.00943    9.55GB   0.0264     5    14      8.84m <dt>   <Rprofmem> <bench_tm> <tibble>


# 1 milhao
# expression       min median `itr/sec` mem_alloc `gc/sec` n_itr  n_gc total_time result memory     time       gc      
# V0.5.0         3.23s  3.23s     0.309     208MB        0     1     0      3.23s <dt>   <Rprofmem> <bench_tm> <tibble>
# V0.6.1         2.37s  2.37s     0.423     225MB        0     1     0      2.37s <dt>   <Rprofmem> <bench_tm> <tibble>
# dev dedup      2.73s  3.05s     0.330     247MB        0     5     0      15.2s <dt>   <Rprofmem> <bench_tm> <tibble>



a <- unique(df$logradouro)
length(a) / length(df$logradouro)
