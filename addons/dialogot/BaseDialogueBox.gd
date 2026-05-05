class_name BaseDialogueBox
extends Control

signal advance_requested

func show_line(_line: DialogueLine) -> void:
	pass

func on_dialogue_started() -> void:
	show()

func on_dialogue_finished() -> void:
	hide()
