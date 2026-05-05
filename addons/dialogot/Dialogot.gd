extends AudioStreamPlayer
class_name ACVoiceBox

signal characters_sounded(characters)
signal finished_phrase()

# Loaded at runtime so paths resolve correctly wherever the plugin is installed.
var sounds: Dictionary = {}

@export var voice: VoiceProfile

var _remaining_sounds := []
var _pitch_effect: AudioEffectPitchShift

func _ready():
	var dir: String = get_script().resource_path.get_base_dir() + "/Sounds/"
	for s in ["a","b","c","d","e","f","g","h","i","j","k","l","m",
			  "n","o","p","q","r","s","t","u","v","w","x","y","z","th","sh"]:
		sounds[s] = load(dir + s + ".wav")

func _setup_bus():
	if voice == null:
		push_error("ACVoiceBox: no VoiceProfile assigned")
		return
	bus = voice.audio_bus
	var bus_idx := AudioServer.get_bus_index(voice.audio_bus)
	if bus_idx == -1:
		push_error("ACVoiceBox: bus '%s' not found." % voice.audio_bus)
		return
	for i in AudioServer.get_bus_effect_count(bus_idx):
		if AudioServer.get_bus_effect(bus_idx, i) is AudioEffectPitchShift:
			_pitch_effect = AudioServer.get_bus_effect(bus_idx, i)
			break
	if _pitch_effect == null:
		push_error("ACVoiceBox: no PitchShift effect on bus '%s'." % voice.audio_bus)

func play_string(in_string: String):
	_setup_bus()
	_remaining_sounds.clear()
	_parse_input_string(in_string)
	_play_loop()

func _play_loop():
	while _remaining_sounds.size() > 0:
		var symbol = _remaining_sounds.pop_front()
		emit_signal("characters_sounded", symbol["characters"])

		match symbol["sound"]:
			'':
				continue
			' ':
				await get_tree().create_timer(voice.word_gap / voice.speed).timeout
				continue
			'.':
				await get_tree().create_timer(voice.sentence_gap / voice.speed).timeout
				continue

		var desired_pitch := voice.base_pitch \
			+ (voice.pitch_range * randf()) \
			+ (voice.inflection_shift if symbol["inflective"] else 0.0)
		pitch_scale = voice.speed
		_pitch_effect.pitch_scale = desired_pitch / voice.speed
		stream = sounds[symbol["sound"]]
		play()
		await self.finished

	emit_signal("finished_phrase")

func _parse_input_string(in_string: String):
	for word in in_string.split(' '):
		_parse_word(word)
		_add_symbol(' ', ' ', false)

func _parse_word(word: String):
	var skip_char := false
	var is_inflective := word[-1] == '?'
	for i in range(len(word)):
		if skip_char:
			skip_char = false
			continue
		if i < len(word) - 1:
			var two_char := word.substr(i, 2).to_lower()
			if two_char in sounds:
				_add_symbol(two_char, word.substr(i, 2), is_inflective)
				skip_char = true
				continue
		var char_lower := word[i].to_lower()
		if char_lower in sounds:
			_add_symbol(char_lower, word[i], is_inflective)
		else:
			_add_symbol('', word[i], false)

func _add_symbol(sound: String, characters: String, inflective: bool):
	_remaining_sounds.append({
		"sound": sound,
		"characters": characters,
		"inflective": inflective
	})
