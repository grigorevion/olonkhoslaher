extends Entity

# --- ДАННЫЕ ---
@export var data: PlayerData

# --- ПЕРЕМЕННЫЕ (Через геттеры) ---
var speed: float:
	get: return data.speed if data else 600.0
var jump_velocity: float:
	get: return data.jump_velocity if data else -1500.0
var gravity: float:
	get: return data.gravity if data else 4000.0
var fall_multiplier: float:
	get: return data.fall_multiplier if data else 1.5
var attack_duration: float:
	get: return data.attack_duration if data else 0.3
var attack_knockback: float:
	get: return data.attack_knockback if data else 400.0
var dash_speed: float:
	get: return data.dash_speed if data else 1500.0
var dash_duration: float:
	get: return data.dash_duration if data else 0.2
var dash_cooldown: float:
	get: return data.dash_cooldown if data else 0.8

# --- ВВОД ---
var input_direction: float = 0.0
var input_attack_pressed: bool = false
var input_dash_pressed: bool = false

# --- ЛОГИКА ---
var facing_direction = 1
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var dash_cooldown_timer = 0.0
var is_stealthed: bool = false # <--- Флаг невидимости
var weapon_base_pos_x = 0.0
var weapon_base_scale_x = 1.0

@onready var health_component = $HealthComponent
@onready var camera = $Camera2D

func _ready():
	if data and has_node("HealthComponent"):
		$HealthComponent.max_hp = data.max_hp
		$HealthComponent.current_hp = data.max_hp

	health_component.died.connect(_on_died)
	
	if has_node("MeleeWeapon"):
		weapon_base_pos_x = abs($MeleeWeapon.position.x)
		weapon_base_scale_x = abs($MeleeWeapon.scale.x)
	
	state_machine = $StateMachine
	if state_machine:
		state_machine.parent = self
		state_machine.add_state(State.IDLE, $StateMachine/PlayerStateIdle)
		state_machine.add_state(State.RUN, $StateMachine/PlayerStateRun)
		state_machine.add_state(State.JUMP, $StateMachine/PlayerStateJump)
		state_machine.add_state(State.ATTACK, $StateMachine/PlayerStateAttack)
		state_machine.add_state(State.DASH, $StateMachine/PlayerStateDash) # <--- Новое состояние
		state_machine.transition_to(State.IDLE)

func _physics_process(delta: float) -> void:
	input_direction = Input.get_axis("move_left", "move_right")
	input_attack_pressed = Input.is_action_just_pressed("attack")
	input_dash_pressed = Input.is_action_just_pressed("dash") # <--- Читаем кнопку рывка
	
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
	
	if is_on_floor():
		coyote_timer = 0.1
	else:
		coyote_timer -= delta
		
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = 0.1
	else:
		jump_buffer_timer -= delta

	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()

func set_facing(dir: int):
	facing_direction = dir
	if has_node("Sprite2D"):
		$Sprite2D.flip_h = dir < 0
		
	if has_node("MeleeWeapon"):
		var weapon = $MeleeWeapon
		weapon.position.x = weapon_base_pos_x * dir
		weapon.scale.x = weapon_base_scale_x * dir

func play_animation(anim_name: String):
	if has_node("Sprite2D"):
		match anim_name:
			"attack": $Sprite2D.modulate = Color(1, 0.8, 0.8)
			"dash": $Sprite2D.modulate = Color(0.5, 0.8, 1.0, 0.5) # Полупрозрачный синий
			_: $Sprite2D.modulate = Color(1, 1, 1)

func take_damage(amount: int, _knockback: float = 0.0):
	health_component.take_damage(amount)
	print("Игрок получил урон! HP: ", health_component.current_hp)

func _on_died():
	print("Игрок умер!")
	call_deferred("_reload_scene")

func _reload_scene():
	get_tree().reload_current_scene()
