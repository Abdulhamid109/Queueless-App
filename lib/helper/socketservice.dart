import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;
  SocketService._internal();

  late IO.Socket socket;
  bool _isInitialized = false;

  void init({required String serverUrl}) {
    if (_isInitialized) return;

    socket = IO.io(
      serverUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])   
          .disableAutoConnect()           
          .build(),
    );

    _registerDefaultListeners();
    socket.connect();
    _isInitialized = true;
  }

  void _registerDefaultListeners() {
    socket.onConnect((_) {
      print('Socket connected: ${socket.id}');
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
    });

    socket.onConnectError((data) {
      print('Connection error: $data');
    });

    socket.onError((data) {
      print('Socket error: $data');
    });
  }

  void emit(String event, dynamic data) {
    if (socket.connected) {
      socket.emit(event, data);
    } else {
      print('Socket not connected. Cannot emit: $event');
    }
  }
  void onceConnected(void Function() callback) {
    if (socket.connected) {
      callback();
    } else {
      socket.onConnect((_) => callback());
    }
  }

  void on(String event, Function(dynamic) handler) {
    socket.on(event, handler);
  }



  void off(String event) {
    socket.off(event);
  }

  void disconnect() {
    socket.disconnect();
    _isInitialized = false;
  }

  bool get isConnected => socket.connected;
}