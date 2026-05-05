extends Node

signal dialogue_started()
signal dialogue_finished()
signal line_started(line: DialogueLine)
signal line_finished(line: DialogueLine)

var _script: DialogueScript
var _current_index: int = 0
var _is_playing: bool = false

func run_script(dialogue_script: DialogueScript) -> void:
	_script = dialogue_script
	_current_index = 0
	_is_playing = true
	emit_signal("dialogue_started")
	emit_signal("line_started", _script.lines[_current_index])

func advance() -> void:
	if not _is_playing:
		return
	_current_index += 1
	if _current_index >= _script.lines.size():
		_is_playing = false
		emit_signal("dialogue_finished")
		return
	emit_signal("line_started", _script.lines[_current_index])

func finish_line() -> void:
	if not _is_playing:
		return
	emit_signal("line_finished", _script.lines[_current_index])

func current_line() -> DialogueLine:
	if not _is_playing:
		return null
	return _script.lines[_current_index]

func is_playing() -> bool:
	return _is_playing
