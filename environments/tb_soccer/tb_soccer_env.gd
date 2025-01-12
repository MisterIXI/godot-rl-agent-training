extends Node3D
class_name TBSoccerEnv

@export var ball: RigidBody3D
@export var tb_left: TurtleBotController
@export var tbc_left: TBSoccerAIController
@export var tb_right: TurtleBotController
@export var tbc_right: TBSoccerAIController
@export var goal_left: Area3D
@export var goal_right: Area3D

var settings: TBSoccerSettings

@export var info_label_left: Label3D
@export var info_label_right: Label3D

var score_left: int = 0
var score_right: int = 0

func update_labels():
	info_label_left.text = (
		"Reward: " + "%+.2f" % tbc_left.running_rewards[-1] + "\n" +
		"Avg Reward: " + "%+.2f" % (tbc_left.running_rewards.reduce(func(acc, x): return acc + x, 0) / 60) + "\n" +
		"Goal score: " + str(score_left)
	)
	info_label_right.text = (
		"Reward: " + "%+.2f" % tbc_right.running_rewards[-1] + "\n" +
		"Avg Reward: " + "%+.2f" % (tbc_right.running_rewards.reduce(func(acc, x): return acc + x, 0) / 60) + "\n" +
		"Goal score: " + str(score_right)
	)

func _physics_process(_delta):
	if tbc_left.needs_reset and tbc_right.needs_reset:
		reset_env()
	update_labels()


func reset_env():
	# place ball between -1 and 1 on z axis (center line of field)
	ball.position = Vector3.FORWARD * (randf() - 0.5) * 2 + Vector3.UP * 0.1
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	# place turtle bots within random square, but symetrically
	# move to left field side
	var random_pos = Vector3.LEFT
	# random vertical offset within -1 and 1 on Z axis
	random_pos.z = (randf() - 0.5) * 2
	# random horizontal offset within -0.5 and 0.5 on X axis
	random_pos.x += (randf() - 0.5)

	tb_left.position = random_pos
	tbc_left.reset()
	# rotate tb left to face right
	tb_left.rotation_degrees = Vector3.UP * 270

	tb_right.position = -random_pos
	tbc_right.reset()
	# rotate tb right to face left
	tb_right.rotation_degrees = Vector3.UP * 90
	update_labels()

func on_goal():
	tbc_left.needs_reset = true
	tbc_left.is_success = true
	tbc_left.done = true
	tbc_right.needs_reset = true
	tbc_right.is_success = true
	tbc_right.done = true

func on_oob():
	tbc_left.needs_reset = true
	tbc_left.is_success = false
	tbc_left.done = true
	tbc_right.needs_reset = true
	tbc_right.is_success = false
	tbc_right.done = true

func on_timeout():
	tbc_left.needs_reset = true
	tbc_left.is_success = false
	tbc_left.done = true
	tbc_right.needs_reset = true
	tbc_right.is_success = false
	tbc_right.done = true

func _on_left_goal_body_entered(body: Node3D):
	if body.is_in_group("Ball"):
		score_right += 1
		update_labels()
		on_goal()
	else:
		# when turtle bot enters goal area, reset
		on_oob()


func _on_right_goal_body_entered(body: Node3D):
	if body.is_in_group("Ball"):
		score_left += 1
		update_labels()
		on_goal()
	else:
		# when turtle bot enters goal area, reset
		on_oob()
