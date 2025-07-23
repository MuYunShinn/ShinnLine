extends Area3D

@export var speed := 1.0
#皇冠旋转
func _process(delta: float) -> void:
	rotate_y(delta * speed)
#玩家碰皇冠事件
func _on_Crown_body_entered(main_line: PhysicsBody3D) -> void:
	State.main_line_transform = main_line.transform
	if "is_turn" in main_line:
		State.is_turn = main_line.is_turn
	if "animation_node" in main_line and main_line.animation_node and main_line.animation_node.current_animation:
		State.anim_time = main_line.animation_node.current_animation_position
	queue_free()
