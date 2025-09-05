extends Control

var main_game: PackedScene = preload("uid://ddqa0ud78t2ml")

@onready var serve_button: Button = %ServeButton
@onready var join_button: Button = %JoinButton
@onready var ip_line_edit: LineEdit = %IpLineEdit


func _ready() -> void:		
	serve_button.pressed.connect(_on_serve_button)
	join_button.pressed.connect(_on_join_pressed)
	multiplayer.connected_to_server.connect(_on_connected)
	
	var args = Array(OS.get_cmdline_args())
	if OS.has_feature("dedicated_server") || args.has("-s"):
		_on_serve_button()
	
	if OS.has_feature("editor"):
		print("RUNNING IN EDITOR")
		ip_line_edit.text = "127.0.0.1"

func _on_serve_button() -> void:
	NetworkManager.become_server()
	await get_tree().process_frame # aspetta che la scena corrente sia caricata prima di cambiarla
	get_tree().change_scene_to_packed(main_game)

func _on_join_pressed() -> void:
	NetworkManager.become_client(ip_line_edit.text.strip_edges())

func _on_connected():
	get_tree().change_scene_to_packed(main_game)
