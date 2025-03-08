extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var selected_animation : ParticleAnimations

enum ParticleAnimations{
	STAYING_JUMP,
	MOVING_JUMP,
	LANDING,
	STEP,
	DASH,
	DASH_STEP,
}


func _ready() -> void:
	match selected_animation:
		ParticleAnimations.STAYING_JUMP:
			animation_player.play("staying_jump")
		
		ParticleAnimations.MOVING_JUMP:
			animation_player.play("moving_jump")
		
		ParticleAnimations.LANDING:
			animation_player.play("landing")
		
		ParticleAnimations.STEP:
			animation_player.play("normal_step")
		
		ParticleAnimations.DASH:
			animation_player.play("dash")
		
		ParticleAnimations.DASH_STEP:
			animation_player.play("dash_step")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	queue_free()
