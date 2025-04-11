# Schemat bazy danych dla aplikacji 10xCards

## 1. Tabele

### Tabela: flashcards
Przechowuje informacje o fiszkach utworzonych przez użytkowników.

| Kolumna | Typ | Ograniczenia | Opis |
|---------|-----|--------------|------|
| id | UUID | PRIMARY KEY, DEFAULT uuid_generate_v4() | Unikalny identyfikator fiszki |
| user_id | UUID | NOT NULL, REFERENCES auth.users(id) | Identyfikator użytkownika, który utworzył fiszkę |
| front_content | VARCHAR(200) | NOT NULL, CHECK (length(front_content) <= 200) | Treść przedniej strony fiszki (pytanie) |
| back_content | VARCHAR(500) | NOT NULL, CHECK (length(back_content) <= 500) | Treść tylnej strony fiszki (odpowiedź) |
| creation_method | VARCHAR(10) | NOT NULL, CHECK (creation_method IN ('manual', 'ai', 'ai_edited')), DEFAULT 'manual' | Sposób utworzenia fiszki |
| is_deleted | BOOLEAN | NOT NULL, DEFAULT false | Flaga soft-delete |
| created_at | TIMESTAMPTZ | NOT NULL, DEFAULT now() | Data i czas utworzenia fiszki |
| updated_at | TIMESTAMPTZ | NOT NULL, DEFAULT now() | Data i czas ostatniej aktualizacji fiszki |

### Tabela: learning_sessions
Przechowuje informacje o sesjach nauki użytkowników.

| Kolumna | Typ | Ograniczenia | Opis |
|---------|-----|--------------|------|
| id | UUID | PRIMARY KEY, DEFAULT uuid_generate_v4() | Unikalny identyfikator sesji |
| user_id | UUID | NOT NULL, REFERENCES auth.users(id) | Identyfikator użytkownika, który rozpoczął sesję |
| start_time | TIMESTAMPTZ | NOT NULL, DEFAULT now() | Data i czas rozpoczęcia sesji |
| finished_time | TIMESTAMPTZ | DEFAULT NULL | Data i czas zakończenia sesji |
| cards_reviewed | INTEGER | NOT NULL, DEFAULT 0 | Liczba fiszek przejrzanych w sesji |
| avg_score | NUMERIC(2,1) | DEFAULT NULL | Średnia ocena w sesji |

### Tabela: flashcard_repetitions
Przechowuje historię powtórek fiszek.

| Kolumna | Typ | Ograniczenia | Opis |
|---------|-----|--------------|------|
| id | UUID | PRIMARY KEY, DEFAULT uuid_generate_v4() | Unikalny identyfikator powtórki |
| flashcard_id | UUID | NOT NULL, REFERENCES flashcards(id) | Identyfikator fiszki |
| session_id | UUID | NOT NULL, REFERENCES learning_sessions(id) | Identyfikator sesji nauki |
| user_id | UUID | NOT NULL, REFERENCES auth.users(id) | Identyfikator użytkownika |
| score | INTEGER | NOT NULL, CHECK (score BETWEEN 1 AND 5) | Ocena znajomości (1-5) |
| review_date | TIMESTAMPTZ | NOT NULL, DEFAULT now() | Data i czas powtórki |
| next_review_date | TIMESTAMPTZ | NOT NULL | Data i czas następnej powtórki |

## 2. Relacje między tabelami

1. **users** (tabela Supabase Auth) ←→ **flashcards**
   - Relacja jeden-do-wielu: Jeden użytkownik może posiadać wiele fiszek
   - Klucz obcy: `flashcards.user_id` → `auth.users.id`

2. **users** (tabela Supabase Auth) ←→ **learning_sessions**
   - Relacja jeden-do-wielu: Jeden użytkownik może posiadać wiele sesji nauki
   - Klucz obcy: `learning_sessions.user_id` → `auth.users.id`

3. **flashcards** ←→ **flashcard_repetitions**
   - Relacja jeden-do-wielu: Jedna fiszka może mieć wiele powtórek
   - Klucz obcy: `flashcard_repetitions.flashcard_id` → `flashcards.id`

4. **learning_sessions** ←→ **flashcard_repetitions**
   - Relacja jeden-do-wielu: Jedna sesja nauki może zawierać wiele powtórek
   - Klucz obcy: `flashcard_repetitions.session_id` → `learning_sessions.id`

