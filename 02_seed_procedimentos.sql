-- ═══════════════════════════════════════════════════════════════════════════
-- CUME — Seed inicial de procedimentos (multi-especialidade)
-- ═══════════════════════════════════════════════════════════════════════════
-- Requisitos:  01_migration_procedimentos.sql já executado.
--
-- Filosofia deste seed:
--   • SIGTAP só é preenchido quando o código é certificado (validado na
--     operação da clínica CUME ou amplamente estável na tabela DATASUS).
--   • TUSS é deixado em branco por padrão — a tabela oficial é da ANS e
--     é atualizada trimestralmente. Importe via 03_import_oficiais.sql
--     depois de baixar a planilha oficial.
--   • nome, especialidade, porte anestésico, via de acesso e lateralidade
--     são preenchidos em todos os registros — essa é a camada clínica
--     que dá inteligência à busca mesmo sem o código.
--   • Origem="SEED" deixa claro o que veio daqui vs. cadastro manual.
--
-- Idempotente: usa ON CONFLICT (upper(trim(nome))) para não duplicar se
-- você rodar duas vezes.
-- ═══════════════════════════════════════════════════════════════════════════

-- Helper: insere e ignora se nome já existe ----------------------------------
-- Colunas: nome, sigtap, tuss, especialidade, porte_anestesico, via_acesso,
--          lateralidade, auxiliares, obs, origem

-- ────────────────────────────────────────────────────────────────────────────
-- CIRURGIA GERAL
-- ────────────────────────────────────────────────────────────────────────────
insert into public.procedimentos
  (nome, sigtap, tuss, especialidade, porte_anestesico, via_acesso, lateralidade, auxiliares, obs, origem) values
  ('COLECISTECTOMIA',                           '0407030026', null, 'CIRURGIA_GERAL', '3', 'ABERTA',      'NA',         1, null, 'SEED'),
  ('COLECISTECTOMIA VIDEOLAPAROSCOPICA',        '0407030034', null, 'CIRURGIA_GERAL', '3', 'VIDEO',       'NA',         1, null, 'SEED'),
  ('APENDICECTOMIA',                            '0407020039', null, 'CIRURGIA_GERAL', '3', 'ABERTA',      'NA',         1, null, 'SEED'),
  ('APENDICECTOMIA VIDEOLAPAROSCOPICA',         '0407020047', null, 'CIRURGIA_GERAL', '4', 'VIDEO',       'NA',         1, null, 'SEED'),
  ('HERNIOPLASTIA INGUINAL UNILATERAL',         '0407040102', null, 'CIRURGIA_GERAL', '3', 'ABERTA',      'UNILATERAL', 1, null, 'SEED'),
  ('HERNIOPLASTIA INGUINAL BILATERAL',          null,         null, 'CIRURGIA_GERAL', '3', 'ABERTA',      'BILATERAL',  1, 'Verificar SIGTAP atual', 'SEED'),
  ('HERNIOPLASTIA INGUINAL VIDEOLAPAROSCOPICA', null,         null, 'CIRURGIA_GERAL', '4', 'VIDEO',       'UNILATERAL', 1, 'TEP ou TAPP', 'SEED'),
  ('HERNIOPLASTIA UMBILICAL',                   null,         null, 'CIRURGIA_GERAL', '2', 'ABERTA',      'NA',         0, null, 'SEED'),
  ('HERNIOPLASTIA EPIGASTRICA',                 '0407040064', null, 'CIRURGIA_GERAL', '2', 'ABERTA',      'NA',         0, null, 'SEED'),
  ('HERNIOPLASTIA INCISIONAL',                  null,         null, 'CIRURGIA_GERAL', '3', 'ABERTA',      'NA',         1, null, 'SEED'),
  ('HERNIOPLASTIA DE PAREDE ABDOMINAL COMPLEXA',null,         null, 'CIRURGIA_GERAL', '4', 'ABERTA',      'NA',         2, null, 'SEED'),
  ('LAPAROTOMIA EXPLORADORA',                   null,         null, 'CIRURGIA_GERAL', '4', 'ABERTA',      'NA',         1, null, 'SEED'),
  ('LAPAROSCOPIA DIAGNOSTICA',                  null,         null, 'CIRURGIA_GERAL', '3', 'VIDEO',       'NA',         0, null, 'SEED'),
  ('COLECTOMIA PARCIAL',                        null,         null, 'CIRURGIA_GERAL', '5', 'ABERTA',      'NA',         2, null, 'SEED'),
  ('COLECTOMIA TOTAL',                          null,         null, 'CIRURGIA_GERAL', '6', 'ABERTA',      'NA',         2, null, 'SEED'),
  ('RETOSSIGMOIDECTOMIA',                       null,         null, 'CIRURGIA_GERAL', '5', 'ABERTA',      'NA',         2, null, 'SEED'),
  ('GASTRECTOMIA PARCIAL',                      null,         null, 'CIRURGIA_GERAL', '5', 'ABERTA',      'NA',         2, null, 'SEED'),
  ('GASTRECTOMIA TOTAL',                        null,         null, 'CIRURGIA_GERAL', '6', 'ABERTA',      'NA',         2, null, 'SEED'),
  ('GASTROSTOMIA',                              null,         null, 'CIRURGIA_GERAL', '2', 'ABERTA',      'NA',         0, null, 'SEED'),
  ('ESPLENECTOMIA',                             null,         null, 'CIRURGIA_GERAL', '4', 'ABERTA',      'NA',         1, null, 'SEED'),
  ('ESPLENECTOMIA VIDEOLAPAROSCOPICA',          null,         null, 'CIRURGIA_GERAL', '4', 'VIDEO',       'NA',         1, null, 'SEED'),
  ('TIREOIDECTOMIA TOTAL',                      null,         null, 'CIRURGIA_GERAL', '4', 'ABERTA',      'NA',         1, null, 'SEED'),
  ('TIREOIDECTOMIA PARCIAL',                    null,         null, 'CIRURGIA_GERAL', '3', 'ABERTA',      'UNILATERAL', 1, null, 'SEED'),
  ('PARATIREOIDECTOMIA',                        null,         null, 'CIRURGIA_GERAL', '4', 'ABERTA',      'NA',         1, null, 'SEED'),
  ('CIRURGIA BARIATRICA BY-PASS',               null,         null, 'CIRURGIA_BARIATRICA','5','VIDEO',    'NA',         2, 'Bypass gástrico em Y de Roux', 'SEED'),
  ('CIRURGIA BARIATRICA SLEEVE',                null,         null, 'CIRURGIA_BARIATRICA','5','VIDEO',    'NA',         1, 'Gastrectomia vertical', 'SEED'),
  ('DRENAGEM DE ABSCESSO',                      null,         null, 'CIRURGIA_GERAL', '1', 'ABERTA',      'NA',         0, null, 'SEED'),
  ('BIOPSIA DE LINFONODO',                      null,         null, 'CIRURGIA_GERAL', '1', 'ABERTA',      'NA',         0, null, 'SEED')
