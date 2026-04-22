-- ═══════════════════════════════════════════════════════════════════════════
-- CUME — Template para importar tabelas oficiais (DATASUS + ANS)
-- ═══════════════════════════════════════════════════════════════════════════
-- Este arquivo é um TEMPLATE. Os dados oficiais precisam ser baixados e
-- convertidos em CSV antes (ver README_IMPORT.md). O fluxo completo é:
--
--   1. Baixar SIGTAP do DATASUS (mensal):
--      ftp://ftp2.datasus.gov.br/public/sistemas/tup/
--      Arquivo: TabelaUnificada_YYYYMM_vNN.zip
--      Dentro tem: tb_procedimento.txt (layout fixo — ver tb_procedimento_layout.txt)
--
--   2. Baixar TUSS da ANS:
--      https://www.gov.br/ans/pt-br/assuntos/prestadores/padrao-para-troca-de-informacao-de-saude-suplementar-tiss/padrao-tiss-versao-vigente
--      Componente: TUSS Terminologia (planilha Excel publicada pela ANS)
--
--   3. Converter ambos em CSV com colunas padronizadas abaixo.
--
--   4. Carregar via Supabase Dashboard → Database → Table Editor → Import CSV
--      (ou via psql \COPY conforme comentários abaixo)
--
--   5. Rodar os blocos UPSERT deste arquivo para integrar com procedimentos.
--
-- ATENÇÃO: CBHPM é publicação da AMB (Associação Médica Brasileira) e está
-- sob licença proprietária. NÃO redistribua a CBHPM completa — apenas
-- códigos individuais como referência.
-- ═══════════════════════════════════════════════════════════════════════════

-- PASSO A) Tabela staging para SIGTAP bruto -------------------------------
create table if not exists public.sigtap_raw (
  codigo              text primary key,  -- 10 dígitos
  nome                text not null,
  complexidade        text,              -- MC, AC, AMB
  sexo                text,              -- A, M, F
  idade_minima        int,
  idade_maxima        int,
  valor_sh            numeric,           -- serviço hospitalar
  valor_sa            numeric,           -- serviço ambulatorial
  valor_sp            numeric,           -- serviço profissional
  dias_permanencia    int,
  grupo               text,
  subgrupo            text,
  forma_organizacao   text,
  atualizado_em       date default current_date
);

-- Exemplo de import via psql (rodar pelo terminal, não pelo SQL Editor):
-- \COPY public.sigtap_raw FROM '/caminho/tb_procedimento.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');


-- PASSO B) Tabela staging para TUSS bruto ---------------------------------
create table if not exists public.tuss_raw (
  codigo              text primary key,  -- 8 dígitos
  nome                text not null,
  capitulo            text,
  grupo               text,
  subgrupo            text,
  porte_anestesico    text,
  porte_cirurgiao     text,              -- CBHPM referência (guardar se vier)
  auxiliares          smallint,
  incidencia          text,              -- unilateral/bilateral/NA
  data_publicacao     date,
  atualizado_em       date default current_date
);

-- Exemplo de import:
-- \COPY public.tuss_raw FROM '/caminho/tuss_terminologia.csv' WITH (FORMAT csv, HEADER true, DELIMITER ';');


-- PASSO C) Mapeamento TUSS ↔ SIGTAP (cross-reference) ---------------------
-- Construído manualmente por um médico ou via script de matching fuzzy.
-- ANS não publica mapeamento oficial (são taxonomias diferentes).
create table if not exists public.proc_mapeamento (
  id             bigserial primary key,
  tuss_codigo    text references public.tuss_raw(codigo),
  sigtap_codigo  text references public.sigtap_raw(codigo),
  confianca      text check (confianca in ('ALTA','MEDIA','BAIXA')) default 'MEDIA',
  revisado_por   text,
  revisado_em    timestamptz,
  observacao     text,
  unique (tuss_codigo, sigtap_codigo)
);


-- PASSO D) UPSERT massa → procedimentos -----------------------------------
-- Depois de carregar sigtap_raw e tuss_raw, este UPSERT popula a tabela
-- procedimentos (que é a usada pelo front) com catálogo completo.

-- D.1 — Importa procedimentos do SIGTAP que ainda não estão cadastrados:
insert into public.procedimentos
  (nome, sigtap, especialidade, complexidade, grupo_sigtap, origem)
select
  upper(trim(s.nome)),
  s.codigo,
  null,                   -- especialidade precisa ser inferida depois
  case s.complexidade
    when 'AC' then 'ALTA'
    when 'MC' then 'MEDIA'
    else 'BAIXA'
  end,
  s.grupo,
  'SIGTAP_IMPORT'
from public.sigtap_raw s
on conflict (upper(trim(nome)))
do update set
  sigtap = coalesce(public.procedimentos.sigtap, excluded.sigtap),
  complexidade = coalesce(public.procedimentos.complexidade, excluded.complexidade),
  grupo_sigtap = coalesce(public.procedimentos.grupo_sigtap, excluded.grupo_sigtap);


-- D.2 — Importa procedimentos do TUSS (completa os que vieram do SIGTAP):
insert into public.procedimentos
  (nome, tuss, especialidade, porte_anestesico, auxiliares, capitulo_tuss, origem)
select
  upper(trim(t.nome)),
  t.codigo,
  null,
  t.porte_anestesico,
  coalesce(t.auxiliares, 0),
  t.capitulo,
  'TUSS_IMPORT'
from public.tuss_raw t
on conflict (upper(trim(nome)))
do update set
  tuss = coalesce(public.procedimentos.tuss, excluded.tuss),
  porte_anestesico = coalesce(public.procedimentos.porte_anestesico, excluded.porte_anestesico),
  auxiliares = coalesce(public.procedimentos.auxiliares, excluded.auxiliares),
  capitulo_tuss = coalesce(public.procedimentos.capitulo_tuss, excluded.capitulo_tuss);


-- D.3 — Via mapeamento (opcional, se existir cross-reference):
update public.procedimentos p
   set tuss = coalesce(p.tuss, m.tuss_codigo)
  from public.proc_mapeamento m
 where p.sigtap = m.sigtap_codigo
   and p.tuss is null;

-- ═══════════════════════════════════════════════════════════════════════════
-- FIM. Ao final deste import, a tabela procedimentos terá os milhares de
-- entradas oficiais + os 180 que vieram do seed + os que a Letícia
-- cadastrou manualmente.
-- ═══════════════════════════════════════════════════════════════════════════
