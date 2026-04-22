# CUME — Expansão do catálogo de procedimentos

Este pacote transforma o catálogo de procedimentos do CUME em algo que escala para **milhares de itens e várias especialidades**, preparando o sistema para atender clínicas além da de vocês.

---

## O que mudou

### Antes
- ~50 procedimentos hardcoded num objeto JavaScript dentro do HTML (`SIGTAP_MAP`).
- Datalist estático no front (trava a partir de alguns milhares de itens).
- Campos: nome, SIGTAP, TUSS, observação.

### Agora
- Tabela `procedimentos` no Supabase com 13 campos clínicos (especialidade, porte anestésico, via de acesso, lateralidade, auxiliares previstos, sinônimos, etc.).
- Busca por **full-text search em português** + **trigram** (acento-insensível, tolera erros de digitação).
- Função RPC `buscar_procedimento(termo, especialidade, limite)` pra o front chamar direto.
- Seed inicial com ~180 procedimentos cobrindo 18 especialidades.
- Caminho documentado pra importar as tabelas completas do DATASUS (SIGTAP) e da ANS (TUSS).

---

## Passo a passo pra Leticia

### 1. Rodar a migration
No Supabase Dashboard → **SQL Editor** → cole o conteúdo de `01_migration_procedimentos.sql` → clique **Run**.

Isso cria colunas novas e índices. É **idempotente**: pode rodar várias vezes sem quebrar.

### 2. Rodar o seed
No mesmo SQL Editor → cole `02_seed_procedimentos.sql` → **Run**.

Isso insere os ~180 procedimentos iniciais. Se algum nome já existir, o insert é ignorado (não duplica).

### 3. Substituir o index.html
Suba o `index.html` atualizado pro GitHub (repo `cume2026/cume`, branch `main`, arquivo `index.html`). O GitHub Pages publica automático em 1-2 minutos.

### 4. (Opcional, quando quiser escala total)
Siga as instruções de **import oficial** abaixo pra trazer o catálogo completo do DATASUS e da ANS — aí passa a cobrir qualquer especialidade que aparecer.

---

## Import oficial das tabelas completas

> **Atenção legal:** SIGTAP é gov.br (livre). TUSS Terminologia é publicada pela ANS (redistribuição permitida pra conformidade). **CBHPM é da AMB e tem licença proprietária** — não publicar a tabela completa.

### SIGTAP (SUS) — atualização mensal

1. Acesse `ftp://ftp2.datasus.gov.br/public/sistemas/tup/`
2. Baixe o arquivo mais recente: `TabelaUnificada_YYYYMM_vNN.zip`
3. Descompacte. O arquivo principal é `tb_procedimento.txt` (layout fixo, descrito em `tb_procedimento_layout.txt`).
4. Converta pra CSV (Excel, Python, ou o LibreOffice já faz). Colunas necessárias:

   ```
   codigo;nome;complexidade;sexo;idade_minima;idade_maxima;
   valor_sh;valor_sa;valor_sp;dias_permanencia;grupo;subgrupo;forma_organizacao
   ```

5. No Supabase Dashboard → **Table Editor** → tabela `sigtap_raw` (criada pelo template) → clique em **Insert → Import data from CSV** e escolha o arquivo.

6. No SQL Editor, rode o bloco **D.1** de `03_import_oficiais_TEMPLATE.sql`.

Resultado: ~4.500 procedimentos do SUS entram no catálogo.

### TUSS (ANS) — atualização trimestral

1. Acesse a página da TISS no gov.br:
   https://www.gov.br/ans/pt-br/assuntos/prestadores/padrao-para-troca-de-informacao-de-saude-suplementar-tiss/padrao-tiss-versao-vigente

2. Baixe o componente **TUSS Terminologia** (planilha Excel, versão vigente).

3. Abra no Excel/LibreOffice e salve como CSV com as colunas:

   ```
   codigo;nome;capitulo;grupo;subgrupo;porte_anestesico;
   porte_cirurgiao;auxiliares;incidencia;data_publicacao
   ```

4. Import via Table Editor → tabela `tuss_raw`.

5. Rode o bloco **D.2** de `03_import_oficiais_TEMPLATE.sql`.

Resultado: ~5.500 procedimentos ANS entram no catálogo.

### Cross-reference TUSS ↔ SIGTAP

Não existe mapeamento oficial. Duas opções:

- **Manual (mais preciso):** médico especialista revisa e preenche `proc_mapeamento` item a item. Demorado mas confiável.
- **Automático por similaridade (mais rápido):** script que compara nomes normalizados (sem acentos, em maiúsculas) e preenche com `confianca='BAIXA'`. Posso gerar esse script se você quiser.

---

## Como o front usa o catálogo

O novo `index.html` traz:

1. **Typeahead server-side** no campo "Procedimento" do formulário de registro. Você digita 2 letras e já aparecem sugestões do banco inteiro, com código SIGTAP, TUSS, especialidade e porte anestésico na lateral.

2. **Auto-preenchimento inteligente**: quando você seleciona um item do typeahead, os campos SIGTAP, TUSS e porte anestésico são preenchidos automaticamente.

3. **Filtro por especialidade** no typeahead (se especialidade do médico logado estiver definida, o filtro é aplicado por padrão — configurável).

4. **Painel admin de procedimentos enriquecido**: agora com selects de especialidade, porte anestésico, via de acesso, lateralidade, auxiliares.

---

## Segurança

A RPC `buscar_procedimento` está com `grant execute` pra `anon` e `authenticated`, ou seja, funciona mesmo sem login (a tabela procedimentos não contém dado sensível).

A tabela `procedimentos` deve ter RLS habilitado quando vocês migrarem pra multi-tenant:

```sql
alter table public.procedimentos enable row level security;

-- Leitura: todos autenticados podem ler catálogo
create policy "procedimentos_read" on public.procedimentos
  for select using (true);

-- Escrita: só admin (role='conf' ou 'admin')
create policy "procedimentos_write" on public.procedimentos
  for all using (
    current_setting('app.role', true) in ('conf','admin')
  );
```

(Por enquanto não é urgente — o catálogo é compartilhado entre clínicas.)

---

## Próximos marcos sugeridos

Depois que estabilizar o catálogo:

1. **Sinônimos inteligentes**: pra "coleci", "colangio", "colecistec" todos acharem COLECISTECTOMIA. Já tem coluna `sinonimos text[]` — só falta popular.

2. **Valor de referência por convênio × procedimento**: adicionar tabela `tabela_preco` ligando procedimento + convênio + valor. Muda tudo: o médico lança o registro e o sistema já prevê o valor esperado.

3. **Glosa pattern detection**: quando estiver com volume, um modelo simples ML vê que "PROCEDIMENTO X + CONVÊNIO Y" glosa 40% das vezes e alerta antes de enviar.

Qualquer coisa me chama.
