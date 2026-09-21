import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:sports_chat_app/src/services/facility_service.dart';
import 'package:sports_chat_app/src/services/php_storage_service.dart';

// Screens imports
import 'package:sports_chat_app/src/screens/home_screen.dart';
import 'package:sports_chat_app/src/screens/signup_screen.dart';
import 'package:sports_chat_app/src/screens/forgot_password_screen.dart';
import 'package:sports_chat_app/src/screens/facility_onboarding_screen.dart';
import 'package:sports_chat_app/src/screens/owner_dashboard_screen.dart';
import 'package:sports_chat_app/src/screens/super_admin_dashboard_screen.dart';
import 'package:sports_chat_app/src/screens/map_screen.dart';
import 'package:sports_chat_app/src/screens/osm_location_picker_screen.dart';
import 'package:sports_chat_app/src/screens/facility_details_screen.dart';
import 'package:sports_chat_app/src/screens/book_slot_screen.dart';
import 'package:sports_chat_app/src/screens/customer_bookings_screen.dart';
import 'package:sports_chat_app/src/screens/create_text_post_screen.dart';
import 'package:sports_chat_app/src/screens/create_media_post_screen.dart';
import 'package:sports_chat_app/src/screens/create_club_screen.dart';
import 'package:sports_chat_app/src/screens/join_club_screen.dart';
import 'package:sports_chat_app/src/screens/messages_screen.dart';
import 'package:sports_chat_app/src/screens/notifications_screen.dart';
import 'package:sports_chat_app/src/screens/discover_people_screen.dart';
import 'package:sports_chat_app/src/screens/events_screen.dart';
import 'package:sports_chat_app/src/screens/profile_screen.dart';
import 'package:sports_chat_app/src/screens/edit_profile_screen.dart';
import 'package:sports_chat_app/src/screens/settings_screen.dart';
import 'package:sports_chat_app/src/screens/privacy_settings_screen.dart';

class FlowNavigatorSheet extends StatefulWidget {
  final Function(String email, String password)? onFillCredentials;
  final Function(String email, String password)? onAutoLogin;

  const FlowNavigatorSheet({
    super.key,
    this.onFillCredentials,
    this.onAutoLogin,
  });

  static void show(
    BuildContext context, {
    Function(String email, String password)? onFillCredentials,
    Function(String email, String password)? onAutoLogin,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FlowNavigatorSheet(
        onFillCredentials: onFillCredentials,
        onAutoLogin: onAutoLogin,
      ),
    );
  }

  @override
  State<FlowNavigatorSheet> createState() => _FlowNavigatorSheetState();
}

class _FlowNavigatorSheetState extends State<FlowNavigatorSheet> {
  static final Facility _sampleFacility = Facility(
    id: 'facility_rawalpindi_arena',
    ownerId: 'p0ZGfuee5eZmtWPOcmSrsPk1eWm2',
    name: 'Rawalpindi Cricket & Padel Arena',
    address: 'Commercial Market, Satellite Town, Rawalpindi',
    city: 'Rawalpindi',
    latitude: 33.6425,
    longitude: 73.0715,
    sports: ['Cricket', 'Padel', 'Football'],
    phone: '+92 300 9876543',
    coverImageUrl: 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800',
    viewsCount: 184,
    createdAt: DateTime.now(),
  );

  static final SportsNet _sampleNet = SportsNet(
    id: 'net_cricket_1',
    facilityId: 'facility_rawalpindi_arena',
    name: 'Fast Bowling Cricket Net 1',
    sport: 'Cricket',
    shape: 'Rectangular',
    lengthFt: 66,
    widthFt: 14,
    heightFt: 12,
    hourlyRate: 1500,
    images: ['https://images.unsplash.com/photo-1531415074868-036b107e775a?w=800'],
    isActive: true,
    openingHour: 6,
    closingHour: 23,
  );

  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _phpStatus = 'Checking...';
  Color _phpStatusColor = Colors.orange;

