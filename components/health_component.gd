extends Node
class_name HealthComponent

# Сигналы, которые сможет слушать любой объект в игре
signal health_changed(current_health, max_health)
signal died

@export var max_hp: int = 3

var current_hp: int

func _ready():
	# При старте восстанавливаем здоровье
	current_hp = max_hp
	# Испускаем сигнал, чтобы UI (полоска здоровья) сразу узнал о HP
	health_changed.emit(current_hp, max_hp)

func take_damage(amount: int):
	current_hp -= amount
	current_hp = max(0, current_hp) # Не даем уйти в минус
	health_changed.emit(current_hp, max_hp) # Сообщаем об изменении
	
	if current_hp <= 0:
		died.emit()

func heal(amount: int):
	current_hp += amount
	current_hp = min(current_hp, max_hp) # Не даем превысить максимум
	health_changed.emit(current_hp, max_hp)
