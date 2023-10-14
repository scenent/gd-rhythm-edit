extends Node2D

static func delete_children(node):
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

var vel : Vector2 = Vector2.ZERO

var noteArray : Array = [
	[],
	[],
	[],
	[]
]

var song_pos : float = 0.0

func hasNoteInfo(channel : int, value : float) -> int:
	for i in range(0, len(noteArray[channel])):
		if (noteArray[channel][i][0] == value):
			return i
	return -1

func _ready():
	OS.center_window()

func _process(delta):
	if $audio.playing:
		$pointer.position.y = 720 - ((song_pos / 0.1) * 20.0)
		song_pos = $audio.get_playback_position()
	vel = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		vel.x = 1
	if Input.is_action_pressed("ui_left"):
		vel.x = -1
	if Input.is_action_pressed("ui_up"):
		vel.y = -1
	if Input.is_action_pressed("ui_down"):
		vel.y = 1
	$cam.position += vel * delta * 1000


func _on_import_pressed():
	$layer/file_dialog.show_hidden_files = true
	$layer/file_dialog.show()

func _on_file_dialog_file_selected(path):
	delete_children($buttons1)
	delete_children($buttons2)
	delete_children($buttons3)
	delete_children($buttons4)
	$audio.stream = load(path)
	$bg.rect_size.y = (($audio.stream.get_length() / 0.1)) * 20.0
	var index = 0.0
	var step = 20.0
	var ID_max = ($audio.stream.get_length() / 0.1)
	var ID = 0
	while index <= $bg.rect_size.y:
		for i in range(0, 4):
			var btn = Button.new()
			btn.rect_position = Vector2(300 + (i * 100), 720 - index - 20)
			btn.rect_size = Vector2(100, 20)
			btn.visible = true
			btn.theme = load("res://default.tres")
			btn.set_script(load("res://note_button.gd"))
			btn.ID = ID
			btn.channel = i
			get_node("buttons" + str(i + 1)).add_child(btn)
		ID += 1
		index += step

class Sorter:
	static func comparr(arr1 : Array, arr2 : Array) -> bool:
		return arr1[0] < arr2[0]

func _on_note_button_pressed(btn : Object, channel : int, ID : int, type : int):
	var sec = ID / 10.0
	if (hasNoteInfo(channel, sec) != -1):
		noteArray[channel].remove(hasNoteInfo(channel, sec))
		btn.text = ""
	else:
		noteArray[channel].append([sec, type])
	noteArray[channel].sort_custom(Sorter, "comparr")


func _on_export_pressed():
	var result : Array = [[], [], [], []]
	for i in range(0, 4):
		var k = 0
		while k < len(noteArray[i]):
			if noteArray[i][k][1] == 0:
				result[i].append([noteArray[i][k][0]])
				k += 1
			elif noteArray[i][k][1] == 1:
				var longnote_start : float = noteArray[i][k][0]
				var longnote_length : float = noteArray[i][k+1][0] - longnote_start
				result[i].append([longnote_start, longnote_length])
				k += 2
	OS.set_clipboard(String(result))


func _on_play_pressed():
	$audio.stop()
	$audio.play(0)

func _on_stop_pressed():
	$audio.stop()


func _on_play2_pressed():
	$audio.stop()
	$audio.play(song_pos)


func _on_rewind_pressed():
	$audio.stop()
	song_pos -= 0.1
	$pointer.position.y = 720 - ((song_pos / 0.1) * 20.0)

func _on_skip_pressed():
	$audio.stop()
	song_pos += 0.1
	$pointer.position.y = 720 - ((song_pos / 0.1) * 20.0)


func _on_speedm_pressed():
	$audio.stop()	
	if $audio.pitch_scale > 0.0:
		$audio.pitch_scale -= 0.1

func _on_speedp_pressed():
	$audio.stop()

	$audio.pitch_scale += 0.1
