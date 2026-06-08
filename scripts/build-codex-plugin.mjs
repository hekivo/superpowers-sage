#!/usr/bin/env node
/**
 * build-codex-plugin.mjs
 *
 * Gera o layout que o Codex CLI (>= 0.137) exige, a partir da FONTE ÚNICA
 * (skills/, hooks/ e .codex-plugin/plugin.json na raiz do repo). Sem réplica
 * mantida à mão — é build, igual ao padrão de plugins multi-harness reais
 * (Anthropic commita plugins/<nome>/ com conteúdo real; EveryInc gera via
 * conversor). Symlink NÃO serve: o install do Codex copia o diretório pro
 * cache (~/.codex/plugins/cache/...) e não segue symlink.
 *
 * Gera (todos derivados, marcados como GENERATED):
 *   .agents/plugins/marketplace.json   — manifesto de marketplace (formato 0.137)
 *   plugins/superpowers-sage/          — o plugin com conteúdo REAL:
 *       .codex-plugin/plugin.json      (cópia do manifesto canônico)
 *       skills/  hooks/                (cópia do que o plugin.json declara)
 *
 * Fonte da verdade permanece a raiz (Claude Code lê de lá). Este script só
 * espelha pro subdir que o Codex precisa.
 *
 * Uso:
 *   node scripts/build-codex-plugin.mjs           # (re)gera
 *   node scripts/build-codex-plugin.mjs --check   # CI: falha se o gerado está stale
 */

import {
  readFileSync, writeFileSync, rmSync, mkdirSync, cpSync, existsSync, readdirSync, statSync,
} from 'node:fs';
import { resolve, dirname, join, relative } from 'node:path';
import { fileURLToPath } from 'node:url';
import process from 'node:process';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = resolve(__dirname, '..');
const PLUGIN_NAME = 'superpowers-sage';

const MANIFEST_SRC = resolve(ROOT, '.codex-plugin', 'plugin.json');
const PLUGIN_DIR = resolve(ROOT, 'plugins', PLUGIN_NAME);
const MARKETPLACE = resolve(ROOT, '.agents', 'plugins', 'marketplace.json');

const GENERATED_NOTE =
  'GENERATED por scripts/build-codex-plugin.mjs — NÃO edite à mão. ' +
  'Fonte: skills/ hooks/ .codex-plugin/plugin.json na raiz do repo.';

// Dirs/arquivos da raiz que o plugin do Codex precisa (o que .codex-plugin/plugin.json declara).
const MIRROR = ['skills', 'hooks'];

function readJson(p) {
  return JSON.parse(readFileSync(p, 'utf8'));
}

