import os
import json
import firebase_admin
from firebase_admin import credentials, firestore
import google.generativeai as genai
from datetime import datetime

# Retrieve the API key and other sensitive information from environment variables
gemini_api_key = os.environ.get('GEMINI_API_KEY')
firebase_adminsdk_json = os.environ.get('FIREBASE_ADMINSDK_JSON')

# Ensure the environment variables are set
if not gemini_api_key:
    raise ValueError("Environment variable GEMINI_API_KEY is not set")
if not firebase_adminsdk_json:
    raise ValueError("Environment variable FIREBASE_ADMINSDK_JSON is not set")

# Initialize Firebase
cred = credentials.Certificate(json.loads(firebase_adminsdk_json))
firebase_admin.initialize_app(cred)
db = firestore.client()

# Configure Google Generative AI SDK
genai.configure(api_key=gemini_api_key)

# Create the model
generation_config = {
    "temperature": 1,
    "top_p": 0.95,
    "top_k": 64,
    "max_output_tokens": 8192,
    "response_mime_type": "text/plain",
}

model = genai.GenerativeModel(
    model_name="gemini-1.5-pro",
    generation_config=generation_config,
)

def ask_gemini(question):
    chat_session = model.start_chat(
        history=[]
    )
    response = chat_session.send_message(question)
    return response.text

# Function to load data from Firestore
def load_firebase(collection, document_id=None):
    ref = db.collection(collection)
    if document_id:
        doc = ref.document(document_id).get()
        return doc.to_dict() if doc.exists else None
    else:
        return [doc.to_dict() for doc in ref.get()]

def format_date():
    now = datetime.now()
    return now.strftime("%B %dth at %I:%M%p").replace('AM', 'am').replace('PM', 'pm')

def grade_exam(exam_id):
    # Load exam data
    exam_data = load_firebase("Exams", exam_id)
    if not exam_data:
        print(f"No exam found with id {exam_id}")
        return

    students = exam_data.get("students", [])
    questions = exam_data.get("questions", [])
    total_scores = []
    
    for student_email in students:
        student_email = student_email.strip()  # Remove any leading/trailing whitespace
        student_exam_data = load_firebase("Students", student_email)
        if not student_exam_data:
            print(f"No data found for student {student_email}")
            continue
        
        completed_exam_data = student_exam_data.get("completedExams", {}).get(exam_id, {}).get("answers", {})
        if not completed_exam_data:
            print(f"No completed exam data found for student {student_email} and exam {exam_id}")
            continue

        student_result = {
            "student_id": student_email,
            "grades": [],
            "final_grade": 0
        }

        for question_data in questions:
            question_text = question_data.get("question")
            rubrics = question_data.get("rubrics")
            student_answer = completed_exam_data.get(question_text)
            
            if not student_answer:
                print(f"No answer found for question '{question_text}' from student {student_email}")
                continue

            # Debugging: Print question and answer being graded
            print(f"Grading question '{question_text}' for student {student_email}")
            print(f"Answer: {student_answer}")

            prompt = (
                "Grade the answer from a student based on the given question and rubrics. "
                "The question includes a set of rubrics, and weights assigned to each rubric. "
                "The answer includes both the question and the student's response. "
                "The output must be a json following this format using double quotes for keys: "
                '{"question_id": "<insert the Question here>", "rubric_scores": [<score1>, <score2>, ...], "total_score": <sum of all rubrics scores>, "feedback": "<Constructive feedback based on the students answer and how it could be improved>"}'
                "Add your graded scores per rubric in the rubric_scores list based on your best assessment."
                "DO NOT DEVIATE FROM THIS FORMAT, DOING SO WILL HURT MY PROGRAM. Print everything in one line.\n\n"
                f"=============Question: {question_text}\n\n"
                f"=============Rubrics: {rubrics}\n\n"
                f"=============Answer: {student_answer}\n\n"
            )
            success = False
            while not success:
                try:
                    graded_response = ask_gemini(prompt)
                    result_dict = json.loads(graded_response)
                    success = True  # Parsing succeeded, exit the loop
                except json.JSONDecodeError:
                    print("Error parsing JSON, trying again...")
                    # The loop will automatically retry

            result_dict["answer"] = student_answer  # Add the student's answer
            result_dict["question_id"] = question_text
            student_result["grades"].append(result_dict)
            student_result["final_grade"] += result_dict["total_score"]
            print(f"Graded question '{question_text}' for student {student_email}")

        total_scores.append(student_result["final_grade"])
        
        # Update the document in Firestore for the individual student
        doc_ref = db.collection('Exams').document(exam_id).collection('graded').document(student_email)
        doc_ref.set(student_result, merge=True)

    # Calculate average score
    if total_scores:
        avg_score = sum(total_scores) / len(total_scores)
    else:
        avg_score = 0

    # Update the main exam document with the average score, graded status, and date last graded
    exam_doc_ref = db.collection('Exams').document(exam_id)
    exam_doc_ref.update({
        "avgScore": avg_score,
        "graded": True,
        "dateLastGraded": format_date()
    })

exam_id = os.getenv('EXAM_ID')
print(f"Grading exam {exam_id}")
grade_exam(exam_id)
print("Grading completed.")
