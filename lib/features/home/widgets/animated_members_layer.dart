import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/models/models.dart';
import 'member_marker.dart';

/// Marker layer that tweens member positions (~800 ms) instead of letting
/// them jump. Only this layer rebuilds on each animation frame.
class AnimatedMembersLayer extends StatefulWidget {
  const AnimatedMembersLayer({
    super.key,
    required this.located,
    required this.selfUid,
    required this.selectedUid,
    required this.onSelect,
  });

  final List<CircleMember> located;
  final String selfUid;
  final String? selectedUid;
  final ValueChanged<CircleMember> onSelect;

  @override
  State<AnimatedMembersLayer> createState() => _AnimatedMembersLayerState();
}

class _AnimatedMembersLayerState extends State<AnimatedMembersLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
    value: 1,
  );
  final Map<String, LatLng> _from = {};
  final Map<String, LatLng> _to = {};

  @override
  void initState() {
    super.initState();
    for (final member in widget.located) {
      final target = LatLng(member.lat!, member.lng!);
      _to[member.uid] = target;
      _from[member.uid] = target;
    }
  }

  @override
  void didUpdateWidget(AnimatedMembersLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    var changed = false;
    for (final member in widget.located) {
      final target = LatLng(member.lat!, member.lng!);
      final previous = _to[member.uid];
      if (previous == null || previous != target) {
        _from[member.uid] = _currentPosition(member.uid) ?? target;
        _to[member.uid] = target;
        changed = true;
      }
    }
    if (changed) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LatLng? _currentPosition(String uid) {
    final from = _from[uid];
    final to = _to[uid];
    if (from == null || to == null) return null;
    final t = Curves.easeInOut.transform(_controller.value);
    return LatLng(
      from.latitude + (to.latitude - from.latitude) * t,
      from.longitude + (to.longitude - from.longitude) * t,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final usedPoints = <String, int>{};
        final markers = <Marker>[];
        for (final member in widget.located) {
          var point = _currentPosition(member.uid) ??
              LatLng(member.lat!, member.lng!);
          final key =
              '${point.latitude.toStringAsFixed(4)},${point.longitude.toStringAsFixed(4)}';
          final duplicateIndex = usedPoints[key] ?? 0;
          usedPoints[key] = duplicateIndex + 1;
          if (duplicateIndex > 0) {
            final shift = 0.00018 * duplicateIndex;
            point = LatLng(point.latitude + shift, point.longitude + shift);
          }
          markers.add(
            Marker(
              point: point,
              width: 260,
              height: 190,
              alignment: Alignment.topCenter,
              child: RepaintBoundary(
                child: MemberMarker(
                  member: member,
                  isSelf: member.uid == widget.selfUid,
                  selected: member.uid == widget.selectedUid,
                  onTap: () => widget.onSelect(member),
                ),
              ),
            ),
          );
        }
        return MarkerLayer(markers: markers);
      },
    );
  }
}
