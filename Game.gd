# TODO - HUD
# TODO - Game Over Screen
# TODO - Starting Screen
extends Node2D

export(PackedScene) var AsteroidScene
export(PackedScene) var UfoScene

var level := 1
var max_asteroid_amount = Global.base_asteroid_amount
var max_ufo_amount = Global.base_ufo_amount
var lives = Global.starting_lives


func _ready():
	randomize()
	Score.connect("score_updated", $Hud, "update_score")
	Score.connect("new_high_score", $Hud, "update_high_score")

	Score.update_highest_score()
	Score.reset()


func _process(_delta):
	if Input.is_action_just_pressed("start_game"):
		begin_game()

	# if Input.is_action_just_pressed("spawn_asteroid"):
	# 	var asteroid = AsteroidScene.instance()
	# 	spawn_at_position(asteroid, get_global_mouse_position())
	# if Input.is_action_just_pressed("spawn_ufo"):
	# 	var ufo = UfoScene.instance()
	# 	spawn_at_position(ufo, get_global_mouse_position())


func begin_game():
	$Hud.switch_mode()
	$Player.respawn($StartPosition.position)
	$Hud.update_lives(lives)

	$StartTimer.start()


func _on_StartTimer_timeout():
	$UfoTimer.start()
	for _a in range(max_asteroid_amount):
		spawn_asteroid()


func spawn_asteroid():
	var asteroid = AsteroidScene.instance()
	asteroid.add_to_group("naturally spawned asteroid")
	asteroid.connect("destroyed", self, "_on_Asteroid_destroyed")
	asteroid.connect("split", self, "_on_Asteroid_split")

	var spawn_location = $AsteroidSpawn/SpawnLocation
	spawn_location.unit_offset = randf()

	add_child(asteroid)
	asteroid.position = spawn_location.global_position


func _on_UfoTimer_timeout():
	for _u in range(max_ufo_amount - get_ufo_count()):
		spawn_ufo()


func spawn_ufo():
	var ufo = UfoScene.instance()
	ufo.add_to_group("naturally spawned ufo")
	ufo.connect("destroyed", self, "_on_UFO_destroyed")

	var spawn_location = $UfoSpawn/SpawnLocation
	spawn_location.unit_offset = randf()

	add_child(ufo)
	ufo.position = spawn_location.global_position


func spawn_at_position(object: Node, pos: Vector2):
	add_child(object)
	object.position = pos


func _on_UFO_destroyed(caller: Node2D, hit_by_player: bool):
	if hit_by_player:
		Score.get_and_sum(caller)

	if get_ufo_count() < max_ufo_amount && get_asteroid_count() > 0:
		$UfoTimer.start()
	else:
		next_level()


func _on_Asteroid_destroyed(caller: Node2D, hit_by_player: bool):
	if hit_by_player:
		Score.get_and_sum(caller)

	yield(get_tree(), "idle_frame")

	if get_asteroid_count() == 0 && get_ufo_count() == 0:
		next_level()


func _on_Asteroid_split(child_asteroids: Array):
	for a in child_asteroids:
		a.connect("destroyed", self, "_on_Asteroid_destroyed")
		a.connect("split", self, "_on_Asteroid_split")
		a.add_to_group("naturally spawned asteroid")


func get_ufo_count():
	var ufos = get_tree().get_nodes_in_group("naturally spawned ufo")

	for u in ufos:
		if u.is_queued_for_deletion():
			ufos.erase(u)

	return ufos.size()


func get_asteroid_count() -> int:
	var asteroids = get_tree().get_nodes_in_group("naturally spawned asteroid")

	for a in asteroids:
		if a.is_queued_for_deletion():
			asteroids.erase(a)

	return asteroids.size()


func next_level():
	level += 1
	$UfoTimer.stop()
	max_asteroid_amount = (
		Global.base_asteroid_amount
		+ Global.asteroid_increase_per_level * (level - 1)
	)
	if level % Global.levels_per_ufo_increase == 0:
		max_ufo_amount += 1
	$StartTimer.start()


func _on_Player_death():
	yield(get_tree().create_timer(2), "timeout")

	if lives > 0:
		lives -= 1
		$Player.respawn($StartPosition.position)
		$Hud.update_lives(lives)

	else:
		# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()
