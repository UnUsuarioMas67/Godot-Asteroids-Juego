extends Node2D

export(Color) var asteroid_color = Color.white
export(float) var asteroid_speed_modifier = 1.0
export(int) var base_asteroid_amount = 4
export(int) var asteroid_increase_per_level = 1

export(Color) var ufo_color = Color.white
export(float) var ufo_speed_modifier = 1.0
export(int) var base_ufo_amount = 1
export(int) var levels_per_ufo_increase = 5

export(int) var starting_lives = 2