on conflict (upper(trim(nome))) do nothing;

-- ────────────────────────────────────────────────────────────────────────────
-- UROLOGIA
-- ────────────────────────────────────────────────────────────────────────────
insert into public.procedimentos
  (nome, sigtap, tuss, especialidade, porte_anestesico, via_acesso, lateralidade, auxiliares, obs, origem) values
  ('RTU DE PROSTATA',                           '0409030040', null, 'UROLOGIA', '3', 'ENDOSCOPICA', 'NA',         0, 'Ressecção endoscópica', 'SEED'),
  ('PROSTATECTOMIA SUPRAPUBICA',                '0409030023', null, 'UROLOGIA', '4', 'ABERTA',      'NA',         1, null, 'SEED'),
  ('PROSTATECTOMIA RADICAL',                    null,         null, 'UROLOGIA', '5', 'ABERTA',      'NA',         2, null, 'SEED'),
  ('PROSTATECTOMIA RADICAL VIDEOLAPAROSCOPICA', null,         null, 'UROLOGIA', '5', 'VIDEO',       'NA',         2, null, 'SEED'),
  ('RTU DE BEXIGA',                             '0409010367', null, 'UROLOGIA', '3', 'ENDOSCOPICA', 'NA',         0, null, 'SEED'),
  ('NEFRECTOMIA TOTAL',                         '0409010219', null, 'UROLOGIA', '5', 'ABERTA',      'UNILATERAL', 1, null, 'SEED'),
  ('NEFRECTOMIA PARCIAL',                       null,         null, 'UROLOGIA', '5', 'ABERTA',      'UNILATERAL', 1, null, 'SEED'),
  ('NEFRECTOMIA VIDEOLAPAROSCOPICA',            null,         null, 'UROLOGIA', '5', 'VIDEO',       'UNILATERAL', 1, null, 'SEED'),
  ('LITOTRIPSIA EXTRACORPOREA',                 '0409010189', null, 'UROLOGIA', '2', 'PERCUTANEA',  'UNILATERAL', 0, null, 'SEED'),
  ('NEFROLITOTRIPSIA PERCUTANEA',               null,         null, 'UROLOGIA', '4', 'PERCUTANEA',  'UNILATERAL', 1, null, 'SEED'),
  ('URETEROLITOTRIPSIA',                        null,         null, 'UROLOGIA', '3', 'ENDOSCOPICA', 'UNILATERAL', 0, null, 'SEED'),
  ('VASECTOMIA',                                '0409040240', null, 'UROLOGIA', '1', 'ABERTA',      'BILATERAL',  0, null, 'SEED'),
  ('ORQUIECTOMIA',                              null,         null, 'UROLOGIA', '2', 'ABERTA',      'UNILATERAL', 0, null, 'SEED'),
  ('POSTECTOMIA',                               null,         null, 'UROLOGIA', '1', 'ABERTA',      'NA',         0, 'Circuncisão', 'SEED'),
  ('HIDROCELECTOMIA',                           null,         null, 'UROLOGIA', '2', 'ABERTA',      'UNILATERAL', 0, null, 'SEED'),
  ('VARICOCELECTOMIA',                          null,         null, 'UROLOGIA', '2', 'ABERTA',      'UNILATERAL', 0, null, 'SEED'),
  ('CISTOSTOMIA',                               null,         null, 'UROLOGIA', '2', 'ABERTA',      'NA',         0, null, 'SEED'),
  ('INSTALACAO CATETER DUPLO J',                '0409010170', null, 'UROLOGIA', '2', 'ENDOSCOPICA', 'UNILATERAL', 0, null, 'SEED'),
  ('RETIRADA CATETER DUPLO J',                  null,         null, 'UROLOGIA', '1', 'ENDOSCOPICA', 'UNILATERAL', 0, null, 'SEED'),
  ('URETROSCOPIA DIAGNOSTICA',                  null,         null, 'UROLOGIA', '2', 'ENDOSCOPICA', 'NA',         0, null, 'SEED'),
  ('BIOPSIA DE PROSTATA',                       null,         null, 'UROLOGIA', '1', 'PERCUTANEA',  'NA',         0, null, 'SEED')
on conflict (upper(trim(nome))) do nothing;

-- ────────────────────────────────────────────────────────────────────────────
-- OBSTETRICIA
-- ────────────────────────────────────────────────────────────────────────────
insert into public.procedimentos
  (nome, sigtap, tuss, especialidade, porte_anestesico, via_acesso, lateralidade, auxiliares, obs, origem) values
  ('PARTO NORMAL',                              '0310010039', null, 'OBSTETRICIA', '3P', 'NA',         'NA', 0, null, 'SEED'),
  ('PARTO NORMAL ALTO RISCO',                   '0310010047', null, 'OBSTETRICIA', '3P', 'NA',         'NA', 0, null, 'SEED'),
  ('CESARIANA',                                 '0411010034', null, 'OBSTETRICIA', '3P', 'ABERTA',     'NA', 1, null, 'SEED'),
  ('CESARIANA ALTO RISCO',                      '0411010026', null, 'OBSTETRICIA', '3P', 'ABERTA',     'NA', 1, null, 'SEED'),
  ('CESARIANA COM LAQUEADURA',                  '0411010042', null, 'OBSTETRICIA', '3P', 'ABERTA',     'NA', 1, null, 'SEED'),
  ('CURETAGEM POS ABORTO',                      '0411020013', null, 'OBSTETRICIA', '2',  'NA',         'NA', 0, null, 'SEED'),
  ('CURETAGEM PUERPERAL',                       null,         null, 'OBSTETRICIA', '2',  'NA',         'NA', 0, null, 'SEED'),
  ('DESCOLAMENTO MANUAL DE PLACENTA',           '0411010018', null, 'OBSTETRICIA', '3P', 'NA',         'NA', 0, null, 'SEED'),
  ('CIRURGIA DE PRENHEZ ECTOPICA',              null,         null, 'OBSTETRICIA', '4',  'ABERTA',     'NA', 1, null, 'SEED'),
  ('CIRURGIA DE PRENHEZ ECTOPICA VIDEO',        null,         null, 'OBSTETRICIA', '4',  'VIDEO',      'NA', 1, null, 'SEED'),
  ('CERCLAGEM DE COLO UTERINO',                 null,         null, 'OBSTETRICIA', '2',  'NA',         'NA', 0, null, 'SEED'),
  ('VERSAO CEFALICA EXTERNA',                   null,         null, 'OBSTETRICIA', '2',  'NA',         'NA', 0, null, 'SEED'),
  ('FORCEPS',                                   null,         null, 'OBSTETRICIA', '3P', 'NA',         'NA', 0, null, 'SEED'),
  ('VACUO EXTRATOR',                            null,         null, 'OBSTETRICIA', '3P', 'NA',         'NA', 0, null, 'SEED'),
  ('REVISAO MANUAL DE CAVIDADE UTERINA',        null,         null, 'OBSTETRICIA', '2',  'NA',         'NA', 0, null, 'SEED')
