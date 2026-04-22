-- ═══════════════════════════════════════════════════════════════════════════
-- CUME — Adiciona Dr. Frederico à tabela usuarios
-- ═══════════════════════════════════════════════════════════════════════════
-- Roda uma vez no Supabase → SQL Editor.
-- Idempotente (ON CONFLICT DO UPDATE) — pode rodar várias vezes.
--
-- Depois de rodar, ajuste a especialidade dele pelo painel da Letícia
-- (aba 👥 Médicos → Editar Dr. Frederico) — ou edite direto o campo abaixo
-- antes de rodar, se já souber a especialidade.
-- ═══════════════════════════════════════════════════════════════════════════

insert into public.usuarios
  (id, nome, especialidade, senha, emoji, role, ativo)
values
  ('frederico', 'Dr. Frederico', 'Ortopedista', 'Frederico@2024', '🦴', 'medico', true)
on conflict (id) do update
  set nome          = excluded.nome,
      especialidade = excluded.especialidade,
      emoji         = excluded.emoji,
      role          = excluded.role,
      ativo         = true;

-- Lembrete: IMPORTANTE trocar a senha padrão depois do primeiro login.
