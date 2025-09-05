extends Node2D

var PLAYER_SCENE : PackedScene = preload("uid://ddet1530l3hqv")

@onready var spawn_point: Marker2D = $SpawnPoint
@onready var players_node: Node2D = $Players
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var ping_label: Label = %PingLabel

func _ready() -> void:
	multiplayer_spawner.spawn_function = add_player
	if !is_multiplayer_authority():
		c_peer_ready.rpc_id(1)

func _process(_delta: float) -> void:
	if !multiplayer.has_multiplayer_peer():
		ping_label.text = ""
		return

	var mp := multiplayer.multiplayer_peer
	# Serve l'implementazione ENet per avere le statistiche
	if mp is ENetMultiplayerPeer:
		var enet := mp as ENetMultiplayerPeer

		if multiplayer.is_server():
			var total_ping := 0
			var total_loss := 0.0
			var count := 0
			for id in multiplayer.get_peers():
				var pkt := enet.get_peer(id) # <- ENetPacketPeer
				if pkt:
					total_ping += pkt.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME)
					total_loss += pkt.get_statistic(ENetPacketPeer.PEER_PACKET_LOSS)
					count += 1
			if count > 0:
				var avg_ping := int(round(float(total_ping) / count))
				var avg_loss := total_loss / count
				ping_label.text = "srv avg ping: %d ms\navg loss: %.0f" % [avg_ping, avg_loss]
			else:
				ping_label.text = "srv: nessun client"
		else:
			# Client: misura verso il server (ID 1)
			var pkt := enet.get_peer(1) # ENetPacketPeer verso il server
			if pkt:
				var ping_ms := pkt.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME)
				var loss := pkt.get_statistic(ENetPacketPeer.PEER_PACKET_LOSS)
				ping_label.text = "ping: %d ms\npacket loss: %.0f" % [ping_ms, loss]
			else:
				ping_label.text = "ping: n/d"
	else:
		# WebSocket/WebRTC non espongono queste statistiche
		ping_label.text = "ping: n/d (non ENet)"


func add_player(data):
	var player = PLAYER_SCENE.instantiate()
	player.name = str(data.id)
	player.player_id = data.id
	player.global_position = spawn_point.global_position
	return player

@rpc("any_peer", "call_remote", "reliable")
func c_peer_ready():
	var client_id := multiplayer.get_remote_sender_id()
	print("client %d ready!" % client_id)
	multiplayer_spawner.spawn({"id": client_id})
	
