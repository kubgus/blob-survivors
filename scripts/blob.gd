extends CharacterBody3D
class_name Blob

@onready var name_label := $Labels/NameLabel
@onready var stats_label := $Labels/StatsLabel
@onready var status_label := $Labels/StatusLabel

@export_subgroup("Evolving Stats")
## The value `current_health` is set to when healed or spawned.
@export var max_health: float
## Chance of picking following food instead of enemies.
@export var peacefulness: float
## Amount of health subtracted from an enemy during a fight each second.
@export var strength: float

@export_subgroup("Permanent Stats")
@export var speed: float
@export var health_loss_per_sec: float
@export var mutation_range: float
@export var recolor_chance: float

# Inherited values
var parent: Blob = null
var color: Color

# Dynamic values
@onready var current_health := max_health
var target: Node3D = null
var enemy: Blob = null

# Static values
var self_scene: PackedScene

func set_color(new_color: Color) -> void:
	color = new_color
	
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	$BlobModel/Mball.set_surface_override_material(0, mat)

func _ready() -> void:
	self_scene = PackedScene.new()
	self_scene.pack(self)
	
	if parent != null and randf_range(0,1) > recolor_chance:
		max_health = parent.max_health + randf_range(-mutation_range, mutation_range)
		peacefulness = parent.peacefulness + randf_range(-mutation_range, mutation_range)
		strength = parent.strength + randf_range(-mutation_range, mutation_range)
		set_color(parent.color)
		name = parent.name.split("#")[0] + "#1"
	else:
		set_color(Color(
			randf_range(0, 1),
			randf_range(0, 1),
			randf_range(0, 1),
		))
	
	name_label.text = name

func _process(delta: float) -> void:
	# Preserve height and rotation
	position.y = 0
	rotation.z = 0
	rotation.x = 0
	# Health logic
	current_health -= health_loss_per_sec * delta
	stats_label.text = \
		str(current_health).pad_decimals(2) + "/" + str(max_health).pad_decimals(2) + \
		", P:" + str(peacefulness).pad_decimals(2) + ", S:" + str(strength).pad_decimals(2)
	if current_health < 0.0:
		queue_free()
	# Attack enemies
	if enemy != null:
		enemy.current_health -= strength * delta
	# Fleeing
	if target is Blob and current_health < peacefulness:
		target = null

func _physics_process(delta: float) -> void:
	if target != null:
		status_label.text = "Following " + target.name
		velocity = (target.position - position).normalized() * speed
	else:
		status_label.text = "Wandering"
		const velocity_change_chance := 120
		if velocity == Vector3.ZERO or randi_range(0, velocity_change_chance) == 0:
			var wandering_axes = Vector3(randi_range(-1, 1), 0, randi_range(-1, 1))
			velocity = wandering_axes.normalized() * speed
	if not position.direction_to(position + velocity).is_zero_approx():
		basis = Basis.looking_at(position.direction_to(position + velocity)).slerp(basis, 0.5)
	move_and_slide()

func _on_detection_trigger_body_entered(body: Node3D) -> void:
	if body == self:
		return
	var previously_satisfied := \
		target != null \
		and (target is Apple or current_health > peacefulness)
	if not previously_satisfied and not (body is Blob and body.color == color and body.target == self):
		target = body
		body.tree_exiting.connect(func(): if target == body: target = null)

func _on_action_trigger_body_entered(body: Node3D) -> void:
	if body is Blob and body.color == color:
		return
	if body is Apple:
		# Eat
		body.queue_free()
		# Heal
		current_health = max_health
		# Reproduce
		var offspring: Blob = self_scene.instantiate()
		offspring.parent = self
		
		var spawn_range = 10.0
		offspring.position = Vector3(
			position.x + randf_range(-spawn_range, spawn_range),
			position.y,
			position.z + randf_range(-spawn_range, spawn_range),
		)
		
		get_parent().add_child(offspring)
	elif body is Blob:
		enemy = body
		body.tree_exited.connect(func(): if enemy == body: enemy = null)

func _on_action_trigger_body_exited(body: Node3D) -> void:
	if body is Blob and body.color == color:
		return
	if body == enemy:
		enemy = null
