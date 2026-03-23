# BetterGoldCounter

Lightweight WoW Classic addon that tracks gold changes and displays a live session counter with configurable behavior, style, and persistence.

## What It Tracks
- Current session delta in the floating frame.
- Daily history records saved per character.
- Multiple session scopes through clean frequency:
    - `SESSION`: resets on each login.
    - `DAILY`: tracks current day total.
    - `NEVER`: tracks all-time session total.

## Usage
- Addon loads automatically.
- Unlock the frame in options, then drag with left click to move it.
- Use position buttons (`^`, `v`, `<`, `>`) for 1-pixel adjustments.
- Open settings with `/bettergoldcounter`, `/bgc`, or by opening the addon settings category.

## Commands
- `/bettergoldcounter` or `/bgc`
- Subcommands:
    - `config`, `options`, `settings`: open addon settings
    - `clear`, `clear session`, `reset`, `reset session`: store current value into today record and reset active session counter
    - `history`: print current character history and total in chat
    - `wipe`: clear all session counters and all history records for current character

## Options
- Position:
    - Lock/Unlock frame
    - Drag-and-drop movement
    - Fine movement buttons (`^`, `v`, `<`, `>`)
- Appearance:
    - Backdrop on/off
    - Font size
    - Font alignment (`LEFT`, `CENTER`, `RIGHT`)
    - Dynamic width toggle
    - Static width value
- Session behavior:
    - Auto clean frequency (`SESSION`, `DAILY`, `NEVER`)
- Fade:
    - Enable/Disable fade
    - Fade out opacity
    - Fade in opacity
    - Fade duration

## Data Storage
- Global settings: `BetterGoldCounterDB`
- Per-character data: `BetterGoldCounterPCDB`
    - Includes session values, last login date, clean frequency, and daily records

## Compatibility
- Interface version: `20505` (defined in TOC)
- Localized for `enUS`, `esES`, and `esMX`

## License
- GPL-3.0 - see LICENSE.