use enderecobr_rs::{
    dado_faltante::zerar_dado_faltante,
    is_dado_faltante,
    metaphone::metaphone,
    normalizar,
    numero_extenso::{
        numero_por_extenso, padronizar_numero_romano_por_extenso, padronizar_numeros_por_extenso,
        romano_para_inteiro,
    },
    padronizar_bairros, padronizar_cep, padronizar_cep_leniente, padronizar_cep_numerico,
    padronizar_complementos, padronizar_estados_para_codigo, padronizar_estados_para_nome,
    padronizar_estados_para_sigla, padronizar_logradouros, padronizar_municipios,
    padronizar_numeros, padronizar_tipo_logradouro,
    separador_endereco::{
        estruturar_segmentos, modelo, obter_caminho_modelo, segmentar_enderecos,
        EnderecoSegmentado, OpcoesSegmentacao, SeparadorEndereco, SegmentoEndereco, TipoSegmento,
    },
    Endereco,
};
use extendr_api::prelude::*;
use extendr_api::ToVectorValue;
use rustc_hash::FxHashMap;
use std::collections::HashMap;
use std::path::Path;

// Função utilitária interna usada para fazer o tratamento em comum
// dos dados vindos do R para os casos de string.
fn mapear_com_cache<F>(x: Strings, fun: F) -> Strings
where
    F: Fn(&str) -> String,
{
    // Hashmap não padrão, porém mais performático.
    let mut cache = FxHashMap::<&str, Rstr>::default();

    // Contorna um bug de vetor vazio no extendr-api 0.9.0
    if x.len() == 0 {
        return Strings::default();
    }

    x.iter()
        .map(|xi| match xi.is_na() {
            true => Rstr::na(),
            false => {
                let chave = xi.as_ref();
                if let Some(valor_cacheado) = cache.get(&chave) {
                    return valor_cacheado.clone();
                }
                let res_fun = fun(chave);
                let res_r = if res_fun.is_empty() {
                    Rstr::na()
                } else {
                    Rstr::from(res_fun)
                };
                cache.insert(chave, res_r.clone());
                res_r
            }
        })
        .collect::<Strings>()
}

// Utilitários

#[extendr]
pub fn dado_faltante_rs(x: Strings) -> Logicals {
    if x.len() == 0 {
        return Logicals::from_values(Vec::<bool>::new());
    }

    x.iter()
        .map(|xi| match xi.is_na() {
            true => true,
            false => is_dado_faltante(xi.as_ref()),
        })
        .collect()
}

#[extendr]
pub fn padronizar_metaphone_rs(x: Strings) -> Strings {
    mapear_com_cache(x, metaphone)
}

// Preprocessamento comum a todas as padronizações: caixa alta, sem acentos e
// sem espaços sobrando no começo e no fim.
#[extendr]
pub fn normalizar_rs(x: Strings) -> Strings {
    mapear_com_cache(x, |xi| normalizar(xi).to_string())
}

#[extendr]
pub fn zerar_dado_faltante_rs(x: Strings) -> Strings {
    mapear_com_cache(x, |xi| zerar_dado_faltante(xi).to_string())
}

#[extendr]
pub fn numero_por_extenso_rs(x: Integers) -> Strings {
    // Contorna um bug de vetor vazio no extendr-api 0.9.0
    if x.len() == 0 {
        return Strings::default();
    }

    x.iter()
        .map(|xi| match xi.is_na() {
            true => Rstr::na(),
            false => Rstr::from(numero_por_extenso(xi.to_integer()).to_string()),
        })
        .collect::<Strings>()
}

#[extendr]
pub fn romano_para_inteiro_rs(x: Strings) -> Integers {
    if x.len() == 0 {
        return Integers::default();
    }

    x.iter()
        .map(|xi| match xi.is_na() {
            true => Rint::na(),
            false => Rint::from(romano_para_inteiro(xi.as_ref())),
        })
        .collect::<Integers>()
}

#[extendr]
pub fn padronizar_numeros_por_extenso_rs(x: Strings) -> Strings {
    mapear_com_cache(x, |xi| padronizar_numeros_por_extenso(xi).to_string())
}

