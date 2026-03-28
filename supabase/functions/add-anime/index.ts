import { serve } from "https://deno.land/std@0.224.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.42.0"

const corsHeaders = {
  'Access-Control-Allow-Origin' : '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // This handles the "handshake" the browser does before the real request
  if (req.method == 'OPTIONS') {
    return new Response('ok', {headers: corsHeaders })
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )
  // NEW: Check if the user wants to DELETE
  if (req.method === 'DELETE') {
  try {
    const { id } = await req.json()
    const { error } = await supabase.from('anime').delete().eq('id', id)
    
    if (error) throw error

    return new Response(JSON.stringify({ message: "Deleted!" }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" }, // <--- MUST HAVE THIS
      status: 200
    })
  } catch (err) {
  // This tells TypeScript: "Treat 'err' as a standard Error object"
  const errorMessage = err instanceof Error ? err.message : 'Unknown error';
  
  return new Response(JSON.stringify({ error: errorMessage }), {
    headers: { ...corsHeaders, "Content-Type": "application/json" },
    status: 400
  })
}
}

  try {
    // 1. Get the search term from your Test tab or Curl
    const { searchTerm } = await req.json()
    
    // 2. Fetch data from Kitsu API
    const kitsuRes = await fetch(`https://kitsu.io/api/edge/anime?filter[text]=${encodeURIComponent(searchTerm)}&page[limit]=1`)
    const kitsuData = await kitsuRes.json()
    
    if (!kitsuData.data || kitsuData.data.length === 0) {
      throw new Error(`Anime not found: ${searchTerm}`)
    }

    const anime = kitsuData.data[0]

    // 3. Connect to Supabase using your 'MY_' secrets
    const supabase = createClient(
      Deno.env.get('MY_PROJECT_URL') ?? '',
      Deno.env.get('MY_SECRET_KEY') ?? ''
    )

    // 4. Save to your 'anime' table (Matches your screenshot columns)
    const { data, error } = await supabase
      .from('anime')
      .upsert({ 
  title: anime.attributes.canonicalTitle || 'Unknown Title',
  status: 'Plan to Watch',
  kitsu_id: String(anime.id),
  cover_image_url: anime.attributes.posterImage?.large || '' 
})
      .select()

    if (error) throw error

    // 5. Send back a clean Success message
    return new Response(JSON.stringify({ message: "Success!", data }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200
    })

  } catch (err) {
    // If anything fails, this shows the REAL error in the Response window
    const msg = err instanceof Error ? err.message : String(err)
    return new Response(JSON.stringify({ error: msg }), { 
      status: 500,
      headers: { "Content-Type": "application/json" }
    })
  }
})