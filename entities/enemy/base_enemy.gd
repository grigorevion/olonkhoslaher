extends CharacterBody2D
class_name BaseEnemy

# --- НАСТРОЙКИ ---
@export var speed = 150.0
@export var chase_speed = 250.0
@export var detection_radius = 500.0
@export var gravity = 4000.0
@export var knockback_power = 500.0

# --- ПЕРЕМЕННЫЕ ---
var direction = 1
var knockback_timer = 0.0
var player_ref = null
var start_position = Vector2.ZERO
var state_machine = null

func _ready():
	start_position = global_position
	player_ref = get_tree().get_first_node_in_group("player")
	
	# Подключаем здоровье
	if has_node("HealthComponent"):
		$HealthComponent.died.connect(_on_died)
		
	# Находим машину состояний и настраиваем её
	state_machine = $StateMachine
	if state_machine:
		state_machine.parent = self
		state_machine.add_state("patrol", $StateMachine/StatePatrol)
		state_machine.add_state("alert", $StateMachine/StateAlert)
		state_machine.add_state("chase", $StateMachine/StateChase)
		state_machine.add_state("return", $StateMachine/StateReturn)
		state_machine.transition_to("patrol")

func _physics_process(delta: float) -> void:
	# Гравитация
	if not is_on_floor():
		velocity.y += gravity * delta

	# Откидывание (если получили урон)
	if knockback_timer > 0.0:
		knockback_timer -= delta
		velocity.x = move_toward(velocity.x, 0, 1500 * delta)
	else:
		# Если не в стане — проверяем, не увидел ли враг игрока
		if player_ref and state_machine and state_machine.current_state == state_machine.states["patrol"]:
			var dist = global_position.distance_to(player_ref.global_position)
			if dist < detection_radius:
				state_machine.transition_to("alert")

	move_and_slide()

func take_damage(damage_amount: int, _knockback: float = 0.0):
	if has_node("HealthComponent"):
		$HealthComponent.take_damage(damage_amount)
		print("Враг получил урон! Осталось HP: ", $HealthComponent.current_hp)
	
	if player_ref:
		if global_position.x > player_ref.global_position.x:
			velocity.x = knockback_power
		else:
			velocity.x = -knockback_power
	knockback_timer = 0.2

func _on_died():
	call_deferred("queue_free")

func _on_damage_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(1)
