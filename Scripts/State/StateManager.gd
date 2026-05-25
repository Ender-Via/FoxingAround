class_name StateManager
extends Node

@onready var player = get_owner()
var currentState:State
var states:Dictionary = {}
func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name] = child
	currentState = states.get("Idle")
	currentState.enter(player)

func _process(delta: float) -> void:
	if currentState:
		currentState.process(delta,player)

func _transition_requested(new_state_name: String) -> void:
	var newState = states.get(new_state_name)
	if newState != currentState and currentState and newState:
		currentState.exit()
		currentState = newState
		currentState.enter(player)
