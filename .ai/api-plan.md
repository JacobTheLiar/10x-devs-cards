# REST API Plan

## 1. Resources

| Resource | Database Table | Description |
|----------|----------------|-------------|
| Flashcards | `flashcards` | User's learning flashcards |
| Learning Sessions | `learning_sessions` | Sessions when users study flashcards |
| Flashcard Repetitions | `flashcard_repetitions` | History of flashcard reviews with scores |
| Statistics | Multiple tables | Learning statistics for users, flashcards, and sessions |
| AI Generation | N/A | Interface for generating flashcards using AI |

## 2. Endpoints

### Flashcards

#### GET /api/flashcards
- **Description**: Get a paginated list of user's flashcards
- **Query Parameters**:
    - `page`: Page number (default: 1)
    - `pageSize`: Items per page (default: 20)
    - `search`: Search term for front or back content
    - `sortBy`: Field to sort by (default: created_at)
    - `sortOrder`: asc or desc (default: desc)
- **Response**:
  ```json
  {
    "items": [
      {
        "id": "uuid",
        "front_content": "string",
        "back_content": "string",
        "creation_method": "manual|ai|ai_edited",
        "created_at": "timestamp",
        "updated_at": "timestamp"
      }
    ],
    "total": 0,
    "page": 1,
    "pageSize": 20,
    "totalPages": 0
  }
  ```
- **Success**: 200 OK
- **Errors**:
    - 401 Unauthorized: User not authenticated
    - 500 Internal Server Error: Server-side error

#### GET /api/flashcards/{id}
- **Description**: Get a specific flashcard by ID
- **Response**:
  ```json
  {
    "id": "uuid",
    "front_content": "string",
    "back_content": "string",
    "creation_method": "manual|ai|ai_edited",
    "created_at": "timestamp",
    "updated_at": "timestamp"
  }
  ```
- **Success**: 200 OK
- **Errors**:
    - 401 Unauthorized: User not authenticated
    - 404 Not Found: Flashcard not found or doesn't belong to user
    - 500 Internal Server Error: Server-side error

#### POST /api/flashcards
- **Description**: Create one or more flashcards (manually or from AI)
- **Request**:
  ```json
  {
    "flashcards": [
      {
        "front_content": "string",
        "back_content": "string",
        "creation_method": "manual|ai|ai_edited" // Optional, defaults to 'manual'
      }
    ]
  }
  ```
- **Response**:
  ```json
  {
    "flashcards": [
      {
        "id": "uuid",
        "front_content": "string",
        "back_content": "string",
        "creation_method": "manual|ai|ai_edited",
        "created_at": "timestamp",
        "updated_at": "timestamp"
      }
    ]
  }
  ```
- **Success**: 201 Created
- **Errors**:
    - 400 Bad Request: Validation failed
    - 401 Unauthorized: User not authenticated
    - 500 Internal Server Error: Server-side error

#### PUT /api/flashcards/{id}
- **Description**: Update an existing flashcard
- **Request**:
  ```json
  {
    "front_content": "string",
    "back_content": "string"
  }
  ```
- **Response**: Same as GET /api/flashcards/{id}
- **Success**: 200 OK
- **Errors**:
    - 400 Bad Request: Validation failed
    - 401 Unauthorized: User not authenticated
    - 404 Not Found: Flashcard not found or doesn't belong to user
    - 500 Internal Server Error: Server-side error

#### DELETE /api/flashcards/{id}
- **Description**: Soft-delete a flashcard
- **Success**: 204 No Content
- **Errors**:
    - 401 Unauthorized: User not authenticated
    - 404 Not Found: Flashcard not found or doesn't belong to user
    - 500 Internal Server Error: Server-side error

#### POST /api/flashcards/generate
- **Description**: Generate flashcards using AI from input text
- **Request**:
  ```json
  {
    "input_text": "string",
    "model": "string" // Optional, defaults to system preference
  }
  ```
