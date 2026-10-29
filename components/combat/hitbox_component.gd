extends Node
class_name HitboxComponent

signal hit_target(target)
@export var damage: int = 1

func _ready():
	# При старте зона удара выключена
	if has_node("Area2D"):
		$Area2D.body_entered.connect(_on_body_entered)
		$Area2D.monitoring = false

func activate(duration: float = 0.2):
	print("ХИТБОКС АКТИВИРОВАН!") # <--- ОТЛАДКА
	if has_node("Area2D"):
		var area = $Area2D
		area.monitoring = true
		await get_tree().create_timer(duration).timeout
		area.monitoring = false

func _on_body_entered(body: Node2D):
	if body.has_method("take_damage"):
		body.take_damage(damage)
		hit_target.emit(body)
		print("ПОПАЛ В ", body.name) # <--- ОТЛАДКА