#[extendr]
pub fn padronizar_numeros_romanos_por_extenso_rs(x: Strings) -> Strings {
    mapear_com_cache(x, |xi| padronizar_numero_romano_por_extenso(xi).to_string())
}

// Principais

#[extendr]
pub fn padronizar_bairros_rs(x: Strings) -> Strings {
    mapear_com_cache(x, padronizar_bairros)
}

#[extendr]
pub fn padronizar_complementos_rs(x: Strings) -> Strings {
    mapear_com_cache(x, padronizar_complementos)
}

#[extendr]
pub fn padronizar_logradouros_rs(x: Strings) -> Strings {
    mapear_com_cache(x, padronizar_logradouros)
}

#[extendr]
pub fn padronizar_tipos_de_logradouros_rs(x: Strings) -> Strings {
    mapear_com_cache(x, padronizar_tipo_logradouro)
}

#[extendr]
pub fn padronizar_municipios_rs(x: Strings) -> Strings {
    mapear_com_cache(x, padronizar_municipios)
}

#[extendr]
pub fn padronizar_ceps_rs(x: Strings) -> Strings {
    mapear_com_cache(x, |cep| match padronizar_cep(cep) {
        Ok(val) => val,
        Err(val) => format!("Erro: {}", val),
    })
}

#[extendr]
pub fn padronizar_ceps_lenientes_rs(x: Strings) -> Strings {
    mapear_com_cache(x, padronizar_cep_leniente)
}

#[extendr]
pub fn padronizar_ceps_numericos_rs(x: Integers) -> Strings {
    if x.len() == 0 {
        return Strings::default();
    }

    x.iter()
        .map(|xi| match xi.is_na() {
            true => Rstr::na(),
            false => match padronizar_cep_numerico(xi.to_integer()) {
                Ok(cep) => Rstr::from(cep),
                Err(err) => Rstr::from(format!("Erro: {}", err.to_string())),
            },
        })
        .collect::<Strings>()
}

#[extendr]
pub fn padronizar_numeros_rs(x: Strings) -> Strings {
    mapear_com_cache(x, padronizar_numeros)
}



// Por algum motivo, na documentação consta para usar #[extendr(default = "value)],
// porém ele só está aceitando o método supostamente depreciado #[default = "value"].
// https://github.com/extendr/extendr/pull/952/files

#[extendr]
pub fn padronizar_estados_rs(
    x: Strings,
    #[extendr(default = "'por_extenso'")] formato: Robj,
) -> Strings {
    match formato.as_str() {
        Some("sigla") => mapear_com_cache(x, |y| padronizar_estados_para_sigla(y).to_string()),
        Some("codigo") => mapear_com_cache(x, |y| padronizar_estados_para_codigo(y).to_string()),
        _ => mapear_com_cache(x, |y| padronizar_estados_para_nome(y).to_string()),
    }
}

// https://extendr.rs/user-guide/type-mapping/into-list.html#intolist-vs-external-pointers

#[extendr]
pub struct Padronizador {
    pub interno: enderecobr_rs::Padronizador,
}

// Função factory simples para o Padronizador.
// Não sei como faria um construtor em R...
#[extendr]
pub fn novo_padronizador(
    #[extendr(default = "list()")] pares_subst: HashMap<&str, Strings>,
) -> Padronizador {
    let mut padr = Padronizador {
        interno: enderecobr_rs::Padronizador::default(),
    };

    if pares_subst.len() > 0 {
        padr.adicionar_substituicoes(pares_subst);
    }
    padr
}

#[extendr]
impl Padronizador {
    // https://extendr.rs/user-guide/type-mapping/collections.html#working-with-mixed-types

