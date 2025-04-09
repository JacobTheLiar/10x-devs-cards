# Dokument Wymagań Projektowych (PRD)
## Aplikacja do nauki z fiszkami wspomaganymi przez AI

### 1. Wprowadzenie i cel produktu

#### 1.1 Problem
Manualne tworzenie wysokiej jakości fiszek edukacyjnych jest czasochłonne, co zniechęca do korzystania z efektywnej metody nauki jaką jest spaced repetition.

#### 1.2 Proponowane rozwiązanie
Aplikacja webowa umożliwiająca automatyczne generowanie fiszek edukacyjnych przy pomocy sztucznej inteligencji na podstawie wprowadzonego przez użytkownika tekstu, wraz z mechanizmem nauki wykorzystującym metodę powtórek interwałowych.

#### 1.3 Kryteria sukcesu
- 75% fiszek wygenerowanych przez AI jest akceptowane przez użytkownika
- Użytkownicy tworzą 75% fiszek z wykorzystaniem AI

### 2. Użytkownicy i przypadki użycia

#### 2.1 Grupa docelowa
Aplikacja skierowana jest do wszystkich osób chcących efektywnie przyswajać wiedzę przy pomocy fiszek, bez określonej grupy wiekowej czy zawodowej.

#### 2.2 Główne przypadki użycia
1. **Generowanie fiszek przez AI**
2. **Manualne tworzenie fiszek**
3. **Nauka z fiszkami**
4. **Przeglądanie statystyk**
5. **Wyszukiwanie fiszek**

### 3. Funkcjonalności produktu

#### 3.1 Zarządzanie kontem użytkownika
- Rejestracja i logowanie (przez Supabase Auth)
- Przeglądanie podstawowych informacji o koncie

#### 3.2 Zarządzanie fiszkami
- Generowanie fiszek przez AI
- Manualne tworzenie fiszek
- Edycja i usuwanie fiszek
- Przeglądanie listy własnych fiszek
- Wyszukiwanie wśród własnych fiszek
- Izolacja danych - użytkownik widzi tylko swoje fiszki

#### 3.3 System nauki
- Rozpoczynanie i zarządzanie sesją nauki
- Algorytm powtórek interwałowych (spaced repetition) zaimplementowany po stronie klienta
- Ocena znajomości od 1 do 5
- Dostosowanie harmonogramu powtórek
- Prezentacja fiszek w trybie nauki

#### 3.4 Statystyki
- Statystyki per fiszka i per sesja

### 4. Wymagania funkcjonalne

#### 4.1 Generowanie fiszek przez AI
- Wprowadzenie dowolnego tekstu
- AI generuje co najmniej jedną fiszkę
- Edycja, akceptacja lub odrzucenie propozycji
- Czas generowania: maksymalnie 15 sekund

#### 4.2 Manualne tworzenie fiszek
- Pola na przód i tył fiszki
- Zapis do bazy danych Supabase

#### 4.3 Mechanizm nauki
- Interfejs rozpoczynania sesji nauki
- Prezentacja fiszek według algorytmu spaced repetition
- Ocena 1–5
- Dostosowanie powtórek
- Implementacja po stronie klienta z synchronizacją do Supabase
- Rejestracja danych statystycznych z sesji nauki

#### 4.4 Przeglądanie i zarządzanie fiszkami
- Lista własnych fiszek z paginacją
- Wyszukiwanie, edycja i usuwanie własnych fiszek
- Potwierdzenie przed usunięciem fiszki
- Formularz edycji z walidacją długości

#### 4.5 Statystyki
- Postęp nauki per fiszka (historia powtórek, ocen, przewidywany termin następnej powtórki)
- Statystyki per sesja (liczba przerobionych fiszek, czas trwania, średnia ocena)
- Wizualizacja danych statystycznych
- Dostęp tylko do własnych statystyk

### 5. Wymagania niefunkcjonalne

