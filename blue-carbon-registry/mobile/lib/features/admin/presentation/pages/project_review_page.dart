import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Data Models
enum VerificationStep {
  initialReview(1, 'Initial Review', 'Basic project information verification'),
  documentVerification(2, 'Document Verification', 'Legal documents and permits validation'),
  technicalAssessment(3, 'Technical Assessment', 'Scientific and technical evaluation'),
  aiAnalysis(4, 'AI Analysis', 'Automated photo and data analysis'),
  satelliteVerification(5, 'Satellite Verification', 'Remote sensing data validation'),
  fieldInspection(6, 'Field Inspection', 'On-site verification (if required)'),
  finalApproval(7, 'Final Approval', 'Final review and decision');

  const VerificationStep(this.stepNumber, this.title, this.description);

  final int stepNumber;
  final String title;
  final String description;
}

enum StepStatus { notStarted, inProgress, completed, rejected, requiresAction }

class VerificationStepData {
  final VerificationStep step;
  final StepStatus status;
  final String? comments;
  final String? assignedTo;
  final DateTime? completedAt;
  final Map<String, dynamic>? data;

  VerificationStepData({
    required this.step,
    required this.status,
    this.comments,
    this.assignedTo,
    this.completedAt,
    this.data,
  });

  VerificationStepData copyWith({
    VerificationStep? step,
    StepStatus? status,
    String? comments,
    String? assignedTo,
    DateTime? completedAt,
    Map<String, dynamic>? data,
  }) {
    return VerificationStepData(
      step: step ?? this.step,
      status: status ?? this.status,
      comments: comments ?? this.comments,
      assignedTo: assignedTo ?? this.assignedTo,
      completedAt: completedAt ?? this.completedAt,
      data: data ?? this.data,
    );
  }
}

class ProjectData {
  final String id;
  final String name;
  final String ngo;
  final String location;
  final Map<String, dynamic> details;
  final List<String> photos;
  final DateTime submissionDate;
  final List<VerificationStepData> verificationSteps;

  ProjectData({
    required this.id,
    required this.name,
    required this.ngo,
    required this.location,
    required this.details,
    required this.photos,
    required this.submissionDate,
    required this.verificationSteps,
  });
}

// Providers
final projectDataProvider = StateNotifierProvider.family<ProjectDataNotifier, AsyncValue<ProjectData>, String>((ref, projectId) {
  return ProjectDataNotifier(projectId);
});

class ProjectDataNotifier extends StateNotifier<AsyncValue<ProjectData>> {
  final String projectId;

  ProjectDataNotifier(this.projectId) : super(const AsyncValue.loading()) {
    loadProjectData();
  }

