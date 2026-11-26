// GET /api/config
// Devuelve la configuración pública de Supabase. La anon key es pública por diseño:
// la seguridad de los datos la ponen las políticas RLS de la base de datos.
// aiEnabled indica si hay API key de Claude; si no, la app solo muestra el modo "A mano".

// Solo se sirve la clave si tiene forma de clave pública de Supabase
// (JWT "eyJ..." o "sb_publishable_..."). Así, si por error se pega otro secreto
// en SUPABASE_ANON_KEY, nunca se expone en esta URL pública.
const looksPublic = (k) => /^eyJ[\w-]+\.[\w-]+\.[\w-]+$/.test(k) || /^sb_publishable_[\w-]+$/.test(k);

export default async () => {
  const key = (process.env.SUPABASE_ANON_KEY || "").trim();
  return new Response(
    JSON.stringify({
      supabaseUrl: process.env.SUPABASE_URL || "",
      supabaseAnonKey: looksPublic(key) ? key : "",
      keyError: key && !looksPublic(key) ? "SUPABASE_ANON_KEY no parece una anon key de Supabase" : undefined,
      aiEnabled: Boolean(process.env.ANTHROPIC_API_KEY),
    }),
    { headers: { "Content-Type": "application/json", "Cache-Control": "no-store" } }
  );
};
