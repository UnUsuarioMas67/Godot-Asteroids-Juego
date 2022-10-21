extends "res://nonplayable/scripts/NonPlayable.gd"

func _on_Timer_timeout():
	queue_free()

func destroy():
	queue_free()
