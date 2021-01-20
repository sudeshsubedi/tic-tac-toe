extends Node

var is_occupied = false
var is_tick = false
var is_circle = false

func display():
	if is_tick:
		$Tick.show()
	elif is_circle:
		$Circle.show()

func setup():
	if is_tick:
		$Tick.hide()
	elif is_circle:
		$Circle.hide()
	is_occupied = false
	is_tick = false
	is_circle = false