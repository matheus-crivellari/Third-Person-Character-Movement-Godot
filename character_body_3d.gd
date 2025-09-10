class_name Player

extends CharacterBody3D

@export var speed := 9.0
@export var jump_velocity := 7
@export var mouse_sensitivity := 0.002

@onready var _camera_gimbal: Node3D = $Node3D
@onready var _spring_arm: SpringArm3D = $Node3D/SpringArm3D
@onready var _mesh: MeshInstance3D = $MeshInstance3D


func _ready():
  Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta):
  # Add the gravity.
  if not is_on_floor():
    velocity += get_gravity() * delta

  # Handle jump.
  if Input.is_action_just_pressed("ui_accept") and is_on_floor():
    velocity.y = jump_velocity

  # Get the input direction and handle the movement/deceleration.
  var input_dir = Input.get_vector("left", "right", "forward", "backward")
  var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
  
  if direction:
    velocity.x = direction.x * speed
    velocity.z = direction.z * speed
  else:
    velocity.x = move_toward(velocity.x, 0, speed)
    velocity.z = move_toward(velocity.z, 0, speed)
    
  var current_camera: Camera3D = get_viewport().get_camera_3d()
  velocity = velocity.rotated(Vector3.UP, current_camera.global_rotation.y)
  
  var desired_rotation := Vector3.UP * current_camera.global_rotation.y
  var desired_basis := Basis.from_euler(desired_rotation)
  var interpolated_basis := _mesh.basis.slerp(desired_basis,.25)
  
  _mesh.basis = interpolated_basis

  move_and_slide()


func _input(event):
  if event.is_action_pressed("ui_cancel"):
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    
  if event.is_action_pressed("click"):
    if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
      Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
  
  if event is InputEventMouseMotion:
    _camera_gimbal.rotate_y(-event.relative.x * mouse_sensitivity)
    
    _spring_arm.rotate_x(-event.relative.y * mouse_sensitivity)
    _spring_arm.rotation.x = clampf(_spring_arm.rotation.x, -deg_to_rad(70), deg_to_rad(70))
