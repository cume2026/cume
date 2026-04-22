-- ═══════════════════════════════════════════════════════════════════════════
-- CUME — Migration: procedimentos enriquecidos (escalável multi-especialidade)
-- ═══════════════════════════════════════════════════════════════════════════
-- Objetivo:
--   • Enriquecer a tabela procedimentos com campos clínicos (especialidade,
--     porte anestésico, lateralidade, via de acesso, sinônimos).
--   • Criar índices rápidos (trigram + full-text) pra busca funcionar em
--     catálogos de milhares de procedimentos.
--   • Expor uma função RPC buscar_procedimento() que o front chama
--     via typeahead quando o médico digita.
--
-- Idempotente — pode rodar várias vezes sem quebrar nada.
-- ═══════════════════════════════════════════════════════════════════════════

-- 1) EXTENSÕES NECESSÁRIAS --------------------------------------------------
create extension if not exists pg_trgm;
create extension if not exists unaccent;

-- 2) TABELA BASE (caso ambiente novo) --------------------------------------
create table if not exists public.procedimentos (
  id              bigserial primary key,
  nome            text not null,
  sigtap          text,
  tuss            text,
  obs             text,
  ativo           boolean not null default true,
  criado_em       timestamptz default now(),
  atualizado_em   timestamptz default now()
);

-- 3) NOVAS COLUNAS (idempotente) -------------------------------------------
alter table public.procedimentos add column if not exists especialidade     text;
alter table public.procedimentos add column if not exists porte_anestesico  text;
alter table public.procedimentos add column if not exists porte_cirurgiao   text;          -- referência CBHPM (ex: '10A')
alter table public.procedimentos add column if not exists auxiliares        smallint default 0;
alter table public.procedimentos add column if not exists via_acesso        text;          -- 'ABERTA','VIDEO','ROBOTICA','ENDOSCOPICA','PERCUTANEA'
alter table public.procedimentos add column if not exists lateralidade      text;          -- 'UNILATERAL','BILATERAL','NA'
alter table public.procedimentos add column if not exists sinonimos         text[] default '{}';
alter table public.procedimentos add column if not exists capitulo_tuss     text;
alter table public.procedimentos add column if not exists grupo_sigtap      text;
alter table public.procedimentos add column if not exists complexidade      text;          -- 'BAIXA','MEDIA','ALTA'
alter table public.procedimentos add column if not exists origem            text default 'MANUAL';  -- 'MANUAL','SEED','SIGTAP_IMPORT','TUSS_IMPORT'
alter table public.procedimentos add column if not exists codigo_cbhpm      text;

-- 4) CHECKS DE FORMATO (recriáveis) ----------------------------------------
alter table public.procedimentos drop constraint if exists sigtap_format;
alter table public.procedimentos add  constraint sigtap_format
  check (sigtap is null or sigtap ~ '^[0-9]{10}$');

alter table public.procedimentos drop constraint if exists tuss_format;
alter table public.procedimentos add  constraint tuss_format
  check (tuss is null or tuss ~ '^[0-9]+$');

alter table public.procedimentos drop constraint if exists porte_anestesico_format;
alter table public.procedimentos add  constraint porte_anestesico_format
  check (porte_anestesico is null or porte_anestesico in ('1','2','3','3P','4','5','6','7','8'));

alter table public.procedimentos drop constraint if exists especialidade_check;
alter table public.procedimentos add  constraint especialidade_check
  check (especialidade is null or especialidade in (
    'CIRURGIA_GERAL','UROLOGIA','OBSTETRICIA','GINECOLOGIA','ANESTESIOLOGIA',
    'OTORRINOLARINGOLOGIA','OFTALMOLOGIA','ORTOPEDIA','ENDOSCOPIA',
    'CARDIOLOGIA','NEUROCIRURGIA','CIRURGIA_VASCULAR','CIRURGIA_PLASTICA',
    'MASTOLOGIA','PROCTOLOGIA','PNEUMOLOGIA','CIRURGIA_TORACICA',
    'PEDIATRIA','DERMATOLOGIA','RADIOLOGIA_INTERVENCIONISTA',
    'CIRURGIA_BARIATRICA','BUCOMAXILOFACIAL','ONCOLOGIA','NEFROLOGIA','OUTRA'
  ));

alter table public.procedimentos drop constraint if exists via_acesso_check;
alter table public.procedimentos add  constraint via_acesso_check
  check (via_acesso is null or via_acesso in (
    'ABERTA','VIDEO','ROBOTICA','ENDOSCOPICA','PERCUTANEA','MICROCIRURGICA','NA'
  ));

alter table public.procedimentos drop constraint if exists lateralidade_check;
alter table public.procedimentos add  constraint lateralidade_check
  check (lateralidade is null or lateralidade in ('UNILATERAL','BILATERAL','NA'));

