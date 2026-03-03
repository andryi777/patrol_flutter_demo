import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// Screen for notification settings and testing
class NotificationsSettingsScreen extends StatefulWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  State<NotificationsSettingsScreen> createState() =>
      _NotificationsSettingsScreenState();
}

class _NotificationsSettingsScreenState
    extends State<NotificationsSettingsScreen> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    tz_data.initializeTimeZones();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    final initialized = await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _showSnackBar('Notification tapped: ${response.payload}');
      },
    );

    setState(() {
      _isInitialized = initialized ?? false;
    });

    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final iosPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      setState(() {
        _permissionGranted = granted ?? false;
      });
    } else {
      // For Android, assume granted for now (Android 13+ needs runtime permission)
      setState(() {
        _permissionGranted = true;
      });
    }
  }

  Future<void> _showInstantNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Channel for test notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      0,
      'Test Notification',
      'This is an instant test notification!',
      details,
      payload: 'instant_test',
    );

    _showSnackBar('Notification sent!');
  }

  Future<void> _scheduleNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      channelDescription: 'Channel for scheduled notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final scheduledTime = DateTime.now().add(const Duration(seconds: 5));

    await _notificationsPlugin.zonedSchedule(
      1,
      'Scheduled Notification',
      'This notification was scheduled 5 seconds ago!',
      tz.TZDateTime.from(scheduledTime, tz.local),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'scheduled_test',
    );

    _showSnackBar('Notification scheduled for 5 seconds from now!');
  }

  Future<void> _showNotificationWithActions() async {
    const androidDetails = AndroidNotificationDetails(
      'actions_channel',
      'Action Notifications',
      channelDescription: 'Channel for notifications with actions',
      importance: Importance.max,
      priority: Priority.high,
      actions: [
        AndroidNotificationAction('accept', 'Accept'),
        AndroidNotificationAction('decline', 'Decline'),
      ],
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      categoryIdentifier: 'test_category',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      2,
      'Action Notification',
      'This notification has action buttons!',
      details,
      payload: 'action_test',
    );

    _showSnackBar('Notification with actions sent!');
  }

  Future<void> _cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    _showSnackBar('All notifications cancelled');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Notification Status',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        _isInitialized && _permissionGranted
                            ? Icons.check_circle
                            : Icons.error,
                        color: _isInitialized && _permissionGranted
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ),
                  const Divider(),
                  _buildStatusRow('Initialized', _isInitialized),
                  _buildStatusRow('Permission Granted', _permissionGranted),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Test Notifications',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),

          const SizedBox(height: 16),

          // Instant notification
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('Send Instant Notification'),
            subtitle: const Text('Shows a notification immediately'),
            trailing: ElevatedButton(
              onPressed:
                  _isInitialized && _permissionGranted
                      ? _showInstantNotification
                      : null,
              child: const Text('Send'),
            ),
          ),

          const Divider(),

          // Scheduled notification
          ListTile(
            leading: const Icon(Icons.schedule),
            title: const Text('Schedule Notification'),
            subtitle: const Text('Notification appears in 5 seconds'),
            trailing: ElevatedButton(
              onPressed:
                  _isInitialized && _permissionGranted
                      ? _scheduleNotification
                      : null,
              child: const Text('Schedule'),
            ),
          ),

          const Divider(),

          // Notification with actions
          ListTile(
            leading: const Icon(Icons.touch_app),
            title: const Text('Notification with Actions'),
            subtitle: const Text('Shows Accept/Decline buttons'),
            trailing: ElevatedButton(
              onPressed:
                  _isInitialized && _permissionGranted
                      ? _showNotificationWithActions
                      : null,
              child: const Text('Send'),
            ),
          ),

          const Divider(),

          // Cancel all
          ListTile(
            leading: const Icon(Icons.cancel),
            title: const Text('Cancel All Notifications'),
            subtitle: const Text('Removes all pending notifications'),
            trailing: OutlinedButton(
              onPressed: _isInitialized ? _cancelAllNotifications : null,
              child: const Text('Cancel'),
            ),
          ),

          const SizedBox(height: 24),

          // Info card
          const Card(
            color: Color(0xFFE3F2FD),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Testing Tips',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '- Minimize the app to see notifications\n'
                    '- On iOS, you may need to allow notifications in Settings\n'
                    '- Tap a notification to see the payload handling',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label),
          const Spacer(),
          Icon(
            value ? Icons.check : Icons.close,
            color: value ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }
}
