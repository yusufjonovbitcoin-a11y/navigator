import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/features/map_radar/domain/models/map_style.dart';

final mapStyleProvider = StateProvider<MapStyle>((ref) => MapStyle.osmStandard);