-- 5) UNIQUE POR NOME (case/trim-insensitive) -------------------------------
alter table public.procedimentos drop constraint if exists procedimentos_nome_key;
drop index if exists procedimentos_nome_upper_idx;
create unique index procedimentos_nome_upper_idx
  on public.procedimentos (upper(trim(nome)));

-- 6) COLUNA TSVECTOR PARA FULL-TEXT SEARCH ---------------------------------
-- Remove a versão antiga se existir (caso a definição mude entre migrations)
alter table public.procedimentos drop column if exists busca_tsv;

-- Adiciona como coluna normal (não gerada) — o Supabase/Postgres bloqueia
-- colunas geradas com to_tsvector/unaccent porque não são IMMUTABLE.
alter table public.procedimentos add column busca_tsv tsvector;

-- Trigger que mantém busca_tsv sempre atualizado em INSERT/UPDATE
create or replace function public.procedimentos_compute_busca_tsv()
returns trigger
language plpgsql as $$
begin
  new.busca_tsv := to_tsvector('portuguese',
    coalesce(new.nome,'') || ' ' ||
    coalesce(new.especialidade,'') || ' ' ||
    coalesce(array_to_string(new.sinonimos,' '),'') || ' ' ||
    coalesce(new.obs,'') || ' ' ||
    coalesce(new.sigtap,'') || ' ' ||
    coalesce(new.tuss,'')
  );
  return new;
end $$;

drop trigger if exists procedimentos_busca_tsv_tg on public.procedimentos;
create trigger procedimentos_busca_tsv_tg
  before insert or update of nome, especialidade, sinonimos, obs, sigtap, tuss
  on public.procedimentos
  for each row execute function public.procedimentos_compute_busca_tsv();

-- Popula valor para linhas que já existem
update public.procedimentos set busca_tsv = to_tsvector('portuguese',
  coalesce(nome,'') || ' ' ||
  coalesce(especialidade,'') || ' ' ||
  coalesce(array_to_string(sinonimos,' '),'') || ' ' ||
  coalesce(obs,'') || ' ' ||
  coalesce(sigtap,'') || ' ' ||
  coalesce(tuss,'')
) where busca_tsv is null;

-- 7) ÍNDICES ---------------------------------------------------------------
create index if not exists procedimentos_busca_tsv_idx
  on public.procedimentos using gin (busca_tsv);

create index if not exists procedimentos_nome_trgm_idx
  on public.procedimentos using gin (nome gin_trgm_ops);

create index if not exists procedimentos_especialidade_idx
  on public.procedimentos (especialidade) where ativo;

create index if not exists procedimentos_sigtap_idx
  on public.procedimentos (sigtap) where sigtap is not null;

create index if not exists procedimentos_tuss_idx
  on public.procedimentos (tuss) where tuss is not null;

-- 8) RPC DE BUSCA ----------------------------------------------------------
-- Usada pelo typeahead do front (Supabase REST expõe /rpc/buscar_procedimento)
create or replace function public.buscar_procedimento(
  termo text,
  especialidade_filtro text default null,
  limite int default 20
)
returns table (
  id bigint,
  nome text,
  sigtap text,
  tuss text,
  especialidade text,
  porte_anestesico text,
  auxiliares smallint,
  via_acesso text,
  lateralidade text,
  obs text,
  rank real
)
language sql stable as $$
  with q as (
    select unaccent(coalesce(trim(termo),'')) as t
  )
  select
    p.id, p.nome, p.sigtap, p.tuss, p.especialidade,
    p.porte_anestesico, p.auxiliares, p.via_acesso, p.lateralidade, p.obs,
    greatest(
      coalesce(ts_rank(p.busca_tsv, plainto_tsquery('portuguese', (select t from q))), 0),
      coalesce(similarity(unaccent(p.nome), (select t from q)), 0)
    )::real as rank
  from public.procedimentos p, q
  where p.ativo
    and (especialidade_filtro is null or p.especialidade = especialidade_filtro)
    and (
      (select t from q) = '' or
      p.busca_tsv @@ plainto_tsquery('portuguese', (select t from q)) or
      unaccent(p.nome) ilike '%' || (select t from q) || '%' or
      p.sigtap like (select t from q) || '%' or
      p.tuss   like (select t from q) || '%'
    )
  order by rank desc, p.nome asc
  limit greatest(limite, 1);
$$;

-- Permite chamada via PostgREST (anon + authenticated)
grant execute on function public.buscar_procedimento(text, text, int) to anon, authenticated;

-- 9) TRIGGER DE atualizado_em ---------------------------------------------
create or replace function public.tg_procedimentos_touch()
returns trigger language plpgsql as $$
begin
  new.atualizado_em := now();
  return new;
end $$;

drop trigger if exists procedimentos_touch on public.procedimentos;
create trigger procedimentos_touch
  before update on public.procedimentos
  for each row execute function public.tg_procedimentos_touch();

-- ═══════════════════════════════════════════════════════════════════════════
-- FIM. Após rodar este arquivo, rode 02_seed_procedimentos.sql.
-- ═══════════════════════════════════════════════════════════════════════════
