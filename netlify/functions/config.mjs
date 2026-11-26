// GET /api/config
// Devuelve la configuración pública de Supabase. La anon key es pública por diseño:
// la seguridad de los datos la ponen las políticas RLS de la base de datos.
export default async () =>
  new Response(
    JSON.stringify({
      supabaseUrl: process.env.SUPABASE_URL || "",
      supabaseAnonKey: process.env.SUPABASE_ANON_KEY || "",
    }),
    { headers: { "Content-Type": "application/json", "Cache-Control": "public, max-age=300" } }
  );