- **Response**:
  ```json
  {
    "generated_flashcards": [
      {
        "front_content": "string",
        "back_content": "string"
      }
    ]
  }
  ```
- **Success**: 200 OK
- **Errors**:
    - 400 Bad Request: Invalid input
    - 401 Unauthorized: User not authenticated
    - 408 Request Timeout: AI generation took too long (>15 seconds)
    - 500 Internal Server Error: Server-side error

### Learning Sessions

#### POST /api/learning-sessions
- **Description**: Start a new learning session
- **Request**:
  ```json
  {
    "new_cards_count": 5 // Optional, number of new cards to include
  }
  ```
- **Response**:
  ```json
  {
    "id": "uuid",
    "start_time": "timestamp",
    "cards_reviewed": 0
  }
  ```
- **Success**: 201 Created
- **Errors**:
    - 401 Unauthorized: User not authenticated
    - 500 Internal Server Error: Server-side error

#### GET /api/learning-sessions/{id}
- **Description**: Get details about a specific learning session
- **Response**:
  ```json
  {
    "id": "uuid",
    "start_time": "timestamp",
    "finished_time": "timestamp",
    "cards_reviewed": 0,
    "avg_score": 0.0
  }
  ```
- **Success**: 200 OK
- **Errors**:
    - 401 Unauthorized: User not authenticated
    - 404 Not Found: Session not found or doesn't belong to user
    - 500 Internal Server Error: Server-side error

#### PUT /api/learning-sessions/{id}/finish
- **Description**: Finish an active learning session
- **Response**: Same as GET /api/learning-sessions/{id}
- **Success**: 200 OK
- **Errors**:
    - 401 Unauthorized: User not authenticated
    - 404 Not Found: Session not found or doesn't belong to user
    - 500 Internal Server Error: Server-side error

#### GET /api/learning-sessions/{id}/flashcards
- **Description**: Get flashcards for the current learning session
- **Response**:
  ```json
  {
    "flashcards": [
      {
        "id": "uuid",
        "front_content": "string",
        "back_content": "string",
        "is_review": true // Whether this is a review card or a new card
      }
    ]
  }
  ```
- **Success**: 200 OK
- **Errors**:
    - 401 Unauthorized: User not authenticated
    - 404 Not Found: Session not found or doesn't belong to user
    - 500 Internal Server Error: Server-side error

### Flashcard Repetitions

#### POST /api/learning-sessions/{session_id}/repetitions
- **Description**: Record a flashcard repetition with score for a specific learning session
- **Request**:
  ```json
  {
    "flashcard_id": "uuid",
    "score": 1 // Integer 1-5
  }
  ```
- **Response**:
  ```json
  {
    "id": "uuid",
    "flashcard_id": "uuid",
    "session_id": "uuid",
    "score": 1,
    "review_date": "timestamp",
    "next_review_date": "timestamp"
  }
  ```
- **Success**: 201 Created
- **Errors**:
    - 400 Bad Request: Validation failed
    - 401 Unauthorized: User not authenticated
    - 404 Not Found: Flashcard or session not found
    - 500 Internal Server Error: Server-side error

### Statistics

#### GET /api/statistics/flashcards/{id}
- **Description**: Get statistics for a specific flashcard
- **Response**:
  ```json
  {
    "flashcard_id": "uuid",
    "repetition_count": 0,
    "average_score": 0.0,
    "next_review_date": "timestamp",
    "history": [
      {
        "review_date": "timestamp",
        "score": 1
      }
    ]
  }
  ```
- **Success**: 200 OK
- **Errors**:
    - 401 Unauthorized: User not authenticated
    - 404 Not Found: Flashcard not found or doesn't belong to user
    - 500 Internal Server Error: Server-side error

