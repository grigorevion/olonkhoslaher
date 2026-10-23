extends Node

# --- БАЗОВЫЕ СТАТЫ ---
var hp: int = 3
var max_hp: int = 3
var resources: int = 0 # Обычные ресурсы с абаасы

# --- УНИКАЛЬНЫЙ РЕСУРС С БОССА ---
# Называем его "rune", чтобы можно было легко поменять на "scale" или "ice_shard" в будущем
var boss_resource_type: String = "rune" 
var boss_resources: int = 0 # Сколько уникальных рун собрано
var boss_kills: int = 0     # Сколько раз побежден босс (для прогресса)

# --- СОСТОЯНИЕ МИРА ---
var phase: int = 0 # 0 = Обычный мир, 1 = Зима, 2 = Оттепель

func reset_run() -> void:
	hp = max_hp
	resources = 0
	# Руны и прогресс босса НЕ сбрасываются при смерти, это метапрогресс

func add_resources(amount: int) -> void:
	resources += amount

func spend_resources(amount: int) -> bool:
	if resources >= amount:
		resources -= amount
		return true
	return false

# --- ФУНКЦИИ ДЛЯ БОССА ---
func add_boss_resource(amount: int = 1) -> void:
	boss_resources += amount
	boss_kills += 1
	print("Получено ", amount, " ", boss_resource_type, "(ов). Всего: ", boss_resources)

# Заглушка для будущих улучшений оружия
func spend_boss_resource(amount: int) -> bool:
	if boss_resources >= amount:
		boss_resources -= amount
		return true
	return false
