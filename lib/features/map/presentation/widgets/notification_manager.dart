import 'dart:async';
import 'package:flutter/material.dart';

class NotificationManager {
  static final _controller = StreamController<_NotificationData>.broadcast();
  static Stream<_NotificationData> get stream => _controller.stream;
  
  static void show(
    String message, {
      Color color = Colors.blue, 
      Duration duration = const Duration(seconds: 2)
      }
    ) 
    {
      _controller.add(_NotificationData(
        message: message, 
        color: color, 
        duration: duration
      )
    );
  }
  
  static void dispose() {
    _controller.close();
  }
}

class _NotificationData {
  final String message;
  final Color color;
  final Duration duration;
  
  _NotificationData({
    required this.message,
    required this.color,
    required this.duration,
  });
}

class CustomSnackbar extends StatelessWidget {
  final String message;
  final Color backgroundColor;
  final IconData icon;
  
  const CustomSnackbar({
    super.key,
    required this.message,
    this.backgroundColor = Colors.blue,
    this.icon = Icons.route,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
               
              },
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationOverlay extends StatefulWidget {
  final Widget child;
  
  const NotificationOverlay({super.key, required this.child});
  
  @override
  State<NotificationOverlay> createState() => _NotificationOverlayState();
}

class _NotificationOverlayState extends State<NotificationOverlay> {
  _NotificationData? _currentNotification;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    NotificationManager.stream.listen((notification) {
      setState(() {
        _currentNotification = notification;
      });
      
      _timer?.cancel();
      _timer = Timer(notification.duration, () {
        if (mounted) {
          setState(() {
            _currentNotification = null;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_currentNotification != null)
          Positioned(
            top: 110,
            left: 16,
            right: 16,
            child: CustomSnackbar(
              message: _currentNotification!.message,
              backgroundColor: _currentNotification!.color,
            ),
          ),
      ],
    );
  }
}