    // Espero em R o que seria uma list(regex=c(), subst=c(), ignorar=c())
    // Algumas validações são feitas da pior forma possível: com `panic!`.
    fn adicionar_substituicoes(&mut self, pares_subst: HashMap<&str, Strings>) {
        let regex_str = pares_subst
            .get("regex")
            .expect("Os pares devem ter um atributo 'regexp'");

        // Nada a adicionar se não há regexes (além de evitar um bug no rextendr com vetor vazio).
        if regex_str.len() == 0 {
            return;
        }

        // Obrigo que nada seja NA aqui.
        let vec_regex: Vec<&str> = regex_str
            .iter()
            .map(|xi| match xi.is_na() {
                true => panic!("'regexp' não podem ser NA"),
                false => xi.as_ref(),
            })
            .collect();

        // Os NA viram string vazia aqui (substituição por nada)
        let vec_subst: Vec<&str> = pares_subst
            .get("subst")
            .expect("Os pares devem ter um atributo 'subst'")
            .iter()
            .map(|xi| match xi.is_na() {
                true => "",
                false => xi.as_ref(),
            })
            .collect();

        // NAs aqui viram simplesmente None
        let vec_ignorar: Vec<Option<&str>> = if let Some(ignorar) = pares_subst.get("ignorar") {
            ignorar
                .iter()
                .map(|xi| match xi.is_na() {
                    true => None,
                    false => Some(xi.as_ref()),
                })
                .collect()
        } else {
            // Caso o atributo ignorar não exista na list(), crio uma vazia com a mesma
            // quantidade de elementos de `regex`.
            vec![None; vec_regex.len()]
        };

        assert!(vec_regex.len() == vec_subst.len() && vec_regex.len() == vec_ignorar.len());

        self.interno
            .adicionar_vetores(&vec_regex, &vec_subst, &vec_ignorar);
    }

    fn padronizar(&self, valor: Strings) -> Strings {
        // Similar às funções de padronização pré-definidas, crio um cache local durante a
        // execução.
        mapear_com_cache(valor, |x| self.interno.padronizar(x))
    }

    fn obter_substituicoes(&self) -> List {
        // Retorno uma lista do R com os atributos iguais ao recebidos no método de
        // adicionar_substituicoes.
        // https://extendr.rs/user-guide/type-mapping/collections.html
        //
        let (regex, subst, ignorar) = self.interno.obter_vetores();
        let mut res: HashMap<&str, Strings> = HashMap::with_capacity(3);

        // O `Strings::from_values` já resolve
        res.insert("regex", Strings::from_values(regex));
        res.insert("subst", Strings::from_values(subst));

        // O `Strings::from_values` não funciona aqui porque é um vetor de Option
        let ignorar_strings: Strings = ignorar
            .iter()
            .map(|opt| match opt {
                None => Rstr::na(),
                Some(val) => Rstr::from(*val),
            })
            .collect();

        res.insert("ignorar", ignorar_strings);
        List::try_from(res).unwrap()
    }
}

// ============= Separação e estruturação de endereços ============
//
// Todas as funções desta seção devolvem uma `List` que, em caso de falha na
// obtenção ou leitura do modelo, tem um único elemento chamado `erro`, com a
// mensagem. O R traduz esse elemento no erro estruturado do pacote; assim,
// nenhum desvio atravessa a fronteira como exceção do Rust.

const NOME_ELEMENTO_ERRO: &str = "erro";

fn lista_de_erro(erro: String) -> List {
    List::from_names_and_values([NOME_ELEMENTO_ERRO], [Rstr::from(erro)])
        .expect("lista de erro sempre tem um nome e um valor")
}

// Segmenta só os endereços preenchidos, preservando a posição de cada um e
// devolvendo `EnderecoSegmentado` vazio para os `NA` (que nunca chegam ao
// modelo).
fn segmentar_sem_na(
    enderecos: &Strings,
    probabilidades: bool,
    modelo: Option<&str>,
) -> Result<Vec<EnderecoSegmentado>, String> {
    let opcoes = OpcoesSegmentacao { probabilidades };

    let posicoes: Vec<usize> = enderecos
        .iter()
        .enumerate()
        .filter(|(_, valor)| !valor.is_na())
        .map(|(indice, _)| indice)
        .collect();

    let textos: Vec<&str> = posicoes
        .iter()
        .map(|&indice| enderecos[indice].as_ref())
        .collect();

    let resultados = match modelo {
        Some(caminho) => {
            SeparadorEndereco::carregar(caminho.into())?.segmentar_enderecos(&textos, &opcoes)
        }
        None => segmentar_enderecos(&textos, &opcoes)?,
    };

    let mut segmentados = vec![EnderecoSegmentado::default(); enderecos.len()];
    for (segmentado, &indice) in resultados.into_iter().zip(posicoes.iter()) {
        segmentados[indice] = segmentado;
    }

    Ok(segmentados)
}

