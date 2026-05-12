import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const DAILY_LIMIT = 10;
const GEMINI_API_URL =
  "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

interface RequestBody {
  task_title: string;
  user_id: string;
}

interface GeminiCandidate {
  content: { parts: Array<{ text: string }> };
}

interface GeminiResponse {
  candidates: GeminiCandidate[];
}

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function jsonResponse(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return jsonResponse({ error: "unauthorized" }, 401);
  }

  const supabaseClient = createClient(
    Deno.env.get("SUPABASE_URL") ?? "",
    Deno.env.get("SUPABASE_ANON_KEY") ?? "",
    { global: { headers: { Authorization: authHeader } } },
  );

  // Verify JWT and extract authenticated user
  const { data: { user }, error: authError } = await supabaseClient.auth
    .getUser();
  if (authError || !user) {
    return jsonResponse({ error: "unauthorized" }, 401);
  }

  let body: RequestBody;
  try {
    body = await req.json() as RequestBody;
  } catch {
    return jsonResponse({ error: "invalid_request_body" }, 400);
  }

  const { task_title, user_id } = body;
  if (!task_title || typeof task_title !== "string" || !user_id) {
    return jsonResponse({ error: "missing_required_fields" }, 400);
  }

  // Prevent user_id spoofing
  if (user_id !== user.id) {
    return jsonResponse({ error: "forbidden" }, 403);
  }

  // Rate limit: count today's AI decompositions (UTC midnight)
  const todayMidnight = new Date();
  todayMidnight.setUTCHours(0, 0, 0, 0);

  const { count, error: countError } = await supabaseClient
    .from("tasks")
    .select("id", { count: "exact", head: true })
    .eq("user_id", user.id)
    .not("decomposed_steps", "is", null)
    .gte("created_at", todayMidnight.toISOString());

  if (countError) {
    console.error("Rate limit query error:", countError.message);
    return jsonResponse({ error: "internal_error" }, 500);
  }

  const usedToday = count ?? 0;
  if (usedToday >= DAILY_LIMIT) {
    return jsonResponse(
      { error: "daily_limit_reached", steps_used: DAILY_LIMIT },
      429,
    );
  }

  const geminiApiKey = Deno.env.get("GEMINI_API_KEY");
  if (!geminiApiKey) {
    console.error("GEMINI_API_KEY not configured");
    return jsonResponse({ error: "service_unavailable" }, 503);
  }

  const prompt =
    `Break this task into exactly 3 short, actionable steps. Return only the 3 steps, one per line, without numbering or bullet points:\n${task_title}`;

  let geminiRes: Response;
  try {
    geminiRes = await fetch(`${GEMINI_API_URL}?key=${geminiApiKey}`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{ parts: [{ text: prompt }] }],
        generationConfig: { temperature: 0.3, maxOutputTokens: 500 },
      }),
    });
  } catch {
    return jsonResponse({ error: "ai_service_unavailable" }, 503);
  }

  if (!geminiRes.ok) {
    console.error("Gemini API returned:", geminiRes.status);
    return jsonResponse({ error: "ai_service_error" }, 502);
  }

  const geminiData = await geminiRes.json() as GeminiResponse;
  const rawText =
    geminiData.candidates?.[0]?.content?.parts?.[0]?.text ?? "";

  const steps = rawText
    .split("\n")
    .map((line: string) => line.trim())
    .filter((line: string) => line.length > 0)
    .slice(0, 3);

  if (steps.length < 3) {
    console.error("Gemini returned fewer than 3 steps");
    return jsonResponse({ error: "ai_parse_error" }, 502);
  }

  return jsonResponse(
    { steps, remaining_today: DAILY_LIMIT - usedToday - 1 },
    200,
  );
});
