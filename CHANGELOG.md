# Changelog

## [1.1.0]  - 23/03/2026

### Added
- New session clean frequency modes: `SESSION`, `DAILY`, and `NEVER`.
- New `wipe` slash command to clear all stored session counters and character history.
- New position nudge controls in the options panel (`^`, `v`, `<`, `>`), moving the frame by 1 pixel.
- New font alignment option (`LEFT`, `CENTER`, `RIGHT`).
- Bundled local libraries: `LibEventBus-1.0`, `LibSharedVariables-1.0`, and `LibStub`.

### Changed
- Refactored internals into clearer modules for model, controller, view, and configuration.
- Reworked saved data model to separate global UI settings and per-character session data.
- Updated options panel with grouped controls for position, appearance, session behavior, width, and fade.
- Updated slash command handling to include aliases for opening settings and clearing session.

### Fixed
- Improved session restoration flow during login and UI reload.
- Improved daily rollover handling by storing daily record and resetting the proper session counters.
- Improved frame update consistency for size, alignment, fade alpha, and backdrop refresh after setting changes.


## [1.0.5] - 14/01/2026
Fixed installation processs
Added interface support for classic

---

## [1.0.4] - 14/01/2026
Work for TBC

---

## [1.0.3] - 2026-01-03
Fixed session restoration and currency count

### Fixed
- Garantied the database session to a nil value

--- 

## [1.0.2] - 2026-01-03
Fixed unti and record initializaction

### Fixed
- Removed guard clauses to ensure values

--- 

## [1.0.1] - 2026-01-03
Fixed fade error settings

### Fixed
- Hot fix to restore fade guard clause

---

## [1.0.0] - 2025-12-31
Initial release of BetterGoldCounter.

### Added
- Session gold tracker showing `+` or `-` with the current delta.
- Per-day record stored and keep in database.
- Options panel (Settings API) with:
	- Lock Frame, Backdrop toggle
	- Font Size (min 8)
	- Dynamic Width or Static Width (min 50)
	- Fade effect with configurable in/out opacity and duration
- Slash commands: `/bettergoldcounter` and `/bgc` with `options|config|settings`, `reset|clean` and `history` subcommands.
- Cross loadings creen keep session amount displayed.
- English (enUS) and Spanish (esES/esMX) localization.

### Compatibility
- WoW Classic Era 1.15.8

### Notes
- `WIP` LF display a floating box with history, more visual than chat. 

### Notes
- Position persists across sessions; movement allowed when unlocked.
- Session reset stores the current session into today's record and zeroes the counter.