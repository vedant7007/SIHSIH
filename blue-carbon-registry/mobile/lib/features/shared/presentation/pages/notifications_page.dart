import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Notification Models and Providers
class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime timestamp;
  final bool isRead;
  final String priority;
  final bool actionRequired;
  final String? relatedId;
  final IconData icon;
  final Color color;
  final String userRole; // 'admin', 'ngo', 'buyer'

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.priority = 'medium',
    this.actionRequired = false,
    this.relatedId,
    required this.icon,
    required this.color,
    required this.userRole,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    DateTime? timestamp,
    bool? isRead,
    String? priority,
    bool? actionRequired,
    String? relatedId,
    IconData? icon,
    Color? color,
    String? userRole,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      priority: priority ?? this.priority,
      actionRequired: actionRequired ?? this.actionRequired,
      relatedId: relatedId ?? this.relatedId,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      userRole: userRole ?? this.userRole,
    );
  }
}

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier() : super([]) {
    _initializeNotifications();
  }

  void _initializeNotifications() {
    state = [
      AppNotification(
        id: '1',
        title: 'Project Approved',
        message: 'Your Coastal Mangrove Project has been approved and is now generating carbon credits.',
        type: 'approval',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        priority: 'high',
        actionRequired: false,
        relatedId: 'project_001',
        icon: Icons.check_circle,
        color: Colors.green,
        userRole: 'ngo',
      ),
      AppNotification(
        id: '2',
        title: 'New Review Required',
        message: 'Sundarbans Restoration project is ready for admin review. AI confidence: 92%',
        type: 'review',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: false,
        priority: 'high',
        actionRequired: true,
        relatedId: 'project_002',
        icon: Icons.rate_review,
        color: Colors.orange,
        userRole: 'admin',
      ),
      AppNotification(
        id: '3',
        title: 'Credit Purchase Successful',
        message: 'You have successfully purchased 50 tCO2e credits for ₹112,500 from Kerala Backwater Initiative.',
        type: 'transaction',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        priority: 'medium',
        actionRequired: false,
        relatedId: 'transaction_001',
        icon: Icons.shopping_cart,
        color: Colors.blue,
        userRole: 'buyer',
      ),
      AppNotification(
        id: '4',
        title: 'AI Anomaly Detected',
        message: 'Unusual pattern detected in project photos. Manual verification recommended.',
        type: 'alert',
        timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
        isRead: false,
        priority: 'high',
        actionRequired: true,
        relatedId: 'project_003',
        icon: Icons.warning,
        color: Colors.red,
        userRole: 'admin',
      ),
      AppNotification(
        id: '5',
        title: 'Monthly Report Ready',
        message: 'Your monthly performance report is now available for download.',
        type: 'report',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        isRead: true,
        priority: 'low',
        actionRequired: false,
        relatedId: 'report_001',
        icon: Icons.file_download,
        color: Colors.purple,
        userRole: 'ngo',
      ),
      AppNotification(
        id: '6',
        title: 'System Maintenance',
        message: 'Scheduled system maintenance on Sunday 3 AM - 5 AM. Services may be temporarily unavailable.',
        type: 'system',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        isRead: true,
        priority: 'medium',
        actionRequired: false,
        relatedId: 'maintenance_001',
        icon: Icons.settings,
        color: Colors.grey,
        userRole: 'admin',
      ),
      AppNotification(
        id: '7',
        title: 'Credit Retirement Complete',
        message: 'Successfully retired 100 tCO2e credits. Retirement certificate generated.',
        type: 'retirement',
        timestamp: DateTime.now().subtract(const Duration(days: 4)),
        isRead: true,
        priority: 'medium',
        actionRequired: false,
        relatedId: 'retirement_001',
        icon: Icons.eco,
        color: Colors.green,
        userRole: 'buyer',
      ),
      AppNotification(
        id: '8',
        title: 'New Message from NGO',
        message: 'Green Coast Foundation has sent you a project update with additional documentation.',
        type: 'message',
        timestamp: DateTime.now().subtract(const Duration(days: 5)),
        isRead: true,
        priority: 'low',
        actionRequired: false,
        relatedId: 'message_001',
        icon: Icons.message,
        color: Colors.blue,
        userRole: 'buyer',
      ),
      AppNotification(
        id: '9',
        title: 'Budget Limit Warning',
        message: 'You have used 80% of your monthly budget limit (₹4,00,000 of ₹5,00,000).',
        type: 'warning',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        isRead: false,
        priority: 'medium',
        actionRequired: false,
        relatedId: 'budget_001',
        icon: Icons.warning_amber,
        color: Colors.orange,
        userRole: 'buyer',
      ),
      AppNotification(
        id: '10',
        title: 'Verification Step Completed',
        message: 'Technical assessment completed for your Tamil Coast Project. Moving to AI analysis.',
        type: 'verification',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        isRead: false,
        priority: 'medium',
        actionRequired: false,
        relatedId: 'project_004',
        icon: Icons.verified,
        color: Colors.blue,
        userRole: 'ngo',
      ),
    ];
  }

  void markAsRead(String notificationId) {
    state = state.map((notification) {
      if (notification.id == notificationId) {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();
  }

  void markAllAsRead(String userRole) {
    state = state.map((notification) {
      if (notification.userRole == userRole || userRole == 'admin') {
        return notification.copyWith(isRead: true);
      }
      return notification;
    }).toList();
  }

  void deleteNotification(String notificationId) {
    state = state.where((notification) => notification.id != notificationId).toList();
  }

  void addNotification(AppNotification notification) {
    state = [notification, ...state];
  }

  List<AppNotification> getNotificationsForRole(String userRole) {
    return state.where((notification) =>
      notification.userRole == userRole || userRole == 'admin'
    ).toList();
  }

  int getUnreadCountForRole(String userRole) {
    return getNotificationsForRole(userRole)
        .where((notification) => !notification.isRead)
        .length;
  }

  int getActionRequiredCountForRole(String userRole) {
    return getNotificationsForRole(userRole)
        .where((notification) => !notification.isRead && notification.actionRequired)
        .length;
  }
}

// Global providers
final notificationsProvider = StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  return NotificationsNotifier();
});

