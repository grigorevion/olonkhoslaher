extends CharacterBody2D

@onready var attack_area = $AttackArea
var attack_timer = 0.0

const SPEED = 600.0
const JUMP_VELOCITY = -1500.0
var gravity = 4000.0
var fall_multiplier = 1.5

var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var facing_direction = 1

func _ready():
	print("СКРИПТ ЗАГРУЖЕН! УДАР ОБНОВЛЕН!")
	attack_area.monitoring = false
	attack_area.visible = false # Прячем визуал при старте

func _physics_process(delta: float) -> void:
	# --- ТАЙМЕРЫ ПРЫЖКА ---
	if is_on_floor():
		coyote_timer = 0.1
	else:
		coyote_timer -= delta
		
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = 0.1
	else:
		jump_buffer_timer -= delta

	# --- ГРАВИТАЦИЯ ---
	if not is_on_floor():
		var current_gravity = gravity
		if velocity.y > 0:
			current_gravity *= fall_multiplier
		velocity.y += current_gravity * delta

	# --- ПРЫЖОК ---
	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	# --- ДВИЖЕНИЕ ВЛЕВО-ВПРАВО ---
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		facing_direction = direction # Запоминаем, куда смотрит игрок
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * 4 * delta)

	move_and_slide()

	# --- ЛОГИКА АТАКИ ---
	if Input.is_action_just_pressed("attack") and attack_timer <= 0.0:
		attack_area.monitoring = true  # Включаем хитбокс
		attack_area.visible = true     # Показываем картинку
		# Поворачиваем зону атаки и её картинку
		attack_area.scale.x = facing_direction
		attack_area.position.x = 40 * facing_direction
		
		attack_timer = 0.2 # Удар длится 0.2 секунды
		velocity.x = facing_direction * 400
		
	if attack_timer > 0.0:
		attack_timer -= delta
		if attack_timer <= 0.0:
			attack_area.monitoring = false # Выключаем хитбокс
			attack_area.visible = false    # Прячем картинку


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		# Передаем урон 1 и силу откидывания 600
		body.take_damage(1, 600.0)
