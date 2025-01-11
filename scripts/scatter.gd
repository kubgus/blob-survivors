extends Node3D
class_name Scatter

@export var scatter_range := 50
@export var scatter_items: Array[Scatterable]

## Time in seconds since last continuous spawn.
var time_since_last_spawn := 0.0

func get_random_spawn_pos() -> Vector3:
	return Vector3(
		randf_range(-scatter_range, scatter_range),
		0.0,
		randf_range(-scatter_range, scatter_range),
	)
	
func instantiate_at(
	spawn_position: Vector3,
	scene: PackedScene,
	new_name: String = "Foo",
) -> Node3D:
	var instance: Node3D = scene.instantiate()
	add_child(instance)
	instance.position = spawn_position
	instance.name = new_name
	return instance

func _enter_tree() -> void:
	for item in scatter_items:
		for i in range(item.initial_count):
			var instance := instantiate_at(
				get_random_spawn_pos(),
				item.scene,
				item.name + str(item.id)
			)

func _process(delta: float) -> void:
	time_since_last_spawn += delta
	if time_since_last_spawn >= 1.0:
		for item in scatter_items:
			for i in range(item.per_second_count):
				var instance := instantiate_at(
					get_random_spawn_pos(),
					item.scene,
					item.name + str(item.id)
				)
				instance.name = item.name + str(item.id)
		time_since_last_spawn = 0.0
