import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sports_chat_app/src/services/facility_service.dart';
import 'package:sports_chat_app/src/services/role_service.dart';

class SuperAdminDashboardScreen extends StatefulWidget {
  const SuperAdminDashboardScreen({super.key});

  @override
  State<SuperAdminDashboardScreen> createState() => _SuperAdminDashboardScreenState();
}

class _SuperAdminDashboardScreenState extends State<SuperAdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _facilityService = FacilityService();
  final _roleService = RoleService();
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return FutureBuilder<bool>(
      future: _roleService.isSuperAdmin(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00))));
        }

        final isAuthorized = authSnapshot.data == true;

        if (!isAuthorized) {
          return Scaffold(
            appBar: AppBar(title: const Text('Super Admin Portal')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.security, size: 72, color: Colors.redAccent),
                    const SizedBox(height: 20),
                    const Text(
                      'Super Admin Access Restricted',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'This control hub is strictly reserved for the SprintIndex platform management team (${user?.email ?? "Not signed in"}).',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8C00)),
                      child: const Text('Sign In as Admin', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFF1E293B),
            elevation: 1,
            title: const Row(
              children: [
                Icon(Icons.shield_outlined, color: Color(0xFFFF8C00), size: 24),
                SizedBox(width: 10),
                Text(
                  'Super Admin Portal',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).pushNamed('/home'),
                icon: const Icon(Icons.apps, color: Colors.white70, size: 18),
                label: const Text('Customer App', style: TextStyle(color: Colors.white70)),
              ),
              IconButton(
                icon: const Icon(Icons.storefront_outlined, color: Colors.white70),
                tooltip: 'Owner Portal',
                onPressed: () => Navigator.of(context).pushNamed('/owner/dashboard'),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: const Color(0xFFFF8C00),
              labelColor: const Color(0xFFFF8C00),
              unselectedLabelColor: Colors.white60,
              tabs: const [
                Tab(icon: Icon(Icons.dashboard_outlined), text: 'Overview'),
                Tab(icon: Icon(Icons.bar_chart_rounded), text: 'Facility Sales'),
                Tab(icon: Icon(Icons.store_mall_directory), text: 'Venues'),
                Tab(icon: Icon(Icons.report_problem_outlined), text: 'Issues & Reports'),
              ],
            ),
          ),
          backgroundColor: const Color(0xFFF1F5F9),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildFacilitySalesTab(),
              _buildVenuesTab(),
              _buildComplaintsTab(),
            ],
          ),
        );
      },
    );
  }

  // TAB 1: Platform Overview
  Widget _buildOverviewTab() {
    return StreamBuilder<List<Facility>>(
      stream: _facilityService.getAllFacilitiesStream(),
      builder: (context, facSnapshot) {
        return StreamBuilder<List<FacilityBooking>>(
          stream: _facilityService.getAllBookingsStream(),
          builder: (context, bookSnapshot) {
            final facilities = facSnapshot.data ?? [];
            final bookings = bookSnapshot.data ?? [];

            final grossVolume = bookings.fold<double>(0.0, (s, b) => s + b.totalAmount);
            final totalViews = facilities.fold<int>(0, (s, f) => s + f.viewsCount);

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Top Metrics Grid
                Row(
                  children: [
                    _buildMetricCard(
                      title: 'Total Booking Value',
                      value: 'PKR ${grossVolume.toInt()}',
                      subtitle: 'Rawalpindi & Islamabad',
                      color: const Color(0xFF2E7D32),
                      icon: Icons.payments,
                    ),
                    const SizedBox(width: 14),
                    _buildMetricCard(
                      title: 'Total Bookings',
                      value: '${bookings.length}',
                      subtitle: 'Hourly net reservations',
                      color: const Color(0xFF1976D2),
                      icon: Icons.calendar_today,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildMetricCard(
                      title: 'Registered Venues',
                      value: '${facilities.length}',
                      subtitle: 'Active sports grounds',
                      color: const Color(0xFFFF8C00),
                      icon: Icons.stadium,
                    ),
                    const SizedBox(width: 14),
                    _buildMetricCard(
                      title: 'Platform Profile Views',
                      value: '$totalViews',
                      subtitle: 'Customer discoveries',
                      color: const Color(0xFF7B1FA2),
                      icon: Icons.visibility,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Recent Bookings Across Platform
                const Text('Recent Platform Bookings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                if (bookings.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(child: Text('No bookings recorded across the platform yet.')),
                    ),
                  )
                else
                  for (final b in bookings.take(5))
                    Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFF8C00),
                          child: Icon(Icons.sports, color: Colors.white, size: 20),
                        ),
                        title: Text('${b.facilityName} - ${b.netName}'),
                        subtitle: Text('${b.customerName} • ${b.date} (${b.startHour}:00 - ${b.endHour}:00)'),
                        trailing: Text(
                          'PKR ${b.totalAmount.toInt()}',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                      ),
                    ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Icon(icon, color: color, size: 22),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  // TAB 2: Facility Sales Breakdown
  Widget _buildFacilitySalesTab() {
    return StreamBuilder<List<Facility>>(
      stream: _facilityService.getAllFacilitiesStream(),
      builder: (context, facSnapshot) {
        return StreamBuilder<List<FacilityBooking>>(
          stream: _facilityService.getAllBookingsStream(),
          builder: (context, bookSnapshot) {
            final facilities = facSnapshot.data ?? [];
            final bookings = bookSnapshot.data ?? [];

            if (facilities.isEmpty) {
              return const Center(child: Text('No facilities listed yet.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: facilities.length,
              itemBuilder: (context, idx) {
                final facility = facilities[idx];
                final facilityBookings = bookings.where((b) => b.facilityId == facility.id).toList();
                final facilitySales = facilityBookings.fold<double>(0.0, (s, b) => s + b.totalAmount);

                return Card(
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(facility.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(
                              'PKR ${facilitySales.toInt()}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${facility.city} • ${facility.sports.join(", ")}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Bookings: ${facilityBookings.length} reservations',
                                style: const TextStyle(fontSize: 13)),
                            Text('Profile Visits: ${facility.viewsCount}',
                                style: const TextStyle(fontSize: 13, color: Colors.indigo)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // TAB 3: Venues Directory
  Widget _buildVenuesTab() {
    return StreamBuilder<List<Facility>>(
      stream: _facilityService.getAllFacilitiesStream(),
      builder: (context, snapshot) {
        final facilities = snapshot.data ?? [];
        if (facilities.isEmpty) {
          return const Center(child: Text('No venues added yet.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: facilities.length,
          itemBuilder: (context, idx) {
            final f = facilities[idx];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFFF8C00).withOpacity(0.2),
                  child: const Icon(Icons.stadium, color: Color(0xFFFF8C00)),
                ),
                title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${f.city} • Contact: ${f.phone}'),
                trailing: Text('${f.viewsCount} views', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ),
            );
          },
        );
      },
    );
  }

  // TAB 4: Complaints & Issues
  Widget _buildComplaintsTab() {
    return StreamBuilder<List<PlatformComplaint>>(
      stream: _facilityService.getComplaintsStream(),
      builder: (context, snapshot) {
        final complaints = snapshot.data ?? [];

        if (complaints.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 54, color: Colors.green),
                  SizedBox(height: 14),
                  Text('No Complaints or Issues Reported', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 6),
                  Text('Facility issues or customer reports will appear here for investigation.',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: complaints.length,
          itemBuilder: (context, idx) {
            final c = complaints[idx];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(c.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        DropdownButton<String>(
                          value: c.status,
                          isDense: true,
                          underline: const SizedBox(),
                          items: ['open', 'investigating', 'resolved'].map((s) {
                            return DropdownMenuItem(value: s, child: Text(s.toUpperCase()));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              _facilityService.updateComplaintStatus(c.id, val);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(c.description, style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 10),
                    Text('Reported by: ${c.reporterName} • Facility: ${c.facilityName}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
