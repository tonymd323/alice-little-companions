// Independent interop check for ALICEBK1 test data, using Node's crypto library.
import assert from 'node:assert/strict';
import { createCipheriv, createHash, pbkdf2Sync } from 'node:crypto';
import { readFileSync } from 'node:fs';

const file = new URL('../fixtures/migration_roundtrip.json', import.meta.url);
const { codec_vector: vector } = JSON.parse(readFileSync(file, 'utf8'));
const header = Buffer.from(vector.header_utf8, 'utf8');
const parameters = JSON.parse(vector.header_utf8);
const length = Buffer.alloc(4);
length.writeUInt32BE(header.length);
const aad = Buffer.concat([Buffer.from('ALICEBK1', 'ascii'), length, header]);
const key = pbkdf2Sync(vector.passphrase, Buffer.from(parameters.salt, 'base64'), parameters.iterations, 32, 'sha256');
const cipher = createCipheriv('aes-256-gcm', key, Buffer.from(parameters.nonce, 'base64'));
cipher.setAAD(aad);
const ciphertext = Buffer.concat([cipher.update(Buffer.from(vector.payload_hex, 'hex')), cipher.final()]);
const tag = cipher.getAuthTag();
assert.equal(key.toString('hex'), vector.key_hex);
assert.equal(ciphertext.toString('hex'), vector.ciphertext_hex);
assert.equal(tag.toString('hex'), vector.tag_hex);
assert.equal(createHash('sha256').update(Buffer.concat([aad,ciphertext,tag])).digest('hex'), vector.container_sha256);
console.log('ALICEBK1 reference vector verified.');