on conflict (upper(trim(nome))) do nothing;

-- ────────────────────────────────────────────────────────────────────────────
-- GINECOLOGIA
-- ────────────────────────────────────────────────────────────────────────────
insert into public.procedimentos
  (nome, sigtap, tuss, especialidade, porte_anestesico, via_acesso, lateralidade, auxiliares, obs, origem) values
  ('HISTERECTOMIA TOTAL ABDOMINAL',             '0409060135', null, 'GINECOLOGIA', '4', 'ABERTA',     'NA',         1, null, 'SEED'),
  ('HISTERECTOMIA VAGINAL',                     '0409060100', null, 'GINECOLOGIA', '3', 'ABERTA',     'NA',         1, null, 'SEED'),
  ('HISTERECTOMIA COM ANEXECTOMIA',             '0409060119', null, 'GINECOLOGIA', '4', 'ABERTA',     'NA',         1, null, 'SEED'),
  ('HISTERECTOMIA VIDEOLAPAROSCOPICA',          null,         null, 'GINECOLOGIA', '4', 'VIDEO',      'NA',         1, null, 'SEED'),
  ('LAQUEADURA TUBARIA',                        '0409060186', null, 'GINECOLOGIA', '3', 'ABERTA',     'BILATERAL',  0, null, 'SEED'),
  ('LAQUEADURA POS PARTO NORMAL',               '0409060313', null, 'GINECOLOGIA', '3', 'ABERTA',     'BILATERAL',  0, 'Mesma internação', 'SEED'),
  ('LAQUEADURA VIDEOLAPAROSCOPICA',             null,         null, 'GINECOLOGIA', '3', 'VIDEO',      'BILATERAL',  0, null, 'SEED'),
  ('ANEXECTOMIA UNILATERAL',                    null,         null, 'GINECOLOGIA', '3', 'ABERTA',     'UNILATERAL', 1, null, 'SEED'),
  ('OOFORECTOMIA BILATERAL',                    null,         null, 'GINECOLOGIA', '3', 'ABERTA',     'BILATERAL',  1, null, 'SEED'),
  ('SALPINGECTOMIA',                            null,         null, 'GINECOLOGIA', '3', 'ABERTA',     'UNILATERAL', 1, null, 'SEED'),
  ('MIOMECTOMIA',                               null,         null, 'GINECOLOGIA', '4', 'ABERTA',     'NA',         1, null, 'SEED'),
  ('MIOMECTOMIA HISTEROSCOPICA',                null,         null, 'GINECOLOGIA', '3', 'ENDOSCOPICA','NA',         0, null, 'SEED'),
  ('HISTEROSCOPIA DIAGNOSTICA',                 null,         null, 'GINECOLOGIA', '2', 'ENDOSCOPICA','NA',         0, null, 'SEED'),
  ('HISTEROSCOPIA CIRURGICA',                   null,         null, 'GINECOLOGIA', '3', 'ENDOSCOPICA','NA',         0, null, 'SEED'),
  ('CONIZACAO',                                 null,         null, 'GINECOLOGIA', '2', 'ABERTA',     'NA',         0, null, 'SEED'),
  ('CAUTERIZACAO DE COLO UTERINO',              null,         null, 'GINECOLOGIA', '1', 'ABERTA',     'NA',         0, null, 'SEED'),
  ('PERINEOPLASTIA',                            null,         null, 'GINECOLOGIA', '2', 'ABERTA',     'NA',         0, null, 'SEED'),
  ('COLPOPERINEOPLASTIA',                       null,         null, 'GINECOLOGIA', '3', 'ABERTA',     'NA',         1, null, 'SEED'),
  ('EXERESE DE BARTOLINITE',                    null,         null, 'GINECOLOGIA', '1', 'ABERTA',     'UNILATERAL', 0, null, 'SEED')
on conflict (upper(trim(nome))) do nothing;

-- ────────────────────────────────────────────────────────────────────────────
-- MASTOLOGIA
-- ────────────────────────────────────────────────────────────────────────────
insert into public.procedimentos
  (nome, sigtap, tuss, especialidade, porte_anestesico, via_acesso, lateralidade, auxiliares, obs, origem) values
  ('NODULECTOMIA MAMARIA',                      null, null, 'MASTOLOGIA', '2', 'ABERTA', 'UNILATERAL', 0, null, 'SEED'),
  ('QUADRANTECTOMIA',                           null, null, 'MASTOLOGIA', '3', 'ABERTA', 'UNILATERAL', 1, null, 'SEED'),
  ('MASTECTOMIA SIMPLES',                       null, null, 'MASTOLOGIA', '4', 'ABERTA', 'UNILATERAL', 1, null, 'SEED'),
  ('MASTECTOMIA RADICAL MODIFICADA',            null, null, 'MASTOLOGIA', '4', 'ABERTA', 'UNILATERAL', 1, null, 'SEED'),
  ('MASTECTOMIA COM LINFADENECTOMIA',           null, null, 'MASTOLOGIA', '5', 'ABERTA', 'UNILATERAL', 2, null, 'SEED'),
  ('BIOPSIA DE LINFONODO SENTINELA',            null, null, 'MASTOLOGIA', '2', 'ABERTA', 'UNILATERAL', 0, null, 'SEED'),
  ('CORE BIOPSY DE MAMA',                       null, null, 'MASTOLOGIA', '1', 'PERCUTANEA','UNILATERAL', 0, null, 'SEED')
