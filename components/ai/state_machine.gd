extends Node

var parent: CharacterBody2D
var current_state = null
var states: Dictionary = {}

func add_state(state_name: String, state_node) -> void:
	states[state_name] = state_node
	state_node.state_machine = self

func transition_to(state_name: String) -> void:
	if not states.has(state_name):
		print("Ошибка: Состояние '", state_name, "' не найдено!")
		return
		
	if current_state:
		current_state.exit()
		
	current_state = states[state_name]
	current_state.enter()

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)
