extends Node2D

@onready var progress_bar = $ProgressBar
var health_comp = null
var fade_tween: Tween = null

func _ready():
	# Ищем компонент здоровья у родителя (у врага)
	health_comp = get_parent().get_node_or_null("HealthComponent")
	
	if health_comp:
		# Настраиваем полоску
		progress_bar.max_value = health_comp.max_hp
		progress_bar.value = health_comp.current_hp
		
		# Скрываем полоску при старте (она прозрачная)
		self.modulate.a = 0.0
		
		# Подписываемся на изменение здоровья
		health_comp.health_changed.connect(_on_health_changed)

func _on_health_changed(current_hp: int, max_hp: int):
	progress_bar.max_value = max_hp
	progress_bar.value = current_hp
	
	# 1. Делаем полоску видимой
	self.modulate.a = 1.0
	
	# 2. Сбрасываем старый таймер исчезновения (если он был)
	if fade_tween and fade_tween.is_valid():
		fade_tween.kill()
		
	# 3. Запускаем новый таймер: ждем 2 секунды, потом плавно скрываем
	fade_tween = create_tween()
	fade_tween.tween_interval(2.0) # Ждем 2 секунды после последнего удара
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.5) # Исчезает за 0.5 сек