on conflict (upper(trim(nome))) do nothing;

-- ────────────────────────────────────────────────────────────────────────────
-- ANESTESIOLOGIA (atos anestésicos como procedimento)
-- ────────────────────────────────────────────────────────────────────────────
insert into public.procedimentos
  (nome, sigtap, tuss, especialidade, porte_anestesico, via_acesso, lateralidade, auxiliares, obs, origem) values
  ('ANESTESIA OBSTETRICA PARA CESARIANA',       '0417010010', null, 'ANESTESIOLOGIA', '3P', 'NA', 'NA', 0, null, 'SEED'),
  ('ANESTESIA OBSTETRICA PARA PARTO NORMAL',    '0417010029', null, 'ANESTESIOLOGIA', '3P', 'NA', 'NA', 0, null, 'SEED'),
  ('ANESTESIA OBSTETRICA CESARIANA ALTO RISCO', '0417010037', null, 'ANESTESIOLOGIA', '3P', 'NA', 'NA', 0, null, 'SEED'),
  ('ANALGESIA DE PARTO',                        '0417010052', null, 'ANESTESIOLOGIA', '3P', 'NA', 'NA', 0, null, 'SEED'),
  ('ANESTESIA GERAL',                           null,         null, 'ANESTESIOLOGIA', null, 'NA', 'NA', 0, 'Porte varia conforme procedimento', 'SEED'),
  ('ANESTESIA RAQUIDIANA',                      null,         null, 'ANESTESIOLOGIA', null, 'NA', 'NA', 0, null, 'SEED'),
  ('ANESTESIA PERIDURAL',                       null,         null, 'ANESTESIOLOGIA', null, 'NA', 'NA', 0, null, 'SEED'),
  ('BLOQUEIO DE PLEXO BRAQUIAL',                null,         null, 'ANESTESIOLOGIA', null, 'NA', 'UNILATERAL', 0, null, 'SEED'),
  ('BLOQUEIO DE NERVO FEMORAL',                 null,         null, 'ANESTESIOLOGIA', null, 'NA', 'UNILATERAL', 0, null, 'SEED'),
  ('SEDACAO CONSCIENTE',                        null,         null, 'ANESTESIOLOGIA', null, 'NA', 'NA', 0, null, 'SEED'),
  ('SEDACAO PROFUNDA',                          null,         null, 'ANESTESIOLOGIA', null, 'NA', 'NA', 0, null, 'SEED')
on conflict (upper(trim(nome))) do nothing;

-- ────────────────────────────────────────────────────────────────────────────
-- OTORRINOLARINGOLOGIA
-- ────────────────────────────────────────────────────────────────────────────
insert into public.procedimentos
  (nome, sigtap, tuss, especialidade, porte_anestesico, via_acesso, lateralidade, auxiliares, obs, origem) values
  ('ADENOAMIGDALECTOMIA',                       '0404010032', null, 'OTORRINOLARINGOLOGIA', '2', 'ABERTA',      'NA',         0, null, 'SEED'),
  ('AMIGDALECTOMIA',                            '0404010024', null, 'OTORRINOLARINGOLOGIA', '2', 'ABERTA',      'NA',         0, null, 'SEED'),
  ('ADENOIDECTOMIA',                            '0404010016', null, 'OTORRINOLARINGOLOGIA', '2', 'ABERTA',      'NA',         0, null, 'SEED'),
  ('SEPTOPLASTIA',                              '0404010520', null, 'OTORRINOLARINGOLOGIA', '3', 'ABERTA',      'NA',         0, null, 'SEED'),
  ('TURBINECTOMIA',                             '0404010415', null, 'OTORRINOLARINGOLOGIA', '2', 'ABERTA',      'BILATERAL',  0, null, 'SEED'),
  ('TIMPANOPLASTIA',                            '0404010350', null, 'OTORRINOLARINGOLOGIA', '3', 'MICROCIRURGICA','UNILATERAL',0, null, 'SEED'),
  ('MIRINGOTOMIA',                              null,         null, 'OTORRINOLARINGOLOGIA', '1', 'MICROCIRURGICA','UNILATERAL',0, null, 'SEED'),
  ('COLOCACAO DE TUBO DE VENTILACAO',           null,         null, 'OTORRINOLARINGOLOGIA', '1', 'MICROCIRURGICA','BILATERAL', 0, null, 'SEED'),
  ('MASTOIDECTOMIA',                            null,         null, 'OTORRINOLARINGOLOGIA', '4', 'MICROCIRURGICA','UNILATERAL',1, null, 'SEED'),
  ('RINOSSEPTOPLASTIA',                         null,         null, 'OTORRINOLARINGOLOGIA', '3', 'ABERTA',      'NA',         0, null, 'SEED'),
  ('CIRURGIA ENDOSCOPICA DOS SEIOS DA FACE',    null,         null, 'OTORRINOLARINGOLOGIA', '3', 'ENDOSCOPICA', 'NA',         0, 'FESS', 'SEED'),
  ('UVULOPALATOFARINGOPLASTIA',                 null,         null, 'OTORRINOLARINGOLOGIA', '3', 'ABERTA',      'NA',         0, 'Apneia do sono', 'SEED'),
  ('LARINGOSCOPIA CIRURGICA',                   null,         null, 'OTORRINOLARINGOLOGIA', '2', 'ENDOSCOPICA', 'NA',         0, null, 'SEED'),
  ('TRAQUEOSTOMIA',                             null,         null, 'OTORRINOLARINGOLOGIA', '3', 'ABERTA',      'NA',         0, null, 'SEED')
on conflict (upper(trim(nome))) do nothing;

