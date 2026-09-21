import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sports_chat_app/src/services/facility_service.dart';

class CustomerBookingsScreen extends StatefulWidget {
  const CustomerBookingsScreen({Key? key}) : super(key: key);

  @override
  State<CustomerBookingsScreen> createState() => _CustomerBookingsScreenState();
}

class _CustomerBookingsScreenState extends State<CustomerBookingsScreen> {
  final FacilityService _facilityService = FacilityService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _cancelBooking(FacilityBooking booking) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Cancel Booking?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to cancel your booking at ${booking.facilityName} (${booking.netName}) for ${booking.date}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep Booking', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel Booking', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _facilityService.updateBookingStatus(booking.id, 'cancelled');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking cancelled successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Net Bookings',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: user == null
          ? const Center(
              child: Text('Please log in to view your bookings', style: TextStyle(color: Colors.white70)),
            )
          : StreamBuilder<List<FacilityBooking>>(
              stream: _facilityService.getCustomerBookingsStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final bookings = snapshot.data ?? [];
                if (bookings.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_outlined, size: 64, color: Colors.white.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          const Text(
                            'No Bookings Yet',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Find cricket nets, football pitches, or padel courts near you and reserve a slot with Cash on Arrival.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white60, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Sort bookings descending by date / created
                bookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final b = bookings[index];
                    final isCancelled = b.status == 'cancelled';

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isCancelled ? Colors.redAccent.withOpacity(0.2) : Colors.white12,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: Facility name + Status badge
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b.facilityName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${b.netName} • ${b.sport}',
                                      style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              _buildStatusBadge(b.status),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Details
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 14, color: Colors.white60),
                              const SizedBox(width: 6),
                              Text(
                                b.date,
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.access_time, size: 14, color: Colors.white60),
                              const SizedBox(width: 6),
                              Text(
                                '${b.startHour}:00 - ${b.endHour}:00 (${b.endHour - b.startHour} hr)',
                                style: const TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Payment info: Cash on Arrival
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isCancelled
                                  ? Colors.grey.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.money,
                                      size: 16,
                                      color: isCancelled ? Colors.white38 : Colors.greenAccent,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Cash on Arrival',
                                      style: TextStyle(
                                        color: isCancelled ? Colors.white38 : Colors.greenAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'PKR ${b.totalAmount.toInt()}',
                                  style: TextStyle(
                                    color: isCancelled ? Colors.white38 : Colors.greenAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Cancel button if confirmed
                          if (b.status == 'confirmed') ...[
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => _cancelBooking(b),
                                icon: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                                label: const Text(
                                  'Cancel Reservation',
                                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    String label = status.toUpperCase();

    switch (status) {
      case 'confirmed':
        bg = Colors.green.withOpacity(0.2);
        text = Colors.greenAccent;
        break;
      case 'cancelled':
        bg = Colors.redAccent.withOpacity(0.2);
        text = Colors.redAccent;
        break;
      case 'completed':
        bg = const Color(0xFF2563EB).withOpacity(0.2);
        text = const Color(0xFF38BDF8);
        break;
      default:
        bg = Colors.amber.withOpacity(0.2);
        text = Colors.amberAccent;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
