/**
 * AI model client using OpenAI-compatible API.
 * Works with GitHub Models (default) or Azure OpenAI.
 *
 * GitHub Models: set GITHUB_TOKEN
 * Azure OpenAI: set AZURE_OPENAI_ENDPOINT + AZURE_OPENAI_KEY (or use managed identity)
 */

import OpenAI from "openai";

export interface GeneratorResult {
  content: string;
  parsed?: Record<string, unknown>;
}

let client: OpenAI | null = null;

function getClient(): OpenAI {
  if (client) return client;

  const githubToken = process.env.GITHUB_TOKEN;
  const azureEndpoint = process.env.AZURE_OPENAI_ENDPOINT;

  if (githubToken) {
    // GitHub Models API
    client = new OpenAI({
      baseURL: "https://models.inference.ai.azure.com",
      apiKey: githubToken,
    });
  } else if (azureEndpoint) {
    client = new OpenAI({
      baseURL: `${azureEndpoint}/openai/deployments/${process.env.AZURE_OPENAI_DEPLOYMENT || "gpt-4o"}`,
      apiKey: process.env.AZURE_OPENAI_KEY || "",
      defaultQuery: { "api-version": "2024-10-21" },
    });
  } else {
    throw new Error("Set GITHUB_TOKEN (for GitHub Models) or AZURE_OPENAI_ENDPOINT (for Azure OpenAI)");
  }

  return client;
}

export async function callModel(
  systemPrompt: string,
  userMessage: string,
): Promise<string> {
  const ai = getClient();
  const model = process.env.AI_MODEL || "gpt-4o";

  const response = await ai.chat.completions.create({
    model,
    messages: [
      { role: "system", content: systemPrompt },
      { role: "user", content: userMessage },
    ],
    temperature: 0.3,
    max_tokens: 16000,
  });

  const content = response.choices[0]?.message?.content;
  if (!content) throw new Error("Empty response from model");
  return content;
}

/**
 * Call the model expecting a JSON response.
 * Extracts JSON from markdown code fences if present.
 */
export async function callModelJson<T>(
  systemPrompt: string,
  userMessage: string,
): Promise<T> {
  const raw = await callModel(systemPrompt, userMessage);

  // Strip markdown code fences if present
  const jsonMatch = raw.match(/```(?:json)?\s*([\s\S]*?)```/);
  const jsonStr = jsonMatch ? jsonMatch[1].trim() : raw.trim();

  return JSON.parse(jsonStr) as T;
}
