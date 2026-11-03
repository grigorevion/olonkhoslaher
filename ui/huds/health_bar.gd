extends CanvasLayer

@onready var hud_node = $HUD
@onready var health_bar = $HUD/HealthBar
@onready var damage_bar = $HUD/DamageBar
@onready var health_label = $HUD/HealthLabel # <--- Ссылка на текст

var _shake_tween: Tween = null
var _damage_tween: Tween = null
var _color_tween: Tween = null
var _previous_health: int = 0

func _ready():
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_node("HealthComponent"):
		var health = player.get_node("HealthComponent")
		
		health_bar.max_value = health.max_hp
		health_bar.value = health.current_hp
		
		damage_bar.max_value = health.max_hp
		damage_bar.value = health.current_hp
		
		_previous_health = health.current_hp
		
		# Устанавливаем начальный текст
		_update_label(health.current_hp, health.max_hp)
		
		health.health_changed.connect(_on_health_changed)
		_update_bar_color(health.current_hp, health.max_hp)

func _on_health_changed(current_health: int, max_health: int):
	health_bar.max_value = max_health
	health_bar.value = current_health
	_update_bar_color(current_health, max_health)
	
	# Обновляем цифры
	_update_label(current_health, max_health)
	
	if current_health < _previous_health:
		_shake()
		
		if _damage_tween and _damage_tween.is_valid():
			_damage_tween.kill()
			
		_damage_tween = create_tween()
		_damage_tween.tween_interval(0.4)
		_damage_tween.tween_property(damage_bar, "value", current_health, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	
	damage_bar.max_value = max_health
	_previous_health = current_health

# Функция обновления текста
func _update_label(current_hp: int, max_hp: int):
	if health_label:
		health_label.text = str(current_hp) + " / " + str(max_hp)

func _update_bar_color(current_hp: int, max_hp: int):
	var ratio = float(current_hp) / float(max_hp)
	
	if _color_tween and _color_tween.is_valid():
		_color_tween.kill()
		
	_color_tween = create_tween()
	if ratio > 0.6:
		_color_tween.tween_property(health_bar, "modulate", Color(1, 1, 1), 0.2) 
	elif ratio > 0.3:
		_color_tween.tween_property(health_bar, "modulate", Color(1, 0.8, 0.2), 0.2)
	else:
		_color_tween.tween_property(health_bar, "modulate", Color(1, 0.2, 0.2), 0.2)

func _shake():
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()
		
	_shake_tween = create_tween()
	var original_pos = hud_node.position
	var shake_power = 12.0 
	
	_shake_tween.tween_property(hud_node, "position", original_pos + Vector2(shake_power, 0), 0.02)
	_shake_tween.tween_property(hud_node, "position", original_pos + Vector2(-shake_power, 0), 0.02)
	_shake_tween.tween_property(hud_node, "position", original_pos + Vector2(shake_power/2, 0), 0.02)
	_shake_tween.tween_property(hud_node, "position", original_pos + Vector2(-shake_power/2, 0), 0.02)
	_shake_tween.tween_property(hud_node, "position", original_pos, 0.02)
