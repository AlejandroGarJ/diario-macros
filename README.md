# Diario de macros

App web para apuntar lo que comes y que la IA (Claude) calcule los macros. Login con Google, datos en Supabase, despliegue en Netlify.

```
public/index.html              ← la app (HTML + JS, sin build)
netlify/functions/analyze.mjs  ← llama a la API de Claude (la API key nunca llega al navegador)
netlify/functions/config.mjs   ← entrega al navegador la URL y la anon key de Supabase
supabase/schema.sql            ← tablas + seguridad por usuario (RLS)
netlify.toml                   ← /api/* → funciones
```

## Puesta en marcha (unos 20 minutos)

### 1. Supabase
1. Crea un proyecto en https://supabase.com (región: Europa).
2. **SQL Editor → New query**: pega `supabase/schema.sql` y ejecútalo.
3. **Project Settings → API**: apunta la **Project URL** y la **anon public key**.

### 2. Google (credenciales OAuth)
1. En https://console.cloud.google.com crea un proyecto.
2. **APIs y servicios → Pantalla de consentimiento OAuth**: tipo *Externo*, rellena el nombre de la app y tu correo.
3. **Credenciales → Crear credenciales → ID de cliente OAuth → Aplicación web**.
   - **URI de redirección autorizados**: `https://TU-PROYECTO.supabase.co/auth/v1/callback`
4. Copia el **Client ID** y el **Client secret**.
5. En Supabase: **Authentication → Sign In / Providers → Google**: actívalo y pega los dos valores.

### 3. API de Claude
En https://console.anthropic.com crea una API key y añade algo de crédito. Con `claude-haiku-5-5` cada cálculo cuesta muy poco.

### 4. Netlify
1. Sube esta carpeta a un repo de GitHub.
2. En Netlify: **Add new site → Import an existing project** → elige el repo. No hace falta comando de build. (Arrastrar la carpeta no sirve: así no se despliegan las funciones.)
3. **Site configuration → Environment variables**: añade `SUPABASE_URL`, `SUPABASE_ANON_KEY` y `ANTHROPIC_API_KEY` (y `ANTHROPIC_MODEL` si quieres otro modelo).
4. Redespliega (**Deploys → Trigger deploy**).

### 5. Conectar Supabase con tu dominio de Netlify
En Supabase: **Authentication → URL Configuration**:
- **Site URL**: `https://tu-app.netlify.app`
- **Redirect URLs**: añade `https://tu-app.netlify.app` y `http://localhost:8888`

Listo: abre tu URL de Netlify y entra con Google.

## Probar en local
```bash
npm i -g netlify-cli
cp .env.example .env   # y rellénalo
netlify dev            # abre http://localhost:8888
```

## Seguridad
- Cada usuario solo puede leer y escribir sus propias filas (políticas RLS en `schema.sql`). Ojo: si quitas RLS, cualquiera con la anon key podría leer los datos de todos.
- `/api/analyze` comprueba el token de Supabase antes de llamar a Claude, así que solo los usuarios con sesión pueden gastar tu crédito. Si abres la app a mucha gente, añade un límite diario por usuario.
- Las fotos se reducen a 1024 px en el navegador antes de enviarse y no se guardan.
