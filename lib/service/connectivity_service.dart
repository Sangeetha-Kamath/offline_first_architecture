import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  
  factory ConnectivityService() => _instance;
  
  ConnectivityService._internal();
  
  late final Connectivity _connectivity;
  
  bool _isOnline = true;
  
  bool get isOnline => _isOnline;
  
  Future<void> initialize() async {
    _connectivity = Connectivity();
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    _isOnline = result != ConnectivityResult.none;
  }
  
  Stream<bool> get statusStream {
    return _connectivity.onConnectivityChanged.map((result) {
      _isOnline = result != ConnectivityResult.none;
      return _isOnline;
    });
  }
}
