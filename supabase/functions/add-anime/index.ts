import { serve } from "https://deno.land/std@0.224.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.42.0"

serve(async (req) => {
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
      headers: { "Content-Type": "application/json" },
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