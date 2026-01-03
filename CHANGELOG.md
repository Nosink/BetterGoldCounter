# Changelog

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
- Slash commands: `/bettergoldcounter` and `/bgc` with `options|config|settings` and `reset` subcommands.
- English (enUS) and Spanish (esES/esMX) localization.

### Compatibility
- WoW Classic Era 1.15.8

### Notes
- Position persists across sessions; movement allowed when unlocked.
- Session reset stores the current session into today's record and zeroes the counter.