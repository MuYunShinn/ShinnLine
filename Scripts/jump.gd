extends Area3D

@export var height := 1.0

func _ready():
	monitoring = true

func _on_body_entered(body: PhysicsBody3D) -> void:
	if body is CharacterBody3D:
		var character := body as CharacterBody3D
		var jump_speed = sqrt(2 * 9.8 * height)
		character.velocity += jump_speed * Vector3.UP
