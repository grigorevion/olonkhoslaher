extends TileMapLayer

@export var width: int = 100
@export var height: int = 20
@export var surface_level: int = 5 
@export var noise_frequency: float = 0.05
@export var surface_amplitude: float = 5.0
@export var flat_start_end_blocks: int = 15 # Увеличил зону, чтобы было больше места для плавного спуска

@export var dirt: Array [Vector2i] = [
	Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2), Vector2i(0, 3)
]

@export var grass: Array[Vector2i] = [
	Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)
]

var noise: FastNoiseLite
var surface_heights: Array[int] = []

func _ready() -> void:
	generate_world()

func generate_world() -> void:
	clear()
	surface_heights.clear()
	
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.frequency = noise_frequency
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	
	var x = 0
	var current_height = surface_level
	
	while x < width:
		var chunk_width = 1
		
		# Если мы в зоне старта или финиша
		if x < flat_start_end_blocks or x >= width - flat_start_end_blocks:
			# ПЛАВНЫЙ СПУСК: высота меняется на 1 блок за раз, пока не достигнет surface_level
			current_height = move_toward(current_height, surface_level, 1)
			chunk_width = 1
		else:
			# Обычная процедурная генерация
			var noise_val = noise.get_noise_1d(x / 3.0)
			var target_height = int(surface_level + (noise_val * surface_amplitude))
			
			current_height = clamp(target_height, current_height - 1, current_height + 1)
			current_height = clamp(current_height, 0, height - 1)
			
			chunk_width = randi_range(3, 6)
			
		# Рисуем текущий кусок
		for i in range(chunk_width):
			if x >= width:
				break
				
			surface_heights.append(current_height)
			
			# Сплошные стены по краям
			if x == 0 or x == width - 1:
				for y in range(height):
					set_cell(Vector2i(x, y), 0, dirt.pick_random())
			else:
				# Трава и земля
				set_cell(Vector2i(x, current_height), 0, grass.pick_random())
				for y in range(current_height + 1, height):
					set_cell(Vector2i(x, y), 0, dirt.pick_random())
					
			x += 1
