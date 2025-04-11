import { Database } from '../database/database.types';

// Base type definitions from database model
export type FlashcardRow = Database['public']['Tables']['flashcards']['Row'];
export type FlashcardInsert = Database['public']['Tables']['flashcards']['Insert'];
export type FlashcardUpdate = Database['public']['Tables']['flashcards']['Update'];

export type LearningSessionRow = Database['public']['Tables']['learning_sessions']['Row'];
export type LearningSessionInsert = Database['public']['Tables']['learning_sessions']['Insert'];
export type LearningSessionUpdate = Database['public']['Tables']['learning_sessions']['Update'];

export type FlashcardRepetitionRow = Database['public']['Tables']['flashcard_repetitions']['Row'];
export type FlashcardRepetitionInsert = Database['public']['Tables']['flashcard_repetitions']['Insert'];
export type FlashcardRepetitionUpdate = Database['public']['Tables']['flashcard_repetitions']['Update'];

// Constants
export const CREATION_METHODS = ['manual', 'ai', 'ai_edited'] as const;
export type CreationMethod = typeof CREATION_METHODS[number];

/**
 * =====================================
 * FLASHCARD DTO
 * =====================================
 */

/**
 * Flashcard representation returned by API
 * Used in responses for GET /api/flashcards and GET /api/flashcards/{id} endpoints
 */
export type FlashcardDto = Pick<FlashcardRow, 'id' | 'front_content' | 'back_content' | 'creation_method' | 'created_at' | 'updated_at'>;

/**
 * Response with paginated flashcard list
 * Used for GET /api/flashcards endpoint
 */
export type FlashcardListResponseDto = {
  items: FlashcardDto[];
  total: number;
  page: number;
  pageSize: number;
  totalPages: number;
};

/**
 * Query parameters for flashcard list
 */
export type FlashcardListQueryParams = {
  page?: number;
  pageSize?: number;
  search?: string;
  sortBy?: keyof FlashcardDto;
  sortOrder?: 'asc' | 'desc';
};

/**
 * Command for creating one or more flashcards
 * Used for POST /api/flashcards endpoint
 */
export type CreateFlashcardCommand = {
  flashcards: {
    front_content: string;
    back_content: string;
    creation_method?: CreationMethod;
  }[];
};

/**
 * Response after flashcard creation
 */
export type CreateFlashcardsResponseDto = {
  flashcards: FlashcardDto[];
};

/**
 * Command for updating a flashcard
 * Used for PUT /api/flashcards/{id} endpoint
 */
export type UpdateFlashcardCommand = Pick<FlashcardRow, 'front_content' | 'back_content'>;

/**
 * Command for generating flashcards using AI
 * Used for POST /api/flashcards/generate endpoint
 */
export type GenerateFlashcardsCommand = {
  input_text: string;
  model?: string;
};

/**
 * Response with AI-generated flashcards
 */
export type GenerateFlashcardsResponseDto = {
  generated_flashcards: Array<Pick<FlashcardRow, 'front_content' | 'back_content'>>;
};

/**
 * =====================================
 * LEARNING SESSION DTO
 * =====================================
 */

/**
 * Command for creating learning session
 * Used for POST /api/learning-sessions endpoint
 */
export type CreateLearningSessionCommand = {
  new_cards_count?: number;
};

/**
 * Learning session representation returned by API
 * Used for GET /api/learning-sessions/{id} endpoint
 */
export type LearningSessionDto = Pick<
  LearningSessionRow,
  'id' | 'start_time' | 'finished_time' | 'cards_reviewed' | 'avg_score'
>;

/**
 * Flashcard in the context of a learning session
 */
export type LearningFlashcardDto = Pick<FlashcardRow, 'id' | 'front_content' | 'back_content'> & {
  is_review: boolean;
};

/**
 * Response with flashcards for a learning session
 * Used for GET /api/learning-sessions/{id}/flashcards endpoint
 */
export type LearningSessionFlashcardsDto = {
  flashcards: LearningFlashcardDto[];
};

/**
 * =====================================
 * FLASHCARD REPETITION DTO
 * =====================================
 */

/**
 * Command do tworzenia powtórki fiszki
 * Używany dla endpoint POST /api/learning-sessions/{session_id}/repetitions
 */
export type CreateFlashcardRepetitionCommand = {
  flashcard_id: string;
  score: 1 | 2 | 3 | 4 | 5;
};

/**
 * Reprezentacja powtórki fiszki zwracana przez API
 */
export type FlashcardRepetitionDto = Pick<
  FlashcardRepetitionRow,
  'id' | 'flashcard_id' | 'session_id' | 'score' | 'review_date' | 'next_review_date'
>;

/**
 * =====================================
 * STATISTICS DTO
 * =====================================
 */

/**
 * Statystyki dla pojedynczej fiszki
 * Używane dla endpoint GET /api/statistics/flashcards/{id}
 */
export type FlashcardStatisticsDto = {
  flashcard_id: string;
  repetition_count: number;
  average_score: number;
  next_review_date: string | null;
  history: {
    review_date: string;
    score: number;
  }[];
};

/**
 * Statystyki dla sesji nauki
 * Używane dla endpoint GET /api/statistics/learning-sessions/{id}
 */
export type LearningSessionStatisticsDto = {
  session_id: string;
  start_time: string;
  finished_time: string | null;
  duration_seconds: number;
  cards_reviewed: number;
  avg_score: number;
  score_distribution: Record<1 | 2 | 3 | 4 | 5, number>;
};

/**
 * Dzienne statystyki użytkownika
 */
export type DailyStatisticsDto = {
  date: string; // format "YYYY-MM-DD"
  cards_reviewed: number;
  average_score: number;
};

/**
 * Ogólne statystyki dla użytkownika
 * Używane dla endpoint GET /api/statistics/user
 */
export type UserStatisticsDto = {
  total_flashcards: number;
  total_repetitions: number;
  total_sessions: number;
  average_score: number;
  cards_due_today: number;
  daily_stats: DailyStatisticsDto[];
};

/**
 * =====================================
 * ERROR HANDLING DTO
 * =====================================
 */

/**
 * Kody błędów API
 */
export type ApiErrorCode =
  'VALIDATION_ERROR' |
  'RESOURCE_NOT_FOUND' |
  'UNAUTHORIZED' |
  'AI_TIMEOUT' |
  'SERVER_ERROR';

/**
 * Struktura błędu API
 */
export type ApiErrorResponse = {
  error: {
    code: ApiErrorCode;
    message: string;
    details?: Record<string, unknown>;
  }
};