-- ────────────────────────────────────────────────────────────────────────────
-- OFTALMOLOGIA
-- ────────────────────────────────────────────────────────────────────────────
insert into public.procedimentos
  (nome, sigtap, tuss, especialidade, porte_anestesico, via_acesso, lateralidade, auxiliares, obs, origem) values
  ('FACOEMULSIFICACAO COM LIO',                 '0405050377', null, 'OFTALMOLOGIA', '2', 'MICROCIRURGICA','UNILATERAL', 0, null, 'SEED'),
  ('FACECTOMIA EXTRACAPSULAR COM LIO',          '0405050108', null, 'OFTALMOLOGIA', '2', 'MICROCIRURGICA','UNILATERAL', 0, null, 'SEED'),
  ('VITRECTOMIA',                               null,         null, 'OFTALMOLOGIA', '3', 'MICROCIRURGICA','UNILATERAL', 0, null, 'SEED'),
  ('TRABECULECTOMIA',                           null,         null, 'OFTALMOLOGIA', '3', 'MICROCIRURGICA','UNILATERAL', 0, 'Glaucoma', 'SEED'),
  ('CIRURGIA DE PTERIGIO',                      null,         null, 'OFTALMOLOGIA', '1', 'MICROCIRURGICA','UNILATERAL', 0, null, 'SEED'),
  ('CIRURGIA DE ESTRABISMO',                    null,         null, 'OFTALMOLOGIA', '3', 'MICROCIRURGICA','BILATERAL',  0, null, 'SEED'),
  ('DACRIOCISTORRINOSTOMIA',                    null,         null, 'OFTALMOLOGIA', '3', 'MICROCIRURGICA','UNILATERAL', 0, null, 'SEED'),
  ('BLEFAROPLASTIA',                            null,         null, 'OFTALMOLOGIA', '2', 'ABERTA',        'BILATERAL',  0, null, 'SEED'),
  ('INJECAO INTRAVITREA',                       null,         null, 'OFTALMOLOGIA', '1', 'MICROCIRURGICA','UNILATERAL', 0, 'Anti-VEGF', 'SEED'),
  ('CIRURGIA DE CATARATA + VITRECTOMIA',        null,         null, 'OFTALMOLOGIA', '3', 'MICROCIRURGICA','UNILATERAL', 0, 'Procedimento combinado', 'SEED')
on conflict (upper(trim(nome))) do nothing;

-- ────────────────────────────────────────────────────────────────────────────
-- ORTOPEDIA
-- ────────────────────────────────────────────────────────────────────────────
insert into public.procedimentos
  (nome, sigtap, tuss, especialidade, porte_anestesico, via_acesso, lateralidade, auxiliares, obs, origem) values
  ('ARTROSCOPIA DE JOELHO',                     '0408050896', null, 'ORTOPEDIA', '3', 'VIDEO',  'UNILATERAL', 1, null, 'SEED'),
  ('VIDEOARTROSCOPIA',                          '0408060719', null, 'ORTOPEDIA', '3', 'VIDEO',  'UNILATERAL', 1, null, 'SEED'),
  ('ARTROSCOPIA DE OMBRO',                      null,         null, 'ORTOPEDIA', '3', 'VIDEO',  'UNILATERAL', 1, null, 'SEED'),
  ('ARTROSCOPIA DE QUADRIL',                    null,         null, 'ORTOPEDIA', '4', 'VIDEO',  'UNILATERAL', 1, null, 'SEED'),
  ('MENISCECTOMIA PARCIAL',                     null,         null, 'ORTOPEDIA', '3', 'VIDEO',  'UNILATERAL', 1, null, 'SEED'),
  ('RECONSTRUCAO DE LCA',                       null,         null, 'ORTOPEDIA', '4', 'VIDEO',  'UNILATERAL', 1, 'Ligamento cruzado anterior', 'SEED'),
  ('ARTROPLASTIA TOTAL DE JOELHO',              null,         null, 'ORTOPEDIA', '5', 'ABERTA', 'UNILATERAL', 2, null, 'SEED'),
  ('ARTROPLASTIA TOTAL DE QUADRIL',             null,         null, 'ORTOPEDIA', '5', 'ABERTA', 'UNILATERAL', 2, null, 'SEED'),
  ('ARTROPLASTIA PARCIAL DE QUADRIL',           null,         null, 'ORTOPEDIA', '4', 'ABERTA', 'UNILATERAL', 1, null, 'SEED'),
  ('OSTEOSSINTESE DE FEMUR',                    null,         null, 'ORTOPEDIA', '4', 'ABERTA', 'UNILATERAL', 1, null, 'SEED'),
  ('OSTEOSSINTESE DE TIBIA',                    null,         null, 'ORTOPEDIA', '4', 'ABERTA', 'UNILATERAL', 1, null, 'SEED'),
  ('OSTEOSSINTESE DE UMERO',                    null,         null, 'ORTOPEDIA', '4', 'ABERTA', 'UNILATERAL', 1, null, 'SEED'),
  ('OSTEOSSINTESE DE PUNHO',                    null,         null, 'ORTOPEDIA', '3', 'ABERTA', 'UNILATERAL', 0, null, 'SEED'),
  ('OSTEOSSINTESE DE TORNOZELO',                null,         null, 'ORTOPEDIA', '3', 'ABERTA', 'UNILATERAL', 0, null, 'SEED'),
  ('TRATAMENTO CIRURGICO DE FRATURA DE CLAVICULA',null,       null, 'ORTOPEDIA', '3', 'ABERTA', 'UNILATERAL', 0, null, 'SEED'),
  ('RETIRADA DE MATERIAL DE SINTESE',           null,         null, 'ORTOPEDIA', '2', 'ABERTA', 'UNILATERAL', 0, null, 'SEED'),
  ('DESCOMPRESSAO DO TUNEL DO CARPO',           null,         null, 'ORTOPEDIA', '1', 'ABERTA', 'UNILATERAL', 0, null, 'SEED'),
  ('TENORRAFIA',                                null,         null, 'ORTOPEDIA', '2', 'ABERTA', 'UNILATERAL', 0, null, 'SEED'),
  ('HALUX VALGO',                               null,         null, 'ORTOPEDIA', '3', 'ABERTA', 'UNILATERAL', 0, null, 'SEED')
on conflict (upper(trim(nome))) do nothing;

