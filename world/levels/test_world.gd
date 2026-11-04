extends Node2D

@export var enemy_scene: PackedScene # <--- Поле для врага
@export var spawn_chance: float = 0.1 
@export var min_spawn_x: int = 15 

func _ready() -> void:
	# Ждем, пока TileMapLayer сгенерирует карту
	await get_tree().process_frame
	
	var tilemap = $TileMapLayer
	if not tilemap:
		return
		
	# 1. СТАВИМ ИГРОКА НА ЗЕМЛЮ (чтобы не падал в пропасть)
	var player = $Player
	if player:
		var start_x = 5 # Ставим его на 5-й тайл
		var y_index = tilemap.surface_heights[start_x]
		var spawn_pos = tilemap.map_to_local(Vector2i(start_x, y_index))
		# Поднимаем чуть выше земли, чтобы не застрял в текстурах
		player.global_position = tilemap.to_global(spawn_pos) + Vector2(0, -50)

	# 2. СПАВНИМ ВРАГОВ
	spawn_enemies()

func spawn_enemies() -> void:
	var tilemap = $TileMapLayer
	
	if not tilemap or not enemy_scene:
		return
		
	for x in range(tilemap.width):
		if x < min_spawn_x:
			continue
			
		if randf() < spawn_chance:
			var y_index = tilemap.surface_heights[x]
			
			var spawn_pos = tilemap.map_to_local(Vector2i(x, y_index))
			var global_spawn_pos = tilemap.to_global(spawn_pos)
			
			global_spawn_pos.y -= 30.0 
			
			var enemy = enemy_scene.instantiate()
			enemy.global_position = global_spawn_pos
			add_child(enemy)
