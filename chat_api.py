from flask import Flask, request, jsonify
from flask_cors import CORS
import re
import requests
import firebase_admin
from firebase_admin import credentials, firestore
import uuid

app = Flask(__name__)
CORS(app)

# Initialize Firebase
cred = credentials.Certificate(
    "C:/Users/win11/resume_screening_system-1/ai-resume-screening-syst-e7924-firebase-adminsdk-fbsvc-4769791f2e.json"
)
firebase_admin.initialize_app(cred)
db = firestore.client()

# Google Custom Search API
GOOGLE_API_KEY = "AIzaSyCch1Z86by4Px4pHO-FSyINZ6W7yQmz9D4"
GOOGLE_CX = "076127451f10646ba"

session_memory = {}

def detect_intent(message):
    msg = message.lower()
    if any(x in msg for x in ["add job", "create job", "new job", "post job"]) or re.search(r"(job for a|create job for a|post job as a) [\w\s]+", msg):
        return "add_job"
    elif "update" in msg and "job" in msg:
        if re.search(r"(job_\w+)", msg):
            return "update"
        return "unknown"
    elif "delete" in msg or "remove job" in msg:
        return "delete"
    elif re.search(r"(show|list|view|display|get)\s+(job_\w+)", msg):
        return "view_single"
    elif any(kw in msg for kw in ["view jobs", "show jobs", "list jobs", "available jobs"]):
        return "view"
    elif msg in ["hi", "hello", "hey"]:
        return "greeting"
    else:
        return "general"


def clean_answer(text):
    text = re.sub(r'\*\*(.*?)\*\*', r'\1', text)
    text = re.sub(r'\*(.*?)\*', r'\1', text)
    text = re.sub(r'\[(.*?)\]\(.*?\)', r'\1', text)
    text = text.replace("...", "").strip()
    return text


def search_web(query):
    try:
        url = f"https://www.googleapis.com/customsearch/v1?q={query}&key={GOOGLE_API_KEY}&cx={GOOGLE_CX}"
        res = requests.get(url)
        res.raise_for_status()
        results = res.json().get("items", [])

        if results:
            top_results = results[:3]
            response = "🔎 **Search Results:**\n\n"
            for i, item in enumerate(top_results, 1):
                title = item.get("title", "No Title")
                snippet = item.get("snippet", "").strip().rstrip("…")
                link = item.get("link", "")  # <--- penting
                response += f"**{i}. {title}**\n📝 {snippet}\n🔗 {link}\n\n"  # <--- tambah link
            return response.strip()
        return "❌ Sorry, no relevant results were found."
    except Exception as e:
        print("Search Error:", e)
        return "⚠️ An error occurred while searching. Please try again later."



icons = {
    "job_title": "💼",
    "location": "📍",
    "skillsPreference": "🛠️",
    "job_type": "📄",
    "majorRequirement": "📘",
    "languagesPreference": "🗣️",
    "job_description": "📝",
    "Description": "🧾",
    "active": "📡"
}

def clean_field_value(field_value):
    # Senarai kata yang ingin dibuang
    unwanted_words = ["is", "are", "in", "the", "a", "to"]

    # Gantikan kata yang tidak diingini dengan kosong
    cleaned_value = " ".join([word for word in field_value.split() if word.lower() not in unwanted_words])
    return cleaned_value.strip()


