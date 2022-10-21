extends Node2D

export (int) var offset = 100

onready var screen_size := get_viewport_rect().size
onready var wrap_parent = get_parent()

func _process(_delta):
    if wrap_parent == null:
        return
    
    wrap_parent.global_position.x = wrapf(wrap_parent.global_position.x, 0 - offset, screen_size.x + offset)
    wrap_parent.global_position.y = wrapf(wrap_parent.global_position.y, 0 - offset, screen_size.y + offset)
    
