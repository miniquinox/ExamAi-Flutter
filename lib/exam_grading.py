import json
import requests
import firebase_admin
from firebase_admin import credentials, firestore
import google.generativeai as genai
import os
from datetime import datetime
import tempfile

# Retrieve the API key and the path to the Firebase Admin SDK JSON file from environment variables
gemini_api_key = os.getenv('GEMINI_API_KEY')
firebase_adminsdk_json_path = os.getenv('FIREBASE_ADMINSDK_JSON_PATH')

# Ensure the environment variables are set
if not gemini_api_key:
    raise ValueError("Environment variable GEMINI_API_KEY is not set")
if not firebase_adminsdk_json_path:
    raise ValueError("Environment variable FIREBASE_ADMINSDK_JSON_PATH is not set")

# Initialize Firebase using the file path
cred = credentials.Certificate(firebase_adminsdk_json_path)
firebase_admin.initialize_app(cred)
db = firestore.client()

genai.configure(api_key=gemini_api_key)

# Create the model
generation_config = {
    "temperature": 0.3,
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
    chat_session = model.start_chat(history=[])
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

def grade_exam(exam_id):
    # Process each student's data
    exam_results = {
        "exam_id": exam_id,
        "students": []
    }

    # Load exam data
    exam_data = load_firebase("Exams", exam_id)
    if not exam_data:
        print(f"No exam found with id {exam_id}")
        return

    students = exam_data.get("students", [])
    print(f"Grading exam for {len(students)} students")
    questions = exam_data.get("questions", [])

    maximum_exam_score = sum(question['weight'] for question in questions)
    all_students_grades = []

    for student_email in students:
        # Check if the student has already been graded
        graded_ref = db.collection("Exams").document(exam_id).collection("graded").document(student_email).get()
        if graded_ref.exists:
            all_students_grades.append(graded_ref.to_dict())
            print(f"Skipping student {student_email} as they have already been graded")
            continue

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

        total_score = 0
        
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
                '{"question_id": "<insert the Question here>", "rubric_scores": [<score1>, <score2>, ...], "total_score": <sum of all rubrics scores>, "feedback": "<Constructive feedback based on the students answer and how it could be improved. The student doesn\'t know these rubrics, so don\'t mention them directly.>"}'
                "Add your graded scores per rubric in the rubric_scores list based on your best assessment. "
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
            total_score += result_dict["total_score"]
            student_result["grades"].append(result_dict)

        student_result["final_grade"] = f'{total_score}/{maximum_exam_score}'
        exam_results["students"].append(student_result)
        all_students_grades.append(student_result)

        # Save graded data to student's entry
        student_ref = db.collection("Exams").document(exam_id).collection("graded").document(student_email)
        student_ref.set(student_result, merge=True)
        print(f"Graded data saved for student {student_email}")

    if all_students_grades:
        # Calculate average score and update exam document
        avg_score = sum(
            float(student["final_grade"].split('/')[0]) for student in all_students_grades
        ) / len(all_students_grades)
        exam_data["avgScore"] = f'{avg_score}/{maximum_exam_score}'
    else:
        exam_data["avgScore"] = "0/0"

    exam_data["graded"] = True
    exam_data["dateLastGraded"] = datetime.now().strftime('%B %dth at %I:%M%p')
    exam_ref = db.collection("Exams").document(exam_id)
    exam_ref.set(exam_data, merge=True)

    # Output the final JSON
    exam_results_json = json.dumps(exam_results, indent=4)
    print(exam_results_json)

exam_id = os.getenv('EXAM_ID')
print(f"Grading exam {exam_id}")
grade_exam(exam_id)
print("Grading completed.")