def extract_job_fields(text):
    patterns = {
        "job_title": r"(?:job (?:title|role)?(?: is|:)?|for (?:a[n]? )?|a new job:|a position called|job title:|a job for|job for a[n]?)\s*([A-Za-z0-9\- &/]+?)(?= in|,| with| who|$)",
        "location": r"(?:located in|location is|location:|based in|in|required in)\s*([A-Za-z0-9\- ]+)",
        "skillsPreference": r"(?:skills required are|skills include|skills:|requires skills in|required skills:|expertise in|requiring skills)\s*([A-Za-z0-9 ,&/]+)",
        "job_type": r"(?:job type is|position is|it's a|job is|type:)\s*(full-time|part-time|internship|contract|freelance|permanent)\b",
        "majorRequirement": r"(?:must major in|major requirement is|major:|major in)\s*([A-Za-z0-9 &/]+)",
        "languagesPreference": r"(?:languages required are|languages include|languages are|language is|languages?:?)\s*([A-Za-z0-9 ,&/]+)",
        "job_description": r"(?:job description is|description is|job description:|description:|job description include|the job is)\s*(.+?)(?:[.;]|$)",
        "Description": r"(?:additional details are|details are|note:|remark:|additional info:|additional details:|additional info)\s*(.+?)(?:[.;]|$)",
        "active": r"(?:status is|status:|job is)\s*(active|inactive|open|closed|ongoing)"
    }

    job_fields = {}
    for field, pattern in patterns.items():
        match = re.search(pattern, text, re.IGNORECASE)
        if match:
            value = match.group(1).strip()
            if field in ["skillsPreference", "languagesPreference"]:
                value = [v.strip() for v in re.split(r"[,&]| and ", value)]
            job_fields[field] = value

    return job_fields