final currentUserRoleProvider = StateProvider<String>((ref) => 'ngo'); // Default role

final userNotificationsProvider = Provider<List<AppNotification>>((ref) {
  final notifications = ref.watch(notificationsProvider);
  final userRole = ref.watch(currentUserRoleProvider);
  return notifications.where((notification) =>
    notification.userRole == userRole || userRole == 'admin'
  ).toList();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(userNotificationsProvider);
  return notifications.where((notification) => !notification.isRead).length;
});

final actionRequiredNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(userNotificationsProvider);
  return notifications.where((notification) => !notification.isRead && notification.actionRequired).length;
});

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AppNotification> _getFilteredNotifications() {
    final notifications = ref.read(userNotificationsProvider);
    List<AppNotification> filtered = notifications;

    if (_selectedFilter != 'all') {
      filtered = filtered.where((notification) => notification.type == _selectedFilter).toList();
    }

    return filtered..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<AppNotification> _getUnreadNotifications() {
    return _getFilteredNotifications().where((notification) => !notification.isRead).toList();
  }

  List<AppNotification> _getActionRequiredNotifications() {
    return _getFilteredNotifications().where((notification) => notification.actionRequired).toList();
  }

  void _markAsRead(String notificationId) {
    ref.read(notificationsProvider.notifier).markAsRead(notificationId);
  }

  void _markAllAsRead() {
    final userRole = ref.read(currentUserRoleProvider);
    ref.read(notificationsProvider.notifier).markAllAsRead(userRole);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _deleteNotification(String notificationId) {
    ref.read(notificationsProvider.notifier).deleteNotification(notificationId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification deleted'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }

    // Navigate based on notification type
    switch (notification.type) {
      case 'approval':
      case 'review':
      case 'verification':
        if (notification.relatedId != null) {
          // Navigate to project details or review page
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opening ${notification.relatedId}')),
          );
        }
        break;
      case 'transaction':
      case 'retirement':
        context.go('/portfolio');
        break;
      case 'report':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Downloading report...')),
        );
        break;
      case 'warning':
        context.go('/marketplace');
        break;
      default:
        break;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }

  Widget _buildAllNotificationsTab() {
    final notifications = _getFilteredNotifications();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedFilter,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Notifications')),
                        DropdownMenuItem(value: 'approval', child: Text('Approvals')),
                        DropdownMenuItem(value: 'review', child: Text('Reviews')),
                        DropdownMenuItem(value: 'transaction', child: Text('Transactions')),
                        DropdownMenuItem(value: 'alert', child: Text('Alerts')),
                        DropdownMenuItem(value: 'report', child: Text('Reports')),
                        DropdownMenuItem(value: 'system', child: Text('System')),
                        DropdownMenuItem(value: 'verification', child: Text('Verification')),
                        DropdownMenuItem(value: 'warning', child: Text('Warnings')),
                      ],
                      onChanged: (value) => setState(() => _selectedFilter = value!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _markAllAsRead,
                    icon: const Icon(Icons.done_all),
                    label: const Text('Mark All Read'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: notifications.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No notifications found'),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return _buildNotificationCard(notification);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildActionRequiredTab() {
    final actionNotifications = _getActionRequiredNotifications();

    return actionNotifications.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text('No action required'),
                Text('All caught up!', style: TextStyle(color: Colors.grey)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: actionNotifications.length,
            itemBuilder: (context, index) {
              final notification = actionNotifications[index];
              return _buildNotificationCard(notification);
            },
          );
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: notification.isRead ? 1 : 3,
      child: ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              backgroundColor: notification.color.withOpacity(0.1),
              child: Icon(
                notification.icon,
                color: notification.color,
              ),
            ),
            if (!notification.isRead)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
            ),
            if (notification.priority == 'high')
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'HIGH',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (notification.actionRequired)
              Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ACTION',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                color: notification.isRead ? Colors.grey : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTimestamp(notification.timestamp),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'mark_read':
                _markAsRead(notification.id);
                break;
              case 'delete':
                _deleteNotification(notification.id);
                break;
            }
          },
          itemBuilder: (context) => [
            if (!notification.isRead)
              const PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    Icon(Icons.mark_email_read),
                    SizedBox(width: 8),
                    Text('Mark as Read'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _handleNotificationTap(notification),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final actionCount = ref.watch(actionRequiredNotificationsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications${unreadCount > 0 ? ' ($unreadCount)' : ''}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _NotificationSettingsDialog(),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'All',
              icon: unreadCount > 0
                  ? Badge(
                      label: Text(unreadCount.toString()),
                      child: const Icon(Icons.notifications),
                    )
                  : const Icon(Icons.notifications),
            ),
            Tab(
              text: 'Action Required',
              icon: actionCount > 0
                  ? Badge(
                      label: Text(actionCount.toString()),
                      child: const Icon(Icons.priority_high),
                    )
                  : const Icon(Icons.priority_high),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAllNotificationsTab(),
          _buildActionRequiredTab(),
        ],
      ),
    );
  }
}

