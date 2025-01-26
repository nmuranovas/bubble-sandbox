extends Node


signal die_signal
signal get_achievement(code: String)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_F:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
