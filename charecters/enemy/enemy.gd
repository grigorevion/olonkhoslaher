extends CharacterBody2D

const SPEED = 100.0
var gravity = 4000.0
var direction = 1
var hp = 3
var knockback_timer = 0.0 # Таймер, пока враг в стане от удара

func _physics_process(delta: float) -> void:
	# Гравитация
	if not is_on_floor():
		velocity.y += gravity * delta

	# Если враг получил удар (в стане)
	if knockback_timer > 0.0:
		knockback_timer -= delta
		# Плавно останавливаем откидывание
		velocity.x = move_toward(velocity.x, 0, 1500 * delta)
	else:
		# Обычное движение врага
		velocity.x = direction * SPEED
		
		# Если враг уперся в стену, он разворачивается
		if is_on_wall():
			direction *= -1
			$Sprite2D.flip_h = direction < 0 # Переворачиваем спрайт

	move_and_slide()

# Функция получения урона (вызывается из игрока)
func take_damage(damage_amount: int, knockback_power: float = 500.0):
	hp -= damage_amount
	knockback_timer = 0.2 # Враг в стане 0.2 секунды
	print("Враг получил урон! Осталось HP: ", hp)
	
	# Откидываем врага в сторону, откуда прилетел удар
	# Если игрок справа от врага, откидываем влево (и наоборот)
	if global_position.x > get_tree().get_first_node_in_group("player").global_position.x:
		velocity.x = knockback_power
	else:
		velocity.x = -knockback_power

	if hp <= 0:
		queue_free() # Удаляем врага из игры
