extends Node
class_name HitboxComponent

signal hit_target(target)

var owner_entity: Node2D = null 
var current_damage: int = 1
var current_variance: float = 0.0

func _ready():
	if has_node("Area2D"):
		$Area2D.body_entered.connect(_on_body_entered)
		$Area2D.monitoring = false
		
	if has_node("Sprite2D"):
		$Sprite2D.visible = false

func activate(duration: float, base_damage: int, variance: float = 0.0):
	# СОХРАНЯЕМ УРОН В ПЕРЕМЕННЫЕ КЛАССА
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
		
		body.take_damage(final_damage)
		hit_target.emit(body)
