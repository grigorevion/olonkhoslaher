extends Node
class_name HitboxComponent

signal hit_target(target)

var owner_entity: Node2D = null 
var current_damage: int = 1
var current_variance: float = 0.0

# Ссылка на сцену цифры урона (загружаем заранее)
var damage_number_scene = preload("res://ui/damage_numbers/DamageNumber.tscn")

func _ready():
	if has_node("Area2D"):
		$Area2D.body_entered.connect(_on_body_entered)
		$Area2D.monitoring = false
		
	if has_node("Sprite2D"):
		$Sprite2D.visible = false

func activate(duration: float, base_damage: int, variance: float = 0.0):
	current_damage = base_damage
	current_variance = variance
	
	if has_node("Area2D"):
		var area = $Area2D
		area.monitoring = true
		
		if has_node("Sprite2D"):
			$Sprite2D.visible = true
			
		await get_tree().create_timer(duration).timeout
		area.monitoring = false
		
		if has_node("Sprite2D"):
			$Sprite2D.visible = false

func _on_body_entered(body: Node2D):
	if body == owner_entity:
		return
		
	if body.has_method("take_damage"):
		# СЧИТАЕМ РАНДОМНЫЙ УРОН
		var min_dmg = current_damage * (1.0 - current_variance)
		var max_dmg = current_damage * (1.0 + current_variance)
		var final_damage = int(randf_range(min_dmg, max_dmg))
		
		# Проверяем на крит (шанс 15%)
		var is_crit = randf() < 0.15
		if is_crit:
			final_damage = int(final_damage * 2.0) # Крит бьет в 2 раза сильнее
			
		body.take_damage(final_damage)
		hit_target.emit(body)
		
		# СПАВНИМ ЦИФРУ УРОНА
		if damage_number_scene:
			var num = damage_number_scene.instantiate()
			# Добавляем цифру на текущий уровень
			get_tree().current_scene.add_child(num)
			# Ставим её на место врага (или чуть выше)
			num.global_position = body.global_position + Vector2(0, -40)
			num.setup(final_damage, is_crit)
