#!/bin/bash

# Export EXAM_ID from EXAM_ID.txt
export EXAM_ID=$(< EXAM_ID.txt)

# Export GEMINI_API_KEY from gemini_api_key.txt
export GEMINI_API_KEY=$(< gemini_api_key.txt)

# Export FIREBASE_ADMINSDK_JSON from examai-2024-firebase-adminsdk-n1um4-81d7727487.json
export FIREBASE_ADMINSDK_JSON="$(< examai-2024-firebase-adminsdk-n1um4-81d7727487.json)"