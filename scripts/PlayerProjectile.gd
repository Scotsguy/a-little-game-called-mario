extends Area2D
class_name PlayerProjectile

# Emitted before deletion.
signal destroyed

export(float) var projectile_speed := 20.0
export(bool) var look_at_direction := true

var _direction := Vector2()
var _active := false


func _ready():
	self.connect("body_entered", self, "_body_entered")


# This is called by the player to set things in motion
func start_moving(dir: Vector2 = Vector2()):
	_handle_start(dir)
	_active = true
	_direction = dir.normalized()


# Override this to play sounds or other animations
func _handle_start(_dir: Vector2):
	pass


func _physics_process(_delta: float):
	if _active:
		_handle_movement()
		if look_at_direction and _direction != Vector2():
			look_at(position + _direction)


# Override to do anything else than move in a straight line
func _handle_movement():
	position += _direction * projectile_speed


func _body_entered(body):
	# If whatever we touched is an enemy and it can be killed, kill it.
	if _active and body.is_in_group("enemy") and body.has_method("kill"):
		body.kill(self)
	destroy()


func destroy():
	if not _active:
		return
	set_deferred("monitorable", false)
	set_deferred("monitoring", false)
	_active = false
	var res = _handle_destruction()
	if res is GDScriptFunctionState:
		yield(res, "completed")
	emit_signal("destroyed")
	queue_free()


# Override to add fancy effects
func _handle_destruction():
	pass
