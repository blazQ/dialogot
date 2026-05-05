extends Node

func _ready():
	# In this example, we create a CharacterProfile programmatically and then set display name and voice.
	# In real game usage, we could create different CharacterProfiles as .tres resource files and assign them to the
	# characters.

	var giovanni := CharacterProfile.new()
	giovanni.display_name = "Giovanni"
	giovanni.voice = preload("res://VoiceProfiles/high_fast_voice.tres")

	var lucifero := CharacterProfile.new()
	lucifero.display_name = "Lucifero"
	lucifero.voice = preload("res://VoiceProfiles/deep_slow_voice.tres")

	var narratore := CharacterProfile.new()
	narratore.display_name = "Narratore"
	narratore.voice = preload("res://VoiceProfiles/standard_voice.tres")

	# We open the file containing the dialogue and we parse it.
	# Feasible for real game? Should we parse at runtine or once? How to parse once?

	var file := FileAccess.open("res://Dialogues/example.dialogue", FileAccess.READ)

	# Dialogue Parser requires knowing every character in the dialogue before loading it.
	var script := DialogueParser.parse(file.get_as_text(), {
		"GIOVANNI": giovanni,
		"LUCIFERO": lucifero,
		"NARRATORE": narratore,
	})
	DialogueManager.run_script(script)