class _NotificationSettingsDialog extends StatefulWidget {
  @override
  State<_NotificationSettingsDialog> createState() => _NotificationSettingsDialogState();
}

class _NotificationSettingsDialogState extends State<_NotificationSettingsDialog> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _projectUpdates = true;
  bool _systemAlerts = true;
  bool _marketingEmails = false;
  bool _weeklyDigest = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Notification Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'General Settings',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive notifications on your device'),
              value: _pushNotifications,
              onChanged: (value) => setState(() => _pushNotifications = value),
            ),
            SwitchListTile(
              title: const Text('Email Notifications'),
              subtitle: const Text('Receive notifications via email'),
              value: _emailNotifications,
              onChanged: (value) => setState(() => _emailNotifications = value),
            ),
            const Divider(),
            const Text(
              'Notification Types',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('Project Updates'),
              subtitle: const Text('Status changes and approvals'),
              value: _projectUpdates,
              onChanged: (value) => setState(() => _projectUpdates = value),
            ),
            SwitchListTile(
              title: const Text('System Alerts'),
              subtitle: const Text('Important system notifications'),
              value: _systemAlerts,
              onChanged: (value) => setState(() => _systemAlerts = value),
            ),
            SwitchListTile(
              title: const Text('Weekly Digest'),
              subtitle: const Text('Weekly summary of activities'),
              value: _weeklyDigest,
              onChanged: (value) => setState(() => _weeklyDigest = value),
            ),
            SwitchListTile(
              title: const Text('Marketing Emails'),
              subtitle: const Text('Product updates and promotions'),
              value: _marketingEmails,
              onChanged: (value) => setState(() => _marketingEmails = value),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notification settings saved'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}