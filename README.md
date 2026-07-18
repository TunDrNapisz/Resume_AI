# AI-Based Resume Screening System

An AI-powered recruitment assistant that uses Retrieval-Augmented Generation (RAG) to match candidates with job openings and provide natural-language insights to recruiters.

## Overview

This system helps recruiters screen resumes faster by combining local LLM inference with RAG-based retrieval over resume and job data. Recruiters can query candidate information using natural language instead of manually filtering spreadsheets.

## Key Features

- **AI-powered resume analysis** — suggests suitable job matches for candidates based on skills and profile
- **RAG-based retrieval** over resume and job posting data for accurate, context-aware responses
- **Natural language queries** — recruiters can ask things like "show me top-ranked candidates" or "who applied most recently"
- **Automated candidate profiling** with Firebase integration
- **Fast response time** — ~5-8 seconds per query

## Tech Stack

- **LLM:** Ollama (phi3:mini)
- **Retrieval:** RAG (Retrieval-Augmented Generation)
- **Database:** Firebase
- **Frontend:** Flutter (Dart) — cross-platform (Android, iOS, Web, Windows, macOS)

## How It Works

1. Resumes and job data are ingested and indexed for retrieval
2. Recruiter submits a natural language query (e.g. "shortlisted candidates for backend role")
3. RAG pipeline retrieves the most relevant resume/job chunks
4. Ollama (phi3:mini) generates a natural language response using retrieved context
5. Results are returned to the recruiter within 5-8 seconds

## Use Cases

- Retrieve top-ranked candidates for a specific role
- View shortlisted or most recent applicants
- Get AI-suggested job matches based on candidate skills

## Project Context

Developed as a personal project (March 2025 - August 2025) to explore practical applications of LLMs and RAG in real-world recruitment workflows.

## Author

**Muhammad Naffiz Bin Sazali**
Final-year AI student, Universiti Teknikal Malaysia Melaka (UTeM)
📧 naffizsazali02@gmail.com | [LinkedIn](https://linkedin.com/in/muhammad-naffiz-sazali-7534a02aa)
