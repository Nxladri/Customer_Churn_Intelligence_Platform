import requests
import os
from dotenv import load_dotenv

load_dotenv()

api_key = os.getenv("OPENROUTER_API_KEY")
print("key:",api_key)

if not api_key:
    print("❌ API key not found")
    exit()

response = requests.post(
    url="https://openrouter.ai/api/v1/chat/completions",
   headers={
    "Authorization": f"Bearer {api_key}",
    "Content-Type": "application/json",
    "HTTP-Referer": "http://localhost",   # REQUIRED sometimes
    "X-Title": "customer-insights-app"    # optional but good
},
    json={
        "model": "meta-llama/llama-3-8b-instruct",
        "messages": [
            {"role": "user", "content": "Say hello in one line"}
        ]
    }
)

print(response.status_code)
print(response.json())
