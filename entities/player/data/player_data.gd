extends Resource
class_name PlayerData

@export_group("Stats")
@export var max_hp: int = 3

@export_group("Movement")
@export var speed: float = 600.0
@export var jump_velocity: float = -1500.0
@export var gravity: float = 4000.0
@export var fall_multiplier: float = 1.5

@export_group("Dash")
@export var dash_speed: float = 1500.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.8

@export_group("Combat")
@export var attack_duration: float = 0.3
@export var attack_knockback: float = 400.0
