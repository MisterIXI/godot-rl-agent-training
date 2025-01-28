extends Node3D
class_name BallLocator

@export var sensors: RayCastSensor3D
@export var indicator_mesh: MeshInstance3D
## the diameter of the serarched circle
@export var search_diameter: float = 30.0
@export var timer: Timer

func _ready():
	indicator_mesh.hide()

func sample_ball():
	var circle_pos = locate_ball()
	if circle_pos != null:
		indicator_mesh.visible = true
		indicator_mesh.position = Vector3(circle_pos.x, 0, circle_pos.y)
		print("Ball located at: ", circle_pos)
	else:
		indicator_mesh.visible = false
		print("No ball found")

func locate_ball():
	var results = sensors.get_observation()
	print(results)
	# use ransac to find the circle
	var best_circle = null
	var best_inliers = 0

	# convert results to relative positions
	for i in range(results.size()):
		if results[i] == null:
			continue
		results[i] = results[i] * sensors.ray_length
		var angle = i * 2 * PI / results.size()
		var x = cos(angle) * results[i]
		var z = sin(angle) * results[i]
		results[i] = Vector2(x, z)
	
	for i in range(100): # RANSAC iterations
		var sample_points = []
		while sample_points.size() < 3:
			var random_index = randi() % results.size()
			if results[random_index] != null:
				sample_points.append(results[random_index])
		
		var circle = fit_circle(sample_points)
		var inliers = 0
		
		for result in results:
			if result != null:
				var distance = (result - circle.center).length()
				if abs(distance - search_diameter / 2) < 1.0: # tolerance
					inliers += 1
		
		if inliers > best_inliers:
			best_inliers = inliers
			best_circle = circle
	
	if best_circle != null:
		return best_circle.center
	else:
		return null

func fit_circle(points: Array):
	# Fit a circle to 3 points
	var x1 = points[0].x
	var y1 = points[0].y
	var x2 = points[1].x
	var y2 = points[1].y
	var x3 = points[2].x
	var y3 = points[2].y

	var ma = (y2 - y1) / (x2 - x1)
	var mb = (y3 - y2) / (x3 - x2)
	var center = Vector2.ZERO
	center.x = (ma * mb * (y1 - y3) + mb * (x1 + x2) - ma * (x2 + x3)) / (2 * (mb - ma))
	center.y = (-1 / ma) * (center.x - (x1 + x2) / 2) + (y1 + y2) / 2
	var radius = (center - points[0]).length()

	
	return { "center": center, "radius": radius }