import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sports_chat_app/src/services/role_service.dart';

class Facility {
  final String id;
  final String ownerId;
  final String name;
  final String address;
  final String city; // Islamabad, Rawalpindi, etc.
  final double latitude;
  final double longitude;
  final List<String> sports;
  final String phone;
  final String? coverImageUrl;
  final int viewsCount;
  final DateTime createdAt;

  Facility({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.sports,
    required this.phone,
    this.coverImageUrl,
    this.viewsCount = 0,
    required this.createdAt,
  });

  factory Facility.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Facility(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? 'Islamabad',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 33.6844,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 73.0479,
      sports: List<String>.from(data['sports'] ?? []),
      phone: data['phone'] ?? '',
      coverImageUrl: data['coverImageUrl'],
      viewsCount: (data['viewsCount'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'sports': sports,
      'phone': phone,
      'coverImageUrl': coverImageUrl,
      'viewsCount': viewsCount,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class SportsNet {
  final String id;
  final String facilityId;
  final String name; // e.g. "Net 1 - Fast Pitch", "Padel Court 1"
  final String sport; // Cricket, Football, Padel, etc.
  final String shape; // Rectangular, Box, Circular, Custom
  final double lengthFt;
  final double widthFt;
  final double heightFt;
  final double hourlyRate; // PKR
  final List<String> images;
  final bool isActive;
  final int openingHour; // 0-23 (e.g. 6)
  final int closingHour; // 0-23 (e.g. 23)

  SportsNet({
    required this.id,
    required this.facilityId,
    required this.name,
    required this.sport,
    required this.shape,
    required this.lengthFt,
    required this.widthFt,
    required this.heightFt,
    required this.hourlyRate,
    this.images = const [],
    this.isActive = true,
    this.openingHour = 6,
    this.closingHour = 23,
  });

  factory SportsNet.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SportsNet(
      id: doc.id,
      facilityId: data['facilityId'] ?? '',
      name: data['name'] ?? '',
      sport: data['sport'] ?? 'Cricket',
      shape: data['shape'] ?? 'Rectangular',
      lengthFt: (data['lengthFt'] as num?)?.toDouble() ?? 66.0,
      widthFt: (data['widthFt'] as num?)?.toDouble() ?? 14.0,
      heightFt: (data['heightFt'] as num?)?.toDouble() ?? 12.0,
      hourlyRate: (data['hourlyRate'] as num?)?.toDouble() ?? 1500.0,
      images: List<String>.from(data['images'] ?? []),
      isActive: data['isActive'] ?? true,
      openingHour: (data['openingHour'] as num?)?.toInt() ?? 6,
      closingHour: (data['closingHour'] as num?)?.toInt() ?? 23,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'facilityId': facilityId,
      'name': name,
      'sport': sport,
      'shape': shape,
      'lengthFt': lengthFt,
      'widthFt': widthFt,
      'heightFt': heightFt,
      'hourlyRate': hourlyRate,
      'images': images,
      'isActive': isActive,
      'openingHour': openingHour,
      'closingHour': closingHour,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class FacilityBooking {
  final String id;
  final String facilityId;
  final String netId;
  final String facilityName;
  final String netName;
  final String sport;
  final String customerId;
  final String customerName;
  final String customerPhone;
  final String date; // YYYY-MM-DD
  final int startHour; // 0-23
  final int endHour; // 0-23
  final double hourlyRate;
  final double totalAmount; // PKR
  final String paymentMethod; // "cash"
  final String status; // "pending", "confirmed", "completed", "cancelled"
  final DateTime createdAt;

  FacilityBooking({
    required this.id,
    required this.facilityId,
    required this.netId,
    required this.facilityName,
    required this.netName,
    required this.sport,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.date,
    required this.startHour,
    required this.endHour,
    required this.hourlyRate,
    required this.totalAmount,
    this.paymentMethod = 'cash',
    this.status = 'confirmed',
    required this.createdAt,
  });

  factory FacilityBooking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return FacilityBooking(
      id: doc.id,
      facilityId: data['facilityId'] ?? '',
      netId: data['netId'] ?? '',
      facilityName: data['facilityName'] ?? '',
      netName: data['netName'] ?? '',
      sport: data['sport'] ?? '',
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      date: data['date'] ?? '',
      startHour: (data['startHour'] as num?)?.toInt() ?? 0,
      endHour: (data['endHour'] as num?)?.toInt() ?? 1,
      hourlyRate: (data['hourlyRate'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: data['paymentMethod'] ?? 'cash',
      status: data['status'] ?? 'confirmed',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'facilityId': facilityId,
      'netId': netId,
      'facilityName': facilityName,
      'netName': netName,
      'sport': sport,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'date': date,
      'startHour': startHour,
      'endHour': endHour,
      'hourlyRate': hourlyRate,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class PlatformComplaint {
  final String id;
  final String reportedBy;
  final String reporterName;
  final String facilityId;
  final String facilityName;
  final String subject;
  final String description;
  final String status; // "open", "investigating", "resolved"
  final DateTime createdAt;

  PlatformComplaint({
    required this.id,
    required this.reportedBy,
    required this.reporterName,
    required this.facilityId,
    required this.facilityName,
    required this.subject,
    required this.description,
    this.status = 'open',
    required this.createdAt,
  });

  factory PlatformComplaint.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PlatformComplaint(
      id: doc.id,
      reportedBy: data['reportedBy'] ?? '',
      reporterName: data['reporterName'] ?? 'Anonymous',
      facilityId: data['facilityId'] ?? '',
      facilityName: data['facilityName'] ?? '',
      subject: data['subject'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'open',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reportedBy': reportedBy,
      'reporterName': reporterName,
      'facilityId': facilityId,
      'facilityName': facilityName,
      'subject': subject,
      'description': description,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class FacilityService {
  static final FacilityService _instance = FacilityService._internal();
  factory FacilityService() => _instance;
  FacilityService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create a new facility with initial nets
  Future<String> createFacility({
    required String name,
    required String address,
    required String city,
    required double latitude,
    required double longitude,
    required List<String> sports,
    required String phone,
    String? coverImageUrl,
    required List<Map<String, dynamic>> netsData,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // 1. Create Facility document
    final facilityRef = _firestore.collection('facilities').doc();
    final facility = Facility(
      id: facilityRef.id,
      ownerId: user.uid,
      name: name,
      address: address,
      city: city,
      latitude: latitude,
      longitude: longitude,
      sports: sports,
      phone: phone,
      coverImageUrl: coverImageUrl,
      createdAt: DateTime.now(),
    );

    await facilityRef.set(facility.toMap());

    // 2. Create sub-collection of nets
    for (final netMap in netsData) {
      final netRef = facilityRef.collection('nets').doc();
      final net = SportsNet(
        id: netRef.id,
        facilityId: facilityRef.id,
        name: netMap['name'] ?? 'Net 1',
        sport: netMap['sport'] ?? (sports.isNotEmpty ? sports.first : 'Cricket'),
        shape: netMap['shape'] ?? 'Rectangular',
        lengthFt: (netMap['lengthFt'] as num?)?.toDouble() ?? 66.0,
        widthFt: (netMap['widthFt'] as num?)?.toDouble() ?? 14.0,
        heightFt: (netMap['heightFt'] as num?)?.toDouble() ?? 12.0,
        hourlyRate: (netMap['hourlyRate'] as num?)?.toDouble() ?? 2000.0,
        images: List<String>.from(netMap['images'] ?? []),
        isActive: true,
      );
      await netRef.set(net.toMap());
    }

    // 3. Upgrade user role to facilityOwner
    await RoleService().setUserRole(user.uid, UserRole.facilityOwner);

    return facilityRef.id;
  }

  /// Get facilities owned by current user
  Stream<List<Facility>> getMyFacilitiesStream() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('facilities')
        .where('ownerId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Facility.fromFirestore(doc)).toList());
  }

  /// Get all active facilities (for customers and super admin)
  Stream<List<Facility>> getAllFacilitiesStream() {
    return _firestore
        .collection('facilities')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Facility.fromFirestore(doc)).toList());
  }

  /// Get single facility by ID
  Future<Facility?> getFacility(String facilityId) async {
    final doc = await _firestore.collection('facilities').doc(facilityId).get();
    if (!doc.exists) return null;
    return Facility.fromFirestore(doc);
  }

  /// Increment facility views counter
  Future<void> incrementFacilityViews(String facilityId) async {
    try {
      await _firestore.collection('facilities').doc(facilityId).update({
        'viewsCount': FieldValue.increment(1),
      });
    } catch (_) {}
  }

  /// Get nets for a facility
  Stream<List<SportsNet>> getNetsStream(String facilityId) {
    return _firestore
        .collection('facilities')
        .doc(facilityId)
        .collection('nets')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => SportsNet.fromFirestore(doc)).toList());
  }

  /// Add a net to existing facility
  Future<void> addNet(String facilityId, SportsNet net) async {
    final ref = _firestore
        .collection('facilities')
        .doc(facilityId)
        .collection('nets')
        .doc();
    await ref.set(net.toMap());
  }

  /// Update an existing net
  Future<void> updateNet(String facilityId, String netId, Map<String, dynamic> data) async {
    await _firestore
        .collection('facilities')
        .doc(facilityId)
        .collection('nets')
        .doc(netId)
        .update(data);
  }

  /// Check booked hours for a given net and date
  Future<List<int>> getBookedHours({
    required String netId,
    required String dateStr, // YYYY-MM-DD
  }) async {
    final snapshot = await _firestore
        .collection('bookings')
        .where('netId', isEqualTo: netId)
        .where('date', isEqualTo: dateStr)
        .where('status', whereIn: ['confirmed', 'pending', 'completed'])
        .get();

    final List<int> bookedHours = [];
    for (final doc in snapshot.docs) {
      final start = (doc.data()['startHour'] as num?)?.toInt() ?? 0;
      final end = (doc.data()['endHour'] as num?)?.toInt() ?? (start + 1);
      for (int h = start; h < end; h++) {
        bookedHours.add(h);
      }
    }
    return bookedHours;
  }

  /// Book an hourly slot (Cash on Arrival)
  Future<String> bookSlot({
    required String facilityId,
    required String netId,
    required String facilityName,
    required String netName,
    required String sport,
    required String date,
    required int startHour,
    required int endHour,
    required double hourlyRate,
    required String customerName,
    required String customerPhone,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Please log in to book');

    // Prevent double booking collision
    final bookedHours = await getBookedHours(netId: netId, dateStr: date);
    for (int h = startHour; h < endHour; h++) {
      if (bookedHours.contains(h)) {
        throw Exception('Slot $h:00 - ${h + 1}:00 has already been booked.');
      }
    }

    final totalHours = (endHour - startHour).clamp(1, 24);
    final totalAmount = totalHours * hourlyRate;

    final bookingRef = _firestore.collection('bookings').doc();
    final booking = FacilityBooking(
      id: bookingRef.id,
      facilityId: facilityId,
      netId: netId,
      facilityName: facilityName,
      netName: netName,
      sport: sport,
      customerId: user.uid,
      customerName: customerName,
      customerPhone: customerPhone,
      date: date,
      startHour: startHour,
      endHour: endHour,
      hourlyRate: hourlyRate,
      totalAmount: totalAmount,
      paymentMethod: 'cash',
      status: 'confirmed',
      createdAt: DateTime.now(),
    );

    await bookingRef.set(booking.toMap());
    return bookingRef.id;
  }

  /// Get bookings for customer
  Stream<List<FacilityBooking>> getCustomerBookingsStream(String customerId) {
    return _firestore
        .collection('bookings')
        .where('customerId', isEqualTo: customerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FacilityBooking.fromFirestore(doc))
            .toList());
  }

  /// Get bookings for owner's facility
  Stream<List<FacilityBooking>> getFacilityBookingsStream(String facilityId) {
    return _firestore
        .collection('bookings')
        .where('facilityId', isEqualTo: facilityId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FacilityBooking.fromFirestore(doc))
            .toList());
  }

  /// Get all platform bookings (Super Admin)
  Stream<List<FacilityBooking>> getAllBookingsStream() {
    return _firestore
        .collection('bookings')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FacilityBooking.fromFirestore(doc))
            .toList());
  }

  /// Update status of a booking (confirmed, completed, cancelled)
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Submit a complaint / issue
  Future<void> submitComplaint({
    required String facilityId,
    required String facilityName,
    required String subject,
    required String description,
  }) async {
    final user = _auth.currentUser;
    final ref = _firestore.collection('reports').doc();
    final complaint = PlatformComplaint(
      id: ref.id,
      reportedBy: user?.uid ?? 'guest',
      reporterName: user?.displayName ?? user?.email ?? 'Anonymous User',
      facilityId: facilityId,
      facilityName: facilityName,
      subject: subject,
      description: description,
      status: 'open',
      createdAt: DateTime.now(),
    );
    await ref.set(complaint.toMap());
  }

  /// Get all complaints (Super Admin)
  Stream<List<PlatformComplaint>> getComplaintsStream() {
    return _firestore
        .collection('reports')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PlatformComplaint.fromFirestore(doc))
            .toList());
  }

  /// Update complaint status
  Future<void> updateComplaintStatus(String complaintId, String newStatus) async {
    await _firestore.collection('reports').doc(complaintId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