-- ────────────────────────────────────────────────────────────────────────────
-- ENDOSCOPIA / DIAGNÓSTICO
-- ────────────────────────────────────────────────────────────────────────────
insert into public.procedimentos
  (nome, sigtap, tuss, especialidade, porte_anestesico, via_acesso, lateralidade, auxiliares, obs, origem) values
  ('COLONOSCOPIA',                              '0209010029', null, 'ENDOSCOPIA', '2', 'ENDOSCOPICA', 'NA', 0, null, 'SEED'),
  ('COLONOSCOPIA COM POLIPECTOMIA',             null,         null, 'ENDOSCOPIA', '2', 'ENDOSCOPICA', 'NA', 0, null, 'SEED'),
  ('ENDOSCOPIA DIGESTIVA ALTA',                 '0209010037', null, 'ENDOSCOPIA', '2', 'ENDOSCOPICA', 'NA', 0, 'EDA', 'SEED'),
  ('ENDOSCOPIA COM BIOPSIA',                    null,         null, 'ENDOSCOPIA', '2', 'ENDOSCOPICA', 'NA', 0, null, 'SEED'),
  ('ENDOSCOPIA COM POLIPECTOMIA',               null,         null, 'ENDOSCOPIA', '2', 'ENDOSCOPICA', 'NA', 0, null, 'SEED'),
  ('CPRE',                                      null,         null, 'ENDOSCOPIA', '3', 'ENDOSCOPICA', 'NA', 0, 'Colangio pancreatografia retrógrada endoscópica', 'SEED'),
  ('RETOSSIGMOIDOSCOPIA',                       '0209010053', null, 'ENDOSCOPIA', '1', 'ENDOSCOPICA', 'NA', 0, null, 'SEED'),
  ('ECOENDOSCOPIA',                             null,         null, 'ENDOSCOPIA', '3', 'ENDOSCOPICA', 'NA', 0, null, 'SEED'),
  ('CAPSULA ENDOSCOPICA',                       null,         null, 'ENDOSCOPIA', null,'NA',          'NA', 0, null, 'SEED'),
  ('DILATACAO ESOFAGICA',                       null,         null, 'ENDOSCOPIA', '2', 'ENDOSCOPICA', 'NA', 0, null, 'SEED')
on conflict (upper(trim(nome))) do nothing;

-- ────────────────────────────────────────────────────────────────────────────
-- CIRURGIA VASCULAR
-- ────────────────────────────────────────────────────────────────────────────
insert into public.procedimentos
  (nome, sigtap, tuss, especialidade, porte_anestesico, via_acesso, lateralidade, auxiliares, obs, origem) values
  ('TRATAMENTO CIRURGICO DE VARIZES UNILATERAL','0406020574', null, 'CIRURGIA_VASCULAR', '2', 'ABERTA',     'UNILATERAL', 0, null, 'SEED'),
  ('TRATAMENTO CIRURGICO DE VARIZES BILATERAL', null,         null, 'CIRURGIA_VASCULAR', '3', 'ABERTA',     'BILATERAL',  1, null, 'SEED'),
  ('SAFENECTOMIA',                              null,         null, 'CIRURGIA_VASCULAR', '2', 'ABERTA',     'UNILATERAL', 0, null, 'SEED'),
  ('ENDOVENOSA LASER DE VARIZES',               null,         null, 'CIRURGIA_VASCULAR', '2', 'PERCUTANEA', 'UNILATERAL', 0, 'EVLT', 'SEED'),
  ('ESCLEROTERAPIA',                            null,         null, 'CIRURGIA_VASCULAR', null,'PERCUTANEA', 'NA',         0, null, 'SEED'),
  ('ANGIOPLASTIA PERIFERICA',                   null,         null, 'CIRURGIA_VASCULAR', '3', 'PERCUTANEA', 'UNILATERAL', 0, null, 'SEED'),
  ('ENDARTERECTOMIA DE CAROTIDA',               null,         null, 'CIRURGIA_VASCULAR', '5', 'ABERTA',     'UNILATERAL', 1, null, 'SEED'),
  ('BY-PASS FEMORO-POPLITEO',                   null,         null, 'CIRURGIA_VASCULAR', '5', 'ABERTA',     'UNILATERAL', 1, null, 'SEED'),
  ('TRATAMENTO ENDOVASCULAR DE ANEURISMA AORTA',null,         null, 'CIRURGIA_VASCULAR', '5', 'PERCUTANEA', 'NA',         2, 'EVAR', 'SEED'),
  ('AMPUTACAO DE MEMBRO INFERIOR',              null,         null, 'CIRURGIA_VASCULAR', '4', 'ABERTA',     'UNILATERAL', 1, null, 'SEED'),
  ('FAV PARA HEMODIALISE',                      null,         null, 'CIRURGIA_VASCULAR', '2', 'ABERTA',     'UNILATERAL', 0, 'Fístula arteriovenosa', 'SEED')
on conflict (upper(trim(nome))) do nothing;

-- ────────────────────────────────────────────────────────────────────────────
-- CIRURGIA PLÁSTICA
-- ────────────────────────────────────────────────────────────────────────────
insert into public.procedimentos
  (nome, sigtap, tuss, especialidade, porte_anestesico, via_acesso, lateralidade, auxiliares, obs, origem) values
  ('MAMOPLASTIA DE AUMENTO',                    null, null, 'CIRURGIA_PLASTICA', '3', 'ABERTA', 'BILATERAL',  0, null, 'SEED'),
  ('MAMOPLASTIA REDUTORA',                      null, null, 'CIRURGIA_PLASTICA', '3', 'ABERTA', 'BILATERAL',  1, null, 'SEED'),
  ('MASTOPEXIA',                                null, null, 'CIRURGIA_PLASTICA', '3', 'ABERTA', 'BILATERAL',  1, null, 'SEED'),
  ('ABDOMINOPLASTIA',                           null, null, 'CIRURGIA_PLASTICA', '4', 'ABERTA', 'NA',         1, null, 'SEED'),
  ('LIPOASPIRACAO',                             null, null, 'CIRURGIA_PLASTICA', '3', 'PERCUTANEA','NA',      0, null, 'SEED'),
  ('RINOPLASTIA',                               null, null, 'CIRURGIA_PLASTICA', '3', 'ABERTA', 'NA',         0, null, 'SEED'),
  ('OTOPLASTIA',                                null, null, 'CIRURGIA_PLASTICA', '2', 'ABERTA', 'BILATERAL',  0, null, 'SEED'),
  ('RITIDOPLASTIA',                             null, null, 'CIRURGIA_PLASTICA', '3', 'ABERTA', 'NA',         0, 'Lifting facial', 'SEED'),
  ('RECONSTRUCAO DE MAMA',                      null, null, 'CIRURGIA_PLASTICA', '4', 'ABERTA', 'UNILATERAL', 1, null, 'SEED'),
  ('RETIRADA DE QUELOIDE',                      null, null, 'CIRURGIA_PLASTICA', '1', 'ABERTA', 'NA',         0, null, 'SEED'),
  ('DERMOLIPECTOMIA',                           null, null, 'CIRURGIA_PLASTICA', '3', 'ABERTA', 'NA',         1, null, 'SEED')
