import { googleAI } from "@genkit-ai/google-genai";
import { genkit, z } from "genkit";
import dotenv from "dotenv";

dotenv.config();

// Validate API key
if (!process.env.GOOGLE_GENAI_API_KEY && !process.env.GEMINI_API_KEY) {
  console.error(
    "Error: GOOGLE_GENAI_API_KEY or GEMINI_API_KEY environment variable is not set",
  );
  process.exit(1);
}

try {
  const ai = genkit({
    plugins: [googleAI()],
    model: "googleai/gemini-2.5-flash-lite", // String reference instead of object
  });

  const RecipeInputSchema = z.object({
    ingredient: z.string(),
    dietaryRestrictions: z.string().optional(),
  });

  const RecipeSchema = z.object({
    title: z.string(),
    description: z.string(),
    prepTime: z.string(),
    cookTime: z.string(),
    servings: z.number(),
    ingredients: z.array(z.string()),
    instructions: z.array(z.string()),
    tips: z.array(z.string()).optional(),
  });

  const recipeGeneratorFlow = ai.defineFlow(
    {
      name: "recipeGeneratorFlow",
      inputSchema: RecipeInputSchema,
      outputSchema: RecipeSchema,
    },
    async (input) => {
      const prompt = `Create a detailed recipe with:
        Main ingredient: ${input.ingredient}
        Dietary restrictions: ${input.dietaryRestrictions || "none"}
        
        Return a complete recipe with all fields.`;

      const result = await ai.generate({
        prompt,
        output: { schema: RecipeSchema },
      });

      if (!result.output) {
        throw new Error("No output generated");
      }

      return result.output;
    },
  );

  async function main() {
    const recipe = await recipeGeneratorFlow({
      ingredient: "avocado",
      dietaryRestrictions: "vegetarian",
    });
    console.log(JSON.stringify(recipe, null, 2));
  }

  if (require.main === module) {
    main().catch(console.error);
  }
} catch (error) {
  console.error("Failed to initialize Genkit:", error);
  process.exit(1);
}
