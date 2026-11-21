# Hidden Features (WoW: Forever)

A switchboard for built-in client features that WoW: Forever runs on the retail engine but ships turned off and leaves out of the options menu. Each switch flips a console variable (CVar), the same as typing `/console <cvar> <value>`.

## Install

Copy the `HiddenFeatures` folder into:

```
World of Warcraft\_forever_\Interface\AddOns\
```

The TOC targets interface `16001` (Forever 1.60.1). After a client patch, if the addon shows as out of date, update `## Interface` in `HiddenFeatures.toc` or tick "Load out of date AddOns".

## Use

- `/hf` opens the panel. You can also find it under Esc → Options → AddOns → Hidden Features.
- Tick a box to turn a feature on. Hover a row to see its CVar, current value and notes.
- Greyed rows mean that CVar doesn't exist in your client build or is locked by the client.
- **Re-apply on login** (on by default) puts your choices back after the server or character profile resets them.
- **Restore originals** puts every CVar the addon changed back to its value before you first touched it.
- **Hide experimental warning** stops the ActionCam "experimental feature" popup.

### Slash commands

| Command | What it does |
| --- | --- |
| `/hf list` | Print every feature and its state |
| `/hf on <cvar>` / `/hf off <cvar>` | Toggle a feature from the catalog |
| `/hf get <cvar>` | Show any CVar's current and default value |
| `/hf set <cvar> <value>` | Set any CVar. It is remembered, re-applied on login, and covered by restore |
| `/hf restore` | Restore every changed CVar |

## Language

On any Chinese client (`zhCN`, or `zhTW`, which covers Taiwan and Hong Kong), the panel, tooltips, chat messages and feature list are shown in Simplified Chinese. Every other client language uses English. Translations are in `HiddenFeatures/Locale.lua`.

## Adding features

Add an entry to `HiddenFeatures/Features.lua`:

```lua
{ cat = "Quality of Life", cvar = "someCVar", on = "1", off = "0",
  name = "Label", desc = "Tooltip text", reload = false },
```

If a CVar isn't in the client, its row is greyed out automatically, so listing one that might not exist is safe.

For Chinese, also add `F.someCVar = { "名称", "说明" }` in `Locale.lua`. Without it, the feature shows in English.
