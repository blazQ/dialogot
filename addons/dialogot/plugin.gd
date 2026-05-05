@tool
extends EditorPlugin

const _BUS_NAME := "Voice"

func _enable_plugin() -> void:
	_ensure_voice_bus()
	add_autoload_singleton("DialogueManager", "res://addons/dialogot/DialogueManager.gd")

func _disable_plugin() -> void:
	remove_autoload_singleton("DialogueManager")

func _ensure_voice_bus() -> void:
	if AudioServer.get_bus_index(_BUS_NAME) != -1:
		return
	AudioServer.add_bus()
	var idx := AudioServer.bus_count - 1
	AudioServer.set_bus_name(idx, _BUS_NAME)
	AudioServer.add_bus_effect(idx, AudioEffectPitchShift.new())
	push_warning("[Dialogot] Added '%s' audio bus with PitchShift effect. Save your project to persist it." \
			% _BUS_NAME)
