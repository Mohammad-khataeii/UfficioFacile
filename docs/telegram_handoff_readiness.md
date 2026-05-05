# Telegram Handoff Readiness

This app does not yet ship a Telegram bot or Mini App integration.

The current Phase 5 readiness layer supports:
- creating a short handoff payload from a generated request
- storing safe summary metadata locally
- preparing future deep-link friendly payloads without exposing sensitive data

Planned future commands:
- `/start canone_rai`
- `/start cheap_electricity`
- `/start rent_problem`
- `/start change_doctor`

Recommended future handoff flow:
1. User starts a safe Telegram command.
2. Bot returns a short explanation and opens the mobile app or Mini App.
3. The app restores the selected procedure and suggested starter input.
4. The user reviews data locally before generating the Italian message.

Privacy guardrails:
- never send full generated request bodies automatically to Telegram
- never include codice fiscale or other sensitive identifiers in a handoff payload
- require explicit user confirmation before sharing any summary text
- keep official Italian request drafting inside the mobile app workspace

Suggested future payload shape:
- `procedureId`
- `title`
- `summary`
- `language`
- `suggestedInput`
- `createdAt`

Important:
- official request texts must still be reviewed inside the app
- Telegram integration must not imply official submission or government affiliation
