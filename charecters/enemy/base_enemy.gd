extends CharacterBody2D

const SPEED = 100.0
var gravity = 4000.0
var direction = 1
var hp = 3
var knockback_timer = 0.0

@export var patrol_distance = 150.0 # Насколько далеко враг уходит от начальной точки
var start_position = Vector2.ZERO

func _ready():
	start_position = global_position

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if knockback_timer > 0.0:
		knockback_timer -= delta
		velocity.x = move_toward(velocity.x, 0, 1500 * delta)
	else:
		velocity.x = direction * SPEED
		
		# --- ЛОГИКА ПАТРУЛИРОВАНИЯ ---
		# Если отошел слишком далеко вправо или влево от старта, разворачиваемся
		if global_position.x > start_position.x + patrol_distance:
			direction = -1
			$Sprite2D.flip_h = true
		elif global_position.x < start_position.x - patrol_distance:
			direction = 1
			$Sprite2D.flip_h = false
			
		# Если уперся в стену, разворачиваемся
		if is_on_wall():
			direction *= -1
			$Sprite2D.flip_h = direction < 0

	move_and_slide()

func take_damage(damage_amount: int, knockback_power: float = 500.0):
	hp -= damage_amount
	knockback_timer = 0.2
	print("Враг получил урон! Осталось HP: ", hp)
	
	if global_position.x > get_tree().get_first_node_in_group("player").global_position.x:
		velocity.x = knockback_power
	else:
		velocity.x = -knockback_power

	if hp <= 0:
		queue_free()
