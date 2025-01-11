extends Resource
class_name Scatterable

@export var scene: PackedScene
@export var name := "Foo"
@export var initial_count := 10
@export var per_second_count := 1

static var id := 0

func _init() -> void:
	id += 1
