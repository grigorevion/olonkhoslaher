extends Node2D

func _ready():
	for i in range(15):
		var rb = RigidBody2D.new()
		rb.gravity_scale = 1.5
		
		# Осколки сталкиваются только с полом
		rb.collision_layer = 0 
		rb.collision_mask = 1  
		
		add_child(rb)
		
		var sprite = Sprite2D.new()
		sprite.texture = load("res://assets/sprites/icon.svg")
		sprite.scale = Vector2(0.15, 0.15)
		sprite.modulate = Color(1, 0.3, 0.3)
		rb.add_child(sprite)
		
		var col = CollisionShape2D.new()
		var shape = CircleShape2D.new()
		shape.radius = 4.0
		col.shape = shape
		rb.add_child(col)
		
		var mat = PhysicsMaterial.new()
		mat.bounce = 0.6 
		mat.friction = 0.5
		rb.physics_material_override = mat
		
		var dir = Vector2(randf_range(-1.0, 1.0), randf_range(-1.5, -0.5)).normalized()
		rb.apply_central_impulse(dir * randf_range(200.0, 400.0))
		
		# --- ФИКС: Рандомное время жизни и плавное исчезновение ---
		var lifetime = randf_range(0.8, 1.8) # Живут от 0.8 до 1.8 секунд
		
		var tween = create_tween()
		tween.tween_interval(lifetime)
		# Плавно делаем спрайт прозрачным за 0.4 секунды
		tween.tween_property(sprite, "modulate:a", 0.0, 0.4)
		# Удаляем физическое тело только после того, как оно стало прозрачным
		tween.tween_callback(rb.queue_free)

	# Ждем чуть больше максимального времени жизни осколков (1.8 + 0.4) и удаляем сам спавнер
	await get_tree().create_timer(2.5).timeout
	queue_free()