  @override
  void initState() {
    super.initState();
    _checkPhpBackend();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkPhpBackend() async {
    try {
      final baseUrl = PhpStorageService().baseUrl;
      final res = await http.get(Uri.parse('$baseUrl/index.php')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          _phpStatus = 'PHP Online (${data['service'] ?? 'Ready'})';
          _phpStatusColor = Colors.green;
        });
      } else {
        setState(() {
          _phpStatus = 'HTTP ${res.statusCode}';
          _phpStatusColor = Colors.orange;
        });
      }
    } catch (_) {
      setState(() {
        _phpStatus = 'Offline (Run: php -S 0.0.0.0:8080 -t backend)';
        _phpStatusColor = Colors.grey;
      });
    }
  }

  void _navigateTo(Widget screen) {
    Navigator.pop(context); // Close bottom sheet
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _openMediaPostFlow() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null && mounted) {
      _navigateTo(CreateMediaPostScreen(mediaFile: file, isVideo: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.90,
      minChildSize: 0.50,
      maxChildSize: 0.96,
      builder: (_, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'lib/assets/crater_code_light.png',
                        width: 38,
                        height: 38,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Crater Code Navigator',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'One-click shortcut to test every app flow & role',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // PHP Backend status pill
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _phpStatusColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _phpStatusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.storage_rounded, size: 16, color: _phpStatusColor),
                    const SizedBox(width: 8),
                    const Text(
                      'PHP Storage: ',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    Expanded(
                      child: Text(
                        _phpStatus,
                        style: TextStyle(fontSize: 12, color: _phpStatusColor, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: _checkPhpBackend,
                      child: const Icon(Icons.refresh, size: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // Search field
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search any screen or flow...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
                ),
              ),

              const Divider(height: 1),

              // Content List
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  children: [
                    // Section 1: Quick Role Logins
                    if (_matchesSearch('super admin owner player login auth password fill credentials'))
                      _buildQuickLoginSection(),

                    // Section 2: Facility & Net Owner Flows
                    if (_matchesSearch('facility owner net booking dimension shape court onboarding dashboard sales'))
                      _buildFacilityOwnerSection(),

                    // Section 3: Super Admin Hub
                    if (_matchesSearch('super admin control analytics charts complaints reports resolution platform volume'))
                      _buildSuperAdminSection(),

                    // Section 4: Customer & Social Flows
                    if (_matchesSearch('customer player feed post media text video club map openstreetmap chat messages'))
                      _buildCustomerCommunitySection(),

                    // Section 5: Profile & Settings
                    if (_matchesSearch('profile edit settings privacy policy forgot signup register'))
                      _buildProfileSettingsSection(),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _matchesSearch(String keywords) {
    if (_searchQuery.isEmpty) return true;
    return keywords.toLowerCase().contains(_searchQuery);
  }

  Widget _buildQuickLoginSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: '🔑 1-Click Role Login & Auto-Fill',
          subtitle: 'Switch accounts instantly without typing passwords',
          color: const Color(0xFF1E88E5),
        ),
        const SizedBox(height: 8),
        _buildRoleLoginCard(
          roleTitle: 'Super Admin',
          email: 'admin@sprintindex.com',
          roleBadge: 'Full Platform Access',
          badgeColor: Colors.purple,
          icon: Icons.shield,
          routeUrl: '/#/admin',
        ),
        _buildRoleLoginCard(
          roleTitle: 'Facility / Net Owner',
          email: 'owner@sprintindex.com',
          roleBadge: 'Venue & Nets Manager',
          badgeColor: const Color(0xFFFF8C00),
          icon: Icons.stadium,
          routeUrl: '/#/owner',
        ),
        _buildRoleLoginCard(
          roleTitle: 'Customer / Player (Ali Ahmed)',
          email: 'player@sprintindex.com',
          roleBadge: 'Social & Slot Booking',
          badgeColor: Colors.teal,
          icon: Icons.person,
          routeUrl: '/#/',
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRoleLoginCard({
    required String roleTitle,
    required String email,
    required String roleBadge,
    required Color badgeColor,
    required IconData icon,
    required String routeUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: badgeColor.withValues(alpha: 0.12),
            foregroundColor: badgeColor,
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(roleTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(roleBadge, style: TextStyle(fontSize: 10, color: badgeColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$email  •  $routeUrl',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          // Action Buttons
          OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onFillCredentials?.call(email, 'Password123!');
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Fill', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 6),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onAutoLogin?.call(email, 'Password123!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: badgeColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Login', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityOwnerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: '🏟️ Facility & Net Owner Flows',
          subtitle: 'Venue management, dimensions, shapes, rates, and sales',
          color: const Color(0xFFFF8C00),
        ),
        const SizedBox(height: 8),
        _buildFlowTile(
          icon: Icons.add_business_rounded,
          iconColor: const Color(0xFFFF8C00),
          title: 'Venue & Net Onboarding Wizard',
          subtitle: 'Add venue, sports, dimensions (L×W×H ft), shape & PKR hourly rate',
          routeTag: '/#/owner/onboarding',
          onTap: () => _navigateTo(const FacilityOnboardingScreen()),
        ),
        _buildFlowTile(
          icon: Icons.dashboard_customize_rounded,
          iconColor: const Color(0xFFFF8C00),
          title: 'Net Owner Management Dashboard',
          subtitle: 'Manage nets, rates, view bookings & cash to collect, monthly revenue',
          routeTag: '/#/owner',
          onTap: () => _navigateTo(const OwnerDashboardScreen()),
        ),
        _buildFlowTile(
          icon: Icons.sports_cricket,
          iconColor: Colors.green,
          title: 'Facility Profile & Net Viewer (Sample Arena)',
          subtitle: 'Customer-facing view of Rawalpindi Cricket & Padel Arena',
          routeTag: 'Facility Details',
          onTap: () => _navigateTo(
            FacilityDetailsScreen(facility: _sampleFacility),
          ),
        ),
        _buildFlowTile(
          icon: Icons.calendar_month,
          iconColor: Colors.blue,
          title: 'Direct Slot Booking (Cash on Arrival)',
          subtitle: 'Pick date & hourly slot, test Cash-on-Arrival booking flow',
          routeTag: 'Book Slot',
          onTap: () => _navigateTo(
            BookSlotScreen(facility: _sampleFacility, net: _sampleNet),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSuperAdminSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: '🛡️ Super Admin Control Hub',
          subtitle: 'Executive analytics, monthly sales charts, and issue moderation',
          color: Colors.purple,
        ),
        const SizedBox(height: 8),
        _buildFlowTile(
          icon: Icons.admin_panel_settings_rounded,
          iconColor: Colors.purple,
          title: 'Super Admin Control Center',
          subtitle: 'Platform gross booking volume, sales charts, venue visits, complaints hub',
          routeTag: '/#/admin',
          onTap: () => _navigateTo(const SuperAdminDashboardScreen()),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCustomerCommunitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: '⚽ Customer & Community Flows',
          subtitle: 'Social feed, OpenStreetMap, clubs, direct chat, and posts',
          color: Colors.teal,
        ),
        const SizedBox(height: 8),
        _buildFlowTile(
          icon: Icons.home_rounded,
          iconColor: Colors.teal,
          title: 'Customer Home & Social Feed',
          subtitle: 'Main timeline, posts, likes, comments, stories',
          routeTag: '/#/home',
          onTap: () => _navigateTo(const HomeScreen()),
        ),
        _buildFlowTile(
          icon: Icons.map_rounded,
          iconColor: Colors.green,
          title: 'OpenStreetMap Venue Discovery',
          subtitle: 'Browse sports nets & turfs on interactive map with bottom sheet',
          routeTag: 'Map Screen',
          onTap: () => _navigateTo(const MapScreen()),
        ),
        _buildFlowTile(
          icon: Icons.pin_drop_rounded,
          iconColor: Colors.deepOrange,
          title: 'OpenStreetMap Location Picker',
          subtitle: 'Interactive map picker to choose venue or club GPS coordinates',
          routeTag: 'OSM Picker',
          onTap: () => _navigateTo(const OSMLocationPickerScreen()),
        ),
        _buildFlowTile(
          icon: Icons.book_online_rounded,
          iconColor: Colors.indigo,
          title: 'My Net Bookings',
          subtitle: 'Customer reservation list with cash dues and cancel option',
          routeTag: '/#/my-bookings',
          onTap: () => _navigateTo(const CustomerBookingsScreen()),
        ),
        _buildFlowTile(
          icon: Icons.post_add_rounded,
          iconColor: Colors.amber[800]!,
          title: 'Create Text Post',
          subtitle: 'Share quick thoughts, updates, and game invitations',
          routeTag: 'Text Post',
          onTap: () => _navigateTo(const CreateTextPostScreen()),
        ),
        _buildFlowTile(
          icon: Icons.perm_media_rounded,
          iconColor: Colors.pink,
          title: 'Create Media Post (PHP Storage)',
          subtitle: 'Upload photo/video via PHP backend and publish to feed',
          routeTag: 'Media Post (PHP)',
          onTap: _openMediaPostFlow,
        ),
        _buildFlowTile(
          icon: Icons.groups_rounded,
          iconColor: Colors.blue[700]!,
          title: 'Clubs Explorer & Join',
          subtitle: 'Explore local sports clubs, view rosters and join',
          routeTag: 'Join Club',
          onTap: () => _navigateTo(const JoinClubScreen()),
        ),
        _buildFlowTile(
          icon: Icons.group_add_rounded,
          iconColor: Colors.blue[800]!,
          title: 'Create New Sports Club',
          subtitle: 'Set up sports club, logo upload (PHP), location, and rules',
          routeTag: 'Create Club',
          onTap: () => _navigateTo(const CreateClubScreen()),
        ),
        _buildFlowTile(
          icon: Icons.chat_bubble_rounded,
          iconColor: Colors.cyan[700]!,
          title: 'Direct Messages & Chat',
          subtitle: '1-on-1 chats and conversation inbox',
          routeTag: 'Messages',
          onTap: () => _navigateTo(const MessagesScreen()),
        ),
        _buildFlowTile(
          icon: Icons.notifications_rounded,
          iconColor: Colors.orange,
          title: 'Notifications Center',
          subtitle: 'Activity alerts, booking reminders, and friend requests',
          routeTag: 'Notifications',
          onTap: () => _navigateTo(const NotificationsScreen()),
        ),
        _buildFlowTile(
          icon: Icons.person_search_rounded,
          iconColor: Colors.deepPurple,
          title: 'Discover Sports Players',
          subtitle: 'Find players nearby by sport preference',
          routeTag: 'Discover',
          onTap: () => _navigateTo(const DiscoverPeopleScreen()),
        ),
        _buildFlowTile(
          icon: Icons.event_rounded,
          iconColor: Colors.redAccent,
          title: 'Sports Events & Tournaments',
          subtitle: 'View upcoming matches, sessions, and tournaments',
          routeTag: 'Events',
          onTap: () => _navigateTo(const EventsScreen()),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProfileSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: '⚙️ Profile, Auth & Settings',
          subtitle: 'User profile, PHP picture upload, password reset, and registration',
          color: Colors.blueGrey,
        ),
        const SizedBox(height: 8),
        _buildFlowTile(
          icon: Icons.account_circle_rounded,
          iconColor: Colors.blueGrey,
          title: 'User Profile Screen',
          subtitle: 'Profile details, portal switcher, PHP photo upload',
          routeTag: 'Profile',
          onTap: () => _navigateTo(const ProfileScreen()),
        ),
        _buildFlowTile(
          icon: Icons.edit_note_rounded,
          iconColor: Colors.blueGrey,
          title: 'Edit Profile Information',
          subtitle: 'Change display name, bio, sports, and phone number',
          routeTag: 'Edit Profile',
          onTap: () => _navigateTo(const EditProfileScreen()),
        ),
        _buildFlowTile(
          icon: Icons.settings_rounded,
          iconColor: Colors.blueGrey,
          title: 'Application Settings',
          subtitle: 'App preferences, theme, sound, and account options',
          routeTag: 'Settings',
          onTap: () => _navigateTo(const SettingsScreen()),
        ),
        _buildFlowTile(
          icon: Icons.lock_person_rounded,
          iconColor: Colors.blueGrey,
          title: 'Privacy Settings',
          subtitle: 'Profile visibility, blocking, and communication controls',
          routeTag: 'Privacy',
          onTap: () => _navigateTo(const PrivacySettingsScreen()),
        ),
        _buildFlowTile(
          icon: Icons.person_add_alt_1_rounded,
          iconColor: Colors.green,
          title: 'Sign Up / New Registration',
          subtitle: 'Create a brand new customer account',
          routeTag: 'Sign Up',
          onTap: () => _navigateTo(const SignupScreen()),
        ),
        _buildFlowTile(
          icon: Icons.lock_reset_rounded,
          iconColor: Colors.blue,
          title: 'Forgot Password Flow',
          subtitle: 'Password recovery and reset email flow',
          routeTag: 'Forgot Password',
          onTap: () => _navigateTo(const ForgotPasswordScreen()),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String routeTag,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        onTap: onTap,
        dense: true,
        tileColor: Colors.grey[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[200]!),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            routeTag,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}
