extends Node3D

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_up"):
		Engine.time_scale *= 2.0
		print("Fast forwarding time: " + str(Engine.time_scale).pad_decimals(2) + "x")
	elif event.is_action_pressed("ui_down"):
		Engine.time_scale /= 2.0
		print("Slowing down time: " + str(Engine.time_scale).pad_decimals(2) + "x")
	elif event.is_action_pressed("ui_cancel"):
		get_tree().quit()
