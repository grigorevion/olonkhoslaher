extends Node
class_name HitboxComponent

signal hit_target(target)

var owner_entity: Node2D = null 
var current_damage: int = 1
var current_variance: float = 0.0

var damage_number_scene = preload("res://ui/damage_numbers/DamageNumber.tscn")

func _ready():
	if has_node("Area2D"):
		$Area2D.body_entered.connect(_on_body_entered)
		$Area2D.monitoring = false
		
	if has_node("Sprite2D"):
		$Sprite2D.visible = false

# Добавили параметр show_default_visual
func activate(duration: float, base_damage: int, variance: float = 0.0, show_default_visual: bool = true):
	current_damage = base_damage
	current_variance = variance
	
	if has_node("Area2D"):
		var area = $Area2D
		area.monitoring = true
		
		# Показываем красный квадрат ТОЛЬКО если нам разрешили
		if has_node("Sprite2D") and show_default_visual:
			$Sprite2D.visible = true
			
		await get_tree().create_timer(duration).timeout
		area.monitoring = false
		
		if has_node("Sprite2D"):
			$Sprite2D.visible = false

func _on_body_entered(body: Node2D):
	if body == owner_entity:
		return
		
	if body.has_method("take_damage"):
		var min_dmg = current_damage * (1.0 - current_variance)
		var max_dmg = current_damage * (1.0 + current_variance)
		var final_damage = int(randf_range(min_dmg, max_dmg))
		
		var is_crit = randf() < 0.15
		if is_crit:
			final_damage = int(final_damage * 2.0) 
			
		body.take_damage(final_damage)
		hit_target.emit(body)
		
		if damage_number_scene:
			var num = damage_number_scene.instantiate()
			get_tree().current_scene.add_child(num)
			num.global_position = body.global_position + Vector2(0, -40)
			num.setup(final_damage, is_crit)
