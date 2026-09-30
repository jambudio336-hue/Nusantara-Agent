import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedFile;

  Future<void> _pickImage() async {
    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;
    setState(() => _selectedFile = image.name);
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null || !mounted) return;
    setState(() => _selectedFile = result.files.single.name);
  }

  Future<void> _openOpenRouter() async {
    await launchUrl(
      Uri.parse('https://openrouter.ai/'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Tools',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        const Text(
          'Toolkit dasar untuk workflow AI. Modul security/trading dapat ditambahkan berikutnya.',
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 20),
        _ToolCard(
          icon: Icons.image_outlined,
          title: 'Image Picker',
          subtitle: _selectedFile ?? 'Pilih gambar dari perangkat',
          onTap: _pickImage,
        ),
        const SizedBox(height: 10),
        _ToolCard(
          icon: Icons.attach_file_outlined,
          title: 'File Picker',
          subtitle: _selectedFile ?? 'Pilih dokumen dari perangkat',
          onTap: _pickFile,
        ),
        const SizedBox(height: 10),
        _ToolCard(
          icon: Icons.open_in_browser_outlined,
          title: 'OpenRouter',
          subtitle: 'Buka dashboard OpenRouter',
          onTap: _openOpenRouter,
        ),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