on conflict (upper(trim(nome))) do nothing;

-- ────────────────────────────────────────────────────────────────────────────
-- PROCTOLOGIA
-- ────────────────────────────────────────────────────────────────────────────
insert into public.procedimentos
  (nome, sigtap, tuss, especialidade, porte_anestesico, via_acesso, lateralidade, auxiliares, obs, origem) values
  ('HEMORROIDECTOMIA',                          null, null, 'PROCTOLOGIA', '2', 'ABERTA', 'NA', 0, null, 'SEED'),
  ('HEMORROIDECTOMIA PPH',                      null, null, 'PROCTOLOGIA', '2', 'ABERTA', 'NA', 0, 'Técnica grampeada', 'SEED'),
  ('FISTULECTOMIA ANAL',                        null, null, 'PROCTOLOGIA', '2', 'ABERTA', 'NA', 0, null, 'SEED'),
  ('ESFINCTEROTOMIA LATERAL',                   null, null, 'PROCTOLOGIA', '2', 'ABERTA', 'NA', 0, 'Fissura anal', 'SEED'),
  ('EXERESE DE CISTO PILONIDAL',                null, null, 'PROCTOLOGIA', '2', 'ABERTA', 'NA', 0, null, 'SEED'),
  ('DRENAGEM DE ABSCESSO PERIANAL',             null, null, 'PROCTOLOGIA', '1', 'ABERTA', 'NA', 0, null, 'SEED')
on conflict (upper(trim(nome))) do nothing;

-- ────────────────────────────────────────────────────────────────────────────
-- CARDIOLOGIA / HEMODINÂMICA
-- ────────────────────────────────────────────────────────────────────────────
insert into public.procedimentos
  (nome, sigtap, tuss, especialidade, porte_anestesico, via_acesso, lateralidade, auxiliares, obs, origem) values
  ('CATETERISMO CARDIACO',                      null, null, 'CARDIOLOGIA', '2', 'PERCUTANEA', 'NA', 0, null, 'SEED'),
  ('ANGIOPLASTIA CORONARIANA',                  null, null, 'CARDIOLOGIA', '3', 'PERCUTANEA', 'NA', 0, 'Com ou sem stent', 'SEED'),
  ('IMPLANTE DE MARCAPASSO',                    null, null, 'CARDIOLOGIA', '3', 'PERCUTANEA', 'NA', 0, null, 'SEED'),
  ('IMPLANTE DE CDI',                           null, null, 'CARDIOLOGIA', '3', 'PERCUTANEA', 'NA', 0, 'Cardiodesfibrilador', 'SEED'),
  ('ESTUDO ELETROFISIOLOGICO',                  null, null, 'CARDIOLOGIA', '3', 'PERCUTANEA', 'NA', 0, null, 'SEED'),
  ('ABLACAO POR CATETER',                       null, null, 'CARDIOLOGIA', '4', 'PERCUTANEA', 'NA', 0, null, 'SEED'),
  ('REVASCULARIZACAO MIOCARDICA',               null, null, 'CIRURGIA_TORACICA','6','ABERTA','NA', 2, 'CRM', 'SEED'),
  ('TROCA VALVAR AORTICA',                      null, null, 'CIRURGIA_TORACICA','6','ABERTA','NA', 2, null, 'SEED'),
  ('TROCA VALVAR MITRAL',                       null, null, 'CIRURGIA_TORACICA','6','ABERTA','NA', 2, null, 'SEED'),
  ('TAVI',                                      null, null, 'CARDIOLOGIA', '5', 'PERCUTANEA', 'NA', 1, 'Implante valvar aórtico percutâneo', 'SEED')
on conflict (upper(trim(nome))) do nothing;

-- ────────────────────────────────────────────────────────────────────────────
-- NEUROCIRURGIA
-- ────────────────────────────────────────────────────────────────────────────
insert into public.procedimentos
  (nome, sigtap, tuss, especialidade, porte_anestesico, via_acesso, lateralidade, auxiliares, obs, origem) values
  ('CRANIOTOMIA',                               null, null, 'NEUROCIRURGIA', '5', 'ABERTA',        'NA', 2, null, 'SEED'),
  ('MICROCIRURGIA PARA HERNIA DISCAL LOMBAR',   null, null, 'NEUROCIRURGIA', '4', 'MICROCIRURGICA','NA', 1, null, 'SEED'),
  ('MICROCIRURGIA PARA HERNIA DISCAL CERVICAL', null, null, 'NEUROCIRURGIA', '4', 'MICROCIRURGICA','NA', 1, null, 'SEED'),
  ('LAMINECTOMIA',                              null, null, 'NEUROCIRURGIA', '4', 'ABERTA',        'NA', 1, null, 'SEED'),
  ('ARTRODESE DE COLUNA',                       null, null, 'NEUROCIRURGIA', '5', 'ABERTA',        'NA', 2, null, 'SEED'),
  ('DERIVACAO VENTRICULO-PERITONEAL',           null, null, 'NEUROCIRURGIA', '3', 'ABERTA',        'NA', 1, 'DVP', 'SEED'),
  ('DRENAGEM DE HEMATOMA SUBDURAL',             null, null, 'NEUROCIRURGIA', '4', 'ABERTA',        'NA', 1, null, 'SEED'),
  ('ANEURISMA CEREBRAL CLIPAGEM',               null, null, 'NEUROCIRURGIA', '6', 'MICROCIRURGICA','NA', 2, null, 'SEED'),
  ('EMBOLIZACAO DE ANEURISMA CEREBRAL',         null, null, 'RADIOLOGIA_INTERVENCIONISTA','5','PERCUTANEA','NA', 1, null, 'SEED')
on conflict (upper(trim(nome))) do nothing;

