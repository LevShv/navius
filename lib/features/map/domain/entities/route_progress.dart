import 'package:equatable/equatable.dart';

class RouteProgress extends Equatable {
  final double remainingDistance; 
  final int remainingDuration; 
  final DateTime eta;
  final double progressPercent; 
  
  const RouteProgress({
    required this.remainingDistance,
    required this.remainingDuration,
    required this.eta,
    required this.progressPercent,
  });
  
  String get formattedRemainingDistance {
    if (remainingDistance >= 1000) {
      return '${(remainingDistance / 1000).toStringAsFixed(1)} км';
    }
    return '${remainingDistance.round()} м';
  }
  
  String get formattedRemainingDuration {
    final hours = Duration(seconds: remainingDuration).inHours;
    final minutes = Duration(seconds: remainingDuration).inMinutes.remainder(60);
    
    if (hours > 0) {
      return '$hours ч $minutes мин';
    }
    return '$minutes мин';
  }
  
  String get formattedEta {
    return _formatTime(eta);
  }
  
  String get formattedRemainingTime {
    final now = DateTime.now();
    final difference = eta.difference(now);
    
    if (difference.inMinutes < 1) {
      return 'менее минуты';
    }
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин';
    }
    
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    return '$hours ч $minutes мин';
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  @override
  List<Object?> get props => [
    remainingDistance, 
    remainingDuration, 
    eta, 
    progressPercent,
  ];
}