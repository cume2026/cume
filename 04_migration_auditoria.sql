-- ═══════════════════════════════════════════════════════════════════════════
-- CUME — Migration: auditoria de registros + comentários internos
-- ═══════════════════════════════════════════════════════════════════════════
-- Objetivo:
--   • Criar tabela registro_auditoria que guarda toda a história de um
--     registro: quem criou, quem editou, quando, o que mudou, comentários
--     internos trocados entre conferente e médico.
--   • Expor função RPC registrar_evento() pra o front chamar com uma única
--     chamada (em vez de POST + INSERT manuais).
--   • Expor função RPC eventos_do_registro() pra buscar a timeline completa.
--
-- Idempotente — pode rodar várias vezes.
-- ═══════════════════════════════════════════════════════════════════════════

-- 1) TABELA ---------------------------------------------------------------
create table if not exists public.registro_auditoria (
  id              bigserial primary key,
  registro_id     bigint,                           -- FK lógica (sem cascade pra preservar histórico de registros deletados)
  tipo            text not null,                    -- CRIACAO, EDICAO, STATUS, COMENTARIO, EXCLUSAO, IMPORT_PDF, VINCULO_EQUIPE
  usuario_id      text,                             -- id do médico/admin que fez a ação
  usuario_nome    text,                             -- snapshot do nome (caso usuário mude depois)
  campo           text,                             -- nome do campo alterado (quando aplicável)
  valor_antigo    text,
  valor_novo      text,
  comentario      text,                             -- texto livre (principalmente pra tipo='COMENTARIO')
  metadata        jsonb,                            -- flexível pra anexos, refs, etc.
  criado_em       timestamptz not null default now()
);

alter table public.registro_auditoria drop constraint if exists registro_auditoria_tipo_check;
alter table public.registro_auditoria add  constraint registro_auditoria_tipo_check
  check (tipo in (
    'CRIACAO','EDICAO','STATUS','COMENTARIO','EXCLUSAO',
    'IMPORT_PDF','VINCULO_EQUIPE','CONFERIDO','RECURSO_GLOSA'
  ));

-- 2) ÍNDICES -------------------------------------------------------------
create index if not exists registro_auditoria_reg_idx
  on public.registro_auditoria (registro_id, criado_em desc);

create index if not exists registro_auditoria_tipo_idx
  on public.registro_auditoria (tipo) where tipo in ('COMENTARIO','STATUS');

create index if not exists registro_auditoria_usr_idx
  on public.registro_auditoria (usuario_id, criado_em desc);

-- 3) RPC: REGISTRAR EVENTO ------------------------------------------------
create or replace function public.registrar_evento(
  p_registro_id bigint,
  p_tipo text,
  p_usuario_id text default null,
  p_usuario_nome text default null,
  p_campo text default null,
  p_valor_antigo text default null,
  p_valor_novo text default null,
  p_comentario text default null,
  p_metadata jsonb default null
) returns bigint
language plpgsql as $$
declare
  v_id bigint;
begin
  insert into public.registro_auditoria
    (registro_id, tipo, usuario_id, usuario_nome, campo, valor_antigo, valor_novo, comentario, metadata)
  values
    (p_registro_id, p_tipo, p_usuario_id, p_usuario_nome, p_campo, p_valor_antigo, p_valor_novo, p_comentario, p_metadata)
  returning id into v_id;
  return v_id;
end $$;

grant execute on function public.registrar_evento(bigint, text, text, text, text, text, text, text, jsonb)
  to anon, authenticated;

-- 4) RPC: BUSCAR TIMELINE DO REGISTRO ------------------------------------
create or replace function public.eventos_do_registro(
  p_registro_id bigint
) returns table (
  id bigint,
  tipo text,
  usuario_id text,
  usuario_nome text,
  campo text,
  valor_antigo text,
  valor_novo text,
  comentario text,
  metadata jsonb,
  criado_em timestamptz
)
language sql stable as $$
  select id, tipo, usuario_id, usuario_nome, campo, valor_antigo, valor_novo,
         comentario, metadata, criado_em
  from public.registro_auditoria
  where registro_id = p_registro_id
  order by criado_em asc;
$$;

grant execute on function public.eventos_do_registro(bigint) to anon, authenticated;

-- 5) RPC: CONTAR COMENTÁRIOS NÃO LIDOS (placeholder p/ futuro badge) -----
create or replace function public.contar_comentarios(
  p_registro_id bigint
) returns int
language sql stable as $$
  select count(*)::int
  from public.registro_auditoria
  where registro_id = p_registro_id and tipo = 'COMENTARIO';
$$;

grant execute on function public.contar_comentarios(bigint) to anon, authenticated;

-- ═══════════════════════════════════════════════════════════════════════════
-- FIM. Depois de rodar:
--   • Toda ação CRUD no front passa a logar aqui.
--   • Modal de detalhe do registro mostra timeline + caixa de comentário.
--   • Central de Conferência usa isso pra saber "última atividade" de cada item.
-- ═══════════════════════════════════════════════════════════════════════════