-- ────────────────────────────────────────────────────────────────────────────
-- CIRURGIA TORÁCICA
-- ────────────────────────────────────────────────────────────────────────────
insert into public.procedimentos
  (nome, sigtap, tuss, especialidade, porte_anestesico, via_acesso, lateralidade, auxiliares, obs, origem) values
  ('TORACOCENTESE',                             null, null, 'CIRURGIA_TORACICA', '1', 'PERCUTANEA', 'UNILATERAL', 0, null, 'SEED'),
  ('DRENAGEM TORACICA',                         null, null, 'CIRURGIA_TORACICA', '2', 'ABERTA',     'UNILATERAL', 0, null, 'SEED'),
  ('LOBECTOMIA PULMONAR',                       null, null, 'CIRURGIA_TORACICA', '5', 'ABERTA',     'UNILATERAL', 2, null, 'SEED'),
  ('PNEUMECTOMIA',                              null, null, 'CIRURGIA_TORACICA', '6', 'ABERTA',     'UNILATERAL', 2, null, 'SEED'),
  ('VIDEOTORACOSCOPIA',                         null, null, 'CIRURGIA_TORACICA', '4', 'VIDEO',      'UNILATERAL', 1, 'VATS', 'SEED'),
  ('MEDIASTINOSCOPIA',                          null, null, 'CIRURGIA_TORACICA', '3', 'VIDEO',      'NA',         0, null, 'SEED')
on conflict (upper(trim(nome))) do nothing;

-- ────────────────────────────────────────────────────────────────────────────
-- DERMATOLOGIA / PEQUENA CIRURGIA
-- ────────────────────────────────────────────────────────────────────────────
insert into public.procedimentos
  (nome, sigtap, tuss, especialidade, porte_anestesico, via_acesso, lateralidade, auxiliares, obs, origem) values
  ('EXERESE DE LESAO DE PELE',                  null, null, 'DERMATOLOGIA', '1', 'ABERTA', 'NA', 0, null, 'SEED'),
  ('BIOPSIA INCISIONAL DE PELE',                null, null, 'DERMATOLOGIA', '1', 'ABERTA', 'NA', 0, null, 'SEED'),
  ('CIRURGIA DE UNHA ENCRAVADA',                null, null, 'DERMATOLOGIA', '1', 'ABERTA', 'NA', 0, null, 'SEED'),
  ('EXERESE DE LIPOMA',                         null, null, 'DERMATOLOGIA', '1', 'ABERTA', 'NA', 0, null, 'SEED'),
  ('EXERESE DE CISTO SEBACEO',                  null, null, 'DERMATOLOGIA', '1', 'ABERTA', 'NA', 0, null, 'SEED'),
  ('CIRURGIA MICROGRAFICA DE MOHS',             null, null, 'DERMATOLOGIA', '2', 'ABERTA', 'NA', 0, null, 'SEED')
on conflict (upper(trim(nome))) do nothing;

-- ────────────────────────────────────────────────────────────────────────────
-- PEDIATRIA CIRÚRGICA
-- ────────────────────────────────────────────────────────────────────────────
insert into public.procedimentos
  (nome, sigtap, tuss, especialidade, porte_anestesico, via_acesso, lateralidade, auxiliares, obs, origem) values
  ('HERNIORRAFIA INGUINAL PEDIATRICA',          null, null, 'PEDIATRIA', '2', 'ABERTA', 'UNILATERAL', 0, null, 'SEED'),
  ('ORQUIOPEXIA',                               null, null, 'PEDIATRIA', '2', 'ABERTA', 'UNILATERAL', 0, 'Criptorquidia', 'SEED'),
  ('CIRCUNCISAO PEDIATRICA',                    null, null, 'PEDIATRIA', '1', 'ABERTA', 'NA',         0, null, 'SEED'),
  ('PIELOPLASTIA PEDIATRICA',                   null, null, 'PEDIATRIA', '4', 'ABERTA', 'UNILATERAL', 1, null, 'SEED'),
  ('CIRURGIA DE FIMOSE',                        null, null, 'PEDIATRIA', '1', 'ABERTA', 'NA',         0, null, 'SEED'),
  ('REPARO DE HIPOSPADIA',                      null, null, 'PEDIATRIA', '3', 'ABERTA', 'NA',         0, null, 'SEED')
on conflict (upper(trim(nome))) do nothing;

-- ────────────────────────────────────────────────────────────────────────────
-- BUCOMAXILOFACIAL
-- ────────────────────────────────────────────────────────────────────────────
insert into public.procedimentos
  (nome, sigtap, tuss, especialidade, porte_anestesico, via_acesso, lateralidade, auxiliares, obs, origem) values
  ('EXODONTIA DE DENTE INCLUSO',                null, null, 'BUCOMAXILOFACIAL', '1', 'ABERTA', 'NA', 0, null, 'SEED'),
  ('OSTEOTOMIA LEFORT I',                       null, null, 'BUCOMAXILOFACIAL', '4', 'ABERTA', 'NA', 1, null, 'SEED'),
  ('OSTEOTOMIA SAGITAL DE MANDIBULA',           null, null, 'BUCOMAXILOFACIAL', '4', 'ABERTA', 'BILATERAL', 1, null, 'SEED'),
  ('REDUCAO DE FRATURA MANDIBULA',              null, null, 'BUCOMAXILOFACIAL', '3', 'ABERTA', 'NA', 0, null, 'SEED'),
  ('REDUCAO DE FRATURA ZIGOMATICA',             null, null, 'BUCOMAXILOFACIAL', '3', 'ABERTA', 'UNILATERAL', 0, null, 'SEED'),
  ('IMPLANTE DENTARIO',                         null, null, 'BUCOMAXILOFACIAL', '1', 'ABERTA', 'NA', 0, null, 'SEED')
on conflict (upper(trim(nome))) do nothing;

-- ═══════════════════════════════════════════════════════════════════════════
-- FIM DO SEED.
--
-- Resultado esperado: ~180 procedimentos cadastrados, organizados por
-- especialidade, prontos pro typeahead do front.
--
-- PRÓXIMO PASSO (quando Leticia quiser códigos completos):
--   Rode 03_import_oficiais.sql depois de baixar as tabelas do DATASUS/ANS
--   (ver README do sistema).
-- ═══════════════════════════════════════════════════════════════════════════
