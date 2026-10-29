extends Entity

@export var data: EnemyData

var speed: float:
	get: return data.speed if data else 150.0
var chase_speed: float:
	get: return data.chase_speed if data else 250.0
var detection_radius: float:
	get: return data.detection_radius if data else 500.0
var knockback_power: float:
	get: return data.knockback_power if data else 500.0
var attack_range: float:
	get: return data.attack_range if data else 120.0
var attack_min_range: float:
	get: return data.attack_min_range if data else 80.0
var attack_cooldown: float:
	get: return data.attack_cooldown if data else 1.2
var reposition_speed: float:
	get: return data.reposition_speed if data else 400.0
var reposition_decel: float:
	get: return data.reposition_decel if data else 2000.0

var gravity = 4000.0
var attack_cooldown_timer = 0.0
var player_ref = null
var start_position = Vector2.ZERO
var weapon_base_pos_x = 0.0
var weapon_base_scale_x = 1.0

func _ready():
	if data:
		if has_node("HealthComponent"):
			$HealthComponent.max_hp = data.max_hp
			$HealthComponent.current_hp = data.max_hp
		if has_node("Sprite2D"):
			if data.sprite_texture:
				$Sprite2D.texture = data.sprite_texture
			$Sprite2D.scale = data.sprite_scale
			
	if has_node("MeleeWeapon"):
		weapon_base_pos_x = abs($MeleeWeapon.position.x)
		weapon_base_scale_x = abs($MeleeWeapon.scale.x)
			
	start_position = global_position
	player_ref = get_tree().get_first_node_in_group("player")
	
	if has_node("HealthComponent"):
		$HealthComponent.died.connect(_on_died)
		
	state_machine = $StateMachine
	if state_machine:
		state_machine.parent = self
		state_machine.add_state(State.PATROL, $StateMachine/StatePatrol)
		state_machine.add_state(State.ALERT, $StateMachine/StateAlert)
		state_machine.add_state(State.CHASE, $StateMachine/StateChase)
		state_machine.add_state(State.RETURN, $StateMachine/StateReturn)
		state_machine.add_state(State.REPOSITION, $StateMachine/StateReposition) # <--- НОВОЕ
		state_machine.add_state(State.ATTACK, $StateMachine/StateAttack)
		state_machine.transition_to(State.PATROL)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	if attack_cooldown_timer > 0.0:
		attack_cooldown_timer -= delta
	if knockback_timer > 0.0:
		knockback_timer -= delta
		velocity.x = move_toward(velocity.x, 0, 3000 * delta)
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

func set_facing(dir: int):
	direction = dir
	if has_node("Sprite2D"):
		$Sprite2D.flip_h = dir < 0
	if has_node("MeleeWeapon"):
		var weapon = $MeleeWeapon
		weapon.position.x = weapon_base_pos_x * dir
		weapon.scale.x = weapon_base_scale_x * dir

func play_animation(anim_name: String):
	if has_node("Sprite2D"):
		match anim_name:
			"patrol": $Sprite2D.modulate = Color(1, 1, 1)
			"alert": $Sprite2D.modulate = Color(1, 1, 0)
			"chase": $Sprite2D.modulate = Color(1, 0.3, 0.3)
			"return": $Sprite2D.modulate = Color(0.5, 0.5, 1)
			"reposition": $Sprite2D.modulate = Color(1, 0.6, 0.2) # Оранжевый
			"attack": $Sprite2D.modulate = Color(0.8, 0.1, 0.1)