  Future<void> loadProjectData() async {
    try {
      state = const AsyncValue.loading();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      final projectData = ProjectData(
        id: projectId,
        name: 'Coastal Mangrove Restoration Project',
        ngo: 'Green Coast Foundation',
        location: 'West Bengal, India',
        details: {
          'coordinates': 'Lat: 22.3511, Long: 87.9085',
          'area': '50.5 hectares',
          'species': 'Rhizophora mucronata, Avicennia marina',
          'budget': '₹92,50,000',
          'duration': '18 months',
          'expectedCredits': '2,500 tCO2e',
          'description': 'A comprehensive mangrove restoration project aimed at restoring coastal ecosystems in the Sundarbans region.',
        },
        photos: [
          'Site preparation photo',
          'Current vegetation photo',
          'Satellite imagery',
          'Location verification photo',
        ],
        submissionDate: DateTime.now().subtract(const Duration(days: 5)),
        verificationSteps: _initializeVerificationSteps(),
      );

      state = AsyncValue.data(projectData);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  List<VerificationStepData> _initializeVerificationSteps() {
    return VerificationStep.values.map((step) {
      StepStatus status = StepStatus.notStarted;
      String? comments;
      DateTime? completedAt;

      // Mock some completed steps
      if (step.stepNumber <= 2) {
        status = StepStatus.completed;
        completedAt = DateTime.now().subtract(Duration(days: 4 - step.stepNumber));
        comments = 'Step completed successfully';
      } else if (step.stepNumber == 3) {
        status = StepStatus.inProgress;
        comments = 'Currently under technical review';
      }

      return VerificationStepData(
        step: step,
        status: status,
        comments: comments,
        assignedTo: step.stepNumber <= 3 ? 'Admin User' : null,
        completedAt: completedAt,
      );
    }).toList();
  }

  Future<void> updateStepStatus(VerificationStep step, StepStatus status, String comments) async {
    final currentState = state.asData?.value;
    if (currentState == null) return;

    final updatedSteps = currentState.verificationSteps.map((stepData) {
      if (stepData.step == step) {
        return stepData.copyWith(
          status: status,
          comments: comments,
          completedAt: status == StepStatus.completed ? DateTime.now() : null,
        );
      }
      return stepData;
    }).toList();

    final updatedProject = ProjectData(
      id: currentState.id,
      name: currentState.name,
      ngo: currentState.ngo,
      location: currentState.location,
      details: currentState.details,
      photos: currentState.photos,
      submissionDate: currentState.submissionDate,
      verificationSteps: updatedSteps,
    );

    state = AsyncValue.data(updatedProject);

    // Simulate API call to update step
    await Future.delayed(const Duration(milliseconds: 500));

    // Send notification to NGO
    _sendNotificationToNGO(step, status);
  }

  void _sendNotificationToNGO(VerificationStep step, StepStatus status) {
    // This would normally send a push notification or email to the NGO
    print('Notification sent to NGO: ${step.title} is now ${status.name}');
  }
}

class ProjectReviewPage extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectReviewPage({
    super.key,
    required this.projectId,
  });

  @override
  ConsumerState<ProjectReviewPage> createState() => _ProjectReviewPageState();
}

class _ProjectReviewPageState extends ConsumerState<ProjectReviewPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _stepController;
  final _commentController = TextEditingController();
  bool _isProcessing = false;
  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _stepController = PageController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _stepController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final projectAsync = ref.watch(projectDataProvider(widget.projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Verification'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin-dashboard'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(projectDataProvider(widget.projectId).notifier).loadProjectData(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Verification Steps', icon: Icon(Icons.fact_check)),
            Tab(text: 'Project Details', icon: Icon(Icons.info)),
            Tab(text: 'Documents & Media', icon: Icon(Icons.folder)),
          ],
        ),
      ),
      body: projectAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading project: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.read(projectDataProvider(widget.projectId).notifier).loadProjectData(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (project) => TabBarView(
          controller: _tabController,
          children: [
            _buildVerificationStepsTab(project),
            _buildProjectDetailsTab(project),
            _buildDocumentsTab(project),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationStepsTab(ProjectData project) {
    return Column(
      children: [
        _buildProgressIndicator(project.verificationSteps),
        Expanded(
          child: PageView.builder(
            controller: _stepController,
            onPageChanged: (index) => setState(() => _currentStepIndex = index),
            itemCount: project.verificationSteps.length,
            itemBuilder: (context, index) {
              final stepData = project.verificationSteps[index];
              return _buildStepDetailView(stepData, project);
            },
          ),
        ),
        _buildStepNavigation(project.verificationSteps),
      ],
    );
  }

  Widget _buildProgressIndicator(List<VerificationStepData> steps) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Verification Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: steps.length,
              itemBuilder: (context, index) {
                final step = steps[index];
                final isActive = index == _currentStepIndex;

                return GestureDetector(
                  onTap: () {
                    setState(() => _currentStepIndex = index);
                    _stepController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getStepColor(step.status),
                            border: Border.all(
                              color: isActive ? Colors.blue : Colors.grey.shade300,
                              width: isActive ? 3 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${step.step.stepNumber}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              _getStepIcon(step.status),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          step.step.title,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepDetailView(VerificationStepData stepData, ProjectData project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(stepData),
          const SizedBox(height: 20),
          _buildStepContent(stepData, project),
          const SizedBox(height: 20),
          _buildStepActions(stepData),
        ],
      ),
    );
  }

  Widget _buildStepHeader(VerificationStepData stepData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStepColor(stepData.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStepIconData(stepData.step),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stepData.step.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        stepData.step.description,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(stepData.status),
              ],
            ),
            if (stepData.assignedTo != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Assigned to: ${stepData.assignedTo}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
            if (stepData.completedAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Completed: ${_formatDate(stepData.completedAt!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(VerificationStepData stepData, ProjectData project) {
    switch (stepData.step) {
      case VerificationStep.initialReview:
        return _buildInitialReviewContent(project);
      case VerificationStep.documentVerification:
        return _buildDocumentVerificationContent(project);
      case VerificationStep.technicalAssessment:
        return _buildTechnicalAssessmentContent(project);
      case VerificationStep.aiAnalysis:
        return _buildAIAnalysisContent(project);
      case VerificationStep.satelliteVerification:
        return _buildSatelliteVerificationContent(project);
      case VerificationStep.fieldInspection:
        return _buildFieldInspectionContent(project);
      case VerificationStep.finalApproval:
        return _buildFinalApprovalContent(project);
    }
  }

  Widget _buildInitialReviewContent(ProjectData project) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information Review',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Project Name', project.name),
            _buildInfoRow('NGO', project.ngo),
            _buildInfoRow('Location', project.location),
            _buildInfoRow('Area', project.details['area'] ?? 'N/A'),
            _buildInfoRow('Budget', project.details['budget'] ?? 'N/A'),
            _buildInfoRow('Duration', project.details['duration'] ?? 'N/A'),
            const SizedBox(height: 16),
            const Text(
              'Review Checklist',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildChecklistItem('Project name is clear and descriptive', true),
            _buildChecklistItem('NGO information is complete', true),
            _buildChecklistItem('Location coordinates are valid', true),
            _buildChecklistItem('Budget appears reasonable', true),
            _buildChecklistItem('Timeline is realistic', true),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentVerificationContent(ProjectData project) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Document Verification',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildDocumentItem('NGO Registration Certificate', 'Verified', Icons.check_circle, Colors.green),
            _buildDocumentItem('Environmental Clearance', 'Verified', Icons.check_circle, Colors.green),
            _buildDocumentItem('Land Use Permit', 'Verified', Icons.check_circle, Colors.green),
            _buildDocumentItem('Project Proposal Document', 'Verified', Icons.check_circle, Colors.green),
            _buildDocumentItem('Financial Statements', 'Verified', Icons.check_circle, Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalAssessmentContent(ProjectData project) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Technical Assessment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildAssessmentMetric('Methodology Compliance', 95, Colors.green),
            _buildAssessmentMetric('Species Selection', 88, Colors.green),
            _buildAssessmentMetric('Site Suitability', 92, Colors.green),
            _buildAssessmentMetric('Carbon Calculation', 85, Colors.orange),
            _buildAssessmentMetric('Risk Assessment', 90, Colors.green),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Carbon calculation methodology needs minor adjustments.',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIAnalysisContent(ProjectData project) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'AI Analysis Results',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _runAIAnalysis(),
                      icon: const Icon(Icons.psychology),
                      label: const Text('Run Analysis'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withOpacity(0.1),
                      border: Border.all(color: Colors.green, width: 4),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '91%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'Confidence',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildAIMetric('Vegetation Match', 92),
                _buildAIMetric('Location Accuracy', 88),
                _buildAIMetric('Species Compatibility', 95),
                _buildAIMetric('Soil Suitability', 87),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Recommendations',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildRecommendationItem('Conduct detailed soil analysis'),
                _buildRecommendationItem('Install monitoring equipment'),
                _buildRecommendationItem('Partner with local fishermen for ongoing maintenance'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSatelliteVerificationContent(ProjectData project) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Satellite Data Analysis',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSatelliteMetric('NDVI Score', '0.45', 'Baseline vegetation index'),
            _buildSatelliteMetric('Water Proximity', '50m', 'Optimal distance to water'),
            _buildSatelliteMetric('Forest Cover', '12%', 'Current coverage (Target: 65%)'),
            _buildSatelliteMetric('Tide Accessibility', 'Excellent', 'Regular tidal access confirmed'),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.satellite, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Satellite Image View'),
                    Text('(Live satellite data)', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldInspectionContent(ProjectData project) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Field Inspection',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Field inspection may be required for projects over 100 hectares or with high risk factors.',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _scheduleFieldInspection(),
                    icon: const Icon(Icons.schedule),
                    label: const Text('Schedule Inspection'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _skipFieldInspection(),
                    icon: const Icon(Icons.skip_next),
                    label: const Text('Skip (Low Risk)'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalApprovalContent(ProjectData project) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Final Approval Summary',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildSummaryItem('Initial Review', StepStatus.completed),
            _buildSummaryItem('Document Verification', StepStatus.completed),
            _buildSummaryItem('Technical Assessment', StepStatus.completed),
            _buildSummaryItem('AI Analysis', StepStatus.completed),
            _buildSummaryItem('Satellite Verification', StepStatus.completed),
            _buildSummaryItem('Field Inspection', StepStatus.completed),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'All verification steps completed successfully. Project is ready for final approval.',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepActions(VerificationStepData stepData) {
    if (stepData.status == StepStatus.completed) {
      return _buildCompletedActions(stepData);
    } else if (stepData.status == StepStatus.inProgress) {
      return _buildInProgressActions(stepData);
    } else {
      return _buildNotStartedActions(stepData);
    }
  }

  Widget _buildCompletedActions(VerificationStepData stepData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Step Completed',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (stepData.comments != null) ...[
              const SizedBox(height: 8),
              Text('Comments: ${stepData.comments}'),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _reviewStep(stepData),
                    icon: const Icon(Icons.visibility),
                    label: const Text('Review Details'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _reopenStep(stepData),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reopen'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInProgressActions(VerificationStepData stepData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Complete This Step',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _commentController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Comments',
                hintText: 'Add your review comments...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _completeStep(stepData, StepStatus.completed),
                    icon: _isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _completeStep(stepData, StepStatus.requiresAction),
                    icon: const Icon(Icons.warning),
                    label: const Text('Needs Action'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _completeStep(stepData, StepStatus.rejected),
                    icon: const Icon(Icons.close),
                    label: const Text('Reject'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotStartedActions(VerificationStepData stepData) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Start This Step',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _startStep(stepData),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Begin Review'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepNavigation(List<VerificationStepData> steps) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: _currentStepIndex > 0
                ? () {
                    setState(() => _currentStepIndex--);
                    _stepController.animateToPage(
                      _currentStepIndex,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
          ),
          const Spacer(),
          Text(
            'Step ${_currentStepIndex + 1} of ${steps.length}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _currentStepIndex < steps.length - 1
                ? () {
                    setState(() => _currentStepIndex++);
                    _stepController.animateToPage(
                      _currentStepIndex,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Next'),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDetailsTab(ProjectData project) {
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
                  const Text(
                    'Project Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Project Name', project.name),
                  _buildInfoRow('NGO', project.ngo),
                  _buildInfoRow('Location', project.location),
                  _buildInfoRow('Coordinates', project.details['coordinates'] ?? 'N/A'),
                  _buildInfoRow('Area', project.details['area'] ?? 'N/A'),
                  _buildInfoRow('Species', project.details['species'] ?? 'N/A'),
                  _buildInfoRow('Budget', project.details['budget'] ?? 'N/A'),
                  _buildInfoRow('Duration', project.details['duration'] ?? 'N/A'),
                  _buildInfoRow('Expected Credits', project.details['expectedCredits'] ?? 'N/A'),
                  _buildInfoRow('Submission Date', _formatDate(project.submissionDate)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Project Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(project.details['description'] ?? 'No description available'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab(ProjectData project) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Project Photos',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: project.photos.length,
            itemBuilder: (context, index) {
              final photo = project.photos[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        photo,
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper methods for building UI components
  Color _getStepColor(StepStatus status) {
    switch (status) {
      case StepStatus.completed:
        return Colors.green;
      case StepStatus.inProgress:
        return Colors.blue;
      case StepStatus.rejected:
        return Colors.red;
      case StepStatus.requiresAction:
        return Colors.orange;
      case StepStatus.notStarted:
        return Colors.grey;
    }
  }

  Widget _getStepIcon(StepStatus status) {
    switch (status) {
      case StepStatus.completed:
        return const Icon(Icons.check, color: Colors.white, size: 12);
      case StepStatus.inProgress:
        return const Icon(Icons.play_arrow, color: Colors.white, size: 12);
      case StepStatus.rejected:
        return const Icon(Icons.close, color: Colors.white, size: 12);
      case StepStatus.requiresAction:
        return const Icon(Icons.warning, color: Colors.white, size: 12);
      case StepStatus.notStarted:
        return const Icon(Icons.circle_outlined, color: Colors.white, size: 12);
    }
  }

  IconData _getStepIconData(VerificationStep step) {
    switch (step) {
      case VerificationStep.initialReview:
        return Icons.info;
      case VerificationStep.documentVerification:
        return Icons.description;
      case VerificationStep.technicalAssessment:
        return Icons.engineering;
      case VerificationStep.aiAnalysis:
        return Icons.psychology;
      case VerificationStep.satelliteVerification:
        return Icons.satellite;
      case VerificationStep.fieldInspection:
        return Icons.location_on;
      case VerificationStep.finalApproval:
        return Icons.check_circle;
    }
  }

  Widget _buildStatusChip(StepStatus status) {
    Color color;
    String text;

    switch (status) {
      case StepStatus.completed:
        color = Colors.green;
        text = 'Completed';
        break;
      case StepStatus.inProgress:
        color = Colors.blue;
        text = 'In Progress';
        break;
      case StepStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        break;
      case StepStatus.requiresAction:
        color = Colors.orange;
        text = 'Needs Action';
        break;
      case StepStatus.notStarted:
        color = Colors.grey;
        text = 'Not Started';
        break;
    }

    return Chip(
      label: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String item, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isChecked ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(item)),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(String title, String status, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAssessmentMetric(String title, int score, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title),
              Text('$score%'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      ),
    );
  }

  Widget _buildAIMetric(String title, int score) {
    return _buildAssessmentMetric(title, score, score >= 90 ? Colors.green : score >= 80 ? Colors.orange : Colors.red);
  }

  Widget _buildRecommendationItem(String recommendation) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.lightbulb, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(child: Text(recommendation)),
        ],
      ),
    );
  }

  Widget _buildSatelliteMetric(String title, String value, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            flex: 2,
            child: Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, StepStatus status) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            status == StepStatus.completed ? Icons.check_circle : Icons.pending,
            color: status == StepStatus.completed ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
          _buildStatusChip(status),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  // Action methods
  Future<void> _startStep(VerificationStepData stepData) async {
    await ref.read(projectDataProvider(widget.projectId).notifier).updateStepStatus(
      stepData.step,
      StepStatus.inProgress,
      'Step started for review',
    );
  }

  Future<void> _completeStep(VerificationStepData stepData, StepStatus status) async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add comments before completing the step'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      await ref.read(projectDataProvider(widget.projectId).notifier).updateStepStatus(
        stepData.step,
        status,
        _commentController.text.trim(),
      );

      _commentController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Step ${status.name}. NGO has been notified.'),
          backgroundColor: Colors.green,
        ),
      );

      // Move to next step if completed successfully
      if (status == StepStatus.completed && _currentStepIndex < VerificationStep.values.length - 1) {
        setState(() => _currentStepIndex++);
        _stepController.animateToPage(
          _currentStepIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _reviewStep(VerificationStepData stepData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Review: ${stepData.step.title}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${stepData.status.name}'),
            if (stepData.comments != null) ...[
              const SizedBox(height: 8),
              Text('Comments: ${stepData.comments}'),
            ],
            if (stepData.completedAt != null) ...[
              const SizedBox(height: 8),
              Text('Completed: ${_formatDate(stepData.completedAt!)}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _reopenStep(VerificationStepData stepData) async {
    await ref.read(projectDataProvider(widget.projectId).notifier).updateStepStatus(
      stepData.step,
      StepStatus.inProgress,
      'Step reopened for re-review',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Step reopened for review'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _runAIAnalysis() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Running AI analysis...'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _scheduleFieldInspection() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Field inspection scheduled'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _skipFieldInspection() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Field inspection skipped (low risk project)'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}