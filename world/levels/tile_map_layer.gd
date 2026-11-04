extends TileMapLayer

@export var width: int = 100
@export var height: int = 20
@export var surface_level: int = 3
@export var noise_frequency: float = 0.05
@export var surface_amplitude: float = 5.0

@export var dirt: Array [Vector2i] = [
	Vector2i(0, 0),
	Vector2i(0, 1),
	Vector2i(0, 2),
	Vector2i(0, 3)
]

@export var grass: Array[Vector2i] = [
	Vector2i(1, 0),
	Vector2i(1, 1),
	Vector2i(1, 2),
	Vector2i(1, 3)
]

var noise: FastNoiseLite
var surface_heights: Array[int] = [] # <--- Массив, где мы запоминаем высоту

func _ready() -> void:
	generate_world()

func generate_world() -> void:
	clear() # Очищаем старые тайлы при перегенерации
	surface_heights.clear() # Очищаем старые данные
	
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = noise_frequency
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	for x in range(width):
		var surface_height = clamp(
			surface_level + int(noise.get_noise_1d(x) * surface_amplitude), 
			0, height - 1
		)
		
		# ЗАПОМИНАЕМ ВЫСОТУ ДЛЯ КАЖДОГО X
		surface_heights.append(surface_height)
		
		var random_grass = grass.pick_random()
		set_cell(Vector2i(x, surface_height), 0, random_grass) 
		
		for y in range(surface_height + 1, height):
			var random_dirt = dirt.pick_random()
			set_cell(Vector2i(x, y), 0, random_dirt)
