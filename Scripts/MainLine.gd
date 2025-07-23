@tool
extends CharacterBody3D

signal new_line1
signal on_sky

@onready var y = $".".position.y
@export var speed := 10.0
@export var color := Color(0,0,0): get = get_color, set = set_color
@export var fly := false
@export var animation:NodePath
@export var is_turn := false

@onready var mesh:Mesh = $MeshInstance3D.mesh
@onready var past_translation := position
@onready var material:StandardMaterial3D = $MeshInstance3D.get_surface_override_material(0)
@onready var tree := get_tree()
@onready var animation_node:AnimationPlayer = get_node(animation) if animation else null

var is_live := true
var line:MeshInstance3D
@warning_ignore("shadowed_variable_base_class")
#var velocity := Vector3.ZERO
var past_is_on_floor := false
var v := Vector3(0,0,0)
var is_start := false

func _ready() -> void:
	if not Engine.is_editor_hint() and State.main_line_transform:
		transform = State.main_line_transform
		is_turn = State.is_turn

func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint() and is_live:
		velocity.y -= 9.8 * delta
		velocity.x = v.x
		velocity.z = v.z
		move_and_slide()
		v = Vector3(velocity.x, v.y, velocity.z)
		if fly:
			$".".position.y = y

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint() and line and is_live:
		@warning_ignore("shadowed_variable_base_class")
		var is_on_floor := is_on_floor() or fly
		if is_on_floor:
			if past_is_on_floor != is_on_floor: 
				new_line()
			var offset = position - past_translation
			line.position = offset / 2 + past_translation
			line.scale = offset.abs() + Vector3(1,1,1)
		else:
			if past_is_on_floor != is_on_floor: emit_signal("on_sky")
		past_is_on_floor = is_on_floor

func _input(event: InputEvent) -> void:
	if not Engine.is_editor_hint():
		if event.is_action_pressed("turn") and is_live:
			turn()
		if event.is_action_pressed("retry"):
# warning-ignore:return_value_discarded
			tree.reload_current_scene()

func new_line():
	line = MeshInstance3D.new()
	line.mesh = mesh
	line.position = position
	past_translation = position
	line.set_surface_override_material(0,material)
	line.name = "Line"
	tree.current_scene.add_child(line)
	emit_signal("new_line1")

func turn():
	if is_on_floor() or fly:
		if animation_node and not animation_node.is_playing(): 
			animation_node.play("Default")
			animation_node.seek(State.anim_time)
		if is_start :
			rotation_degrees += Vector3(0,1,0) * 90 if is_turn else Vector3.DOWN * 90
			is_turn = not is_turn
		else:
			is_start = true
		v = to_global(Vector3(0,0,-1) * speed) - position
		new_line()

func set_color(value: Color):
	if not is_instance_valid(material):
		material = StandardMaterial3D.new()
		$MeshInstance3D.set_surface_override_material(0, material)
	material.albedo_color = value

func get_color() -> Color:
	return material.albedo_color if is_instance_valid(material) else Color(0, 0, 0)

func _on_Area_body_entered(_body: Node) -> void:
	is_live = false
	if animation_node: animation_node.stop()
	$AudioStreamPlayer.play()
