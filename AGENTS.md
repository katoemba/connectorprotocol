
# AGENTS.md

## Project Overview
This is a Swift based protocol for network-based players (e.g. MPD, OpenHome, Sonos-like systems).
It does NOT play audio locally. It controls external players over the network.

Targets:
- iOS 18+ (focus: iOS 26)
- iPadOS 18+ (focus: iPadOS 26)
- macOS 15+ (focus: macOS 26)

Primary frameworks:
- async/await (preferred)

Language:
- Target Swift 6

---

## Core Principles

1. **Controller, not player**
   - Never introduce local playback unless explicitly requested
   - All playback actions must go through the network player abstraction

2. **Async-first**
   - Prefer `async/await` over Combine
   - Only use Combine where clearly beneficial

3. **Performance matters**
   - Avoid blocking the main thread (especially for network calls)

---

## Architecture Guidelines

### Networking
- Use structured concurrency (`Task`, `async let`, etc.)

### Models
- Prefer value types (`struct`) unless reference semantics are required
- Use `@Observable` (Swift 5.9+) instead of `ObservableObject` when possible

---

## Concurrency Rules

- Never block the main thread
- Network calls should be:
  - async
  - cancellable where possible

---

## Code Style

- Follow Swift API Design Guidelines
- Use clear, descriptive names
- Avoid abbreviations unless widely understood

### Example naming
- ✅ `loadAlbums()`
- ❌ `getAlb()`

---

## Music Domain Rules

- The protocol controls:
  - playback (play/pause/skip)
  - queue management
  - browsing (albums, artists, playlists)

- The protocol does NOT:
  - decode audio
  - manage local playback buffers

---

## What to Avoid

- Do not introduce:
  - unnecessary third-party dependencies
  - complex abstractions without clear benefit

- Do not:
  - duplicate networking logic

---

## Testing & Debugging

- Prefer small, testable units
- Add logging for network interactions where useful
- Avoid excessive logging in production code

---

## Notes for Agents

- Be concise in code changes
- Do not refactor unrelated code
- Respect existing architecture
- If unsure: extend, don’t rewrite
