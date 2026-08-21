// Uploads the category icons in SmartMoney.Api/wwwroot/media/categories to the
// public `catalogue-media` bucket in Supabase Storage, creating the bucket on
// first run. Safe to re-run: uploads use PUT, so an existing object is
// overwritten in place and its public URL never changes.
//
// The PNGs in wwwroot stay the source of truth and remain version-controlled;
// this script only mirrors them to the CDN that the app actually reads from.
//
// Usage (PowerShell):
//   $env:SUPABASE_URL = 'https://<project-ref>.supabase.co'
//   $env:SUPABASE_SERVICE_ROLE_KEY = '<service role key>'
//   node backend/tools/upload-category-media.mjs
//
// The service role key bypasses row-level security, so keep it out of the repo
// and out of anything shipped to a client. The API reads the same pair from
// user-secrets as SupabaseStorage:Url / SupabaseStorage:ServiceRoleKey.

import { readFileSync, readdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const BUCKET = 'catalogue-media';
const PREFIX = 'categories';
const CACHE_CONTROL = '3600';

const SRC_DIR = join(
  dirname(fileURLToPath(import.meta.url)),
  '../src/SmartMoney.Api/wwwroot/media/categories',
);

const url = (process.env.SUPABASE_URL ?? '').replace(/\/+$/, '');
const key = process.env.SUPABASE_SERVICE_ROLE_KEY ?? '';

if (!url || !key) {
  console.error(
    'Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY before running this script.',
  );
  process.exit(1);
}

const api = (path, init = {}) =>
  fetch(`${url}${path}`, {
    ...init,
    headers: { apikey: key, Authorization: `Bearer ${key}`, ...(init.headers ?? {}) },
  });

async function ensureBucket() {
  const existing = await api(`/storage/v1/bucket/${BUCKET}`);
  if (existing.ok) {
    const bucket = await existing.json();
    if (!bucket.public) {
      throw new Error(
        `Bucket ${BUCKET} exists but is private; the app reads these icons anonymously.`,
      );
    }
    return;
  }

  const created = await api('/storage/v1/bucket', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      id: BUCKET,
      name: BUCKET,
      public: true,
      allowed_mime_types: ['image/png', 'image/jpeg', 'image/webp', 'image/svg+xml'],
    }),
  });

  if (!created.ok) {
    throw new Error(`Bucket create failed (${created.status}): ${await created.text()}`);
  }
  console.log(`Created public bucket ${BUCKET}.`);
}

async function upload(file) {
  const objectPath = `${PREFIX}/${file}`;
  const bytes = readFileSync(join(SRC_DIR, file));

  const response = await api(
    `/storage/v1/object/${encodeURIComponent(BUCKET)}/${objectPath}`,
    {
      method: 'PUT',
      headers: { 'Content-Type': 'image/png', 'cache-control': CACHE_CONTROL },
      body: bytes,
    },
  );

  if (!response.ok) {
    throw new Error(
      `Upload of ${objectPath} failed (${response.status}): ${await response.text()}`,
    );
  }

  console.log(
    `  ${objectPath.padEnd(34)} ${String(Math.round(bytes.length / 1024)).padStart(4)} KB`,
  );
}

await ensureBucket();

const files = readdirSync(SRC_DIR)
  .filter((file) => file.endsWith('.png'))
  .sort();

for (const file of files) {
  await upload(file);
}

console.log(
  `\nUploaded ${files.length} icon(s). Public URL form:\n` +
    `  ${url}/storage/v1/object/public/${BUCKET}/${PREFIX}/<slug>.png\n\n` +
    'Cached for an hour: a replaced icon can take up to that long to propagate.',
);
