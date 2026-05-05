extends SceneTree

var _passed := 0
var _failed := 0

func _initialize() -> void:
	_test_dialogue_parser()
	print("\n%d passed, %d failed" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)

func _ok(condition: bool, message: String) -> void:
	if condition:
		print("  PASS  " + message)
		_passed += 1
	else:
		printerr("  FAIL  " + message)
		_failed += 1

func _test_dialogue_parser() -> void:
	print("== DialogueParser ==")

	var r: DialogueScript

	# Single block, unknown character
	r = DialogueParser.parse("[HERO]\nHello world", {})
	_ok(r.lines.size() == 1, "single block → one line")
	_ok(r.lines[0].text == "Hello world", "text is correct")
	_ok(r.lines[0].speaker == null, "unknown character → null speaker")
	_ok(r.lines[0].auto_advance == false, "auto_advance defaults to false")
	_ok(r.lines[0].auto_advance_delay == 0.5, "delay defaults to 0.5")

	# Known character
	var npc := CharacterProfile.new()
	npc.display_name = "NPC"
	r = DialogueParser.parse("[NPC]\nHi", {"NPC": npc})
	_ok(r.lines[0].speaker == npc, "known character assigned as speaker")

	# auto_advance and delay
	r = DialogueParser.parse("[NPC auto_advance=true delay=2.0]\nHi", {})
	_ok(r.lines[0].auto_advance == true, "auto_advance=true parsed")
	_ok(r.lines[0].auto_advance_delay == 2.0, "delay=2.0 parsed")

	# Comments ignored
	r = DialogueParser.parse("# this is a comment\n[HERO]\nHello", {})
	_ok(r.lines.size() == 1, "comment lines are ignored")

	# Multiline text joined with space
	r = DialogueParser.parse("[HERO]\nFirst line\nSecond line", {})
	_ok(r.lines[0].text == "First line Second line", "multiline text joined with space")

	# Multiple blocks
	r = DialogueParser.parse("[A]\nHello\n\n[B]\nWorld", {})
	_ok(r.lines.size() == 2, "two blocks → two lines")
	_ok(r.lines[1].text == "World", "second block text correct")

	# BBCode tags preserved
	r = DialogueParser.parse("[HERO]\n[wave]Hello[/wave]", {})
	_ok(r.lines[0].text == "[wave]Hello[/wave]", "BBCode tags preserved in text")

	# Empty input
	r = DialogueParser.parse("", {})
	_ok(r.lines.size() == 0, "empty input → no lines")
