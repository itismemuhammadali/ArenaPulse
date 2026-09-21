import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:sports_chat_app/src/services/osrm_routing_service.dart';
import 'package:sports_chat_app/src/services/voice_guidance_service.dart';
import 'package:sports_chat_app/src/services/facility_service.dart';

class TurnByTurnOverlay extends StatefulWidget {
  final RoutePlan routePlan;
  final String destinationTitle;
  final String destinationPhone;
  final FacilityBooking? activeBooking;
  final VoidCallback onEndNavigation;
  final Function(LatLng currentPos)? onPositionChanged;

  const TurnByTurnOverlay({
    super.key,
    required this.routePlan,
    required this.destinationTitle,
    this.destinationPhone = '',
    this.activeBooking,
    required this.onEndNavigation,
    this.onPositionChanged,
  });

  @override
  State<TurnByTurnOverlay> createState() => _TurnByTurnOverlayState();
}

class _TurnByTurnOverlayState extends State<TurnByTurnOverlay> {
  final VoiceGuidanceService _voiceService = VoiceGuidanceService();
  int _currentStepIndex = 0;
  bool _isSimulating = false;
  Timer? _simTimer;
  int _simPointIndex = 0;
  double _currentSpeedKmh = 38.0;

  @override
  void initState() {
    super.initState();
    _startInitialVoice();
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    _voiceService.stop();
    super.dispose();
  }

  void _startInitialVoice() {
    if (widget.routePlan.steps.isNotEmpty) {
      final firstStep = widget.routePlan.steps[0];
      final text = 'Starting route to ${widget.destinationTitle}. '
          '${widget.routePlan.totalDistanceKm.toStringAsFixed(1)} kilometers remaining. '
          '${firstStep.instruction}.';
      _voiceService.speak(text);
    }
  }

  void _toggleSimulation() {
    if (_isSimulating) {
      _simTimer?.cancel();
      setState(() {
        _isSimulating = false;
      });
      return;
    }

    setState(() {
      _isSimulating = true;
    });

    final poly = widget.routePlan.polyline;
    if (poly.isEmpty) return;

    _simTimer = Timer.periodic(const Duration(milliseconds: 750), (timer) {
      if (_simPointIndex >= poly.length - 1) {
        timer.cancel();
        setState(() {
          _isSimulating = false;
        });
        _voiceService.speak('You have arrived at ${widget.destinationTitle}.');
        return;
      }

      _simPointIndex++;
      final currentPos = poly[_simPointIndex];
      widget.onPositionChanged?.call(currentPos);

      // Check step advancement
      if (_currentStepIndex < widget.routePlan.steps.length - 1) {
        final nextStep = widget.routePlan.steps[_currentStepIndex + 1];
        const dist = Distance();
        final metersToNext = dist.as(LengthUnit.Meter, currentPos, nextStep.location);
        if (metersToNext < 60) {
          setState(() {
            _currentStepIndex++;
          });
          _voiceService.speak(nextStep.instruction);
        }
      }

      setState(() {
        _currentSpeedKmh = 35.0 + (_simPointIndex % 4) * 3.5;
      });
    });
  }

  IconData _getManeuverIcon(RouteStep step) {
    final mod = step.modifier.toLowerCase();
    final type = step.maneuverType.toLowerCase();

    if (type == 'arrive') return Icons.flag_rounded;
    if (mod.contains('slight left')) return Icons.turn_slight_left_rounded;
    if (mod.contains('slight right')) return Icons.turn_slight_right_rounded;
    if (mod.contains('left')) return Icons.turn_left_rounded;
    if (mod.contains('right')) return Icons.turn_right_rounded;
    if (mod.contains('uturn')) return Icons.u_turn_left_rounded;
    return Icons.straight_rounded;
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toInt()} m';
  }

  bool _isLateForBooking() {
    if (widget.activeBooking == null) return false;
    final now = DateTime.now();
    final eta = now.add(Duration(minutes: widget.routePlan.totalDurationMinutes));
    final slotStart = DateTime(now.year, now.month, now.day, widget.activeBooking!.startHour);
    return eta.isAfter(slotStart);
  }

  Future<void> _callVenue() async {
    final phone = widget.destinationPhone.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number registered for this venue desk.')),
      );
      return;
    }
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = (widget.routePlan.steps.isNotEmpty &&
            _currentStepIndex < widget.routePlan.steps.length)
        ? widget.routePlan.steps[_currentStepIndex]
        : null;

    final isLate = _isLateForBooking();
    final now = DateTime.now();
    final etaTime = now.add(Duration(minutes: widget.routePlan.totalDurationMinutes));
    final etaStr =
        '${etaTime.hour > 12 ? etaTime.hour - 12 : (etaTime.hour == 0 ? 12 : etaTime.hour)}:${etaTime.minute.toString().padLeft(2, '0')} ${etaTime.hour >= 12 ? 'PM' : 'AM'}';

    return Stack(
      children: [
        // Top Turn Maneuver Banner
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        currentStep != null
                            ? _getManeuverIcon(currentStep)
                            : Icons.straight_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            currentStep != null
                                ? _formatDistance(currentStep.distanceMeters)
                                : '100 m',
                            style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            currentStep?.instruction ?? 'Proceed along route',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _voiceService.isMuted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: _voiceService.isMuted ? Colors.white38 : Colors.greenAccent,
                      ),
                      tooltip: _voiceService.isMuted ? 'Unmute Voice' : 'Mute Voice',
                      onPressed: () {
                        setState(() {
                          _voiceService.toggleMute();
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Late Arrival Warning Banner (If Booking at risk)
              if (isLate) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C2D12).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF97316)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFFDBA74), size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Delay Warning: Slot starts at ${widget.activeBooking!.startHour}:00, ETA is $etaStr',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: _callVenue,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEA580C),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.call, color: Colors.white, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'Call Desk',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Bottom Navigation Dashboard
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Destination header
                Row(
                  children: [
                    const Icon(Icons.sports_cricket, color: Color(0xFF10B981), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.destinationTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        '${_currentSpeedKmh.toInt()} km/h',
                        style: const TextStyle(
                          color: Color(0xFF38BDF8),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12, height: 20),

                // Metrics Row: ETA, Remaining Time, Distance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetric(
                      label: 'ARRIVAL (ETA)',
                      value: etaStr,
                      color: isLate ? const Color(0xFFF97316) : Colors.greenAccent,
                    ),
                    Container(width: 1, height: 32, color: Colors.white12),
                    _buildMetric(
                      label: 'TIME LEFT',
                      value: '${widget.routePlan.totalDurationMinutes} min',
                      color: Colors.white,
                    ),
                    Container(width: 1, height: 32, color: Colors.white12),
                    _buildMetric(
                      label: 'DISTANCE',
                      value: '${widget.routePlan.totalDistanceKm.toStringAsFixed(1)} km',
                      color: const Color(0xFF38BDF8),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Actions: End Navigation & Simulate Drive
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _isSimulating ? Colors.orangeAccent : Colors.white70,
                          side: BorderSide(
                            color: _isSimulating ? Colors.orangeAccent : Colors.white24,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: Icon(
                          _isSimulating ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 18,
                        ),
                        label: Text(
                          _isSimulating ? 'Pause Test' : 'Simulate Drive',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        onPressed: _toggleSimulation,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.close_rounded, size: 18),
                        label: const Text(
                          'End Navigation',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        onPressed: widget.onEndNavigation,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetric({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
