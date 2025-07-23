// // File: lib/features/training/presentation/widgets/audio_feedback_status.dart
// import 'package:flutter/material.dart';
// import '../../../../core/services/audio_feedback_service.dart';
// import '../../../../core/theme/app_theme.dart';
//
// class AudioFeedbackStatus extends StatefulWidget {
//   final bool soundEnabled;
//   final bool isMonitoring;
//
//   const AudioFeedbackStatus({
//     Key? key,
//     required this.soundEnabled,
//     required this.isMonitoring,
//   }) : super(key: key);
//
//   @override
//   State<AudioFeedbackStatus> createState() => _AudioFeedbackStatusState();
// }
//
// class _AudioFeedbackStatusState extends State<AudioFeedbackStatus>
//     with TickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late Animation<double> _pulseAnimation;
//
//   Map<String, dynamic> _audioStatus = {};
//
//   @override
//   void initState() {
//     super.initState();
//
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );
//
//     _pulseAnimation = Tween<double>(
//       begin: 0.8,
//       end: 1.2,
//     ).animate(CurvedAnimation(
//       parent: _pulseController,
//       curve: Curves.easeInOut,
//     ));
//
//     _updateAudioStatus();
//
//     // Update status periodically when monitoring
//     if (widget.isMonitoring) {
//       _startStatusUpdates();
//     }
//   }
//
//   @override
//   void didUpdateWidget(AudioFeedbackStatus oldWidget) {
//     super.didUpdateWidget(oldWidget);
//
//     if (widget.isMonitoring != oldWidget.isMonitoring) {
//       if (widget.isMonitoring) {
//         _startStatusUpdates();
//       } else {
//         _stopStatusUpdates();
//       }
//     }
//
//     _updateAudioStatus();
//   }
//
//   void _startStatusUpdates() {
//     _pulseController.repeat(reverse: true);
//   }
//
//   void _stopStatusUpdates() {
//     _pulseController.stop();
//     _pulseController.reset();
//   }
//
//   void _updateAudioStatus() {
//     if (mounted) {
//       setState(() {
//         _audioStatus = AudioFeedbackService().getStatus();
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _pulseController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: widget.soundEnabled ?
//         (widget.isMonitoring ? Colors.green[50] : Colors.blue[50]) :
//         Colors.grey[100],
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(
//           color: widget.soundEnabled ?
//           (widget.isMonitoring ? Colors.green : Colors.blue) :
//           Colors.grey,
//           width: 1,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Icon(
//                 widget.soundEnabled ? Icons.volume_up : Icons.volume_off,
//                 color: widget.soundEnabled ?
//                 (widget.isMonitoring ? Colors.green : Colors.blue) :
//                 Colors.grey,
//                 size: 20,
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 'Audio Feedback',
//                 style: TextStyle(
//                   fontWeight: FontWeight.w600,
//                   color: widget.soundEnabled ?
//                   (widget.isMonitoring ? Colors.green : Colors.blue) :
//                   Colors.grey,
//                 ),
//               ),
//               const Spacer(),
//               if (widget.isMonitoring && widget.soundEnabled)
//                 AnimatedBuilder(
//                   animation: _pulseAnimation,
//                   builder: (context, child) {
//                     return Transform.scale(
//                       scale: _pulseAnimation.value,
//                       child: Container(
//                         width: 8,
//                         height: 8,
//                         decoration: const BoxDecoration(
//                           color: Colors.green,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//             ],
//           ),
//           const SizedBox(height: 8),
//
//           // Status Text
//           Text(
//             _getStatusText(),
//             style: TextStyle(
//               fontSize: 12,
//               color: Colors.grey[600],
//             ),
//           ),
//
//           // Active Audio Indicators
//           if (widget.soundEnabled && widget.isMonitoring && _hasActiveAudio())
//             Padding(
//               padding: const EdgeInsets.only(top: 8),
//               child: Row(
//                 children: [
//                   if (_audioStatus['currentCant'] != null)
//                     _buildAudioIndicator(
//                       'CANT',
//                       _audioStatus['currentCant'],
//                       _audioStatus['cantLevel'] ?? 1,
//                       Colors.orange,
//                     ),
//                   if (_audioStatus['currentCant'] != null && _audioStatus['currentTilt'] != null)
//                     const SizedBox(width: 12),
//                   if (_audioStatus['currentTilt'] != null)
//                     _buildAudioIndicator(
//                       'TILT',
//                       _audioStatus['currentTilt'],
//                       _audioStatus['tiltLevel'] ?? 1,
//                       Colors.purple,
//                     ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   String _getStatusText() {
//     if (!widget.soundEnabled) {
//       return 'Audio feedback disabled';
//     }
//
//     if (!widget.isMonitoring) {
//       return 'Ready - Start monitoring to enable feedback';
//     }
//
//     if (_hasActiveAudio()) {
//       List<String> activeDirections = [];
//       if (_audioStatus['currentCant'] != null) {
//         activeDirections.add('${_audioStatus['currentCant']} cant');
//       }
//       if (_audioStatus['currentTilt'] != null) {
//         activeDirections.add('${_audioStatus['currentTilt']} tilt');
//       }
//       return 'Active: ${activeDirections.join(', ')}';
//     }
//
//     return 'Monitoring - Position within tolerance';
//   }
//
//   bool _hasActiveAudio() {
//     return _audioStatus['currentCant'] != null || _audioStatus['currentTilt'] != null;
//   }
//
//   Widget _buildAudioIndicator(String type, String direction, int level, Color color) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color, width: 1),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             type,
//             style: TextStyle(
//               fontSize: 10,
//               fontWeight: FontWeight.bold,
//               color: color,
//             ),
//           ),
//           const SizedBox(width: 4),
//           Icon(
//             _getDirectionIcon(direction),
//             size: 12,
//             color: color,
//           ),
//           const SizedBox(width: 4),
//           // Urgency level indicators
//           Row(
//             children: List.generate(3, (index) {
//               return Container(
//                 width: 3,
//                 height: 8,
//                 margin: const EdgeInsets.symmetric(horizontal: 1),
//                 decoration: BoxDecoration(
//                   color: index < level ? color : color.withOpacity(0.3),
//                   borderRadius: BorderRadius.circular(1),
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//     );
//   }
//
//   IconData _getDirectionIcon(String direction) {
//     switch (direction.toLowerCase()) {
//       case 'left':
//         return Icons.keyboard_arrow_left;
//       case 'right':
//         return Icons.keyboard_arrow_right;
//       case 'up':
//         return Icons.keyboard_arrow_up;
//       case 'down':
//         return Icons.keyboard_arrow_down;
//       default:
//         return Icons.radio_button_checked;
//     }
//   }
// }
//
