import 'package:equatable/equatable.dart';

abstract class MapEvent extends Equatable{
  const MapEvent();

  @override
  List<Object> get props => [];
}

class LoadLocation extends MapEvent {}
class CenterOnUser extends MapEvent {}
class ResetForceCenter extends MapEvent {}