/** Constrói a árvore de saída em memória → { caminho relativo ao ROOT : conteúdo string } */
function buildArtifacts() {
  const manifest = readJson(MANIFEST_SRC);
  const version = manifest.version;
  const out = {};

  // 1. marketplace.json (formato Codex 0.137: interface + source.path subdir + policy + category)
  const marketplace = {
    name: `${PLUGIN_NAME}-marketplace`,
    interface: {
      displayName: manifest.interface?.displayName ?? 'Superpowers Sage',
    },
    plugins: [
      {
        name: PLUGIN_NAME,
        version,
        source: { source: 'local', path: `./plugins/${PLUGIN_NAME}` },
        policy: { installation: 'AVAILABLE' },
        category: manifest.interface?.category ?? 'Development',
      },
    ],
  };
  out[relative(ROOT, MARKETPLACE)] = JSON.stringify(marketplace, null, 2) + '\n';

  // 2. plugin manifest (cópia) + marcador GENERATED
  out[`plugins/${PLUGIN_NAME}/.codex-plugin/plugin.json`] =
    JSON.stringify(manifest, null, 2) + '\n';
  out[`plugins/${PLUGIN_NAME}/GENERATED.md`] = `# ${GENERATED_NOTE}\n`;

  // 2b. AGENTS.md — regras universais espelhadas de CLAUDE.md para ferramentas
  // que carregam AGENTS.md como instrução sempre-on (OpenAI Codex etc.). Diferente
  // do Claude Code, o Codex NÃO carrega o CLAUDE.md do plugin nem auto-carrega o
  // AGENTS.md do diretório do plugin — ele lê o AGENTS.md do PROJETO (cwd pra cima)
  // e ~/.codex/AGENTS.md. Por isso geramos o canônico aqui (fonte única: CLAUDE.md)
  // e o usuário Codex traz para o root do projeto (ver README → OpenAI Codex).
  const claudeMd = readFileSync(resolve(ROOT, 'CLAUDE.md'), 'utf8');
  const agentsBody =
    '<!-- GENERATED de CLAUDE.md por scripts/build-codex-plugin.mjs — não edite à mão. -->\n' +
    '<!-- Regras universais superpowers-sage para Codex e ferramentas que leem AGENTS.md. -->\n\n' +
    claudeMd;
  out['AGENTS.md'] = agentsBody;
  out[`plugins/${PLUGIN_NAME}/AGENTS.md`] = agentsBody;

  // 3. conteúdo espelhado (skills/, hooks/) — arquivos reais
  for (const dir of MIRROR) {
    const srcDir = resolve(ROOT, dir);
    if (!existsSync(srcDir)) continue;
    for (const file of walk(srcDir)) {
      const rel = relative(ROOT, file);
      out[`plugins/${PLUGIN_NAME}/${rel}`] = readFileSync(file); // Buffer (binário-safe)
    }
  }
  return out;
}

function* walk(dir) {
  for (const entry of readdirSync(dir)) {
    const p = join(dir, entry);
    if (statSync(p).isDirectory()) yield* walk(p);
    else yield p;
  }
}

function writeAll(artifacts) {
  // limpa as saídas geradas antes de reescrever
  rmSync(PLUGIN_DIR, { recursive: true, force: true });
  rmSync(dirname(MARKETPLACE), { recursive: true, force: true });
  for (const [rel, content] of Object.entries(artifacts)) {
    const abs = resolve(ROOT, rel);
    mkdirSync(dirname(abs), { recursive: true });
    writeFileSync(abs, content);
  }
}

function check(artifacts) {
  const drift = [];
  for (const [rel, content] of Object.entries(artifacts)) {
    const abs = resolve(ROOT, rel);
    if (!existsSync(abs)) {
      drift.push(`faltando: ${rel}`);
      continue;
    }
    const cur = readFileSync(abs);
    const exp = Buffer.isBuffer(content) ? content : Buffer.from(content);
    if (!cur.equals(exp)) drift.push(`stale: ${rel}`);
  }
  // arquivos extras no gerado que não deveriam estar
  if (existsSync(PLUGIN_DIR)) {
    for (const file of walk(PLUGIN_DIR)) {
      const rel = relative(ROOT, file);
      if (!(rel in artifacts)) drift.push(`extra: ${rel}`);
    }
  }
  return drift;
}

const isCheck = process.argv.includes('--check');
const artifacts = buildArtifacts();

if (isCheck) {
  const drift = check(artifacts);
  if (drift.length) {
    console.error('Codex plugin (plugins/ + .agents/) está stale vs a fonte:\n');
    for (const d of drift.slice(0, 20)) console.error(`  - ${d}`);
    if (drift.length > 20) console.error(`  ... +${drift.length - 20}`);
    console.error('\nRode: node scripts/build-codex-plugin.mjs');
    process.exit(1);
  }
  console.log('Codex plugin gerado está em sync com a fonte.');
} else {
  writeAll(artifacts);
  const files = Object.keys(artifacts).length;
  console.log(`Codex plugin gerado: ${files} arquivos em plugins/${PLUGIN_NAME}/ + .agents/plugins/marketplace.json`);
}
