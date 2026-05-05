extends BaseDialogueBox

@export var default_voice: VoiceProfile

var _voiced_chars: int = 0
var _bbcode_strip_regex: RegEx

@onready var voicebox: Dialogot = $Dialogot
@onready var text_label: RichTextLabel = $Box/MarginContainer/VBox/TextLabel
@onready var name_label: Label = $Box/MarginContainer/VBox/Header/NameLabel
@onready var portrait: TextureRect = $Box/MarginContainer/VBox/Header/Portrait

func _ready():
	_bbcode_strip_regex = RegEx.new()
	_bbcode_strip_regex.compile("\\[.+?\\]")

	hide()
	DialogueManager.dialogue_started.connect(on_dialogue_started)
	DialogueManager.dialogue_finished.connect(on_dialogue_finished)
	DialogueManager.line_started.connect(show_line)
	voicebox.characters_sounded.connect(_on_characters_sounded)
	voicebox.finished_phrase.connect(_on_finished_phrase)

func show_line(line: DialogueLine) -> void:
	_voiced_chars = 0
	text_label.bbcode_text = line.text
	text_label.visible_characters = 0

	if line.speaker:
		name_label.text = line.speaker.display_name
		portrait.texture = line.speaker.portrait
		voicebox.voice = line.speaker.voice if line.speaker.voice else default_voice
	else:
		name_label.text = ""
		portrait.texture = null
		voicebox.voice = default_voice

	# Strip BBCode tags before voicing so phoneme timing matches visible characters.
	var voiced_text: String = _bbcode_strip_regex.sub(line.text, "", true)
	voicebox.play_string(voiced_text)

func _on_characters_sounded(characters: String) -> void:
	_voiced_chars += characters.length()
	text_label.visible_characters = _voiced_chars

func _on_finished_phrase() -> void:
	text_label.visible_characters = -1
	DialogueManager.finish_line()
	var line: DialogueLine = DialogueManager.current_line()
	if line and line.auto_advance:
		await get_tree().create_timer(line.auto_advance_delay).timeout
		if DialogueManager.current_line() == line:
			DialogueManager.advance()

func _input(event: InputEvent) -> void:
	if not DialogueManager.is_playing():
		return
	if event.is_action_pressed("ui_cancel"):
		voicebox.stop()
		DialogueManager.skip()
		return
	if not event.is_action_pressed("ui_accept"):
		return
	if text_label.visible_characters != -1:
		# Skip to end of current line.
		voicebox.stop()
		text_label.visible_characters = -1
		DialogueManager.finish_line()
	else:
		emit_signal("advance_requested")
		DialogueManager.advance()
