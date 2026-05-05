class_name DialogueParser
extends RefCounted

# Parses a .dialogue text file into a DialogueScript.
#
# Format:
#   [CHARACTER_NAME]
#   Line of dialogue text.
#
#   [OTHER_CHARACTER auto_advance=true delay=1.5]
#   Another line, supports [wave]BBCode[/wave] effects.
#
# Each paragraph (text block preceded by a [NAME] header) becomes one DialogueLine.
# The characters dict maps header names to CharacterProfile resources.
# Unknown names produce a DialogueLine with speaker = null (no crash, just no voice/portrait).

static func parse(text: String, characters: Dictionary = {}) -> DialogueScript:
	var script := DialogueScript.new()
	script.lines = []

	var current_name := ""
	var current_auto_advance := false
	var current_delay := 0.5
	var current_text_lines: Array[String] = []

	for raw_line in text.split("\n"):
		var line := raw_line.strip_edges()

		if line.begins_with("#"):
			continue

		if line.begins_with("[") and line.ends_with("]"):
			_flush(script, current_name, current_text_lines, current_auto_advance, current_delay, characters)
			current_text_lines = []
			var inner := line.substr(1, line.length() - 2)
			var parts := inner.split(" ", false)
			current_name = parts[0] if parts.size() > 0 else ""
			current_auto_advance = false
			current_delay = 0.5
			for i in range(1, parts.size()):
				var kv := parts[i].split("=")
				if kv.size() == 2:
					match kv[0]:
						"auto_advance":
							current_auto_advance = kv[1] == "true"
						"delay":
							current_delay = float(kv[1])
		elif line.is_empty():
			_flush(script, current_name, current_text_lines, current_auto_advance, current_delay, characters)
			current_text_lines = []
		else:
			current_text_lines.append(line)

	_flush(script, current_name, current_text_lines, current_auto_advance, current_delay, characters)
	return script


static func _flush(
	script: DialogueScript,
	name: String,
	text_lines: Array[String],
	auto_advance: bool,
	delay: float,
	characters: Dictionary
) -> void:
	if name.is_empty() or text_lines.is_empty():
		return
	var dl := DialogueLine.new()
	dl.speaker = characters.get(name, null)
	dl.text = " ".join(text_lines)
	dl.auto_advance = auto_advance
	dl.auto_advance_delay = delay
	script.lines.append(dl)
