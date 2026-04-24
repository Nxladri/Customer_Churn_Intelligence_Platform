
# An auto generated text using ollama API, which is a local LLM hosting solution. 
# It allows us to run large language models on our own machines without relying on external APIs, 
# ensuring data privacy and faster response times.
# --------------------------------------------------------------------------
# Experimental module: LLM-based retention message generator
# Not included in production pipeline due to performance and deployment constraints

def customer_insights_extraction(prompt):
    import requests

    try:
        response = requests.post(
            "http://localhost:11434/api/generate",
            json={
                "model": "phi",
                "prompt": prompt,
                "stream": False
            },
            timeout=180
        )

        data = response.json()
        return data.get("response", "No response")

    except Exception as e:
        return f"Error: {str(e)}"

def clean_output(text):
    start = text.find("Key Insight:")
    if start != -1:
        return text[start:]
    return text


# Write down the prompt here
def generate_prompt(segment, total, churned, churn_rate):
    return f"""
You are a senior Business Strategy Consultant.

DATA:
Segment: {segment}
Total Customers: {total}
Churned: {churned}
Churn Rate: {churn_rate}%


INSTRUCTIONS:
- No introduction
- No definitions
- No generic statements
- Use the exact churn rate value
- Make response specific to this segment
- Do NOT repeat template phrases
- Follow format strictly

FORMAT:

Key Insight:
(mention exact churn rate and what it means)



Action Plan:
1. (specific action)
2. (specific action)
3. (specific action)

"""


