import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/room_provider.dart';
import '../providers/dhcp_provider.dart';
import '../providers/monitoring_provider.dart';
import '../utils/constants.dart';
import '../utils/responsive_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Load initial data
      context.read<RoomProvider>().loadRooms();
      context.read<DhcpProvider>().loadDhcpLeases();
      context.read<MonitoringProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          AppStrings.appTitle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle, color: Colors.white),
                onSelected: (value) async {
                  if (value == 'logout') {
                    await authProvider.logout();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(AppStrings.logoutSuccess),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else if (value == 'refresh') {
                    await authProvider.refreshUserInfo();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(authProvider.user?.name ?? 'User'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'refresh',
                    child: Row(
                      children: [
                        Icon(Icons.refresh, color: Colors.grey),
                        SizedBox(width: 8),
                        Text('Refresh'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Logout', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final padding = ResponsiveHelper.getResponsivePadding(
            context,
            mobileHorizontal: 12,
            mobileVertical: 16,
            tabletHorizontal: 20,
            tabletVertical: 20,
          );
          
          return SingleChildScrollView(
            padding: padding,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveHelper.getMaxWidth(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Card
                  _buildWelcomeCard(authProvider),
                  
                  SizedBox(height: ResponsiveHelper.getSpacing(
                    context,
                    mobile: 16,
                    tablet: 20,
                    desktop: 24,
                  )),
                  
                  // Network Monitoring Overview
                  _buildMonitoringOverview(),
                  
                  SizedBox(height: ResponsiveHelper.getSpacing(
                    context,
                    mobile: 16,
                    tablet: 20,
                    desktop: 24,
                  )),
                  
                  // Network Statistics with Real Data
                  _buildNetworkStats(),
                  
                  SizedBox(height: ResponsiveHelper.getSpacing(
                    context,
                    mobile: 16,
                    tablet: 20,
                    desktop: 24,
                  )),
                  
                  // Quick Actions
                  _buildQuickActionsSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(AuthProvider authProvider) {
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      mobile: 20,
      tablet: 24,
      desktop: 28,
    );
    final nameFontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      mobile: 16,
      tablet: 18,
      desktop: 20,
    );
    final emailFontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      mobile: 12,
      tablet: 14,
      desktop: 16,
    );
    final cardPadding = ResponsiveHelper.getResponsivePadding(
      context,
      mobileHorizontal: 16,
      mobileVertical: 16,
      tabletHorizontal: 20,
      tabletVertical: 20,
    );
    final borderRadius = ResponsiveHelper.getBorderRadius(
      context,
      mobile: 8,
      tablet: 12,
      desktop: 16,
    );

    return Card(
      elevation: ResponsiveHelper.getCardElevation(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        width: double.infinity,
        padding: cardPadding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang!',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 6, tablet: 8)),
            Text(
              authProvider.user?.name ?? 'User',
              style: TextStyle(
                fontSize: nameFontSize,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 2, tablet: 4)),
            Text(
              authProvider.user?.email ?? '',
              style: TextStyle(
                fontSize: emailFontSize,
                color: Colors.white60,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      mobile: 18,
      tablet: 20,
      desktop: 22,
    );
    final crossAxisCount = ResponsiveHelper.getGridCrossAxisCount(
      context,
      mobile: context.isVerySmallScreen 
          ? 1 
          : context.screenWidth < 380 
              ? 1 
              : 2,
      tablet: 3,
      desktop: 4,
    );
    final spacing = ResponsiveHelper.getSpacing(
      context,
      mobile: 12,
      tablet: 16,
      desktop: 20,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: spacing),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: crossAxisCount == 1 
              ? 4.5 
              : ResponsiveHelper.getGridChildAspectRatio(
                  context,
                  verySmall: 3.5,
                  small: 1.05,
                  normal: 1.15,
                ),
          children: [
            _buildActionCard(
              context.isVerySmallScreen || context.screenWidth < 380 
                  ? 'Room' 
                  : 'Room Management',
              'Kelola ruangan',
              Icons.room_preferences,
              Colors.blue,
              () {
                context.push('/rooms');
              },
              crossAxisCount,
            ),
            _buildActionCard(
              context.isVerySmallScreen || context.screenWidth < 380 
                  ? 'DHCP' 
                  : 'DHCP Control',
              'Kontrol DHCP',
              Icons.settings_ethernet,
              Colors.green,
              () {
                context.push('/dhcp');
              },
              crossAxisCount,
            ),
            _buildActionCard(
              context.isVerySmallScreen || context.screenWidth < 380 
                  ? 'Monitor' 
                  : 'Network Monitor',
              'Monitor jaringan',
              Icons.monitor,
              Colors.orange,
              () {
                context.push('/monitoring');
              },
              crossAxisCount,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final iconSize = ResponsiveHelper.getIconSize(
      context,
      mobile: 20,
      tablet: 24,
      desktop: 28,
    );
    final valueFontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      mobile: 20,
      tablet: 24,
      desktop: 28,
    );
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      mobile: 12,
      tablet: 14,
      desktop: 16,
    );
    final cardPadding = ResponsiveHelper.getResponsivePadding(
      context,
      mobileHorizontal: 12,
      mobileVertical: 12,
      tabletHorizontal: 16,
      tabletVertical: 16,
    );
    final borderRadius = ResponsiveHelper.getBorderRadius(
      context,
      mobile: 8,
      tablet: 10,
      desktop: 12,
    );

    return Card(
      elevation: ResponsiveHelper.getCardElevation(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      child: Padding(
        padding: cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: iconSize),
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: valueFontSize,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveHelper.getSpacing(context, mobile: 6, tablet: 8)),
            Text(
              title,
              style: TextStyle(
                fontSize: titleFontSize,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
    int crossAxisCount,
  ) {
    final iconSize = ResponsiveHelper.getIconSize(
      context,
      mobile: context.isVerySmallScreen 
          ? 18 
          : context.screenWidth < 380 
              ? 20 
              : context.screenWidth < 420
                  ? 22
                  : 24,
      tablet: 28,
      desktop: 32,
    );
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      mobile: context.isVerySmallScreen 
          ? 9 
          : context.screenWidth < 380 
              ? 10 
              : context.screenWidth < 420
                  ? 11
                  : 12,
      tablet: 14,
      desktop: 16,
    );
    final subtitleFontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      mobile: context.isVerySmallScreen 
          ? 8 
          : context.screenWidth < 380 
              ? 9 
              : context.screenWidth < 420
                  ? 10
                  : 11,
      tablet: 12,
      desktop: 14,
    );
    final cardPadding = ResponsiveHelper.getResponsivePadding(
      context,
      mobileHorizontal: context.isVerySmallScreen 
          ? 6 
          : context.screenWidth < 380 
              ? 8 
              : 12,
      mobileVertical: context.isVerySmallScreen 
          ? 6 
          : context.screenWidth < 380 
              ? 8 
              : 12,
      tabletHorizontal: 16,
      tabletVertical: 16,
    );
    final borderRadius = ResponsiveHelper.getBorderRadius(
      context,
      mobile: 6,
      tablet: 8,
      desktop: 12,
    );
    final iconContainerSize = ResponsiveHelper.getResponsiveValue(
      context,
      mobile: context.isVerySmallScreen 
          ? 4 
          : context.screenWidth < 380 
              ? 5 
              : context.screenWidth < 420
                  ? 6
                  : 8,
      tablet: 10,
      desktop: 12,
    );

    return Card(
      elevation: ResponsiveHelper.getCardElevation(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: cardPadding,
          child: crossAxisCount == 1 || context.isVerySmallScreen
            ? Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(iconContainerSize),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(iconContainerSize),
                    ),
                    child: Icon(icon, color: color, size: iconSize),
                  ),
                  SizedBox(width: ResponsiveHelper.getSpacing(
                    context, 
                    mobile: context.isVerySmallScreen ? 8 : 12,
                  )),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: crossAxisCount == 1 ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: ResponsiveHelper.getSpacing(
                          context, 
                          mobile: context.isVerySmallScreen ? 1 : 2,
                        )),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(iconContainerSize),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(iconContainerSize),
                      ),
                      child: Icon(icon, color: color, size: iconSize),
                    ),
                    SizedBox(height: ResponsiveHelper.getSpacing(
                      context, 
                      mobile: context.isVerySmallScreen ? 6 : 8, 
                      tablet: 12,
                    )),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: context.isVerySmallScreen ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ResponsiveHelper.getSpacing(
                      context, 
                      mobile: context.isVerySmallScreen ? 2 : 4,
                    )),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: subtitleFontSize,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMonitoringOverview() {
    return Consumer<MonitoringProvider>(
      builder: (context, monitoringProvider, child) {
        final dashboardData = monitoringProvider.dashboardData;
        
        if (dashboardData == null) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.monitor, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text(
                    'Network Monitoring',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Loading monitoring data...',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/monitoring'),
                    icon: const Icon(Icons.dashboard),
                    label: const Text('View Dashboard'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final overview = dashboardData.overview;
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.indigo.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Network Monitoring Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.push('/monitoring'),
                      icon: const Icon(Icons.open_in_new, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Overall Utilization
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Overall Network Utilization',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${overview.overallUtilization.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${overview.totalUsedIps}/${overview.totalIps} IPs used',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: CircularProgressIndicator(
                        value: overview.overallUtilization / 100,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          overview.overallUtilization >= 90 ? Colors.red :
                          overview.overallUtilization >= 75 ? Colors.orange : Colors.green
                        ),
                        strokeWidth: 6,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Status Summary
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusIndicator(
                        'Critical', 
                        overview.criticalRooms, 
                        Colors.red,
                        Icons.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatusIndicator(
                        'Warning', 
                        overview.warningRooms, 
                        Colors.orange,
                        Icons.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatusIndicator(
                        'Normal', 
                        overview.normalRooms, 
                        Colors.green,
                        Icons.check_circle,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusIndicator(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            count.toString(),
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkStats() {
    final titleFontSize = ResponsiveHelper.getResponsiveFontSize(
      context,
      mobile: 18,
      tablet: 20,
      desktop: 22,
    );
    final spacing = ResponsiveHelper.getSpacing(
      context,
      mobile: 12,
      tablet: 16,
      desktop: 20,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Statistik Jaringan',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: spacing),
        
        // Use GridView for better responsiveness
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: context.isVerySmallScreen ? 1 : 2,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: ResponsiveHelper.getGridChildAspectRatio(
            context,
            verySmall: 2.5,
            small: 1.8,
            normal: 2.0,
          ),
          children: [
            Consumer<RoomProvider>(
              builder: (context, roomProvider, child) {
                return _buildStatCard(
                  'Total Rooms',
                  roomProvider.rooms.length.toString(),
                  Icons.meeting_room,
                  Colors.blue,
                );
              },
            ),
            Consumer<DhcpProvider>(
              builder: (context, dhcpProvider, child) {
                return _buildStatCard(
                  'DHCP Leases',
                  dhcpProvider.dhcpLeases.length.toString(),
                  Icons.network_check,
                  Colors.green,
                );
              },
            ),
            Consumer<DhcpProvider>(
              builder: (context, dhcpProvider, child) {
                final activeLeases = dhcpProvider.dhcpLeases
                    .where((lease) => lease.isActive)
                    .length;
                return _buildStatCard(
                  'Active Leases',
                  activeLeases.toString(),
                  Icons.device_hub,
                  Colors.teal,
                );
              },
            ),
            Consumer<MonitoringProvider>(
              builder: (context, monitoringProvider, child) {
                final alertsCount = monitoringProvider.totalAlerts;
                final color = monitoringProvider.totalCriticalAlerts > 0 
                    ? Colors.red 
                    : monitoringProvider.totalWarningAlerts > 0 
                        ? Colors.orange 
                        : Colors.green;
                return _buildStatCard(
                  'Network Alerts',
                  alertsCount.toString(),
                  Icons.notifications,
                  color,
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}