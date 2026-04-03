extends Node
class_name NetworkLobby

signal lobby_created(port)
signal lobby_joined(host, port)
signal player_joined(peer_id, name)
signal player_left(peer_id)
signal lobby_closed()
signal network_error(message)

@export var default_port: int = 7777
@export var max_players: int = 8

func _ready() -> void:
    pass

func start_host(port: int = -1) -> void:
    var server_port: int
    if port > 0:
        server_port = port
    else:
        server_port = default_port
    var peer = ENetMultiplayerPeer.new()
    var err = peer.create_server(server_port, max_players)
    if err != OK:
        emit_signal("network_error", "Failed to start server: %s" % err)
        return
    get_tree().network_peer = peer
    _connect_events()
    emit_signal("lobby_created", server_port)

func join_lobby(host: String, port: int = -1) -> void:
    var connect_port: int
    if port > 0:
        connect_port = port
    else:
        connect_port = default_port
    var peer = ENetMultiplayerPeer.new()
    var err = peer.create_client(host, connect_port)
    if err != OK:
        emit_signal("network_error", "Failed to join: %s" % err)
        return
    get_tree().network_peer = peer
    _connect_events()
    emit_signal("lobby_joined", host, connect_port)

func leave_lobby() -> void:
    if get_tree().network_peer:
        get_tree().network_peer.close_connection()
    get_tree().network_peer = null
    emit_signal("lobby_closed")

func _connect_events() -> void:
    var mp = get_tree().multiplayer
    if mp is MultiplayerAPI:
        mp.peer_connected.connect(Callable(self, "_on_peer_connected"))
        mp.peer_disconnected.connect(Callable(self, "_on_peer_disconnected"))
        mp.connection_failed.connect(Callable(self, "_on_connection_failed"))
        mp.server_disconnected.connect(Callable(self, "_on_server_disconnected"))

func _on_peer_connected(id: int) -> void:
    emit_signal("player_joined", id, "Player %d" % id)

func _on_peer_disconnected(id: int) -> void:
    emit_signal("player_left", id)

func _on_connection_failed() -> void:
    emit_signal("network_error", "Connection failed")

func _on_server_disconnected() -> void:
    emit_signal("network_error", "Server disconnected")
