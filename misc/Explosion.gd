extends Particles2D

enum ExplosionSize { SMALL = 0, MEDIUM = 1, LARGE = 2 }

export(ExplosionSize) var explosion_size = ExplosionSize.MEDIUM


func _ready():
	match explosion_size:
		ExplosionSize.SMALL:
			scale *= 0.75
			$ExplosionSound.stream = preload("res://sound/bangSmall.wav")

		ExplosionSize.MEDIUM:
			$ExplosionSound.stream = preload("res://sound/bangMedium.wav")

		ExplosionSize.LARGE:
			scale *= 1.25
			$ExplosionSound.stream = preload("res://sound/bangLarge.wav")

	emitting = true
	$ExplosionSound.play()


func _on_AudioStreamPlayer_finished() -> void:
	yield(get_tree().create_timer(1), "timeout")
	call_deferred("queue_free")