5. **users** (tabela Supabase Auth) ←→ **flashcard_repetitions**
   - Relacja jeden-do-wielu: Jeden użytkownik może mieć wiele powtórek
   - Klucz obcy: `flashcard_repetitions.user_id` → `auth.users.id`

## 3. Indeksy

| Tabela | Nazwa indeksu | Kolumny | Typ | Opis |
|--------|---------------|---------|-----|------|
| flashcards | idx_flashcards_user_id | user_id | B-tree | Przyspiesza wyszukiwanie fiszek danego użytkownika |
| flashcards | idx_flashcards_is_deleted | is_deleted | B-tree | Przyspiesza filtrowanie nieskasowanych fiszek |
| flashcards | idx_flashcards_front_content | front_content | GIN (z operatorem tekstowym) | Przyspiesza wyszukiwanie tekstowe w treści przodu fiszki |
| flashcard_repetitions | idx_flashcard_repetitions_user_next_review | (user_id, next_review_date) | B-tree | Przyspiesza wyszukiwanie fiszek do powtórki dla danego użytkownika |
| flashcard_repetitions | idx_flashcard_repetitions_flashcard_id | flashcard_id | B-tree | Przyspiesza wyszukiwanie powtórek dla danej fiszki |
| flashcard_repetitions | idx_flashcard_repetitions_session_id | session_id | B-tree | Przyspiesza wyszukiwanie powtórek w ramach sesji |
| learning_sessions | idx_learning_sessions_user_id | user_id | B-tree | Przyspiesza wyszukiwanie sesji danego użytkownika |

## 4. Funkcje i wyzwalacze

### Funkcja: calculate_next_review_date()
Implementuje algorytm spaced repetition zgodnie z ocenami:
- Ocena 1: powtórka za 2 dni
- Ocena 2: powtórka za 3 dni
- Ocena 3: powtórka za 5 dni
- Ocena 4: powtórka za tydzień
- Ocena 5: powtórka za 2 tygodnie

```sql
CREATE OR REPLACE FUNCTION calculate_next_review_date(score INTEGER)
RETURNS TIMESTAMPTZ AS $$
DECLARE
  next_date TIMESTAMPTZ;
BEGIN
  CASE score
    WHEN 1 THEN next_date := now() + INTERVAL '2 days';
    WHEN 2 THEN next_date := now() + INTERVAL '3 days';
    WHEN 3 THEN next_date := now() + INTERVAL '5 days';
    WHEN 4 THEN next_date := now() + INTERVAL '7 days';
    WHEN 5 THEN next_date := now() + INTERVAL '14 days';
    ELSE next_date := now() + INTERVAL '1 day';
  END CASE;
  
  RETURN next_date;
END;
$$ LANGUAGE plpgsql;
```

### Wyzwalacz: set_updated_at_timestamp
Automatyczna aktualizacja pola updated_at podczas aktualizacji fiszki.

```sql
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_set_timestamp
BEFORE UPDATE ON flashcards
FOR EACH ROW
EXECUTE FUNCTION trigger_set_timestamp();
```

### Wyzwalacz: update_learning_session_stats
Aktualizacja statystyk sesji po każdej nowej powtórce.

```sql
CREATE OR REPLACE FUNCTION update_learning_session_stats()
RETURNS TRIGGER AS $
BEGIN
  -- Zwiększenie licznika przejrzanych fiszek
  UPDATE learning_sessions
  SET 
    cards_reviewed = cards_reviewed + 1,
    finished_time = now()
  WHERE id = NEW.session_id;
  
  -- Aktualizacja średniej oceny
  UPDATE learning_sessions
  SET avg_score = (
    SELECT AVG(score)::NUMERIC(2,1)
    FROM flashcard_repetitions
    WHERE session_id = NEW.session_id
  )
  WHERE id = NEW.session_id;
  
  RETURN NEW;
END;
$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_learning_session_stats
AFTER INSERT ON flashcard_repetitions
FOR EACH ROW
EXECUTE FUNCTION update_learning_session_stats();
```

### Funkcja: get_flashcards_for_learning
Pobiera fiszki do nauki (przeterminowane + nowe).

