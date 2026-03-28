// 1. Stable imports
import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.7.1"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS, DELETE',
}

// 2. Typing 'req' as 'Request' fixes the implicit 'any' error
serve(async (req: Request) => {
  // Handle CORS Preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    // 3. DELETE logic
    if (req.method === 'DELETE') {
      const { id } = await req.json()
      const { error } = await supabase.from('anime').delete().eq('id', id)
      
      if (error) throw error
      
      return new Response(JSON.stringify({ message: "Deleted" }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    }

    // 4. POST logic
    if (req.method === 'POST') {
      const { searchTerm } = await req.json()
      const kitsuRes = await fetch(`https://kitsu.io/api/edge/anime?filter[text]=${encodeURIComponent(searchTerm)}`)
      const kitsuData = await kitsuRes.json()

      if (!kitsuData.data || kitsuData.data.length === 0) {
        throw new Error(`Anime not found: ${searchTerm}`)
      }

      const anime = kitsuData.data[0]
      const { data, error } = await supabase
        .from('anime')
        .insert([{
          title: anime.attributes.canonicalTitle,
          cover_image_url: anime.attributes.posterImage?.large,
          status: 'Plan to Watch'
        }])
        .select()

      if (error) throw error
      
      return new Response(JSON.stringify(data), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      })
    }

    return new Response(JSON.stringify({ error: "Method not allowed" }), { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 405 
    })

  } catch (err: unknown) {
    // 5. Explicitly typing the error avoids the 'unknown' squiggle
    const errorMessage = err instanceof Error ? err.message : 'Unknown error'
    
    return new Response(JSON.stringify({ error: errorMessage }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})