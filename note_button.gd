extends Button

var channel : int = 0
var ID : int = 0

signal note
signal longnote

func _enter_tree():
	self.set("custom_colors/font_color", Color.black)
	self.connect("note", get_parent().get_parent(), "_on_note_button_pressed", [])
	self.connect("longnote", get_parent().get_parent(), "_on_note_button_pressed", [])

func _gui_input(event : InputEvent):
	if event is InputEventMouseButton:
		if get_rect().has_point(get_global_mouse_position()) && event.button_index == BUTTON_LEFT and event.pressed:
			text = "------"
			emit_signal("note", self, channel, ID, 0)
		if get_rect().has_point(get_global_mouse_position()) && event.button_index == BUTTON_RIGHT and event.pressed:
			text = "||||||"
			emit_signal("longnote", self, channel, ID, 1)
		