```sql
CREATE OR REPLACE FUNCTION get_flashcards_for_learning(
  p_user_id UUID,
  p_new_cards_count INTEGER DEFAULT 5
)
RETURNS TABLE (
  id UUID,
  front_content VARCHAR(200),
  back_content VARCHAR(500),
  is_review BOOLEAN
) AS $$
BEGIN
  -- Pobierz fiszki do powtórki
  RETURN QUERY
  SELECT DISTINCT ON (f.id)
    f.id,
    f.front_content,
    f.back_content,
    TRUE as is_review
  FROM flashcards f
  JOIN flashcard_repetitions fr ON f.id = fr.flashcard_id
  WHERE f.user_id = p_user_id
    AND f.is_deleted = FALSE
    AND fr.next_review_date <= now()
    AND fr.user_id = p_user_id
  ORDER BY f.id, fr.next_review_date DESC;

  -- Pobierz nowe fiszki (które nie mają jeszcze powtórek)
  RETURN QUERY
  SELECT 
    f.id,
    f.front_content,
    f.back_content,
    FALSE as is_review
  FROM flashcards f
  WHERE f.user_id = p_user_id
    AND f.is_deleted = FALSE
    AND NOT EXISTS (
      SELECT 1 FROM flashcard_repetitions fr
      WHERE fr.flashcard_id = f.id
    )
  ORDER BY random()
  LIMIT p_new_cards_count;
END;
$$ LANGUAGE plpgsql;
```

## 5. Polityki Row Level Security (RLS)

### Tabela: flashcards

```sql
-- Włączenie RLS
ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;

-- Polityka SELECT
CREATE POLICY flashcards_select ON flashcards
  FOR SELECT USING (auth.uid() = user_id);

-- Polityka INSERT
CREATE POLICY flashcards_insert ON flashcards
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Polityka UPDATE
CREATE POLICY flashcards_update ON flashcards
  FOR UPDATE USING (auth.uid() = user_id);

-- Polityka DELETE (soft-delete)
CREATE POLICY flashcards_delete ON flashcards
  FOR UPDATE USING (auth.uid() = user_id);
```

### Tabela: learning_sessions

```sql
-- Włączenie RLS
ALTER TABLE learning_sessions ENABLE ROW LEVEL SECURITY;

-- Polityka SELECT
CREATE POLICY learning_sessions_select ON learning_sessions
  FOR SELECT USING (auth.uid() = user_id);

-- Polityka INSERT
CREATE POLICY learning_sessions_insert ON learning_sessions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Polityka UPDATE
CREATE POLICY learning_sessions_update ON learning_sessions
  FOR UPDATE USING (auth.uid() = user_id);
```

### Tabela: flashcard_repetitions

```sql
-- Włączenie RLS
ALTER TABLE flashcard_repetitions ENABLE ROW LEVEL SECURITY;

-- Polityka SELECT
CREATE POLICY flashcard_repetitions_select ON flashcard_repetitions
  FOR SELECT USING (auth.uid() = user_id);

-- Polityka INSERT
CREATE POLICY flashcard_repetitions_insert ON flashcard_repetitions
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Polityka UPDATE (nie powinna być potrzebna, bo nie aktualizujemy powtórek)
CREATE POLICY flashcard_repetitions_update ON flashcard_repetitions
  FOR UPDATE USING (auth.uid() = user_id);
```

## 6. Uwagi i wyjaśnienia

1. **Bezpieczeństwo danych**:
   - Zastosowano Row Level Security (RLS) dla wszystkich tabel, aby zapewnić izolację danych użytkowników.
   - Użytkownicy mogą przeglądać, dodawać i modyfikować tylko własne dane.

2. **Soft-delete**:
   - Zastosowano mechanizm soft-delete (pole `is_deleted`) dla fiszek, co pozwala na potencjalne odzyskanie usuniętych danych.
   - Przy pobieraniu fiszek należy zawsze filtrować po `is_deleted = FALSE`.

3. **Algorytm spaced repetition**:
   - Zaimplementowano prosty algorytm spaced repetition zgodnie z wymaganiami.
   - W przyszłości można rozważyć bardziej zaawansowane algorytmy (np. SuperMemo).

4. **Wydajność**:
   - Dodano indeksy na kluczowych kolumnach, które będą często używane w zapytaniach.
   - Zoptymalizowano funkcję `get_flashcards_for_learning` dla szybkiego pobierania fiszek do nauki.

5. **Przyszłe rozbudowy**:
   - Schemat jest przygotowany na potencjalne dodanie kategoryzacji/tagowania fiszek w przyszłości.
   - Możliwe jest rozbudowanie o mechanizmy współdzielenia fiszek między użytkownikami.