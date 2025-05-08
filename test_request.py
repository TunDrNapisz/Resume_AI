import requests
import json

# Define the API endpoint
url = 'http://127.0.0.1:5005/api/chat'  # Ensure this matches the Flask API route

# Example data to simulate creating a job
user_message = {
    "message": "Create job",
    "job_name": "Software Engineer",
    "location": "New York",
    "description": "Developing software solutions."
}

# Send POST request to Flask API
response = requests.post(url, json=user_message)

# Print the response from the Flask API
if response.status_code == 200:
    data = response.json()
    print("Response from API: ", data)
else:
    print(f"Failed to get a response, status code: {response.status_code}")