#### 5.1 Wydajność
- Generowanie fiszek przez AI: max 15 sek.
- UI reaguje poniżej 1 sekundy

#### 5.2 Skalowalność
- Obsługa wielu użytkowników równocześnie

#### 5.3 Bezpieczeństwo
- Bezpieczne przechowywanie danych
- Zgodność z RODO
- Wykorzystanie wbudowanych mechanizmów bezpieczeństwa Supabase
- Izolacja danych - każdy użytkownik ma dostęp tylko do swoich fiszek
- Polityka dostępu do danych zdefiniowana na poziomie Supabase

#### 5.4 Użyteczność
- Responsywny i intuicyjny interfejs webowy
- Stylistyka oparta na komponentach PrimeNG z Tailwind

### 6. Ograniczenia i założenia

#### 6.1 Ograniczenia techniczne
- Limit 200 znaków (przód), 500 znaków (tył)
- Brak obsługi obrazów, tagów, kategorii
- Modele AI hostowane lokalnie (Ollama)

#### 6.2 Założenia biznesowe
- Projekt edukacyjny, bez monetyzacji

### 7. Specyfikacja techniczna

#### 7.1 Architektura systemu
- Frontend: Angular (najnowsza stabilna wersja) + PrimeNG (Tailwind)
- Backend: Supabase jako Backend-as-a-Service
- Baza danych: PostgreSQL (zarządzana przez Supabase)
- AI: Modele LLM uruchamiane przez Ollama w kontenerze Docker (Mistral 7B Instruct, Gemma 7B Instruct, Phi-3 Mini)

#### 7.2 Interfejsy API
- Supabase API: zarządzanie kontem, fiszkami, statystykami
- REST API do komunikacji z modelami Ollama

#### 7.3 Model danych
- Użytkownicy, fiszki, sesje nauki, statystyki
- Schemat przechowywany w PostgreSQL Supabase
- Relacje między tabelami zapewniające izolację danych użytkowników
- Każda fiszka i sesja nauki powiązana z ID użytkownika

#### 7.4 CI/CD i hosting
- GitHub Actions do automatyzacji procesów CI/CD
- Hosting na serwerze VPS (CAL.pl) z wykorzystaniem kontenerów Docker

### 8. Co NIE wchodzi w zakres MVP
- Zaawansowane algorytmy (SuperMemo, Anki)
- Import plików (PDF, DOCX)
- Współdzielenie zestawów
- Integracje z platformami edukacyjnymi
- Aplikacje mobilne
- Eksport i druk fiszek
- Kategoryzacja/tagowanie

### 9. Plan wdrożenia

#### 9.1 Milestones
1. UI – podstawowa nawigacja z komponentami PrimeNG
2. Integracja z Supabase (autentykacja, baza danych)
3. Integracja modeli AI (Ollama)
4. Implementacja systemu powtórek w Angular
5. Statystyki i raportowanie
6. Testy i poprawki
7. Konfiguracja CI/CD i wdrożenie MVP

#### 9.2 Kryteria akceptacji
- Poprawne działanie AI z czasem odpowiedzi do 15 sekund
- Działający system nauki z algorytmem spaced repetition
- Intuicyjny UI z PrimeNG
- Wydajność zgodna z założeniami
- Poprawna synchronizacja danych z Supabase

### 10. Ryzyka
- Niska jakość generowanych fiszek przez lokalne modele AI
- Wydajność lokalnie hostowanych modeli AI
- Problemy z synchronizacją danych między klientem a Supabase
- Brak zaangażowania użytkowników

### 11. User Stories

#### **US-001** – Rejestracja konta
- Jako nowy użytkownik
- Chcę móc założyć konto poprzez formularz rejestracji
- Aby uzyskać dostęp do aplikacji
**Kryteria akceptacji:**
- Wpisanie loginu i hasła
- Walidacja danych (unikalność loginu)
- Rejestracja poprzez Supabase Auth
- Błędy pokazują komunikat

