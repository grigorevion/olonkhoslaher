extends Node
class_name HealthComponent

signal health_changed(current_health, max_health)
signal died

@export var max_hp: int = 3
var current_hp: int
var status_manager: Node = null

func _ready():
	current_hp = max_hp
	health_changed.emit(current_hp, max_hp)
	# Ищем компонент статусов у родителя (Игрока или Врага)
	status_manager = get_parent().get_node_or_null("StatusEffectComponent")

func take_damage(amount: int):
	# Если у нас есть компонент статусов и активна неуязвимость — игнорируем урон
	if status_manager and status_manager.has_effect("invulnerable"):
		return 
		
	current_hp -= amount
	current_hp = max(0, current_hp)
	health_changed.emit(current_hp, max_hp)
	
	if current_hp <= 0:
		died.emit()

func heal(amount: int):
	current_hp += amount
	current_hp = min(current_hp, max_hp)
	health_changed.emit(current_hp, max_hp)
