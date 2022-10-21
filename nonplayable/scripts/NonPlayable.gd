extends Area2D

signal destroyed
var caller := self
var hit_by_player := false

export(float) var speed = 150.0
export(PackedScene) var ExplosionScene

var velocity := Vector2.ZERO


func _process(delta):
	position += velocity * delta


func destroy():
	queue_free()
	emit_signal("destroyed", caller, hit_by_player)


func _on_NonPlayable_area_entered(area: Area2D):
	if area.is_in_group("player") && !is_in_group("bullet"):
		hit_by_player = true

	if area.is_in_group("bullet"):
		area.destroy()


func set_body_color(color: Color):
	var lines = $Body.get_children()

	for l in lines:
		if l is Line2D:
			l.default_color = color


func explode(size: int):
	var explosion = ExplosionScene.instance()

	explosion.explosion_size = size

	explosion.position = global_position
	get_parent().add_child(explosion)