#### **US-002** – Logowanie do konta
- Jako zarejestrowany użytkownik
- Chcę się zalogować
- Aby mieć dostęp do fiszek i statystyk
**Kryteria akceptacji:**
- Logowanie po poprawnych danych przez Supabase Auth
- Komunikat przy błędnym logowaniu

#### **US-003** – Generowanie fiszek przez AI
- Jako użytkownik
- Chcę wkleić tekst i wygenerować fiszki przez AI
- Aby szybko stworzyć materiał do nauki
**Kryteria akceptacji:**
- Możliwość edycji, akceptacji lub odrzucenia fiszek
- Zapis zatwierdzonych fiszek do Supabase
- Czas generowania nie przekracza 15 sekund

#### **US-004** – Ręczne tworzenie fiszek
- Jako użytkownik
- Chcę samodzielnie tworzyć fiszki
- Aby dodawać własne pytania i odpowiedzi
**Kryteria akceptacji:**
- Formularz przód/tył
- Walidacja długości
- Zapis do Supabase

#### **US-005** – Rozpoczęcie sesji nauki
- Jako użytkownik
- Chcę rozpocząć sesję nauki z fiszkami
- Aby skutecznie przyswajać wiedzę
**Kryteria akceptacji:**
- Interfejs z możliwością rozpoczęcia nowej sesji
- Wybór zestawu fiszek do nauki (lub automatyczny wybór przez algorytm)
- Prezentacja pierwszej fiszki z sesji

#### **US-006** – Nauka z fiszkami
- Jako użytkownik
- Chcę uczyć się fiszek zgodnie z spaced repetition
- Aby lepiej zapamiętywać
**Kryteria akceptacji:**
- Ocena 1–5 po pokazaniu odpowiedzi
- Harmonogram dostosowany do wyników
- Algorytm zaimplementowany w Angular

#### **US-007** – Przeglądanie fiszek
- Jako użytkownik
- Chcę mieć dostęp do listy moich fiszek
- Aby móc nimi zarządzać
**Kryteria akceptacji:**
- Lista z paginacją
- Wyszukiwanie fiszek
- Widoczne tylko fiszki utworzone przez zalogowanego użytkownika
- Synchronizacja z Supabase

#### **US-008** – Edycja fiszek
- Jako użytkownik
- Chcę edytować moje istniejące fiszki
- Aby poprawiać lub aktualizować ich zawartość
**Kryteria akceptacji:**
- Formularz edycji z wypełnionymi aktualnymi danymi
- Możliwość zmiany treści przodu i tyłu fiszki
- Walidacja długości
- Aktualizacja w bazie danych Supabase

#### **US-009** – Usuwanie fiszek
- Jako użytkownik
- Chcę usuwać niepotrzebne fiszki
- Aby utrzymać porządek w moich materiałach
**Kryteria akceptacji:**
- Możliwość usunięcia fiszki z listy
- Potwierdzenie przed usunięciem
- Usunięcie tylko własnych fiszek
- Aktualizacja w bazie danych Supabase

#### **US-010** – Przeglądanie statystyk sesji
- Jako użytkownik
- Chcę widzieć statystyki moich sesji nauki
- Aby śledzić mój postęp
**Kryteria akceptacji:**
- Widok statystyk per sesja
- Informacje o liczbie przerobionych fiszek
- Informacje o czasie trwania sesji
- Średnia ocena w sesji
- Wizualizacja danych

#### **US-011** – Przeglądanie statystyk fiszek
- Jako użytkownik
- Chcę widzieć statystyki poszczególnych fiszek
- Aby zidentyfikować problematyczne zagadnienia
**Kryteria akceptacji:**
- Widok statystyk per fiszka
- Historia powtórek
- Historia ocen
- Przewidywany termin następnej powtórki
- Wskaźnik trudności fiszki