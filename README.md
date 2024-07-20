# Exam Ai: An AI-powered Grading Platform

Welcome to [**Exam Ai**](https://examai.ai) ([https://examai.ai](https://examai.ai)), an innovative AI-powered grading platform designed to revolutionize how exams and assignments are graded. Our goal is to provide a seamless experience for professors and students, ensuring efficient, accurate, and fair grading. Below, you'll find an in-depth explanation of the project, suitable for both Angel Investors and technical enthusiasts.

## Overview

Exam Ai is an enterprise platform that enables users to log in as professors or students. Here’s a brief summary of what each role can do:

### For Professors:
- **Create Exams**: Add questions, rubrics, and weights per question.
- **Automated Grading**: AI grades according to the professor’s rubrics, ensuring adherence to the desired grading criteria.
- **Detailed Feedback**: Each question receives specific feedback, helping students understand their performance.
- **Grading Control**: Professors decide when exams are graded, capturing only the latest submission by default.
- **Analytics Portal**: View class averages, grade distributions, and insights into the hardest and easiest questions.
- **Versatile Applications**: The platform can be used to create and automate homework, quizzes, exams, forms, or even interviews!

### For Students:
- **Simple Portal**: Take exams with various question types (short answers, essays, programming challenges, etc.).
- **Automated Feedback**: Receive detailed feedback on each question after grading.
- **Performance Analytics**: Access analytics to see performance trends and areas for improvement.

## Technology Stack

### Frontend:
- **Flutter**: The platform is built using Flutter as a WebApp, providing a seamless and responsive user experience.

### AI Component:
- **Gemini 1.5 PRO**: Utilizes prompt engineering to automate grading based on loaded questions, rubrics, and student answers, providing detailed feedback.

### Backend:
- **Firebase Firestore**: Manages the database and user authentication.
- **Firebase Login**: Handles secure user logins.
- **GitHub Actions**: Minimal backend setup, using a webhook and a Python script to handle grading requests and update the database.

### Security:
- **Database Rules**: Ensures that only authenticated users can push data, limiting access to documents associated with their email ID.

## Flowchart of the App Structure

Below is a flowchart that visualizes how the screens connect with each other:

```mermaid
flowchart TD
    A("main.dart") -- Login as Student --> B("student_dashboard.dart")
    A -- Login as Professor --> C("professor_dashboard.dart")
    B -- Take a New Exam --> D("takeExam_examSelection.dart")
    B -- Recent Exams Analytics --> I("ExamResults_professor.dart")
    D -- Select Exam --> F("takeExam_instructions.dart")
    F -- Start Exam --> G("takeExam_final.dart")
    G -- Submit Exam --> H[("Firebase")]
    I -- View Student Feedback --> J("studentExam_feedback.dart")
    C -- Your Exams --> K("Your Exams Table")
    C -- Create Exam --> L("createExam_examDetails.dart")
    K -- Grade Exam --> M("exam_grading.py")
    M -- Grade Exam --> W((("Gemini")))
    W -- Grade Exam --> H
    K -- Analytics --> I
    K -- Student Grades --> N("examGrades.dart")
    L -- Next --> O("createExam_addQuestions.dart")
    O -- Next --> P("createExam_review.dart")
    P -- Publish --> H
    style B stroke:#757575,fill:#2962FF
    style C stroke:#757575,fill:#AA00FF
    style D stroke:#757575,fill:#2962FF
    style I stroke:#757575,fill:#2962FF
    style F stroke:#757575,fill:#2962FF
    style G stroke:#757575,fill:#2962FF
    style H stroke:#757575,fill:#00C853,color:#000000
    style J stroke:#757575,fill:#2962FF
    style K stroke:#757575,fill:#AA00FF
    style L stroke:#757575,fill:#AA00FF
    style M stroke:#757575,fill:#D50000
    style W stroke:#FFF9C4,fill:#D50000
    style N stroke:#757575,fill:#AA00FF
    style O stroke:#757575,fill:#AA00FF
    style P stroke:#757575,fill:#AA00FF
```

## Future Vision

With your support, we aim to secure funding for the continued use of Gemini and Firebase, keeping the platform free for professors worldwide. This will help bring high standards of education to regions that cannot afford teaching assistants for grading extensive homework and quizzes.

Thank you for your interest in Exam Ai. Together, we can enhance the educational experience for both professors and students globally. 

Please visit our ([ExamAi Landing Page](https://examai.framer.website/)) for more information about or project.