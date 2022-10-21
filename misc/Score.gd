extends Node

signal score_updated
var value: int

signal new_high_score
var new_value: int

enum ObjectFactor { ASTEROID = 50, UFO = 125 }

enum SizeFactor { SMALL = 4, MEDIUM = 2, LARGE = 1 }

var current_score := 0
var highest_score := 0


func get_and_sum(object: Node2D):
	var type_factor
	var size_factor

	if object.is_in_group("asteroid"):
		type_factor = ObjectFactor.ASTEROID

		if object.scale.x == 1:
			size_factor = SizeFactor.LARGE
		elif object.scale.x >= 0.5:
			size_factor = SizeFactor.MEDIUM
		else:
			size_factor = SizeFactor.SMALL

	if object.is_in_group("ufo"):
		type_factor = ObjectFactor.UFO

		if object.scale.x == 1:
			size_factor = SizeFactor.MEDIUM
		else:
			size_factor = SizeFactor.SMALL

	current_score += type_factor * size_factor
	value = current_score
	emit_signal("score_updated", value)
	# print("Current Score: " + str(current_score))


func update_highest_score():
	if current_score > highest_score:
		highest_score = current_score

	new_value = highest_score
	emit_signal("new_high_score", new_value)
	# print("Highest Score: " + str(highest_score))


func reset():
	current_score = 0
