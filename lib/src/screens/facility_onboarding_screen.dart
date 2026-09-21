import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sports_chat_app/src/services/facility_service.dart';
import 'package:sports_chat_app/src/services/php_storage_service.dart';

class FacilityOnboardingScreen extends StatefulWidget {
  const FacilityOnboardingScreen({super.key});

  @override
  State<FacilityOnboardingScreen> createState() => _FacilityOnboardingScreenState();
}

class _FacilityOnboardingScreenState extends State<FacilityOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _facilityService = FacilityService();

  // Basic Info Controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedCity = 'Islamabad';
  double _latitude = 33.6844;
  double _longitude = 73.0479;

  final List<String> _cities = ['Islamabad', 'Rawalpindi', 'Other'];
  String? _coverImageUrl;
  bool _isUploadingCover = false;

  Future<void> _pickAndUploadCover() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;

    setState(() => _isUploadingCover = true);
    final url = await PhpStorageService().uploadFile(file: file, folder: 'facilities');
    setState(() {
      _isUploadingCover = false;
      if (url != null) _coverImageUrl = url;
    });
  }

  Future<void> _pickAndUploadNetImage(Map<String, dynamic> net) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;

    final url = await PhpStorageService().uploadFile(file: file, folder: 'nets');
    if (url != null) {
      setState(() {
        (net['images'] as List<String>).insert(0, url);
      });
    }
  }

  // Sports Offered
  final List<String> _allSports = [
    'Cricket',
    'Football',
    'Padel',
    'Tennis',
    'Badminton',
    'Basketball',
    'Table Tennis',
  ];
  final Set<String> _selectedSports = {'Cricket'};

  // Nets list
  final List<Map<String, dynamic>> _nets = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Add default initial net
    _addDefaultNet();
  }

  void _addDefaultNet() {
    _nets.add({
      'name': 'Net ${_nets.length + 1}',
      'sport': _selectedSports.isNotEmpty ? _selectedSports.first : 'Cricket',
      'shape': 'Rectangular',
      'lengthFt': 66.0,
      'widthFt': 14.0,
      'heightFt': 12.0,
      'hourlyRate': 2000.0,
      'images': <String>[
        'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800',
      ],
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitFacility() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one sport.')),
      );
      return;
    }
    if (_nets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one net or court.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _facilityService.createFacility(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        city: _selectedCity,
        latitude: _latitude,
        longitude: _longitude,
        sports: _selectedSports.toList(),
        phone: _phoneController.text.trim(),
        coverImageUrl: _coverImageUrl ??
            (_nets.first['images']?.isNotEmpty == true
                ? _nets.first['images'][0]
                : 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?w=800'),
        netsData: _nets,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Facility & Nets published successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pushReplacementNamed('/owner/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Venue & Net Onboarding',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF8C00), Color(0xFFFFA500)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.sports_cricket, color: Colors.white, size: 36),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'List Your Facility & Nets',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Rawalpindi & Islamabad Sports Network',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 1: Venue Details
            _buildSectionCard(
              title: '1. Venue Information',
              icon: Icons.storefront,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Facility / Venue Name *',
                    hintText: 'e.g. Rawalpindi Cricket Hub or Padel Arena F-7',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        value: _selectedCity,
                        decoration: const InputDecoration(
                          labelText: 'City *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_city),
                        ),
                        items: _cities
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedCity = val;
                              if (val == 'Islamabad') {
                                _latitude = 33.6844;
                                _longitude = 73.0479;
                              } else if (val == 'Rawalpindi') {
                                _latitude = 33.5651;
                                _longitude = 73.0169;
                              }
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Contact Phone *',
                          hintText: '0300-1234567',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Full Address / Sector *',
                    hintText: 'e.g. Street 12, Sector I-8/2, Islamabad',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.map),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 14),

                // Venue Cover Photo
                OutlinedButton.icon(
                  onPressed: _isUploadingCover ? null : _pickAndUploadCover,
                  icon: _isUploadingCover
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.add_photo_alternate),
                  label: Text(_coverImageUrl != null ? 'Change Venue Cover Photo' : 'Upload Venue Cover Photo'),
                ),
                if (_coverImageUrl != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(_coverImageUrl!, height: 120, width: double.infinity, fit: BoxFit.cover),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),

            // Section 2: Sports Offered
            _buildSectionCard(
              title: '2. Sports Offered',
              icon: Icons.sports,
              children: [
                const Text(
                  'Select all sports available at this venue:',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _allSports.map((sport) {
                    final isSelected = _selectedSports.contains(sport);
                    return FilterChip(
                      label: Text(sport),
                      selected: isSelected,
                      selectedColor: const Color(0xFFFF8C00).withOpacity(0.2),
                      checkmarkColor: const Color(0xFFFF8C00),
                      labelStyle: TextStyle(
                        color: isSelected ? const Color(0xFFFF8C00) : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedSports.add(sport);
                          } else {
                            if (_selectedSports.length > 1) {
                              _selectedSports.remove(sport);
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Section 3: Nets & Pitches Specifications
            _buildSectionCard(
              title: '3. Nets, Pitches & Courts',
              icon: Icons.grid_view_rounded,
              trailing: TextButton.icon(
                onPressed: () => setState(_addDefaultNet),
                icon: const Icon(Icons.add_circle, color: Color(0xFFFF8C00)),
                label: const Text('Add Another Net', style: TextStyle(color: Color(0xFFFF8C00))),
              ),
              children: [
                for (int i = 0; i < _nets.length; i++) _buildNetCard(i),
              ],
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitFacility,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C00),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Publish Venue & Nets',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    Widget? trailing,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFFF8C00), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const Divider(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNetCard(int index) {
    final net = _nets[index];
    final shapes = ['Rectangular', 'Box / Square', 'Circular / Oval', 'Custom'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFFFF8C00),
                child: Text('${index + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  initialValue: net['name'],
                  decoration: const InputDecoration(
                    labelText: 'Net / Court Label',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  onChanged: (val) => net['name'] = val,
                ),
              ),
              if (_nets.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => setState(() => _nets.removeAt(index)),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Sport and Shape Row
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSports.contains(net['sport']) ? net['sport'] : _selectedSports.first,
                  decoration: const InputDecoration(labelText: 'Sport', isDense: true),
                  items: _selectedSports
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) => setState(() => net['sport'] = val),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: net['shape'],
                  decoration: const InputDecoration(labelText: 'Shape', isDense: true),
                  items: shapes
                      .map((sh) => DropdownMenuItem(value: sh, child: Text(sh)))
                      .toList(),
                  onChanged: (val) => setState(() => net['shape'] = val),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Dimensions (L x W x H)
          const Text('Dimensions (Feet):', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: '${net['lengthFt']}',
                  decoration: const InputDecoration(labelText: 'Length (ft)', isDense: true),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => net['lengthFt'] = double.tryParse(val) ?? 66.0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: '${net['widthFt']}',
                  decoration: const InputDecoration(labelText: 'Width (ft)', isDense: true),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => net['widthFt'] = double.tryParse(val) ?? 14.0,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: '${net['heightFt']}',
                  decoration: const InputDecoration(labelText: 'Height (ft)', isDense: true),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => net['heightFt'] = double.tryParse(val) ?? 12.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Hourly Rate
          TextFormField(
            initialValue: '${net['hourlyRate'].toInt()}',
            decoration: const InputDecoration(
              labelText: 'Hourly Rate (PKR / Hour) *',
              prefixText: 'PKR ',
              prefixIcon: Icon(Icons.payments_outlined),
              isDense: true,
            ),
            keyboardType: TextInputType.number,
            onChanged: (val) => net['hourlyRate'] = double.tryParse(val) ?? 2000.0,
          ),
          const SizedBox(height: 12),

          // Net Photo Upload
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _pickAndUploadNetImage(net),
                icon: const Icon(Icons.camera_alt_outlined, size: 16),
                label: const Text('Add Net Photo', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 8),
              if ((net['images'] as List<String>).isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    (net['images'] as List<String>).first,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
