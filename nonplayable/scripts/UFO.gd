extends "res://nonplayable/scripts/NonPlayable.gd"

export(PackedScene) var Projectile
export(float) var radius_size = 400.0

var target: Node
var objects_within_radius := []

var x_directions := [Vector2.LEFT, Vector2.RIGHT]
var y_directions := [Vector2.UP, Vector2.DOWN]

var sizes := [1, 0.7]


func _ready():
	var ufo_size = sizes[round(rand_range(0, 1))]

	speed *= rand_range(0.85, 1.15) * (2 - ufo_size) * Global.ufo_speed_modifier
	set_body_color(Global.ufo_color)
	velocity = Vector2(
		speed * x_directions[round(rand_range(0, 1))].x,
		speed * y_directions[round(rand_range(0, 1))].y
	)

	scale *= ufo_size

	$DetectRadius/CollisionShape2D.shape.set_deferred("radius", radius_size)

	if ufo_size < 1:
		$SaucerSound.stream = preload("res://sound/saucerSmall.wav")
	else:
		$SaucerSound.stream = preload("res://sound/saucerBig.wav")

	$SaucerSound.play()


func _on_NonPlayable_area_entered(area: Area2D):
	if !area.is_in_group("ufo"):
		._on_NonPlayable_area_entered(area)
		destroy()


# Randomly change vertical direction
func _on_WaveTimer_timeout():
	velocity.y = speed * round(rand_range(-1, 1))
	$WaveTimer.wait_time = rand_range(1, 2.5)


func shoot():
	var bullet = Projectile.instance()
	bullet.add_to_group("ufo")

	# pick the closest target within radius if there isn't any then target the player
	target = pick_target()
	if target == null:
		target = get_parent().get_tree().get_nodes_in_group("player object")[0]

	var target_position = target.global_position
	var target_direction = global_position.direction_to(target_position)
	var direction_with_offset = target_direction.rotated(rand_range(-PI / 8, PI / 8))

	bullet.set_rotation(direction_with_offset.angle())
	bullet.velocity = bullet.speed * direction_with_offset.normalized()

	get_parent().add_child(bullet)
	bullet.position = global_position
	$ShootSound.play()


func _on_DetectRadius_area_entered(area: Area2D):
	objects_within_radius.append(area)
	# print(str(objects_within_radius))


func _on_DetectRadius_area_exited(area: Area2D):
	objects_within_radius.erase(area)
	# print(str(objects_within_radius))


func pick_target() -> Area2D:
	if objects_within_radius.size() == 0:
		return null

	var nearest_object = objects_within_radius[0]
	var nearest_object_distance = nearest_object.global_position.distance_to(global_position)

	for t in objects_within_radius:
		var curr_object_distance = t.global_position.distance_to(global_position)

		if curr_object_distance < nearest_object_distance:
			nearest_object = t
			nearest_object_distance = curr_object_distance

	return nearest_object


func _on_InvulnerabilityTimer_timeout():
	# changes collision mask to be able to collide with asteroids
	collision_mask = 0b111


func destroy():
	.destroy()

	if scale.x < 1:
		explode(0)
	else:
		explode(1)
