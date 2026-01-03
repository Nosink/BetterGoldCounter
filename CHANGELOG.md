# Changelog

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