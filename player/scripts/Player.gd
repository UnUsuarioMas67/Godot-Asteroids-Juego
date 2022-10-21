# TODO - Set up invulnerability timer
extends KinematicBody2D

signal death

export(float) var max_speed = 800.0
export(float) var rotation_speed = 6.0
export(float) var acceleration = 1500.0
export(float) var space_friction = 1.2

export(PackedScene) var Projectile
export(PackedScene) var ExplosionScene

export(bool) var can_die = true

var velocity := Vector2.ZERO
var thrust_strength: float
var rotation_dir: float

var can_shoot := true
var is_invincible := false
var is_dead := false


func _ready():
	if Projectile == null:
		can_shoot = false

	$Thrust.visible = false


func _process(_delta):
	if thrust_strength != 0 && !is_dead:
		$ThrustAnimation.play("thrust")
		$ThrustParticles.emitting = true
		if !$ThrustSound.playing:
			$ThrustSound.play()
	else:
		$Thrust.visible = false
		$ThrustAnimation.stop()
		$ThrustParticles.emitting = false
		$ThrustSound.stop()


func _physics_process(delta):
	if is_dead:
		return

	thrust_strength = Input.get_action_strength("move_forward")
	rotation_dir = Input.get_axis("steer_left", "steer_right")

	velocity += Vector2(thrust_strength * acceleration * delta, 0).rotated(rotation)
	velocity.x = clamp(velocity.x, -max_speed, max_speed)
	velocity.y = clamp(velocity.y, -max_speed, max_speed)

	velocity = lerp(velocity, Vector2.ZERO, space_friction * delta)

	if abs(velocity.x) <= 0.1:
		velocity.x = 0
	if abs(velocity.y) <= 0.1:
		velocity.y = 0

	if Input.is_action_pressed("shoot") && can_shoot:
		shoot()

	rotation += rotation_speed * rotation_dir * delta
	velocity = move_and_slide(velocity)


func shoot():
	var bullet = Projectile.instance()
	bullet.add_to_group("player")

	bullet.rotation = rotation
	bullet.velocity = Vector2(bullet.speed, 0).rotated(rotation)

	get_parent().add_child(bullet)
	bullet.position = $BulletPosition.global_position
	$ShootSound.play()

	can_shoot = false
	$ShootTimer.start()


func _on_ShootTimer_timeout():
	can_shoot = true


func _on_Hitbox_area_entered(area: Area2D):
	if !area.is_in_group("player"):
		print("Player collided with: " + str(area))
		if can_die && !is_invincible:
			die()


func die():
	emit_signal("death")
	$CollisionPolygon2D.set_deferred("disabled", true)
	$PlayerHitbox/CollisionPolygon2D.set_deferred("disabled", true)
	$ShootTimer.stop()
	hide()
	explode()
	is_dead = true


func explode():
	var explosion = ExplosionScene.instance()

	explosion.explosion_size = 0

	explosion.position = global_position
	get_parent().add_child(explosion)


func respawn(pos: Vector2):
	global_position = pos
	rotation = 0
	velocity = Vector2.ZERO
	$CollisionPolygon2D.set_deferred("disabled", false)
	$PlayerHitbox/CollisionPolygon2D.set_deferred("disabled", false)
	can_shoot = true
	is_dead = false
	show()
	become_invincible()


func become_invincible():
	is_invincible = true
	$AnimationPlayer.play("RESET")
	$AnimationPlayer.play("blink")
	$InvincibilityTimer.start()


func _on_InvincibilityTimer_timeout() -> void:
	show()
	$AnimationPlayer.play("pulse")
	is_invincible = false
