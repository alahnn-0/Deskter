// import 'package:flutter/material.dart';
// import '../services/notification_service.dart';
// import '../constants/theme.dart';

// class NotificationScreen extends StatefulWidget {
//   const NotificationScreen({super.key});

//   @override
//   State<NotificationScreen> createState() => _NotificationScreenState();
// }

// class _NotificationScreenState extends State<NotificationScreen> {
//   bool dailyEnabled = true;
//   bool streakEnabled = true;
//   TimeOfDay dailyTime = const TimeOfDay(hour: 8, minute: 0);
//   TimeOfDay streakTime = const TimeOfDay(hour: 20, minute: 0);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.bg,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('SETTINGS', style: AppText.label),
//               const SizedBox(height: 4),
//               Text('Notifications', style: AppText.title),
//               const SizedBox(height: 24),

//               // daily reminder
//               _buildNotificationCard(
//                 icon: '⚔️',
//                 title: 'Daily Quest Reminder',
//                 subtitle: 'Reminds you to complete your tasks',
//                 enabled: dailyEnabled,
//                 time: dailyTime,
//                 onToggle: (val) async {
//                   setState(() => dailyEnabled = val);
//                   if (val) {
//                     await NotificationService().scheduleDailyReminder(
//                       hour: dailyTime.hour,
//                       minute: dailyTime.minute,
//                     );
//                   } else {
//                     await NotificationService().cancel(0);
//                   }
//                 },
//                 onTimeTap: () async {
//                   final picked = await showTimePicker(
//                     context: context,
//                     initialTime: dailyTime,
//                     builder: (context, child) => Theme(
//                       data: ThemeData.dark().copyWith(
//                         colorScheme: const ColorScheme.dark(
//                           primary: AppColors.accent,
//                           surface: AppColors.surface,
//                         ),
//                       ),
//                       child: child!,
//                     ),
//                   );
//                   if (picked != null) {
//                     setState(() => dailyTime = picked);
//                     if (dailyEnabled) {
//                       await NotificationService().scheduleDailyReminder(
//                         hour: picked.hour,
//                         minute: picked.minute,
//                       );
//                     }
//                   }
//                 },
//               ),
//               const SizedBox(height: 12),

//               // streak reminder
//               _buildNotificationCard(
//                 icon: '🔥',
//                 title: 'Streak Protection',
//                 subtitle: 'Alerts you if streak is at risk',
//                 enabled: streakEnabled,
//                 time: streakTime,
//                 onToggle: (val) async {
//                   setState(() => streakEnabled = val);
//                   if (val) {
//                     await NotificationService().scheduleStreakReminder(
//                       hour: streakTime.hour,
//                       minute: streakTime.minute,
//                     );
//                   } else {
//                     await NotificationService().cancel(1);
//                   }
//                 },
//                 onTimeTap: () async {
//                   final picked = await showTimePicker(
//                     context: context,
//                     initialTime: streakTime,
//                     builder: (context, child) => Theme(
//                       data: ThemeData.dark().copyWith(
//                         colorScheme: const ColorScheme.dark(
//                           primary: AppColors.accent,
//                           surface: AppColors.surface,
//                         ),
//                       ),
//                       child: child!,
//                     ),
//                   );
//                   if (picked != null) {
//                     setState(() => streakTime = picked);
//                     if (streakEnabled) {
//                       await NotificationService().scheduleStreakReminder(
//                         hour: picked.hour,
//                         minute: picked.minute,
//                       );
//                     }
//                   }
//                 },
//               ),
//               const SizedBox(height: 24),

//               // info card
//               Container(
//                 padding: const EdgeInsets.all(14),
//                 decoration: BoxDecoration(
//                   color: AppColors.surface,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                       color: AppColors.accent.withOpacity(0.3)),
//                 ),
//                 child: const Row(
//                   children: [
//                     Icon(Icons.info_outline,
//                         color: AppColors.accentLight, size: 18),
//                     SizedBox(width: 10),
//                     Expanded(
//                       child: Text(
//                         'Goal deadline reminders are sent automatically when you create a goal.',
//                         style: TextStyle(
//                             fontSize: 12,
//                             color: AppColors.textMuted),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNotificationCard({
//     required String icon,
//     required String title,
//     required String subtitle,
//     required bool enabled,
//     required TimeOfDay time,
//     required Function(bool) onToggle,
//     required VoidCallback onTimeTap,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: enabled
//               ? AppColors.accent.withOpacity(0.3)
//               : AppColors.border,
//         ),
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Text(icon, style: const TextStyle(fontSize: 20)),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(title,
//                         style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: AppColors.textPrimary)),
//                     Text(subtitle,
//                         style: const TextStyle(
//                             fontSize: 11,
//                             color: AppColors.textMuted)),
//                   ],
//                 ),
//               ),
//               Switch(
//                 value: enabled,
//                 onChanged: onToggle,
//                 activeColor: AppColors.accent,
//               ),
//             ],
//           ),
//           if (enabled) ...[
//             const SizedBox(height: 10),
//             GestureDetector(
//               onTap: onTimeTap,
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(
//                     horizontal: 14, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: AppColors.surface2,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: AppColors.border),
//                 ),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.access_time,
//                         size: 14, color: AppColors.textMuted),
//                     const SizedBox(width: 8),
//                     Text(
//                       '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
//                       style: const TextStyle(
//                           fontSize: 14,
//                           color: AppColors.textPrimary,
//                           fontWeight: FontWeight.w500),
//                     ),
//                     const Spacer(),
//                     const Text('Tap to change',
//                         style: TextStyle(
//                             fontSize: 11,
//                             color: AppColors.textMuted)),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }