extends "res://nonplayable/scripts/NonPlayable.gd"

signal split
var child_asteroids: Array

export(float) var base_rotation_speed = 0.5
onready var rotation_speed := rand_range(-base_rotation_speed, base_rotation_speed)

var scene := load("res://nonplayable/Asteroid.tscn")


func _ready():
	set_body_color(Global.asteroid_color)
	velocity = (
		Vector2(rand_range(-speed, speed), rand_range(-speed, speed))
		* Global.asteroid_speed_modifier
	)
	rotation = rand_range(0, 2 * PI)


func _process(delta):
	rotation += rotation_speed * delta


func destroy():
	.destroy()

	if scale.x > 0.25:
		for _i in range(2):
			var asteroid = scene.instance()

			asteroid.position = global_position
			asteroid.scale = scale * 0.5
			asteroid.speed = speed * 2

			get_parent().call_deferred("add_child", asteroid)
			child_asteroids.append(asteroid)
		emit_signal("split", child_asteroids)

		if scale.x > 0.5:
			explode(2)
		else:
			explode(1)
	else:
		explode(0)


func _on_NonPlayable_area_entered(area: Area2D):
	if !area.is_in_group("asteroid"):
		._on_NonPlayable_area_entered(area)
		destroy()