#### GET /api/statistics/learning-sessions/{id}
- **Description**: Get statistics for a specific learning session
- **Response**:
  ```json
  {
    "session_id": "uuid",
    "start_time": "timestamp",
    "finished_time": "timestamp",
    "duration_seconds": 0,
    "cards_reviewed": 0,
    "avg_score": 0.0,
    "score_distribution": {
      "1": 0,
      "2": 0,
      "3": 0,
      "4": 0,
      "5": 0
    }
  }
  ```
- **Success**: 200 OK
- **Errors**:
    - 401 Unauthorized: User not authenticated
    - 404 Not Found: Session not found or doesn't belong to user
    - 500 Internal Server Error: Server-side error

#### GET /api/statistics/user
- **Description**: Get overall statistics for the current user
- **Response**:
  ```json
  {
    "total_flashcards": 0,
    "total_repetitions": 0,
    "total_sessions": 0,
    "average_score": 0.0,
    "cards_due_today": 0,
    "daily_stats": [
      {
        "date": "YYYY-MM-DD",
        "cards_reviewed": 0,
        "average_score": 0.0
      }
    ]
  }
  ```
- **Success**: 200 OK
- **Errors**:
    - 401 Unauthorized: User not authenticated
    - 500 Internal Server Error: Server-side error

## 3. Authentication & Authorization

### Authentication
- Authentication will be handled by Supabase Auth.
- Each API request must include a valid JWT token from Supabase Auth in the `Authorization` header:
  ```
  Authorization: Bearer [JWT_TOKEN]
  ```
- The API will verify the token and extract the user ID for all authorized requests.

### Authorization
- Authorization is enforced through Supabase's Row Level Security (RLS) policies.
- API endpoints will respect these RLS policies and ensure data isolation.
- Each request will be tied to the authenticated user's ID to ensure they can only access their own data.

## 4. Validation & Business Logic

### Validation Rules

#### Flashcards
- `front_content`: Required, maximum 200 characters
- `back_content`: Required, maximum 500 characters
- `creation_method`: Must be one of: 'manual', 'ai', 'ai_edited'

#### Flashcard Repetitions
- `score`: Required, integer between 1 and 5
- `flashcard_id`: Must reference an existing flashcard owned by the user
- `session_id`: Must reference an active learning session owned by the user

### Business Logic

#### Spaced Repetition Algorithm
The API will implement the spaced repetition algorithm when recording repetitions:
- Score 1: next review in 2 days
- Score 2: next review in 3 days
- Score 3: next review in 5 days
- Score 4: next review in 7 days
- Score 5: next review in 14 days

#### Learning Session Flashcards
When retrieving flashcards for a learning session, the API will:
1. Prioritize flashcards due for review (based on next_review_date)
2. Include new flashcards (without any repetitions) up to the specified limit
3. Sort them in an appropriate order for learning

#### AI Flashcard Generation
When generating flashcards with AI:
1. The API will respect the 15-second timeout requirement
2. It will parse the input text and create relevant flashcard suggestions
3. The response will include generated flashcards but won't save them automatically
4. The user can review, edit, and save the generated flashcards using the standard POST /api/flashcards endpoint

#### Session Statistics
The API will utilize the database trigger functions to automatically:
- Increment the cards_reviewed counter
- Update the average score
- Set the finished_time when appropriate

## 5. Error Handling

All API endpoints should return standard HTTP status codes and include detailed error messages:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {} // Optional additional details
  }
}
```

Common error codes:
- `VALIDATION_ERROR`: Request data doesn't meet validation requirements
- `RESOURCE_NOT_FOUND`: Requested resource doesn't exist
- `UNAUTHORIZED`: User not authenticated or not authorized
- `AI_TIMEOUT`: AI generation timed out
- `SERVER_ERROR`: Internal server error

## 6. API Versioning

The API will be versioned to allow for future changes without breaking existing clients:

- All endpoints will be prefixed with `/api/v1/` for the initial version
- Future versions will use `/api/v2/`, etc.

For simplicity, this document omits the version prefix, but it should be included in the actual implementation.