extends Node

const PORT: int = 19132
var ip: String

func _ready() -> void:
	pass
	
func become_server():
	var server_peer := ENetMultiplayerPeer.new()
	server_peer.create_server(PORT)
	multiplayer.multiplayer_peer = server_peer

func become_client(server_ip: String):
	ip = server_ip
	var client_peer := ENetMultiplayerPeer.new()
	client_peer.create_client(ip, PORT)
	multiplayer.multiplayer_peer = client_peer