// Vetor de texto a partir de campos opcionais, com `NA` nos ausentes.
fn coluna_de_texto(valores: impl Iterator<Item = Option<String>>) -> Strings {
    valores
        .map(|valor| valor.map_or_else(Rstr::na, Rstr::from))
        .collect()
}

// Vetor numérico a partir de campos opcionais, com `NA` nos ausentes.
fn coluna_numerica(valores: impl Iterator<Item = Option<f64>>) -> Doubles {
    valores
        .map(|valor| valor.map_or_else(Rfloat::na, Rfloat::from))
        .collect()
}

// Colunas do data.frame de endereços: um vetor por campo, com `NA` nos campos
// ausentes. As colunas de probabilidade só entram quando a segmentação as
// pediu, para o data.frame não ganhar colunas vazias de brinde.
//
// O campo `localidade` do Rust sai como `bairro`, que é o vocabulário do pacote
// no R (`correspondencia_campos()`, `padronizar_bairros()`).
fn colunas_do_endereco(enderecos: &[Endereco]) -> List {
    let mut nomes: Vec<&str> = vec!["logradouro", "numero", "complemento", "bairro", "cep"];
    let mut colunas: Vec<Robj> = vec![
        coluna_de_texto(enderecos.iter().map(|e| e.logradouro.clone())).into_robj(),
        coluna_de_texto(enderecos.iter().map(|e| e.numero.clone())).into_robj(),
        coluna_de_texto(enderecos.iter().map(|e| e.complemento.clone())).into_robj(),
        coluna_de_texto(enderecos.iter().map(|e| e.localidade.clone())).into_robj(),
        coluna_de_texto(enderecos.iter().map(|e| e.cep.clone())).into_robj(),
    ];

    if enderecos.iter().any(|e| e.probabilidade.is_some()) {
        nomes.push("probabilidade");
        nomes.push("confianca");
        colunas.push(coluna_numerica(enderecos.iter().map(|e| e.probabilidade)).into_robj());
        colunas.push(coluna_numerica(enderecos.iter().map(|e| e.confianca)).into_robj());
    }

    List::from_names_and_values(nomes, colunas).expect("nomes e colunas têm o mesmo tamanho")
}

// Estrutura um vetor de endereços em texto livre, devolvendo uma coluna por
// campo (`logradouro`, `numero`, `complemento`, `bairro`, `cep`) e, quando as
// probabilidades são pedidas, também `probabilidade` e `confianca`.
//
// O data.frame é montado no R a partir das colunas; aqui só os vetores saem.
#[extendr]
fn estruturar_enderecos_rs(
    enderecos: Strings,
    padronizar: bool,
    probabilidades: bool,
    modelo: Option<&str>,
) -> List {
    // Contorna um bug de vetor vazio no extendr-api 0.9.0
    if enderecos.len() == 0 {
        return colunas_do_endereco(&[]);
    }

    let segmentados = match segmentar_sem_na(&enderecos, probabilidades, modelo) {
        Ok(segmentados) => segmentados,
        Err(erro) => return lista_de_erro(erro),
    };

    let estruturados: Vec<Endereco> = segmentados
        .iter()
        .map(|segmentado| estruturar_segmentos(segmentado, padronizar))
        .collect();

    colunas_do_endereco(&estruturados)
}