@app.route("/api/chat", methods=["POST"])
def chat():
    data = request.get_json()
    if not data or "messages" not in data:
        return jsonify({"error": "Invalid request"}), 400

    session_id = data.get("session_id", "default")
    user_message = data["messages"][-1]["content"]

    # ✅ Tambah di sini
    if user_message.strip().lower() == "back":
        # Sama seperti intent == "view"
        jobs_ref = db.collection("Job").stream()
        jobs = [doc.to_dict() for doc in jobs_ref]

        if jobs:
            response_message = "📋 **Here are the available jobs:**\n\n"
            for job in jobs:
                job_id = job.get("job_id", "N/A")
                job_title = job.get("job_title", "No Title")
                location = job.get("location", "N/A")
                job_type = job.get("job_type", "N/A")
                status = "🟢 Active" if job.get("isActive") else "🔴 Inactive"

                response_message += f"""
    "-------------------------------------------------"
    🔹 **Job ID**: `{job_id}`
       📌 **Title**: {job_title}
       🌍 **Location**: {location}
       💼 **Type**: {job_type}
       ⚡ **Status**: {status}
    "-------------------------------------------------"\n
    """
            response_message += "💬 *Type a Job ID (e.g., `view job_0005`) to view more details.*"
        else:
            response_message = "❗ No jobs found."

        return jsonify({"message": response_message, "intent": "view", "job_data": {}})

    if session_id not in session_memory:
        session_memory[session_id] = {}

    memory = session_memory[session_id]

    if user_message.strip().lower() == "cancel":
        if memory.get("pending_delete"):
            memory.pop("pending_delete", None)
            response_message = "❎ Delete operation cancelled."
            return jsonify({"message": response_message, "intent": "cancel", "job_data": {}})


    if re.search(r"\b(hi|hello|hai|hey|good morning|good evening)\b", user_message.lower()):
        response_message = "Hello! How can I assist you with your job requests?"
        session_memory[session_id] = {}
        return jsonify({"message": response_message, "intent": "greeting", "job_data": {}})

    if any(keyword in user_message.lower() for keyword in
           ["job for", "job title", "required skills", "description", "status is", "status:", "location", "languages"]):
        job_details = extract_job_fields(user_message)
        if job_details:
            intent = "add_job"
            memory["intent"] = intent
            job_id = f"custom_{str(uuid.uuid4())[:8]}"
            job_details["job_id"] = job_id
            memory["job_id"] = job_id
            memory["job_details"] = job_details
            memory["awaiting_confirmation"] = True
            memory["confirmation_state"] = "pending"

            response_message = f"""
✅ **Job Preview**
-------------------
🆔 **Job ID**: `{job_details.get('job_id', 'N/A')}`
📑 **Job Title**: {job_details.get('job_title', 'N/A')}
📍 **Location**: {job_details.get('location', 'N/A')}
💼 **Job Type**: {job_details.get('job_type', 'N/A')}
🎓 **Major Requirement**: {job_details.get('majorRequirement', 'N/A')}
📝 **Job Description**: {job_details.get('job_description', 'N/A')}
🧾 **Additional Details**: {job_details.get('Description', 'N/A')}
🌍 **Languages Required**: {", ".join(job_details.get('languagesPreference', ['N/A']))}
🛠️ **Skills Required**: {", ".join(job_details.get('skillsPreference', ['N/A']))}
⚡ **Status**: {job_details.get('active', 'N/A')}
--------------------------
💬 Do you want to save this job? Reply with 'yes' to confirm or 'no' to cancel.
"""
            return jsonify({"message": response_message, "intent": intent, "job_data": memory})

    intent = memory.get("intent", detect_intent(user_message))

    if intent == "general" and memory.get("intent") != "add_job":
        response_message = search_web(user_message)
        return jsonify({"message": response_message, "intent": "general", "job_data": memory})

    if intent == "add_job" or memory.get("intent") == "add_job":
        memory.setdefault("intent", "add_job")

        if user_message.strip().lower() == "no":
            if memory.get("confirmation_state") == "confirmed":
                response_message = "❌ Job was already created successfully and cannot be cancelled now."
            else:
                response_message = "❌ Job creation cancelled. No further actions will be taken."
                session_memory[session_id] = {}
            return jsonify({"message": response_message, "intent": "add_job", "job_data": {}})

        if user_message.strip().lower() == "yes" and memory.get("awaiting_confirmation"):
            if memory.get("confirmation_state") == "cancelled":
                return jsonify({"message": "❌ Job creation was already cancelled. Please start a new job creation if needed.", "intent": "add_job", "job_data": {}})

            job_data = memory.get("job_details", {})
            mapped_data = {
                "job_id": memory["job_id"],
                "job_name": job_data.get("job_title", "No Title"),
                "job_title": job_data.get("job_title", "No Title"),
                "location": job_data.get("location", "Unknown"),
                "job_type": job_data.get("job_type", "N/A"),
                "majorRequirement": job_data.get("majorRequirement", "N/A"),
                "languages": job_data.get("languagesPreference", []),
                "skills_used": job_data.get("skillsPreference", []),
                "job_description": job_data.get("job_description", "N/A"),
                "Description": job_data.get("Description", "N/A"),
                "isActive": job_data.get("active", "").lower() == "active",
                "created_at": firestore.SERVER_TIMESTAMP
            }
            try:
                db.collection("Job").document(memory["job_id"]).set(mapped_data)
                memory["confirmation_state"] = "confirmed"
                response_message = f"✅ Job `{memory['job_id']}` has been successfully created and saved."
            except Exception as e:
                response_message = f"❌ Error while saving job: {str(e)}"

            session_memory[session_id] = {}
            safe_mapped_data = mapped_data.copy()
            safe_mapped_data.pop("created_at", None)
            return jsonify({"message": response_message, "intent": "add_job", "job_data": safe_mapped_data})

        elif memory.get("awaiting_confirmation"):
            return jsonify({"message": "Please type 'yes' to confirm or 'no' to cancel.", "intent": "add_job", "job_data": memory})

        fields = [
            "job_title", "location", "skillsPreference", "job_type",
            "majorRequirement", "languagesPreference", "job_description", "Description", "active"
        ]
        current_step = memory.get("current_step", 0)

        if current_step == 0:
            response_message = "Please provide the **Job Title** for the new job."
            memory["current_step"] = 1
        elif current_step == 1:
            memory["job_title"] = user_message
            response_message = "Please provide the **Location** for the new job."
            memory["current_step"] = 2
        elif current_step == 2:
            memory["location"] = user_message
            response_message = "Please provide the **Skills Preference** for the new job."
            memory["current_step"] = 3
        elif current_step == 3:
            memory["skillsPreference"] = user_message.split(",")
            response_message = "Please provide the **Job Type** for the new job."
            memory["current_step"] = 4
        elif current_step == 4:
            memory["job_type"] = user_message
            response_message = "Please provide the **Major Requirement** (e.g., Degree) for the new job."
            memory["current_step"] = 5
        elif current_step == 5:
            memory["majorRequirement"] = user_message
            response_message = "Please provide the **Languages Preference** for the new job."
            memory["current_step"] = 6
        elif current_step == 6:
            memory["languagesPreference"] = user_message
            response_message = "Please provide the **Job Description** for the new job."
            memory["current_step"] = 7
        elif current_step == 7:
            memory["job_description"] = user_message
            response_message = "Please provide any **Additional Details** (e.g., benefits, work culture) for the job."
            memory["current_step"] = 8
        elif current_step == 8:
            memory["Description"] = user_message
            response_message = "Please provide the **Status** for the job (active/inactive)."
            memory["current_step"] = 9
        elif current_step == 9:
            memory["active"] = user_message
            job_id = f"custom_{str(uuid.uuid4())[:8]}"
            job_details = {
                "job_id": job_id,
                "job_title": memory.get("job_title"),
                "location": memory.get("location"),
                "job_type": memory.get("job_type"),
                "majorRequirement": memory.get("majorRequirement"),
                "skillsPreference": memory.get("skillsPreference"),
                "languagesPreference": memory.get("languagesPreference"),
                "job_description": memory.get("job_description"),
                "Description": memory.get("Description"),
                "active": memory.get("active"),
            }
            memory["job_id"] = job_id
            memory["job_details"] = job_details
            memory["awaiting_confirmation"] = True
            memory["confirmation_state"] = "pending"
            memory["current_step"] = 10
            response_message = f"""
            
✅ **Job Preview**
Here are the details you've provided:

🆔 Job ID: `{job_id}`
💼 Job Title: {job_details.get('job_title', 'N/A')}
📍 Location: {job_details.get('location', 'N/A')}
📄 Job Type: {job_details.get('job_type', 'N/A')}
📘 Major Requirement: {job_details.get('majorRequirement', 'N/A')}
📝 Job Description: {job_details.get('job_description', 'N/A')}
🧾 Additional Details: {job_details.get('Description', 'N/A')}
🗣️ Languages Required: {job_details.get('languagesPreference', 'N/A')}
🛠️ Skills Required: {", ".join(job_details.get('skillsPreference', []))}
📡 Status: {job_details.get('active', 'N/A')}

💬 Do you want to save this job? Reply with 'yes' to confirm or 'no' to cancel.
"""

        session_memory[session_id] = memory
        return jsonify({"message": response_message, "intent": "add_job", "job_data": memory})


    # Fungsi untuk update job

    # 🛠️ Modern Update Job Flow

    elif intent == "update" and not memory.get("job_id"):

        match = re.search(r"(job_\d+)", user_message)

        if match:

            job_id = match.group(0)

            doc = db.collection("Job").document(job_id).get()

            if doc.exists:

                memory.update({"intent": "update", "job_id": job_id})

                job_info = doc.to_dict()

                response_message = f"""

    🔧 **Update Job Details**

    🆔 **Job ID**: `{job_id}`

    ━━━━━━━━━━━━━━━━━━━━━━━━━━

    📌 **Title**: `{job_info.get('job_title', 'N/A')}`

    📍 **Location**: `{job_info.get('location', 'N/A')}`

    🕒 **Type**: `{job_info.get('job_type', 'N/A')}`

    📝 **Description**: `{job_info.get('job_description', 'N/A')}`

    💡 **Skills**: `{', '.join(job_info.get('skillsPreference', [])) if isinstance(job_info.get('skillsPreference'), list) else job_info.get('skillsPreference', 'N/A')}`

    🗣️ **Languages**: `{', '.join(job_info.get('languagesPreference', [])) if isinstance(job_info.get('languagesPreference'), list) else job_info.get('languagesPreference', 'N/A')}`

    🎓 **Job Name**: `{job_info.get('job_name', 'N/A')}`

    ⚡ **Status**: `{'🟢 Active' if job_info.get('active') == True else '🔴 Inactive'}`

    ━━━━━━━━━━━━━━━━━━━━━━━━━━


    🔄 **Which field would you like to update?**

    Please type a number or name of the field:


    1️⃣  Job Title

    2️⃣  Location

    3️⃣  Job Type

    4️⃣  Description

    5️⃣  Skills

    6️⃣  Status

    7️⃣  Languages

    8️⃣  Job Name


    ✅ Type `done` when you're finished or `cancel` to exit.

    """

            else:

                response_message = f"❌ Job ID `{job_id}` not found."

        else:

            response_message = "❓ Please provide a valid Job ID (e.g., `job_0005`)."


    elif memory.get("intent") == "update" and user_message.strip().lower() == "done":

        job_id = memory.get("job_id")

        session_memory[session_id] = {}

        response_message = f"🎉 Successfully updated Job ID `{job_id}`. Anything else I can help with?"


    elif memory.get("intent") == "update" and user_message.strip().lower() == "cancel":

        session_memory[session_id] = {}

        response_message = "🚫 Update cancelled. Let me know if you need anything else."


    elif memory.get("intent") == "update" and "field" not in memory:

        user_field = user_message.strip().lower().replace(" ", "")

        number_mapping = {

            "1": "job_title",

            "2": "location",

            "3": "job_type",

            "4": "job_description",

            "5": "skillsPreference",

            "6": "active",

            "7": "languagesPreference",

            "8": "job_name"

        }

        field_mapping = {

            "jobtitle": "job_title",

            "location": "location",

            "jobtype": "job_type",

            "description": "job_description",

            "skills": "skillsPreference",

            "status": "active",

            "languages": "languagesPreference",

            "jobname": "job_name"

        }

        if user_field in number_mapping:

            field = number_mapping[user_field]

            memory["field"] = field

            response_message = f"✏️ Please enter the new value for `{field.replace('_', ' ').title()}`."

        else:

            matched = next((key for key in field_mapping if user_field in key), None)

            if matched:

                memory["field"] = field_mapping[matched]

                response_message = f"✏️ Please enter the new value for `{matched.replace('_', ' ').title()}`."

            else:

                response_message = "⚠️ I couldn't recognize that field. Please try again or type `cancel`."


    elif memory.get("intent") == "update" and "field" in memory:

        field = memory["field"]

        new_value = user_message.strip()

        if field in ["job_title", "location", "job_name"]:

            if len(new_value) < 3 or new_value.isdigit():
                response_message = f"⚠️ `{field.replace('_', ' ').title()}` must be at least 3 characters and not just digits. Please re-enter."

                return jsonify({"response": response_message})


        elif field == "job_type":

            valid_types = ["Full-Time", "Part-Time", "Internship", "Contract"]

            if new_value not in valid_types:
                response_message = f"⚠️ Invalid job type. Choose from: {', '.join(valid_types)}"

                return jsonify({"response": response_message})


        elif field == "job_description":

            if len(new_value) < 10:
                response_message = "⚠️ Description must be at least 10 characters. Please re-enter."

                return jsonify({"response": response_message})


        elif field in ["skillsPreference", "languagesPreference"]:

            new_value = [v.strip() for v in new_value.split(",") if v.strip()]

            if not new_value:
                response_message = f"⚠️ Please enter at least one {field.replace('Preference', '').lower()}."

                return jsonify({"response": response_message})


        elif field == "active":

            status_map = {

                "true": True, "1": True, "yes": True, "active": True,

                "false": False, "0": False, "no": False, "inactive": False

            }

            if new_value.lower() in status_map:

                new_value = status_map[new_value.lower()]

            else:

                response_message = "⚠️ Please enter a valid status: `active` or `inactive`."

                return jsonify({"response": response_message})

        db.collection("Job").document(memory["job_id"]).update({field: new_value})

        response_message = f"✅ `{field.replace('_', ' ').title()}` updated to **{new_value}**.\nYou can type another field to update or `done` to finish."

        memory.pop("field", None)

    # Handle "cancel" command before intent checks
    if user_message.strip().lower() == "cancel":

        if memory.get("pending_delete"):
            memory.pop("pending_delete", None)
            response_message = "❎ Delete operation cancelled."
            return jsonify({"message": response_message, "intent": "cancel", "job_data": {}})

    # Handle confirm delete command
    elif user_message.strip().lower().startswith("confirm delete"):
        job_id = memory.get("pending_delete")
        if job_id:
            db.collection("Job").document(job_id).delete()
            memory.pop("pending_delete", None)
            response_message = f"🗑️ Job ID `{job_id}` has been successfully deleted."

        else:
            response_message = "⚠️ No job is pending deletion. Please specify a Job ID to delete first."


    # Handle delete intent (initial prompt)

    elif intent == "delete":
        match = re.search(r"(job_\d+)", user_message)
        if match:
            job_id = match.group(0)
            doc = db.collection("Job").document(job_id).get()
            if doc.exists:
                job = doc.to_dict()
                response_message = f"""

    ⚠️ **Confirmation Needed**
    Are you sure you want to delete the following job?

    🔹 **Job ID**: `{job_id}`
    📌 **Title**: {job.get('job_title', 'N/A')}
    📍 **Location**: {job.get('location', 'N/A')}

    💬 Reply with **`confirm delete {job_id}`** to proceed, or type **`cancel`** to abort.

    """
                memory["pending_delete"] = job_id  # Save state for confirmation
            else:
                response_message = f"❌ Job ID `{job_id}` not found."
        else:
            response_message = "❓ Please provide a valid Job ID to delete (e.g., `job_0005`)."



    elif intent == "view":
        jobs_ref = db.collection("Job").stream()
        jobs = [doc.to_dict() for doc in jobs_ref]
        if jobs:
            response_message = "📋 **Available Job Listings**\n\n"
            for job in jobs:
                job_id = job.get('job_id', 'N/A')
                title = job.get('job_title', 'No Title')
                location = job.get('location', 'N/A')
                job_type = job.get('job_type', 'N/A')
                status = "🟢 Active" if job.get('active', '').lower() == "active" else "🔴 Inactive"
                response_message += (

                    f"🆔 `{job_id}`\n"
                    f"   📌 **Title**: {title}\n"
                    f"   🌍 **Location**: {location}\n"
                    f"   💼 **Type**: {job_type}\n"
                    f"   ⚡ **Status**: {status}\n"
                    "------------------------------------\n"

                )
            response_message += "\n💬 To view details, type: `view job_id`"
        else:
            response_message = "❌ No job listings found at the moment."




    elif intent == "view_single":
        match = re.search(r"(custom_[a-zA-Z0-9]+|job_\d+)", user_message)
        if not match:
            response_message = "❓ Please provide a valid Job ID (e.g., `custom_ab12cd34` or `job_0007`)."
        else:
            job_id = match.group(0)
            doc = db.collection("Job").document(job_id).get()
            if doc.exists:
                job = doc.to_dict()
                # Job details for the user
                response_message = f"""

    🔍 **Job Details for `{job_id}`**
    ------------------------------------
    📌 **Title**: {job.get('job_title', 'N/A')}
    🌍 **Location**: {job.get('location', 'N/A')}
    💼 **Job Type**: {job.get('job_type', 'N/A')}
    🎓 **Major Requirement**: {job.get('majorRequirement', 'N/A')}
    🗣️ **Languages Required**: {", ".join(job.get('languages', [])) if isinstance(job.get('languages'), list) else job.get('languages', 'N/A')}
    🛠️ **Skills Required**: {", ".join(job.get('skills_used', [])) if isinstance(job.get('skills_used'), list) else job.get('skills_used', 'N/A')}
    📝 **Job Description**: {job.get('job_description', 'N/A')}
    🧾 **Additional Details**: {job.get('Description', 'N/A')}
    ⚡ **Status**: {"🟢 Active" if job.get("isActive") else "🔴 Inactive"}
    ------------------------------------
    💬 If you would like to search for another job, type 'back' to return to the job list.

    """
            else:

                response_message = f"❌ Job ID `{job_id}` not found. Please check the ID and try again."
                session_memory[session_id] = memory  # Update session memory with response data
                return jsonify({"message": response_message, "intent": "view_single", "job_data": memory})


    elif intent == "general":
        response_message = search_web(user_message)

    return jsonify({"message": response_message, "intent": intent, "job_data": memory})

if __name__ == "__main__":
    app.run(debug=True, port=5005)
