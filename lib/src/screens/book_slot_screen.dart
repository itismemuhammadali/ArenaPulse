import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sports_chat_app/src/services/facility_service.dart';
import 'package:sports_chat_app/src/screens/customer_bookings_screen.dart';
import 'package:sports_chat_app/src/screens/map_screen.dart';

class BookSlotScreen extends StatefulWidget {
  final Facility facility;
  final SportsNet net;

  const BookSlotScreen({
    super.key,
    required this.facility,
    required this.net,
  });

  @override
  State<BookSlotScreen> createState() => _BookSlotScreenState();
}

class _BookSlotScreenState extends State<BookSlotScreen> {
  final FacilityService _facilityService = FacilityService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime _selectedDate = DateTime.now();
  int _selectedDuration = 1; // 1, 2, 3, 4 hours
  int? _startHour; // starting slot hour
  final Set<int> _selectedHours = {};
  List<int> _bookedHours = [];
  bool _isLoadingSlots = false;
  bool _isSubmitting = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final List<int> _durationOptions = [1, 2, 3, 4];

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _phoneController.text = user.phoneNumber ?? '';
    }
    _loadBookedSlots();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatHour(int h) {
    final period = h >= 12 ? 'PM' : 'AM';
    final standard = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$standard:00 $period';
  }

  Future<void> _loadBookedSlots() async {
    setState(() {
      _isLoadingSlots = true;
      _startHour = null;
      _selectedHours.clear();
    });

    try {
      final dateStr = _formatDate(_selectedDate);
      final booked = await _facilityService.getBookedHours(
        netId: widget.net.id,
        dateStr: dateStr,
      );
      if (mounted) {
        setState(() {
          _bookedHours = booked;
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSlots = false);
      }
    }
  }

  Future<void> _pickCalendarDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF2563EB),
              onPrimary: Colors.white,
              surface: Color(0xFF1E293B),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0F172A),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadBookedSlots();
    }
  }

  void _onDurationChanged(int duration) {
    setState(() {
      _selectedDuration = duration;
      _applySlotSelection();
    });
  }

  void _onSlotTapped(int hour) {
    // If the slot is already booked, disallow
    if (_bookedHours.contains(hour)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_formatHour(hour)} is already booked by another team. Sports nets are single-occupancy.',
          ),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check if contiguous block is available
    final closing = widget.net.closingHour;
    if (hour + _selectedDuration > closing) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cannot select $_selectedDuration hours: Venue closes at ${_formatHour(closing)}.',
          ),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    // Zero-overlap collision test
    for (int h = hour; h < hour + _selectedDuration; h++) {
      if (_bookedHours.contains(h)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Cannot select $_selectedDuration-hour block: ${_formatHour(h)} is already booked. Slots cannot overlap.',
            ),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    setState(() {
      _startHour = hour;
      _applySlotSelection();
    });
  }

  void _applySlotSelection() {
    _selectedHours.clear();
    if (_startHour == null) return;

    for (int h = _startHour!; h < _startHour! + _selectedDuration; h++) {
      if (!_bookedHours.contains(h) && h < widget.net.closingHour) {
        _selectedHours.add(h);
      }
    }
  }

  Future<void> _confirmBooking() async {
    if (_selectedHours.isEmpty || _startHour == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an available starting hourly slot.')),
      );
      return;
    }

    if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide your name and contact phone number.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final sortedHours = _selectedHours.toList()..sort();
      final dateStr = _formatDate(_selectedDate);
      final startHour = sortedHours.first;
      final endHour = sortedHours.last + 1;

      final bookingId = await _facilityService.bookSlot(
        facilityId: widget.facility.id,
        netId: widget.net.id,
        facilityName: widget.facility.name,
        netName: widget.net.name,
        sport: widget.net.sport,
        date: dateStr,
        startHour: startHour,
        endHour: endHour,
        hourlyRate: widget.net.hourlyRate,
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
      );

      if (mounted) {
        _showSuccessDialog(bookingId, startHour, endHour);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking error: $e'),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
        _loadBookedSlots(); // Refresh slot state
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSuccessDialog(String bookingId, int startHour, int endHour) {
    final totalAmount = widget.net.hourlyRate * (endHour - startHour);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.greenAccent, size: 28),
            SizedBox(width: 8),
            Text('Booking Confirmed!', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Facility: ${widget.facility.name}',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Net: ${widget.net.name} (${widget.net.sport})',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            Text(
              'Date: ${_formatDate(_selectedDate)}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            Text(
              'Time: ${_formatHour(startHour)} - ${_formatHour(endHour)} (${endHour - startHour} Hours)',
              style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payment Mode: CASH ON ARRIVAL',
                    style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total Due: PKR ${totalAmount.toInt()} (Pay at venue desk)',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.navigation, color: Color(0xFF38BDF8), size: 18),
            label: const Text('Navigate (OSM GPS)', style: TextStyle(color: Color(0xFF38BDF8))),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MapScreen(targetFacilityId: widget.facility.id),
                ),
              );
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CustomerBookingsScreen()),
              );
            },
            child: const Text('My Bookings', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double totalAmount = widget.net.hourlyRate * _selectedHours.length;
    final totalHoursCount = (widget.net.closingHour - widget.net.openingHour).clamp(1, 24);
    final availableCount = totalHoursCount - _bookedHours.length;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Zero-Overlap Slot Booking',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.facility.name} • ${widget.net.name}',
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: Color(0xFF38BDF8)),
            tooltip: 'Open Calendar',
            onPressed: _pickCalendarDate,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Net Summary Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.sports_cricket, color: Color(0xFF38BDF8), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.net.name,
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${widget.net.lengthFt.toInt()}ft × ${widget.net.widthFt.toInt()}ft (${widget.net.sport})',
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'PKR ${widget.net.hourlyRate.toInt()}/hr',
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$availableCount slots free',
                        style: TextStyle(
                          color: availableCount > 0 ? Colors.white60 : Colors.redAccent,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 1: Interactive Date & Calendar Strip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '1. Select Date (Calendar)',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _pickCalendarDate,
                  icon: const Icon(Icons.calendar_today, size: 14, color: Color(0xFF38BDF8)),
                  label: const Text(
                    'Full Calendar',
                    style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 14,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final date = DateTime.now().add(Duration(days: index));
                  final isSelected = date.year == _selectedDate.year &&
                      date.month == _selectedDate.month &&
                      date.day == _selectedDate.day;

                  final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  final monthNames = [
                    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                  ];
                  final dayStr = index == 0 ? 'Today' : dayNames[date.weekday - 1];
                  final monthStr = monthNames[date.month - 1];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                      _loadBookedSlots();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 64,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF38BDF8) : Colors.white12,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            dayStr,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            date.day.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            monthStr,
                            style: TextStyle(
                              color: isSelected ? Colors.white70 : Colors.white38,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),

            // Section 2: Duration Selector (1h, 2h, 3h, 4h)
            const Text(
              '2. Select Booking Duration',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose how many continuous hours you want to reserve this net:',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 10),
            Row(
              children: _durationOptions.map((hours) {
                final isSelected = _selectedDuration == hours;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                        foregroundColor: isSelected ? Colors.white : Colors.white70,
                        elevation: isSelected ? 2 : 0,
                        side: BorderSide(
                          color: isSelected ? const Color(0xFF38BDF8) : Colors.white12,
                          width: isSelected ? 1.5 : 1,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _onDurationChanged(hours),
                      child: Text(
                        '$hours hr${hours > 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Section 3: Hourly Slot Selection & Availability Grid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '3. Pick Starting Hour',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                if (_isLoadingSlots)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Slots Legend
            Row(
              children: [
                _buildLegendItem(const Color(0xFF1E293B), 'Available', Colors.white70),
                const SizedBox(width: 12),
                _buildLegendItem(const Color(0xFF2563EB), 'Selected', Colors.white),
                const SizedBox(width: 12),
                _buildLegendItem(Colors.redAccent.withValues(alpha: 0.15), 'Booked 🔒', Colors.redAccent),
              ],
            ),
            const SizedBox(height: 14),

            // Slot Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 2.1,
              ),
              itemCount: totalHoursCount,
              itemBuilder: (context, index) {
                final hour = widget.net.openingHour + index;
                final isBooked = _bookedHours.contains(hour);
                final isSelected = _selectedHours.contains(hour);
                final isStartingHour = _startHour == hour;

                // Check if starting at this hour would cause collision for duration
                bool wouldCollide = false;
                for (int h = hour; h < hour + _selectedDuration; h++) {
                  if (_bookedHours.contains(h) || h >= widget.net.closingHour) {
                    wouldCollide = true;
                    break;
                  }
                }

                Color bgColor;
                Color textColor;
                Border border;

                if (isBooked) {
                  bgColor = Colors.redAccent.withValues(alpha: 0.12);
                  textColor = Colors.redAccent.withValues(alpha: 0.8);
                  border = Border.all(color: Colors.redAccent.withValues(alpha: 0.3));
                } else if (isSelected) {
                  bgColor = const Color(0xFF2563EB);
                  textColor = Colors.white;
                  border = Border.all(color: const Color(0xFF38BDF8), width: 1.5);
                } else if (wouldCollide && _selectedDuration > 1) {
                  bgColor = const Color(0xFF1E293B).withValues(alpha: 0.5);
                  textColor = Colors.white38;
                  border = Border.all(color: Colors.white10);
                } else {
                  bgColor = const Color(0xFF1E293B);
                  textColor = Colors.white;
                  border = Border.all(color: Colors.white12);
                }

                return GestureDetector(
                  onTap: () => _onSlotTapped(hour),
                  child: Container(
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                      border: border,
                    ),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$hour:00 - ${hour + 1}:00',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        if (isBooked)
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock, size: 10, color: Colors.redAccent),
                              SizedBox(width: 2),
                              Text('Booked', style: TextStyle(color: Colors.redAccent, fontSize: 10)),
                            ],
                          )
                        else if (isStartingHour)
                          Text(
                            'Start (${_selectedDuration}h)',
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          )
                        else if (isSelected)
                          const Text(
                            'Included',
                            style: TextStyle(color: Colors.white70, fontSize: 10),
                          )
                        else
                          Text(
                            'PKR ${widget.net.hourlyRate.toInt()}',
                            style: const TextStyle(color: Colors.white38, fontSize: 10),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Booking Summary Banner (If Slots Selected)
            if (_selectedHours.isNotEmpty && _startHour != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified, color: Color(0xFF38BDF8), size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Zero-Overlap Slot Confirmed',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Reserved Time: ${_formatHour(_startHour!)} to ${_formatHour(_startHour! + _selectedDuration)} ($_selectedDuration Hours)',
                      style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Price: PKR ${totalAmount.toInt()} (PKR ${widget.net.hourlyRate.toInt()}/hr × $_selectedDuration)',
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Section 4: Customer Contact Info
            const Text(
              '4. Player / Team Contact Details',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Full Name / Team Name',
                labelStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.person, color: Color(0xFF38BDF8)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Phone Number (for booking verification)',
                labelStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.phone, color: Color(0xFF38BDF8)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 24),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: _isSubmitting ? null : _confirmBooking,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _selectedHours.isEmpty
                            ? 'Select Slots to Continue'
                            : 'Confirm Booking • PKR ${totalAmount.toInt()} (Cash)',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Payment Mode: Cash on Arrival at Venue Desk',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white24),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
