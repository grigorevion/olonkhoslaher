extends CharacterBody2D

@onready var attack_area = $AttackArea
@onready var camera = $Camera2D
@onready var health_component = $HealthComponent

# --- НАСТРОЙКИ ДВИЖЕНИЯ ---
const SPEED = 600.0
const JUMP_VELOCITY = -1500.0
var gravity = 4000.0
var fall_multiplier = 1.5

# --- НАСТРОЙКИ АТАКИ ---
@export var attack_cooldown = 0.4
@export var attack_duration = 0.2
@export var attack_offset = 50.0

# --- ПЕРЕМЕННЫЕ ---
var attack_timer = 0.0
var cooldown_timer = 0.0
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var facing_direction = 1
var hit_enemies = [] 

func _ready():
	attack_area.monitoring = false
	attack_area.visible = false
	# Подключаем сигнал смерти
	health_component.died.connect(_on_died)

func _physics_process(delta: float) -> void:
	# --- ПРЫЖКИ И ГРАВИТАЦИЯ ---
	if is_on_floor():
		coyote_timer = 0.1
	else:
		coyote_timer -= delta
		
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = 0.1
	else:
		jump_buffer_timer -= delta

	if not is_on_floor():
		var current_gravity = gravity
		if velocity.y > 0:
			current_gravity *= fall_multiplier
		velocity.y += current_gravity * delta

	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	# --- ДВИЖЕНИЕ ---
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		facing_direction = direction
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 4 * delta)

	move_and_slide()

	# --- ЛОГИКА АТАКИ ---
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
		
	if Input.is_action_just_pressed("attack") and attack_timer <= 0.0 and cooldown_timer <= 0.0:
		attack_area.monitoring = true
		attack_area.visible = true
		
		hit_enemies.clear()
		
		attack_area.position.x = attack_offset * facing_direction
		if facing_direction == -1:
			attack_area.rotation = PI
		else:
			attack_area.rotation = 0
		
		attack_timer = attack_duration
		cooldown_timer = attack_cooldown
		velocity.x = facing_direction * 400
		
		var tween = create_tween()
		tween.tween_property(attack_area, "scale", Vector2(1.0, 1.0), 0.1).from(Vector2(0.5, 1.5))
		
	if attack_timer > 0.0:
		attack_timer -= delta
		if attack_timer <= 0.0:
			attack_area.monitoring = false
			attack_area.visible = false

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body in hit_enemies:
		return
		
	if body.has_method("take_damage"):
		hit_enemies.append(body)
		body.take_damage(1)

func take_damage(amount: int):
	health_component.take_damage(amount)
	print("Игрок получил урон! HP: ", health_component.current_hp)

func _on_died():
	print("Игрок умер!")
	call_deferred("_reload_scene")

func _reload_scene():
	get_tree().reload_current_scene()
