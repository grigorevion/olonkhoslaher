extends CharacterBody2D
class_name Entity

enum State { IDLE, RUN, JUMP, PATROL, ALERT, CHASE, RETURN, REPOSITION, ATTACK, DASH }

var state_machine: Node = null
var knockback_timer: float = 0.0
var direction: int = 1

func take_damage(_amount: int, _knockback: float = 0.0) -> void:
	pass

func set_facing(_dir: int) -> void:
	pass

func play_animation(_anim_name: String) -> void:
	pass