// Segmenta um vetor de endereços em texto livre. Devolve os segmentos de cada
// endereço numa lista (um data.frame de `valor`, `tipo` e `probabilidade` por
// endereço) mais os vetores `probabilidade` e `confianca` da segmentação
// inteira.
#[extendr]
fn segmentar_enderecos_rs(
    enderecos: Strings,
    probabilidades: bool,
    modelo: Option<&str>,
) -> List {
    if enderecos.len() == 0 {
        return List::from_names_and_values(["segmentos"], [List::default()])
            .expect("lista fixa");
    }

    let segmentados = match segmentar_sem_na(&enderecos, probabilidades, modelo) {
        Ok(segmentados) => segmentados,
        Err(erro) => return lista_de_erro(erro),
    };

    let segmentos: List = segmentados
        .iter()
        .map(|segmentado| {
            let valor = Strings::from_values(segmentado.segmentos.iter().map(|s| s.valor.clone()));
            let tipo = Strings::from_values(
                segmentado
                    .segmentos
                    .iter()
                    .map(|s| s.tipo.como_str()),
            );
            let probabilidade =
                coluna_numerica(segmentado.segmentos.iter().map(|s| s.probabilidade));

            let mut colunas = List::from_values([
                valor.into_robj(),
                tipo.into_robj(),
                probabilidade.into_robj(),
            ]);
            colunas
                .set_names(["valor", "tipo", "probabilidade"])
                .expect("nomes das colunas são fixos");
            colunas
        })
        .collect();

    let probabilidade = coluna_numerica(segmentados.iter().map(|s| s.probabilidade));
    let confianca = coluna_numerica(segmentados.iter().map(|s| s.confianca));

    List::from_names_and_values(
        ["segmentos", "probabilidade", "confianca"],
        [
            segmentos.into_robj(),
            probabilidade.into_robj(),
            confianca.into_robj(),
        ],
    )
    .expect("lista fixa")
}

// Reagrupa segmentos já prontos nos campos de um endereço. Espera, para cada
// endereço, um data.frame com as colunas `valor` e `tipo` (as mesmas que
// `segmentar_enderecos_rs` devolve), e opcionalmente os atributos
// `probabilidade` e `confianca`.
#[extendr]
fn estruturar_segmentos_rs(segmentos: List, padronizar: bool) -> List {
    if segmentos.len() == 0 {
        return colunas_do_endereco(&[]);
    }

    let mut enderecos: Vec<Endereco> = Vec::with_capacity(segmentos.len());

    for (_, elemento) in segmentos.iter() {
        let valores: Strings = match elemento.dollar("valor").and_then(Strings::try_from) {
            Ok(valores) => valores,
            Err(_) => return lista_de_erro("Segmentos devem ter a coluna 'valor'".to_string()),
        };
        let tipos: Strings = match elemento.dollar("tipo").and_then(Strings::try_from) {
            Ok(tipos) => tipos,
            Err(_) => return lista_de_erro("Segmentos devem ter a coluna 'tipo'".to_string()),
        };

        let mut segmentado = EnderecoSegmentado::default();
        // Iterar `Strings` vazio aborta o processo no Windows (extendr 0.9.0):
        // um data.frame de segmentos sem linhas tem que ser pulado aqui.
        if valores.len() > 0 && tipos.len() > 0 {
            for (valor, tipo) in valores.iter().zip(tipos.iter()) {
                if valor.is_na() || tipo.is_na() {
                    continue;
                }
                let tipo = TipoSegmento::from(tipo.as_ref());
                segmentado
                    .segmentos
                    .push(SegmentoEndereco::novo(valor.as_ref(), tipo));
            }
        }

        segmentado.probabilidade = elemento
            .get_attrib("probabilidade")
            .and_then(|x| x.as_real());
        segmentado.confianca = elemento.get_attrib("confianca").and_then(|x| x.as_real());

        enderecos.push(estruturar_segmentos(&segmentado, padronizar));
    }

    colunas_do_endereco(&enderecos)
}

// ============= Modelo e metadados ============

