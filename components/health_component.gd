extends Node
class_name HealthComponent

signal health_changed(current_health, max_health)
signal died

@export var max_hp: int = 3
var current_hp: int
var is_invulnerable: bool = false # <--- Флаг неуязвимости

func _ready():
	current_hp = max_hp
	health_changed.emit(current_hp, max_hp)

func take_damage(amount: int):
	if is_invulnerable:
		return # Если неуязвим — игнорируем урон
		
	current_hp -= amount
	current_hp = max(0, current_hp)
	health_changed.emit(current_hp, max_hp)
	
	if current_hp <= 0:
		died.emit()

func heal(amount: int):
	current_hp += amount
	current_hp = min(current_hp, max_hp)
	health_changed.emit(current_hp, max_hp)
