import firebase_admin
from firebase_admin import credentials, firestore
import json
import os

# Retrieve the Firebase Admin SDK credentials from environment variables
firebase_adminsdk_json = os.environ.get('FIREBASE_ADMINSDK_JSON')

# Ensure the environment variables are set
if not firebase_adminsdk_json:
    raise ValueError("Environment variable FIREBASE_ADMINSDK_JSON is not set")

# Initialize Firebase Admin using the service account credentials from the environment variable
cred = credentials.Certificate(json.loads(firebase_adminsdk_json))
firebase_admin.initialize_app(cred)

db = firestore.client()

# Function to retrieve and save all data from the 'Student' collection
def save_and_print_all_students():
    students_ref = db.collection('Exams')
    students = students_ref.get()

    all_students = [student.to_dict() for student in students]

    # Convert the data to a JSON string with indentation
    json_data = json.dumps(all_students, indent=4)

    # Print the JSON data for debugging
    print("Retrieved student data:")
    print(json_data)

    # Save the JSON data to a file
    with open('exam.json', 'w') as f:
        f.write(json_data)

# Call the function
save_and_print_all_students()
