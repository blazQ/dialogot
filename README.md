# Dialogot

[![CI](https://github.com/blazQ/dialogot/actions/workflows/ci.yml/badge.svg)](https://github.com/blazQ/dialogot/actions/workflows/ci.yml)
[![Godot v4.6](https://img.shields.io/badge/Godot-v4.6-blue?logo=godot-engine)](https://godotengine.org/)
[![License: MIT](https://img.shields.io/github/license/blazQ/dialogot)](LICENSE)

An Animal Crossing–style phoneme voicebox and dialogue system for Godot 4. Each character speaks in a distinct synthesised voice by playing phoneme sounds per letter, driven by a simple plain-text `.dialogue` script format.

Inspired by [Equalo's animalese-generator](https://github.com/equalo-official/animalese-generator). Letter sounds taken from the same repo.

---

## Installation

### As a plugin (recommended)

1. Copy the `addons/dialogot/` folder into your game project's `addons/` folder.
2. In Godot: **Project → Project Settings → Plugins**, enable **Dialogot**.  
   This registers `DialogueManager` as an autoload singleton automatically.
3. Add a `Voice` audio bus in **Project → Project Settings → Audio → Buses** and attach an `AudioEffectPitchShift` effect to it. The bus name must match the `audio_bus` field on your `VoiceProfile` resources (default: `"Voice"`).

### Standalone (running the example)

Open the project directly in Godot. `DialogueManager` is already registered as an autoload in `project.godot` and the example scene is set as the main scene.

---

## Dialogue format

Dialogue is written in plain `.dialogue` text files. To make them visible and editable in the Godot editor, add `dialogue` to **Editor → Editor Settings → Docks → FileSystem → Textfile Extensions**.

```text
# Lines starting with # are comments.

[CHARACTER_NAME]
This is a line of dialogue.

[OTHER_CHARACTER auto_advance=true delay=1.5]
This line advances automatically after 1.5 seconds.
It supports [wave]BBCode[/wave] effects and [b]bold[/b] text.
```

- Each `[NAME]` header starts a new dialogue line.
- `auto_advance=true` skips waiting for player input.
- `delay=<seconds>` sets how long to wait before auto-advancing (default `0.5`).
- Blank lines between paragraphs are ignored.
- Unknown character names produce a speakerless line (no crash).

---

## Setup

### 1. Create VoiceProfile resources

A `VoiceProfile` is a `.tres` resource that controls how a character sounds. Create one via **Inspector → New Resource → VoiceProfile**, or duplicate one from `addons/dialogot/VoiceProfiles/`.

| Property | Description |
| --- | --- |
| `base_pitch` | Base pitch multiplier |
| `pitch_range` | Random pitch variance per phoneme |
| `inflection_shift` | Extra pitch added on questions (`?`) |
| `speed` | Playback speed |
| `word_gap` | Pause between words (seconds) |
| `sentence_gap` | Pause after sentence-ending punctuation (seconds) |
| `audio_bus` | Name of the audio bus to use (must have a PitchShift effect) |

### 2. Create CharacterProfile resources

A `CharacterProfile` is a `.tres` resource that binds a display name, portrait texture, and voice to a character.

```gdscript
var giovanni := CharacterProfile.new()
giovanni.display_name = "Giovanni"
giovanni.portrait = preload("res://assets/giovanni_portrait.png")
giovanni.voice = preload("res://voices/giovanni.tres")
```

Or create them as `.tres` files in the inspector and preload them.

### 3. Parse and run a dialogue script

```gdscript
var file := FileAccess.open("res://dialogues/intro.dialogue", FileAccess.READ)
var script := DialogueParser.parse(file.get_as_text(), {
	"GIOVANNI": preload("res://characters/giovanni.tres"),
	"LUCIFERO": preload("res://characters/lucifero.tres"),
})
DialogueManager.run_script(script)
```

### 4. Add a dialogue box to your scene

Instance `addons/dialogot/DialogueUI.tscn` into your scene. It connects to `DialogueManager` automatically and handles display, voicing, and input.

Player advances dialogue with the `ui_accept` action (default: `Enter` / `Space`). Pressing it mid-line skips to the end of the current line; pressing it again advances to the next.

---

## DialogueManager signals

```gdscript
DialogueManager.dialogue_started          # emitted when run_script() is called
DialogueManager.dialogue_finished         # emitted after the last line
DialogueManager.line_started(line)        # emitted at the start of each DialogueLine
DialogueManager.line_finished(line)       # emitted at the end of each DialogueLine
```

---

## Customising the dialogue box

### Font

The dialogue box uses Godot's Theme system. Assign a custom `Theme` resource to the `DialogueUI` Control node (or to individual child nodes) in the inspector. Font overrides on `NameLabel` (a `Label`) and `TextLabel` (a `RichTextLabel`) follow standard Godot theme property overrides.

### Box style

The visible panel is a `PanelContainer` named `Box` inside `DialogueUI.tscn`. To restyle it, instance the scene, select `Box` in the inspector, and set a `theme_override_styles/panel` override with a `StyleBoxFlat` or `StyleBoxTexture`.

### Custom dialogue box layout

For a completely different layout, create a new scene whose root script extends `BaseDialogueBox` and override `show_line(line: DialogueLine)`:

```gdscript
extends BaseDialogueBox

func show_line(line: DialogueLine) -> void:
    $MyLabel.text = line.text
    # wire up your own Dialogot node, portrait, etc.
```

Use your scene instead of `DialogueUI.tscn`. `BaseDialogueBox` already handles `on_dialogue_started` / `on_dialogue_finished` (show/hide), so you only need to implement `show_line`.

---

## Credits

- Original concept and phoneme sounds: [Equalo](https://github.com/equalo-official/animalese-generator)
- Godot 4 port: [Alex](https://github.com/alexQueue)
