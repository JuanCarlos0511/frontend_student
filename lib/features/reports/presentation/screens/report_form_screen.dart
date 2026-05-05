import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../logic/reports_provider.dart';
import 'package:uni_social_student/core/theme/app_theme.dart';

class ReportFormScreen extends StatefulWidget {
  final String targetId;
  final String targetType; // 'post', 'market', 'community'
  final int targetItemId;

  const ReportFormScreen({
    super.key,
    required this.targetId,
    required this.targetType,
    required this.targetItemId,
  });

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedImagePath;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedImagePath = result.files.first.path;
      });
    }
  }

  Future<void> _submitReport() async {
    if (_subjectController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor llena todos los campos.'), backgroundColor: AppTheme.primaryRed),
      );
      return;
    }

    try {
      await context.read<ReportsProvider>().createReport(
        targetId: widget.targetId,
        targetType: widget.targetType,
        targetItemId: widget.targetItemId,
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        evidenceImagePath: _selectedImagePath,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reporte enviado correctamente.'))
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppTheme.primaryRed)
      );
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<ReportsProvider>().isSubmitting;

    return Scaffold(
      appBar: AppBar(title: const Text('Reportar Contenido')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Asunto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Descripción del problema',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Adjuntar Evidencia (Opcional)'),
                ),
                const SizedBox(height: 8),
                Text(_selectedImagePath != null 
                  ? 'Imagen adjuntada: ${_selectedImagePath!.split('/').last}'
                  : 'Sin evidencia adjuntada',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            if (_selectedImagePath != null) ...[
              const SizedBox(height: 16),
              Image.file(File(_selectedImagePath!), height: 150),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRed,
                padding: const EdgeInsets.symmetric(vertical: 16)
              ),
              onPressed: isSubmitting ? null : _submitReport,
              child: isSubmitting 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Enviar Reporte', style: TextStyle(color: Colors.white, fontSize: 16)),
            )
          ],
        ),
      ),
    );
  }
}
