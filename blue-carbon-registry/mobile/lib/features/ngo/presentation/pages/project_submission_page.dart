import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class DocumentUpload {
  final String name;
  final String type;
  final XFile file;
  final bool isRequired;

  DocumentUpload({
    required this.name,
    required this.type,
    required this.file,
    this.isRequired = false,
  });
}

class ProjectSubmissionPage extends ConsumerStatefulWidget {
  const ProjectSubmissionPage({super.key});

  @override
  ConsumerState<ProjectSubmissionPage> createState() => _ProjectSubmissionPageState();
}

class _ProjectSubmissionPageState extends ConsumerState<ProjectSubmissionPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  // Basic Info Controllers
  final _projectNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _areaController = TextEditingController();
  final _budgetController = TextEditingController();
  final _durationController = TextEditingController();
  final _expectedCreditsController = TextEditingController();

  // Environmental Info Controllers
  final _speciesController = TextEditingController();
  final _methodologyController = TextEditingController();
  final _baselineController = TextEditingController();
  final _monitoringPlanController = TextEditingController();

  // Community Impact Controllers
  final _communityBenefitsController = TextEditingController();
  final _livelihoodImpactController = TextEditingController();
  final _stakeholdersController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  List<XFile> _selectedImages = [];
  List<DocumentUpload> _documents = [];
  Position? _currentLocation;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;

  String _selectedProjectType = 'Mangrove Restoration';
  String _selectedState = 'West Bengal';
  String _selectedMethodology = 'Blue Carbon';

  final List<String> _projectTypes = [
    'Mangrove Restoration',
    'Seagrass Conservation',
    'Salt Marsh Protection',
    'Coastal Wetland Restoration',
    'Kelp Forest Restoration',
  ];

  final List<String> _indianStates = [
    'West Bengal', 'Gujarat', 'Maharashtra', 'Kerala', 'Tamil Nadu',
    'Karnataka', 'Andhra Pradesh', 'Telangana', 'Odisha', 'Goa',
  ];

  final List<String> _methodologies = [
    'Blue Carbon',
    'VM0033 - Methodology for Tidal Wetland',
    'VM0034 - Coastal Blue Carbon',
    'AR-AM0014 - Afforestation and Reforestation',
    'Custom Methodology',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _projectNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _areaController.dispose();
    _speciesController.dispose();
    _budgetController.dispose();
    _durationController.dispose();
    _expectedCreditsController.dispose();
    _methodologyController.dispose();
    _baselineController.dispose();
    _monitoringPlanController.dispose();
    _communityBenefitsController.dispose();
    _livelihoodImpactController.dispose();
    _stakeholdersController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = position;
        _locationController.text =
            'Lat: ${position.latitude.toStringAsFixed(6)}, Long: ${position.longitude.toStringAsFixed(6)}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location captured successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Project Submission'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/ngo'),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.info, size: 20), text: 'Basic Info'),
            Tab(icon: Icon(Icons.eco, size: 20), text: 'Environmental'),
            Tab(icon: Icon(Icons.people, size: 20), text: 'Community'),
            Tab(icon: Icon(Icons.upload_file, size: 20), text: 'Documents'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicInfoTab(),
            _buildEnvironmentalTab(),
            _buildCommunityTab(),
            _buildDocumentsTab(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (_tabController.index > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _tabController.animateTo(_tabController.index - 1);
                  },
                  child: const Text('Previous'),
                ),
              ),
            if (_tabController.index > 0) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : (_tabController.index == 3 ? _submitProject : () {
                  _tabController.animateTo(_tabController.index + 1);
                }),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _tabController.index == 3 ? Colors.green : null,
                ),
                child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_tabController.index == 3 ? 'Submit Project' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Project Information',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedProjectType,
                    decoration: const InputDecoration(
                      labelText: 'Project Type *',
                      border: OutlineInputBorder(),
                    ),
                    items: _projectTypes.map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedProjectType = value!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _projectNameController,
                    decoration: const InputDecoration(
                      labelText: 'Project Name *',
                      hintText: 'Enter a descriptive project name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a project name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Project Description *',
                      hintText: 'Describe your blue carbon project in detail',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a project description';
                      }
                      if (value.length < 100) {
                        return 'Description must be at least 100 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedState,
                    decoration: const InputDecoration(
                      labelText: 'State *',
                      border: OutlineInputBorder(),
                    ),
                    items: _indianStates.map((state) {
                      return DropdownMenuItem(value: state, child: Text(state));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedState = value!),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _locationController,
                          decoration: const InputDecoration(
                            labelText: 'Specific Location *',
                            hintText: 'District, Village, Coordinates',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please specify the location';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                        icon: _isLoadingLocation
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.my_location),
                        tooltip: 'Get GPS coordinates',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _areaController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Project Area (hectares) *',
                      hintText: 'Enter area in hectares',
                      border: OutlineInputBorder(),
                      suffixText: 'ha',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the project area';
                      }
                      final area = double.tryParse(value);
                      if (area == null || area <= 0) {
                        return 'Please enter a valid area';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _budgetController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Project Budget *',
                            hintText: 'Total budget in rupees',
                            prefixText: '₹ ',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the project budget';
                            }
                            final budget = double.tryParse(value);
                            if (budget == null || budget <= 0) {
                              return 'Please enter a valid budget';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _durationController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Duration *',
                            hintText: 'Months',
                            border: OutlineInputBorder(),
                            suffixText: 'months',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter duration';
                            }
                            final duration = int.tryParse(value);
                            if (duration == null || duration <= 0) {
                              return 'Please enter valid duration';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentalTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Environmental Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _speciesController,
                    decoration: const InputDecoration(
                      labelText: 'Species Information *',
                      hintText: 'Rhizophora, Avicennia, Bruguiera, etc.',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please specify the species';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedMethodology,
                    decoration: const InputDecoration(
                      labelText: 'Carbon Methodology *',
                      border: OutlineInputBorder(),
                    ),
                    items: _methodologies.map((method) {
                      return DropdownMenuItem(value: method, child: Text(method));
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedMethodology = value!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _baselineController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Baseline Assessment *',
                      hintText: 'Current carbon stock, degradation status',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide baseline assessment';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _monitoringPlanController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Monitoring Plan *',
                      hintText: 'How will you monitor carbon sequestration?',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please provide monitoring plan';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _expectedCreditsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Expected Carbon Credits *',
                      hintText: 'Estimated tCO2e over project lifetime',
                      border: OutlineInputBorder(),
                      suffixText: 'tCO2e',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter expected carbon credits';
                      }
                      final credits = double.tryParse(value);
                      if (credits == null || credits <= 0) {
                        return 'Please enter valid carbon credits';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Community Impact',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _communityBenefitsController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Community Benefits *',
                      hintText: 'How will this project benefit local communities?',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please describe community benefits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _livelihoodImpactController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Livelihood Impact *',
                      hintText: 'Jobs, income generation, skill development',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please describe livelihood impact';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _stakeholdersController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Key Stakeholders *',
                      hintText: 'Local communities, government, partners',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please list key stakeholders';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Required Documents',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDocumentSection('Project Design Document (PDD)', 'pdf', true),
                  _buildDocumentSection('Environmental Impact Assessment', 'pdf', true),
                  _buildDocumentSection('Community Consent Letter', 'pdf', true),
                  _buildDocumentSection('Land Use Certificates', 'pdf', true),
                  _buildDocumentSection('Baseline Study Report', 'pdf', false),
                  _buildDocumentSection('Monitoring Protocol', 'pdf', false),
                  const SizedBox(height: 20),
                  Text(
                    'Project Images',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickImages,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Add Project Images'),
                  ),
                  if (_selectedImages.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image, size: 50),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImages.removeAt(index);
                                  });
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentSection(String title, String type, bool required) {
    final isUploaded = _documents.any((doc) => doc.name == title);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (isUploaded) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.check_circle, color: Colors.green, size: 16),
                      ],
                    ],
                  ),
                  Text(
                    required ? 'Required' : 'Optional',
                    style: TextStyle(
                      color: required ? Colors.red : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _pickDocument(title, type, required),
              icon: Icon(isUploaded ? Icons.check : Icons.upload_file),
              label: Text(isUploaded ? 'Uploaded' : 'Upload'),
              style: OutlinedButton.styleFrom(
                foregroundColor: isUploaded ? Colors.green : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      setState(() {
        _selectedImages.addAll(images);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting images: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickDocument(String name, String type, bool required) async {
    try {
      final XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() {
          // Remove existing document with same name if any
          _documents.removeWhere((doc) => doc.name == name);
          // Add new document
          _documents.add(DocumentUpload(
            name: name,
            type: type,
            file: file,
            isRequired: required,
          ));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading document: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitProject() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check required documents
    final requiredDocs = ['Project Design Document (PDD)', 'Environmental Impact Assessment', 'Community Consent Letter', 'Land Use Certificates'];
    final missingDocs = requiredDocs.where((doc) => !_documents.any((upload) => upload.name == doc)).toList();

    if (missingDocs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Missing required documents: ${missingDocs.join(', ')}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate API submission
      await Future.delayed(const Duration(seconds: 3));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Project submitted successfully! You will receive updates via notifications.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );

      context.go('/ngo');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}