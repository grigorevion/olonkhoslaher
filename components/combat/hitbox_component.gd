extends Node
class_name HitboxComponent

signal hit_target(target)
@export var damage: int = 1

var owner_entity: Node2D = null 

func _ready():
	if has_node("Area2D"):
		$Area2D.body_entered.connect(_on_body_entered)
		$Area2D.monitoring = false
		
	if has_node("Sprite2D"):
		$Sprite2D.visible = false

func activate(duration: float = 0.2):
	if has_node("Area2D"):
		var area = $Area2D
		area.monitoring = true
		
		# Просто показываем спрайт, без изменения его размера
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
		body.take_damage(damage)
		hit_target.emit(body)