// Resolve o caminho do modelo padrão sem tocar no disco. O download é feito
// pelo R (`utils::download.file()`), não pela crate, que é compilada sem a
// feature `download`.
#[extendr]
fn obter_caminho_modelo_rs(modelo: Option<&str>) -> List {
    match obter_caminho_modelo(modelo.map(Path::new)) {
        Ok(caminho) => List::from_names_and_values(
            ["caminho"],
            [Rstr::from(caminho.to_string_lossy().to_string())],
        )
        .expect("lista fixa"),
        Err(erro) => lista_de_erro(erro),
    }
}

// Rótulos dos tipos de segmento, na ordem do enum do Rust. É a lista que o R
// expõe como `tipos_de_segmento()` e usa para validar entradas.
#[extendr]
fn tipos_de_segmento_rs() -> Strings {
    Strings::from_values(TipoSegmento::TODOS.iter().map(|tipo| tipo.como_str()))
}

// Constantes que descrevem o modelo padrão: versão, origem do download, nome
// do arquivo, diretório de cache e variáveis de ambiente que o controlam.
#[extendr]
fn informacoes_do_modelo_rs() -> List {
    List::from_names_and_values(
        [
            "versao",
            "url",
            "diretorio_cache",
            "arquivo",
            "variavel_ambiente",
            "variavel_ambiente_sem_download",
        ],
        [
            Rstr::from(modelo::VERSAO_MODELO),
            Rstr::from(modelo::MODEL_DOWNLOAD_PATH),
            Rstr::from(modelo::NOME_DIRETORIO_CACHE),
            Rstr::from(modelo::NOME_ARQUIVO_MODELO),
            Rstr::from(modelo::VAR_AMBIENTE_MODELO),
            Rstr::from(modelo::VAR_AMBIENTE_SEM_DOWNLOAD),
        ],
    )
    .expect("lista fixa")
}

// ============= Padronizadores predefinidos ============
// A ideia é liberar para personalização.

#[extendr]
fn obter_padronizador_logradouros() -> Padronizador {
    Padronizador {
        interno: enderecobr_rs::logradouro::criar_padronizador_logradouros(),
    }
}

#[extendr]
fn obter_padronizador_numeros() -> Padronizador {
    Padronizador {
        interno: enderecobr_rs::numero::criar_padronizador_numeros(),
    }
}

#[extendr]
fn obter_padronizador_bairros() -> Padronizador {
    Padronizador {
        interno: enderecobr_rs::bairro::criar_padronizador_bairros(),
    }
}

#[extendr]
fn obter_padronizador_complementos() -> Padronizador {
    Padronizador {
        interno: enderecobr_rs::complemento::criar_padronizador_complemento(),
    }
}

#[extendr]
fn obter_padronizador_tipos_logradouros() -> Padronizador {
    Padronizador {
        interno: enderecobr_rs::tipo_logradouro::criar_padronizador_tipo_logradouro(),
    }
}

extendr_module! {
    mod enderecobr;
    fn dado_faltante_rs;
    fn padronizar_metaphone_rs;
    fn padronizar_numeros_por_extenso_rs;
    fn padronizar_numeros_romanos_por_extenso_rs;
    fn padronizar_bairros_rs;
    fn padronizar_complementos_rs;
    fn padronizar_logradouros_rs;
    fn padronizar_tipos_de_logradouros_rs;
    fn padronizar_municipios_rs;
    fn padronizar_numeros_rs;
    fn padronizar_estados_rs;
    fn padronizar_ceps_rs;
    fn padronizar_ceps_numericos_rs;
    fn padronizar_ceps_lenientes_rs;
    fn normalizar_rs;
    fn zerar_dado_faltante_rs;
    fn numero_por_extenso_rs;
    fn romano_para_inteiro_rs;
    fn estruturar_enderecos_rs;
    fn segmentar_enderecos_rs;
    fn estruturar_segmentos_rs;
    fn obter_caminho_modelo_rs;
    fn tipos_de_segmento_rs;
    fn informacoes_do_modelo_rs;
    impl Padronizador;
    fn novo_padronizador;
    fn obter_padronizador_logradouros;
    fn obter_padronizador_tipos_logradouros;
    fn obter_padronizador_complementos;
    fn obter_padronizador_bairros;
    fn obter_padronizador_numeros;
}
