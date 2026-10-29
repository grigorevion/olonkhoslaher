extends CharacterBody2D
class_name BaseEnemy

# --- ДАННЫЕ ---
@export var data: EnemyData

# --- ПЕРЕМЕННЫЕ (Через геттеры) ---
var speed: float:
	get: return data.speed if data else 150.0
var chase_speed: float:
	get: return data.chase_speed if data else 250.0
var detection_radius: float:
	get: return data.detection_radius if data else 500.0
var knockback_power: float:
	get: return data.knockback_power if data else 500.0
var attack_range: float:
	get: return data.attack_range if data else 100.0

var gravity = 4000.0

# --- ЛОГИКА ---
var direction = 1
var knockback_timer = 0.0
var player_ref = null
var start_position = Vector2.ZERO
var state_machine = null

func _ready():
	# Если есть данные, применяем здоровье и картинку
	if data:
		if has_node("HealthComponent"):
			$HealthComponent.max_hp = data.max_hp
			$HealthComponent.current_hp = data.max_hp
			
		if has_node("Sprite2D"):
			if data.sprite_texture:
				$Sprite2D.texture = data.sprite_texture
			$Sprite2D.scale = data.sprite_scale
			
	# Остальная инициализация
	start_position = global_position
	player_ref = get_tree().get_first_node_in_group("player")
	
	if has_node("HealthComponent"):
		$HealthComponent.died.connect(_on_died)
		
	state_machine = $StateMachine
	if state_machine:
		state_machine.parent = self
		state_machine.add_state("patrol", $StateMachine/StatePatrol)
		state_machine.add_state("alert", $StateMachine/StateAlert)
		state_machine.add_state("chase", $StateMachine/StateChase)
		state_machine.add_state("return", $StateMachine/StateReturn)
		state_machine.add_state("attack", $StateMachine/StateAttack) # <--- НОВОЕ СОСТОЯНИЕ
		state_machine.transition_to("patrol")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if knockback_timer > 0.0:
		knockback_timer -= delta
		velocity.x = move_toward(velocity.x, 0, 3000 * delta)
	else:
		pass

	move_and_slide()

func take_damage(damage_amount: int, _knockback: float = 0.0):
	if has_node("HealthComponent"):
		$HealthComponent.take_damage(damage_amount)
		print("Враг получил урон! Осталось HP: ", $HealthComponent.current_hp)
	
	velocity.x = 0
	if player_ref:
		if global_position.x > player_ref.global_position.x:
			velocity.x = knockback_power
		else:
			velocity.x = -knockback_power
			
	velocity.y = -300.0
	knockback_timer = 0.3

func _on_died():
	call_deferred("queue_free")

func _on_damage_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(1)
