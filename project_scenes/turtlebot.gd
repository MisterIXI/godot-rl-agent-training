extends CharacterBody3D

## simulated twist velocity for backward/forward (-0.20 to 0.20) (theoretical max -0.22 to 0.22)
var twist_vel = 0.0
## simulated twist angle for backward/forward (-2 to 2) (theoretical max -2.84 to 2.84)
var twist_ang = 0.0

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# TODO: implement twist velocity and angle
func _physics_process(delta: float) -> void:
	# # Add the gravity.
	# if not is_on_floor():
	# 	velocity += get_gravity() * delta

	# # Handle jump.
	# if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	# 	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	# Move and collide, and push rigidbody
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider is RigidBody3D:
			collider.apply_central_force(velocity * collider.mass)

