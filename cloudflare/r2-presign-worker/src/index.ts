/**
 * Cloudflare Worker — Generate R2 Presigned URL with JWT
 */

import { AwsClient } from 'aws4fetch';
import * as jose from 'jose'; // untuk verify JWT
import jwt from 'jsonwebtoken';

const R2_BUCKET = 'whypost-bucket';
const R2_ACCOUNT_ID = '326214d461ab1cca1a960b3dadb2fde5';

export interface Env {
	R2_ACCESS_KEY: string;
	R2_SECRET_KEY: string;
	API_SECRET: string; // secret untuk verify JWT
}

export default {
	async fetch(request, env, ctx): Promise<Response> {
		const url = new URL(request.url);

		if (url.pathname === '/get-presigned') {
			// Ambil header Authorization
			const authHeader = request.headers.get('Authorization');
			if (!authHeader?.startsWith('Bearer ')) {
				return new Response('Unauthorized', { status: 401 });
			}

			const token = authHeader.split(' ')[1];

			// Verify JWT
			try {
				const { payload } = await jose.jwtVerify(token, new TextEncoder().encode(env.API_SECRET));

				// bisa cek payload.userId atau claims lain di sini
				console.log('JWT valid:', payload);
			} catch (err) {
				return new Response('Unauthorized', { status: 401 });
			}

			// Ambil nama file
			const filename = url.searchParams.get('filename');
			if (!filename) {
				return new Response(JSON.stringify({ error: 'Missing filename' }), {
					status: 400,
					headers: { 'Content-Type': 'application/json' },
				});
			}

			// Generate presigned URL
			const client = new AwsClient({
				accessKeyId: env.R2_ACCESS_KEY,
				secretAccessKey: env.R2_SECRET_KEY,
			});

			const r2Url = new URL(`https://${R2_BUCKET}.${R2_ACCOUNT_ID}.r2.cloudflarestorage.com/${filename}`);

			r2Url.searchParams.set('X-Amz-Expires', '300'); // URL berlaku 5 menit

			const signed = await client.sign(new Request(r2Url, { method: 'PUT' }), { aws: { signQuery: true } });

			return new Response(JSON.stringify({ url: signed.url }), { status: 200, headers: { 'Content-Type': 'application/json' } });
		} else if (url.pathname === '/get-token') {
			const userId = url.searchParams.get('userId');

			// Buat JWT 5 menit
			const token = await new jose.SignJWT({ userId })
				.setProtectedHeader({ alg: 'HS256', typ: 'JWT' })
				.setExpirationTime('5m')
				.sign(new TextEncoder().encode(env.API_SECRET));

			return new Response(JSON.stringify({ token }), {
				status: 200,
				headers: { 'Content-Type': 'application/json' },
			});
		}

		return new Response('Hello World!');
	},
} satisfies ExportedHandler<Env>;
