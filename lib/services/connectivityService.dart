import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance =
      ConnectivityService._();

  final Connectivity _connectivity = Connectivity();

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool isConnected = true;

  final StreamController<bool> _controller =
      StreamController<bool>.broadcast();

  Stream<bool> get connectionStream => _controller.stream;

  Future<void> initialize() async {
    final result = await _connectivity.checkConnectivity();

    _updateConnection(result);

    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnection,
    );
  }

  // THIS is for Try Again
  Future<void> checkNow() async {
    final result = await _connectivity.checkConnectivity();

    _updateConnection(result);
  }

  void _updateConnection(List<ConnectivityResult> result) {
    final connected =
        !result.contains(ConnectivityResult.none);

    isConnected = connected;

    if (!_controller.isClosed) {
      _controller.add(connected);
    }

    print("Internet connection: $connected");
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}