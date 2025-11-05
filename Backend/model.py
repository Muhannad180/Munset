from openai import OpenAI
import tiktoken

api_key="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"

client = OpenAI(api_key=api_key)
MODEL = "gpt-4.1-nano-2025-04-14"
TEMPERATURE = 0.3
MAX_TOKENS = 50
TOKEN_BUDGET = 1000
SYSTEM_PROMPT = "You are a professional psychologist using the CBT methods to interact with patients."
messages = [
          {"role": "system", "content": SYSTEM_PROMPT},
      ]

def get_encoding(model):
    try:
        return tiktoken.encoding_for_model(model)
    except KeyError:
        print(f"Warning: Tokenizer for model '{model}' not found. Falling back to 'cl100k_base'.")
        return tiktoken.get_encoding("cl100k_base")

def count_tokens(text):
    return len(ENCODING.encode(text))

def total_tokens_used(messages):
    try:
        return sum(count_tokens(msg["content"]) for msg in messages)
    except Exception as e:
        print(f"[token count error]: {e}")
        return 0

def enforce_token_budget(messages, budget=TOKEN_BUDGET):
    try:
        while total_tokens_used(messages) > budget:
            if len(messages) <= 2:
                break 
            messages.pop(1)
    except Exception as e:
        print(f"[token budget error]: {e}")

ENCODING = get_encoding(MODEL)

def chat(user_input):
  messages.append({"role": "user", "content": user_input})
  response = client.chat.completions.create(
      model=MODEL,
      messages=messages,
      temperature= TEMPERATURE,
      max_tokens= MAX_TOKENS,
  )

  reply = response.choices[0].message.content
  messages.append({"role": "assistant", "content": reply})

  enforce_token_budget(messages)

  return reply

while True:
  user_input = input("You: ")
  if user_input.strip().lower() in {"exit", "quit"}:
      break
  answer = chat(user_input)
  print("Assistant:", answer)