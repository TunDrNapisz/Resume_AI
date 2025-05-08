import firebase_admin
from firebase_admin import credentials, firestore
from ollama import Client

# Initialize Firebase Admin SDK
cred = credentials.Certificate("C:/Users/win11/Desktop/Flutter/ai_resume_screening/ai-resume-screening-syst-e7924-firebase-adminsdk-fbsvc-4769791f2e.json")


firebase_admin.initialize_app(cred)

# Initialize the Ollama client
client = Client()

# Firestore client
db = firestore.client()


# Function to create a job in Firestore
def create_job(data):
    job_ref = db.collection('jobs').add(data)
    print(f"Job created with ID: {job_ref.id}")


# Function to detect intent from the Ollama response
def detect_intent(message):
    response = client.chat(
        model="llama3",  # Ensure you have the correct model
        messages=[{"role": "user", "content": message}],
    )

    content = response['message']['content']
    print(f"Response from Ollama: {content}")

    # Dummy logic to detect intent (Create, Update, Delete)
    if "create" in content.lower():
        return 'Create'
    elif "update" in content.lower():
        return 'Update'
    elif "delete" in content.lower():
        return 'Delete'
    else:
        return 'View'


# Example usage
if __name__ == '__main__':
    # Simulate user message
    user_message = "Boleh bagi saya contoh resume untuk kerja IT?"

    # Detect intent from Ollama's response
    intent = detect_intent(user_message)

    if intent == 'Create':
        data = {"job_name": "IT Developer", "location": "Malaysia", "skills": ["Flutter", "Dart"]}
        create_job(data)
    elif intent == 'Update':
        print("Update job logic")
    elif intent == 'Delete':
        print("Delete job logic")
    else:
        print("View job logic")
