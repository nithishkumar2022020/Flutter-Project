# SYNQRA // Neural Retrieval & Attribution Canvas

> **A high-performance, neo-brutalist Archival RAG client engineered in Flutter with low-latency Server-Sent Events (SSE) streaming, granular document-scoped vector retrieval, grounded citation deep linking, and real-time agentic thought telemetry.**

---

[![Flutter](https://img.shields.io/badge/Flutter-3.7+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.7+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture%20%2B%20Provider-FF4C29)](https://flutter.dev)
[![Theme](https://img.shields.io/badge/Design-Neo--Brutalist%20Archival-121110)](#design-system--visual-identity)
[![Tests](https://img.shields.io/badge/Tests-39%20Passing-success)](#testing--verification)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)

---

## Table of Contents

- [1. Executive Summary](#1-executive-summary)
- [2. Architectural Blueprint](#2-architectural-blueprint)
- [3. Core Features](#3-core-features)
  - [Real-Time SSE Token Streaming](#real-time-sse-token-streaming)
  - [Agentic Thought-Process Telemetry](#agentic-thought-process-telemetry)
  - [Granular Document Scoping & Slide Range Selection](#granular-document-scoping--slide-range-selection)
  - [Grounded Citations & Modal Attribution Sheets](#grounded-citations--modal-attribution-sheets)
  - [Formatted Markdown & LaTeX Synthesis](#formatted-markdown--latex-synthesis)
  - [Corpus Management & Multipart Ingest](#corpus-management--multipart-ingest)
  - [Typewriter Boot Screen & Adaptive Icons](#typewriter-boot-screen--adaptive-icons)
  - [Latent Matrix & Diagnostics Canvases](#latent-matrix--diagnostics-canvases)
- [4. Backend API Contract](#4-backend-api-contract)
- [5. Design System & Visual Identity](#5-design-system--visual-identity)
- [6. Directory Structure](#6-directory-structure)
- [7. Getting Started](#7-getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation & Dependency Resolution](#installation--dependency-resolution)
  - [Local Backend & ADB Port Forwarding](#local-backend--adb-port-forwarding)
  - [Building & Deploying](#building--deploying)
- [8. Testing & Verification](#8-testing--verification)
- [9. Configuration & Settings](#9-configuration--settings)

---

## 1. Executive Summary

**SYNQRA** is an archival retrieval-augmented generation (RAG) interface built for researchers, intelligence analysts, and knowledge architects who require complete transparency and attribution when querying dense document stores.

Unlike conventional chat interfaces that output opaque responses with vague references, SYNQRA treats retrieval as an observable scientific process:
- Responses are **streamed token-by-token over HTTP SSE** with live throughput tracking.
- Every retrieval step (dense HNSW vector queries, cross-encoder reranking, context assembly) is surfaced in an **agentic thought timeline** modeled after cutting-edge developer environments.
- Claims in generated answers are paired with **interactive, hyperlinked citation badges** that expand into grounded source text previews with document IDs and page references.
- Users can scope queries to the **entire corpus**, a **single document**, or a **dynamically selected range of documents** using touch or slide gestures.
- The UI adheres to a strict **Neo-Brutalist Archival aesthetic**: high-contrast tactile borders, zero-blur vector graphics, warm parchment and deep nocturne palettes, monospaced data readouts, and typewriter terminal animations.

---

## 2. Architectural Blueprint

SYNQRA follows **Clean Architecture** principles, maintaining strict separation among Domain, Data, Presentation, and Core utility layers.

```
┌────────────────────────────────────────────────────────────────────────┐
│                          PRESENTATION LAYER                            │
│  ┌─────────────────────────┐  ┌──────────────────────────────────────┐ │
│  │   Screens & Canvases    │  │        ChangeNotifier Providers      │ │
│  │  - ArchivalSplashScreen │  │  - RagSessionProvider                │ │
│  │  - RootShellScreen      │  │  - CorpusProvider                    │ │
│  │  - QueryCanvasScreen    │  │  - TelemetryProvider                 │ │
│  │  - IngestionScreen      │  │  - SettingsProvider                  │ │
│  │  - MatrixOverviewScreen │  └──────────────────────────────────────┘ │
│  │  - GraphTelemetryScreen │  ┌──────────────────────────────────────┐ │
│  │  - ClearanceAuthScreen  │  │        Neo-Brutalist Widgets         │ │
│  └─────────────────────────┘  │  - ProcessTimelineCard / MiniDock    │ │
│                               │  - CitationBadge / FormattedAnswer   │ │
│                               │  - BrutalistContainer / EvidenceSheet│ │
│                               └──────────────────────────────────────┘ │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │ consumes & triggers
┌────────────────────────────────────▼───────────────────────────────────┐
│                             DOMAIN LAYER                               │
│  ┌─────────────────────────┐  ┌──────────────────────────────────────┐ │
│  │      Domain Models      │  │         Repository Contracts         │ │
│  │  - RagStreamEvent       │  │  - IRagStreamRepository              │ │
│  │  - Citation             │  │  - ICorpusRepository                 │ │
│  │  - DocumentEntry        │  │  - ITelemetryRepository              │ │
│  │  - RagProcessStep       │  │  - IProfileSettingsRepository        │ │
│  │  - ProfileSettings      │  │  - IVectorInspectorRepository        │ │
│  └─────────────────────────┘  └──────────────────────────────────────┘ │
└────────────────────────────────────▲───────────────────────────────────┘
                                     │ implements
┌────────────────────────────────────┴───────────────────────────────────┐
│                              DATA LAYER                                │
│  ┌──────────────────────────────────────────────────────────────────┐  │
│  │  - RagStreamRepository (SSE EventSource parsing & HTTP fallback) │  │
│  │  - CorpusRepository (Multipart PDF upload & manifest persistence)│  │
│  │  - ProfileSettingsRepository (SharedPreferences persistence)     │  │
│  │  - MockTelemetryRepository / MockVectorInspectorRepository       │  │
│  └──────────────────────────────────────────────────────────────────┘  │
└────────────────────────────────────┬───────────────────────────────────┘
                                     │ utility & foundation
┌────────────────────────────────────▼───────────────────────────────────┐
│                              CORE LAYER                                │
│  - AppTheme (Parchment & Nocturne palettes, typography, borders)       │
│  - CitationParser (Regex token extraction & inline badge mapping)      │
│  - SmoothPageRoute (Tactile transitional routing)                      │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 3. Core Features

### Real-Time SSE Token Streaming
- Connects directly to backend Server-Sent Events endpoints (e.g. `POST /questions/stream`).
- Emits atomic `RagStreamEvent` variants as chunks arrive:
  - `StreamStatusEvent`: Telemetry progress updates.
  - `AnswerChunkEvent`: Real-time incremental token stream.
  - `CitationsEvent`: Source attribution data with document metadata.
  - `StreamErrorEvent`: Rich error messages with status code inspection.
  - `StreamDoneEvent`: Stream completion signal.
- Graceful fallback: Automatically falls back to standard `POST /questions` if the SSE endpoint is unavailable.

### Agentic Thought-Process Telemetry
- Replaces generic spinner wheels with an expandable neo-brutalist **Process Timeline Card**.
- Visualizes discrete stages of the retrieval pipeline in real time:
  1. `Query parameters prepared` (Scoping verification, top-k, dense vs. hybrid)
  2. `Embedding generation` (Projecting query into latent vector manifold)
  3. `HNSW graph traversal` (Retrieving nearest neighbor chunks)
  4. `Cross-encoder reranking` (Scoring relevance and filtering noise)
  5. `Grounded synthesis` (Live generation of cited response)
- Displays execution metrics: elapsed processing time (e.g. `842ms`), generated token count, and active stage badges (`IN PROGRESS`, `OK`, `FAILED`).

### Granular Document Scoping & Slide Range Selection
- In the **Corpus Canvas**, documents are presented with metadata chips (chunks, status, timestamp).
- **Scope Flexibility**:
  - Tap a single PDF to restrict retrieval exclusively to that document.
  - Slide across multiple document cards to select a continuous range.
  - Clear selection to query the entire vector database.
- Dynamic query dispatch sends `document_ids: [...]` within the request payload, instructing the retrieval backend to apply strict metadata pre-filtering.

### Grounded Citations & Modal Attribution Sheets
- Inline references (e.g., `[1]`, `[2]`, `[1, 2]`) are extracted via regex and rendered as interactive **Attribution Chips**.
- Tapping a citation opens the **Evidence Modal Sheet**:
  - Document Title & ID
  - Page Number
  - Relevance Score / Similarity Metric
  - Extracted Chunk Snippet
  - Source verification badges

### Formatted Markdown & LaTeX Synthesis
- Responses are formatted using rich typographical hierarchy:
  - Header tags (`#`, `##`, `###`)
  - Formatted bulleted and numbered lists
  - Syntax-highlighted code blocks with monospaced styling
  - Tables and callouts
  - In-line and display mathematical notation rendered cleanly via KaTeX (`$x^2 + y^2 = r^2$`).

### Corpus Management & Multipart Ingest
- Integrated document upload workflow using `file_picker`.
- Transmits documents to `POST /documents` as `multipart/form-data`.
- Tracks real-time upload progress, chunking statistics, and persists ingested documents across sessions using `SharedPreferences`.

### Typewriter Boot Screen & Adaptive Icons
- **Typewriter Splash Screen**: Heroic neo-brutalist terminal header that types out `SYNQRA` character-by-character with a blinking vermilion block cursor (`▌`), followed by a typed subtitle line and live boot telemetry.
- **Zero Blurry Bitmaps**: All graphics rendered via crisp vector canvas drawing and high-resolution typography.
- **Android 12+ Adaptive Icons**: Full support for monochrome themed icons (`adaptive_monochrome.png`), vector foregrounds, and launch window background sync (`#F5EFE6`).

### Latent Matrix & Diagnostics Canvases
- **Matrix Overview**: 1536-dimensional embedding space diagnostics, vector dispersion metrics, and cluster health.
- **Graph Telemetry**: Milvus / HNSW graph indices, cache hit rates, BM25 keyword index status, and memory footprints.

---

## 4. Backend API Contract

SYNQRA integrates with FastAPI-based RAG engines. The primary endpoints are outlined below:

### 1. Ingestion (`POST /documents`)
Uploads a document for parsing, chunking, and vector indexing.

- **Content-Type**: `multipart/form-data`
- **Field**: `file` (PDF document)
- **Response (`201 Created`)**:
  ```json
  {
    "document_id": "doc-8f3a12bc",
    "filename": "quantum_error_correction.pdf",
    "chunks": 42
  }
  ```

### 2. Streaming Retrieval (`POST /questions/stream`)
Dispatches a natural language query for streaming token generation.

- **Content-Type**: `application/json`
- **Request Body**:
  ```json
  {
    "question": "Explain topological surface codes.",
    "document_ids": ["doc-8f3a12bc"],
    "top_k": 5,
    "dense_only": false
  }
  ```
- **SSE Stream Protocol (`text/event-stream`)**:
  ```
  event: status
  data: {"step": "vector_search", "message": "Searching HNSW index for top 5 candidates...", "done": false}

  event: answer_chunk
  data: {"chunk": "Topological surface codes are "}

  event: citations
  data: {"citations": [{"id": 1, "document_id": "doc-8f3a12bc", "filename": "quantum_error_correction.pdf", "page": 4, "text": "Surface codes arrange physical qubits in a 2D square lattice..."}]}

  event: done
  data: {}
  ```

### 3. Fallback Non-Streaming Retrieval (`POST /questions`)
Invoked automatically if streaming is unavailable or disabled.

- **Content-Type**: `application/json`
- **Response (`200 OK`)**:
  ```json
  {
    "answer": "Topological surface codes arrange physical qubits on a 2D square lattice [1].",
    "citations": [
      {
        "id": 1,
        "document_id": "doc-8f3a12bc",
        "filename": "quantum_error_correction.pdf",
        "page": 4,
        "text": "Surface codes arrange physical qubits in a 2D square lattice..."
      }
    ]
  }
  ```

---

## 5. Design System & Visual Identity

SYNQRA uses a custom design token system implemented in `lib/core/theme/app_theme.dart`.

| Design Token | Parchment (Light) | Nocturne (Dark) | Usage |
|---|---|---|---|
| **Background** | `#F5EFE6` (Warm Parchment) | `#121110` (Obsidian) | Root scaffold background |
| **Surface** | `#EDE6DB` (Toned Vellum) | `#1C1A18` (Smoked Charcoal) | Cards, terminal windows, docks |
| **Borders** | `#1A1918` (Solid Charcoal) | `#3D3833` (Warm Carbon) | High-contrast 1.5px - 2.5px borders |
| **Accent** | `#FF4C29` (Vermilion) | `#FF5C38` (Vivid Vermilion) | Buttons, blinking cursors, status tags |
| **Text Primary** | `#121110` (Ink Black) | `#F2ECE4` (Parchment Cream) | Headlines, body text, data values |
| **Text Muted** | `#6B655E` (Archive Muted) | `#9E978F` (Nocturne Dust) | Telemetry codes, labels, captions |

### Typography Hierarchy
- **Header Slab / Display**: `GoogleFonts.newsreader()` / `GoogleFonts.syne()` — High-contrast editorial authority.
- **Code & Telemetry**: `GoogleFonts.spaceMono()` / `GoogleFonts.jetBrainsMono()` — Fixed-width alignment for telemetry readouts and terminal prompts.
- **Tactile Shadows**: Hard-edge brutalist offset shadows (`boxShadow: [BoxShadow(offset: Offset(3, 3), blurRadius: 0)]`).

---

## 6. Directory Structure

```text
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart            # Palette tokens, typography, ThemeData factory
│   └── utils/
│       ├── citation_parser.dart      # Regex parsing for inline [1], [2] citation markers
│       └── smooth_page_route.dart    # Custom slide/fade transition curve
├── data/
│   ├── constants.dart                # Global application constants
│   └── repositories/
│       ├── corpus_repository.dart    # Multipart PDF upload, local manifest persistence
│       ├── profile_settings_repository.dart # SharedPreferences settings repository
│       ├── rag_stream_repository.dart# SSE client connection, streaming parser, fallback
│       └── mock_*.dart               # Telemetry, graph, and vector inspection stubs
├── domain/
│   ├── models/
│   │   ├── citation.dart             # Grounded citation entity
│   │   ├── corpus.dart               # DocumentEntry, chunk metadata
│   │   ├── profile_settings.dart     # Endpoint URLs, nocturne mode, retrieval params
│   │   ├── rag_process_step.dart     # Step telemetry model (ID, status, duration)
│   │   ├── rag_stream_event.dart     # Sealed stream event hierarchy
│   │   └── telemetry.dart            # System health and index statistics
│   └── repositories/
│       ├── i_corpus_repository.dart
│       ├── i_profile_settings_repository.dart
│       ├── i_rag_stream_repository.dart
│       └── i_telemetry_repository.dart
├── presentation/
│   ├── providers/
│   │   ├── corpus_provider.dart      # Document selection state, upload status
│   │   ├── rag_session_provider.dart # Stream state machine, token accumulator, step tracker
│   │   ├── settings_provider.dart    # User clearance, endpoint configs, dark mode
│   │   └── telemetry_provider.dart   # Polled telemetry and matrix metrics
│   ├── screens/
│   │   ├── archival_splash_screen.dart # Kinetic typewriter boot animation
│   │   ├── chunk_inspector_screen.dart # Deep chunk inspection view
│   │   ├── clearance_auth_screen.dart  # Biometric and passkey auth gate
│   │   ├── graph_telemetry_screen.dart # Knowledge graph & index health
│   │   ├── ingestion_screen.dart       # Corpus management and PDF upload canvas
│   │   ├── matrix_overview_screen.dart # 1536-D vector space distribution
│   │   ├── query_canvas_screen.dart    # Main RAG query input, telemetry, and answer canvas
│   │   ├── root_shell_screen.dart      # 4-canvas navigation container with MiniDock
│   │   └── user_profile_screen.dart    # Clearance credentials and settings editor
│   └── widgets/
│       ├── brutalist_container.dart    # Reusable neo-brutalist container with offset shadow
│       ├── citation_badge.dart         # Interactive [n] badge with click-to-preview
│       ├── evidence_bottom_sheet.dart  # Draggable modal attribution preview
│       ├── formatted_answer_view.dart  # Markdown & KaTeX answer renderer
│       ├── mini_dock.dart              # Tactile bottom navigation bar
│       └── process_timeline_card.dart  # Agentic thought progress timeline
└── main.dart                         # App initialization, Provider binding, Root widget
```

---

## 7. Getting Started

### Prerequisites
- **Flutter SDK**: `^3.7.0`
- **Dart SDK**: `^3.7.0`
- **Android Studio / Android SDK**: Platform API 34+
- **Physical Device or Android Emulator** (Google Pixel 8 Pro recommended)
- **Local Python RAG Backend** (FastAPI running on port `8000`)

### Installation & Dependency Resolution

Clone the repository and install all dependencies:

```bash
git clone https://github.com/your-username/Flutter-Project.git
cd Flutter-Project

# Fetch all Dart dependencies
flutter pub get
```

### Local Backend & ADB Port Forwarding

When running on a physical Android device connected over USB, forward host port `8000` so the mobile app can reach `http://localhost:8000`:

```bash
# Check connected Android devices
adb devices

# Reverse port forwarding for local FastAPI server
adb reverse tcp:8000 tcp:8000
```

Verify your backend is accessible:
```bash
curl http://localhost:8000/documents
```

### Building & Deploying

#### Run in Debug Mode
```bash
flutter run
```

#### Build Debug APK
```bash
flutter build apk --debug
```

#### Install Directly via ADB
```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Force-stop and launch main activity
adb shell am force-stop com.example.my_flutter_proj_dq
adb shell am start -n com.example.my_flutter_proj_dq/.MainActivity
```

---

## 8. Testing & Verification

SYNQRA maintains a comprehensive suite of unit and widget tests covering stream parsing, state management, citation resolution, and UI interactions:

```bash
# Run static code analysis (0 warnings expected)
flutter analyze

# Execute full automated test suite (39/39 passing)
flutter test
```

### Test Coverage Breakdown
- `test/citation_parser_test.dart`: Validates regex extraction of inline citation tokens `[1]`, `[2, 3]` and mapping to grounded evidence records.
- `test/rag_stream_repository_test.dart`: Mocks SSE HTTP event streams, chunk buffers, cancellations, error status codes, and non-streaming fallback.
- `test/rag_session_provider_test.dart`: Verifies state machine transitions (`idle` → `streaming` → `completed`), token counters, and step progression.
- `test/corpus_selection_test.dart`: Tests tap and slide range selection across document entries and query scoping payload generation.
- `test/corpus_repository_test.dart`: Tests multipart file serialization, preference caching, and manifest decoding.
- `test/formatted_answer_test.dart`: Tests KaTeX rendering, markdown formatting, and citation click handlers.
- `test/splash_screen_test.dart`: Validates terminal typewriter character-by-character timing, cursor blinking, skip gesture, and navigation trigger.

---

## 9. Configuration & Settings

Configuration parameters can be tuned in `SettingsProvider` or interactively adjusted within the app's **User Profile Screen**:

| Setting | Default | Description |
|---|---|---|
| `sseEndpoint` | `http://localhost:8000/questions/stream` | Primary Server-Sent Events endpoint |
| `documentsUrl` | `http://localhost:8000/documents` | Multipart document ingest endpoint |
| `topK` | `5` | Maximum number of vector chunks retrieved |
| `enableDenseOnly` | `false` | Disables BM25 sparse hybrid retrieval when `true` |
| `similarityThreshold`| `0.75` | Minimum cosine similarity cutoff for context chunks |
| `isNocturneMode` | `false` | Toggles between Warm Parchment and Nocturne Dark themes |
| `useOfflineSimulation`| `false` | Generates realistic mock SSE events for offline demonstrations |

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
