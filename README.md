# 10xCards

A web application for learning with AI-assisted flashcards

![Project Status](https://img.shields.io/badge/status-in%20development-yellow)
![Angular](https://img.shields.io/badge/Angular-18-red)
![PrimeNG](https://img.shields.io/badge/PrimeNG-19-blue)
![License](https://img.shields.io/badge/license-MIT-green)

## Table of Contents

- [Project Description](#project-description)
- [Tech Stack](#tech-stack)
- [Getting Started Locally](#getting-started-locally)
- [Available Scripts](#available-scripts)
- [Project Scope](#project-scope)
- [Project Status](#project-status)
- [License](#license)

## Project Description

### The Problem

Manual creation of high-quality educational flashcards is time-consuming, which discourages people from using the effective spaced repetition learning method.

### The Solution

10xCards is a web application that enables automatic generation of educational flashcards using artificial intelligence based on user-provided text, along with a learning mechanism utilizing the spaced repetition method.

### Key Features

- AI-powered flashcard generation from text input
- Manual flashcard creation
- Learning with spaced repetition algorithm
- Flashcard management (edit, delete, search)
- Learning statistics and progress tracking
- Simple user account system

### Target Audience

The application is aimed at anyone who wants to effectively learn using flashcards, without targeting a specific age or professional group.

### Success Criteria

- 75% of AI-generated flashcards are accepted by users
- Users create 75% of their flashcards using AI

## Tech Stack

### Frontend
- **Angular 18.1** - latest version for building web applications
- **PrimeNG 19** with Tailwind CSS 4.1 - for UI components and styling
- **SCSS** for component styling

### Backend
- **Supabase** as a Backend-as-a-Service solution:
    - PostgreSQL database
    - Built-in user authentication
    - SDK for Angular
    - Open-source solution that can be self-hosted

### AI
- Communication with LLM models:
    - Access to language models running on Ollama in a Docker container
    - Support for models like Mistral 7B Instruct, Gemma 7B Instruct, Phi-3 Mini

### CI/CD & Hosting
- **GitHub Actions** for CI/CD pipelines
- **VPS from CAL.pl** for hosting the application via Docker

## Getting Started Locally

### Prerequisites

- Node.js (v18+)
- pnpm 9.15.4 (strongly recommended, project is configured to use pnpm only)
- Docker and Docker Compose
- Git

### Installation

1. Clone the repository
   ```bash
   git clone https://github.com/JacobTheLiar/10x-devs-cards.git
   cd 10x-devs-cards
   ```

2. Install dependencies
   ```bash
   # Project is configured to use pnpm only
   pnpm install
   ```

3. Configure Supabase
    - Create a Supabase account or set up a local Supabase instance
    - Create a new project in Supabase
    - Set up the database schema according to the project requirements
    - Create an `.env` file with your Supabase credentials
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_KEY=your_supabase_anon_key
   ```

4. Configure Ollama with Docker
    - Pull and run the Ollama Docker image
   ```bash
   docker pull ollama/ollama
   docker run -d --name ollama -p 11434:11434 ollama/ollama
   ```
    - Download the required models
   ```bash
   docker exec -it ollama ollama pull mistral:7b-instruct
   docker exec -it ollama ollama pull gemma:7b-instruct
   docker exec -it ollama ollama pull phi3:mini
   ```

   Alternatively, you can use the provided Docker Compose setup when available.

5. Start the development server
   ```bash
   pnpm start
   ```

6. Open your browser and navigate to `http://localhost:4200`

## Available Scripts

Commands can be run with pnpm (strongly recommended):

- `pnpm start` - Starts the development server using Angular CLI
- `pnpm run build` - Builds the application for production
- `pnpm run watch` - Builds and watches for changes in development mode
- `pnpm test` - Runs unit tests using Karma and Jasmine
- `pnpm run lint` - Runs prettier to format code

## Project Scope

### What's Included in MVP

- AI-generated flashcards from user-provided text
- Manual flashcard creation
- Flashcard viewing, editing, and deletion
- Simple user account system
- Spaced repetition learning algorithm integrated with flashcards

### What's NOT Included in MVP

- Advanced algorithms (SuperMemo, Anki)
- File imports (PDF, DOCX, etc.)
- Flashcard set sharing between users
- Integrations with other educational platforms
- Mobile applications (web-only for now)
- Flashcard export and printing
- Categorization/tagging system

## Project Status

The project is currently in development phase, working toward the MVP release. The README will be updated during the development process to reflect current status and any changes in implementation details.

### Development Milestones

1. UI - Basic navigation with PrimeNG components
2. Supabase integration (authentication, database)
3. AI model integration (Ollama)
4. Spaced repetition system implementation in Angular
5. Statistics and reporting
6. Testing and fixes
7. CI/CD configuration and MVP deployment

## License

This project is licensed under the MIT License - see the LICENSE file for details.

---

© 2025 10xCards. All rights reserved.