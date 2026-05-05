import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_social_student/core/theme/app_theme.dart';
import 'package:uni_social_student/core/network/api_constants.dart';

// Standalone provider for Moderator Reports Feed to avoid clashing with the student ReportForm provider

import '../../data/repositories/reports_repository.dart';

class ReportsFeedProvider with ChangeNotifier {
  final _repository = ReportsRepository();

  List<dynamic> _reports = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get reports => _reports;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadReports() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reports = await _repository.getReports();
    } catch (e) {
      _error = 'Error cargando reportes: ' + e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleAction(int reportId, String action) async {
    try {
      await _repository.handleAction(reportId, action);
      _reports.removeWhere((r) => r['id'] == reportId);
      notifyListeners();
    } catch (e) {
      throw Exception('Error procesando acción: ' + e.toString());
    }
  }
}



class ReportsFeedScreen extends StatefulWidget {
  const ReportsFeedScreen({super.key});

  @override
  State<ReportsFeedScreen> createState() => _ReportsFeedScreenState();
}

class _ReportsFeedScreenState extends State<ReportsFeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportsFeedProvider>().loadReports();
    });
  }

  void _handleAction(BuildContext context, int reportId, String action) async {
    try {
      await context.read<ReportsFeedProvider>().handleAction(reportId, action);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(action == 'penalize' ? 'Usuario penalizado por 5 días.' : 'Reporte cancelado.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.errorRed),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReportsFeedProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(provider.error!),
                ElevatedButton(
                  onPressed: provider.loadReports,
                  child: const Text('Reintentar'),
                )
              ],
            ),
          );
        }

        if (provider.reports.isEmpty) {
          return const Center(child: Text('No hay reportes pendientes.'));
        }

        return RefreshIndicator(
          onRefresh: provider.loadReports,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.reports.length,
            itemBuilder: (context, index) {
              final report = provider.reports[index];
              final isCommunity = report['target_type'] == 'community';
              final labelTag = isCommunity ? 'REPORTE COMUNIDAD' : 'REPORTE GLOBAL';

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              report['subject'],
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isCommunity ? Colors.blue.withAlpha(50) : AppTheme.primaryRed.withAlpha(50),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              labelTag,
                              style: TextStyle(
                                color: isCommunity ? Colors.blue : AppTheme.primaryRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('Reportado por: ${report['reporter_id']}'),
                      Text('Culpable: ${report['target_id']}'),
                      const SizedBox(height: 8),
                      const Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(report['description'] ?? ''),
                      if (report['evidence_image_url'] != null) ...[
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: ConstrainedBox(
                             constraints: const BoxConstraints(
                               maxHeight: 200,
                             ),
                             child: Image.network(
                               '${ApiConstants.baseUrl.replaceAll('/api', '')}${report['evidence_image_url']}',
                               fit: BoxFit.contain,
                             ),
                           ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => _handleAction(context, report['id'], 'cancel'),
                            child: const Text('Cancelar Reporte'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
                            onPressed: () => _handleAction(context, report['id'], 'penalize'),
                            child: const Text('Penalizar (5 días)', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
