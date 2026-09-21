import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sports_chat_app/src/services/facility_service.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _facilityService = FacilityService();
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Facility Owner Portal')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text('Please sign in to access your Venue Owner Portal',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed('/login'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8C00)),
                child: const Text('Sign In', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<List<Facility>>(
      stream: _facilityService.getMyFacilitiesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00))),
          );
        }

        final facilities = snapshot.data ?? [];

        // If owner hasn't listed any facility yet, invite them to onboarding
        if (facilities.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Facility Owner Portal', style: TextStyle(color: Colors.black87)),
              backgroundColor: Colors.white,
              elevation: 0.5,
              actions: [
                IconButton(
                  icon: const Icon(Icons.home_outlined, color: Colors.black87),
                  tooltip: 'Go to Customer App',
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                ),
              ],
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.sports_cricket_outlined, size: 80, color: Color(0xFFFF8C00)),
                    const SizedBox(height: 24),
                    const Text(
                      'No Facilities Listed Yet',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'List your cricket nets, football turfs, or padel courts in Rawalpindi & Islamabad to start receiving hourly bookings!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed('/owner/onboarding'),
                      icon: const Icon(Icons.add_business, color: Colors.white),
                      label: const Text('List My Venue & Nets Now', style: TextStyle(color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8C00),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final activeFacility = facilities.first;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            title: Row(
              children: [
                const Icon(Icons.sports_soccer, color: Color(0xFFFF8C00), size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeFacility.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${activeFacility.city} • Owner Dashboard',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton.icon(
                onPressed: () => Navigator.of(context).pushNamed('/home'),
                icon: const Icon(Icons.visibility_outlined, size: 18, color: Color(0xFFFF8C00)),
                label: const Text('Customer View', style: TextStyle(color: Color(0xFFFF8C00), fontSize: 13)),
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFFF8C00),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFFF8C00),
              tabs: const [
                Tab(icon: Icon(Icons.grid_view), text: 'Nets & Courts'),
                Tab(icon: Icon(Icons.calendar_month), text: 'Bookings'),
                Tab(icon: Icon(Icons.analytics_outlined), text: 'Sales & Revenue'),
              ],
            ),
          ),
          backgroundColor: const Color(0xFFF8F9FA),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildNetsTab(activeFacility),
              _buildBookingsTab(activeFacility),
              _buildSalesTab(activeFacility),
            ],
          ),
        );
      },
    );
  }

  // TAB 1: Nets & Courts Management
  Widget _buildNetsTab(Facility facility) {
    return StreamBuilder<List<SportsNet>>(
      stream: _facilityService.getNetsStream(facility.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00)));
        }

        final nets = snapshot.data ?? [];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${nets.length} Listed Nets / Courts',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddNetDialog(facility.id),
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text('Add Net', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C00),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (nets.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: Text('No nets added yet. Tap "Add Net" above.'),
                ),
              )
            else
              for (final net in nets) _buildNetCard(facility.id, net),
          ],
        );
      },
    );
  }

  Widget _buildNetCard(String facilityId, SportsNet net) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8C00).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    net.sport.toLowerCase().contains('cricket')
                        ? Icons.sports_cricket
                        : net.sport.toLowerCase().contains('football')
                            ? Icons.sports_soccer
                            : Icons.sports_tennis,
                    color: const Color(0xFFFF8C00),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(net.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${net.sport} • ${net.shape}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ),
                Switch(
                  value: net.isActive,
                  activeColor: const Color(0xFFFF8C00),
                  onChanged: (val) {
                    _facilityService.updateNet(facilityId, net.id, {'isActive': val});
                  },
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              children: [
                _buildMetricChip(
                  icon: Icons.straighten,
                  label: 'Dimensions',
                  value: "${net.heightFt.toInt()}' H × ${net.widthFt.toInt()}' W × ${net.lengthFt.toInt()}' L",
                ),
                const SizedBox(width: 12),
                _buildMetricChip(
                  icon: Icons.payments,
                  label: 'Hourly Rate',
                  value: 'PKR ${net.hourlyRate.toInt()} / hr',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showEditNetDialog(facilityId, net),
                icon: const Icon(Icons.edit, size: 16, color: Color(0xFFFF8C00)),
                label: const Text('Edit Dimensions & Rate', style: TextStyle(color: Color(0xFFFF8C00))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip({required IconData icon, required String label, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  void _showEditNetDialog(String facilityId, SportsNet net) {
    final rateCtrl = TextEditingController(text: '${net.hourlyRate.toInt()}');
    final lenCtrl = TextEditingController(text: '${net.lengthFt.toInt()}');
    final widCtrl = TextEditingController(text: '${net.widthFt.toInt()}');
    final htCtrl = TextEditingController(text: '${net.heightFt.toInt()}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit ${net.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: rateCtrl,
              decoration: const InputDecoration(labelText: 'Hourly Rate (PKR)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: lenCtrl,
                    decoration: const InputDecoration(labelText: 'Length (ft)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: widCtrl,
                    decoration: const InputDecoration(labelText: 'Width (ft)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: htCtrl,
                    decoration: const InputDecoration(labelText: 'Height (ft)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              _facilityService.updateNet(facilityId, net.id, {
                'hourlyRate': double.tryParse(rateCtrl.text) ?? net.hourlyRate,
                'lengthFt': double.tryParse(lenCtrl.text) ?? net.lengthFt,
                'widthFt': double.tryParse(widCtrl.text) ?? net.widthFt,
                'heightFt': double.tryParse(htCtrl.text) ?? net.heightFt,
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8C00)),
            child: const Text('Save Changes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddNetDialog(String facilityId) {
    final nameCtrl = TextEditingController(text: 'Net New');
    final rateCtrl = TextEditingController(text: '2000');
    String shape = 'Rectangular';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Net or Pitch'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Net Name')),
            const SizedBox(height: 8),
            TextField(controller: rateCtrl, decoration: const InputDecoration(labelText: 'Hourly Rate (PKR)'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newNet = SportsNet(
                id: '',
                facilityId: facilityId,
                name: nameCtrl.text.trim(),
                sport: 'Cricket',
                shape: shape,
                lengthFt: 66,
                widthFt: 14,
                heightFt: 12,
                hourlyRate: double.tryParse(rateCtrl.text) ?? 2000,
              );
              _facilityService.addNet(facilityId, newNet);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8C00)),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // TAB 2: Bookings (Cash on Arrival)
  Widget _buildBookingsTab(Facility facility) {
    return StreamBuilder<List<FacilityBooking>>(
      stream: _facilityService.getFacilityBookingsStream(facility.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFF8C00)));
        }

        final bookings = snapshot.data ?? [];

        if (bookings.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 54, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No Bookings Received Yet', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 6),
                  Text('Player reservations will appear here with cash collection details.',
                      textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, idx) {
            final b = bookings[idx];
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
                        Text(b.netName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: b.status == 'completed'
                                ? Colors.green.withOpacity(0.15)
                                : Colors.orange.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            b.status == 'completed' ? 'PAID & COMPLETED' : 'CASH ON ARRIVAL',
                            style: TextStyle(
                              color: b.status == 'completed' ? Colors.green : Colors.orange.shade800,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('👤 ${b.customerName} (${b.customerPhone})', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('📅 Date: ${b.date}  •  ⏰ Slot: ${b.startHour}:00 - ${b.endHour}:00',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cash To Collect: PKR ${b.totalAmount.toInt()}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFFFF8C00)),
                        ),
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
  }

  // TAB 3: Sales & Revenue Overview
  Widget _buildSalesTab(Facility facility) {
    return StreamBuilder<List<FacilityBooking>>(
      stream: _facilityService.getFacilityBookingsStream(facility.id),
      builder: (context, snapshot) {
        final bookings = snapshot.data ?? [];
        final totalSales = bookings.fold<double>(0.0, (sum, b) => sum + b.totalAmount);
        final totalHours = bookings.fold<int>(0, (sum, b) => sum + (b.endHour - b.startHour));

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Gross Bookings Revenue', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text('PKR ${totalSales.toInt()}',
                      style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text('Total Reserved Hours: $totalHours hrs  •  Bookings: ${bookings.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Performance Highlights', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 14),
                    _buildStatRow('Total Venue Profile Visits', '${facility.viewsCount} views'),
                    const Divider(),
                    _buildStatRow('Average Booking Value', bookings.isEmpty ? 'PKR 0' : 'PKR ${(totalSales / bookings.length).toInt()}'),
                    const Divider(),
                    _buildStatRow('Payment Mode', '100% Cash at Venue'),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
