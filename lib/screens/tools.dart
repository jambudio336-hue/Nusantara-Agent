import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'trading.dart';
import 'ops/ops_center.dart';

class ToolsScreen extends StatefulWidget {
  const ToolsScreen({super.key});
  @override State<ToolsScreen> createState() => _ToolsScreenState();
}
class _ToolsScreenState extends State<ToolsScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedFile;
  Future<void> _pickImage() async { final image = await _imagePicker.pickImage(source: ImageSource.gallery); if (image != null && mounted) setState(() => _selectedFile = image.name); }
  Future<void> _pickFile() async { final result = await FilePicker.platform.pickFiles(); if (result != null && mounted) setState(() => _selectedFile = result.files.single.name); }
  Future<void> _openOpenRouter() async => launchUrl(Uri.parse('https://openrouter.ai/'), mode: LaunchMode.externalApplication);
  Widget _section(String title, List<Widget> children) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)), const SizedBox(height: 8), ...children])));
  @override Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    const Text('Tools & Workspaces', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
    const SizedBox(height: 8), const Text('Semua request AI tetap langsung dari perangkat ke provider pilihan pengguna; tidak ada backend wajib.', style: TextStyle(color: Colors.white70)), const SizedBox(height: 16),
    _section('AI & MEDIA', [
      _ToolCard(icon: Icons.image_outlined, title: 'Analisis gambar', subtitle: _selectedFile ?? 'Pilih gambar dari perangkat', onTap: _pickImage),
      _ToolCard(icon: Icons.attach_file_outlined, title: 'Analisis berkas', subtitle: _selectedFile ?? 'Pilih PDF, teks, atau dokumen', onTap: _pickFile),
      _ToolCard(icon: Icons.open_in_browser_outlined, title: 'OpenRouter', subtitle: 'Kelola key dan billing di situs resmi', onTap: _openOpenRouter),
    ]), const SizedBox(height: 12),
    _section('SECURITY WORKSPACE', [
      _ToolCard(icon: Icons.security, title: 'Authorized Security Ops', subtitle: 'CVE/KEV, SSL, breach hygiene, threat feed, vault', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OpsCenter()))),
      const Padding(padding: EdgeInsets.only(top: 6), child: Text('Gunakan hanya pada aset yang kamu miliki atau punya izin untuk menguji. Tidak ada fitur malware, pencurian kredensial, atau serangan tanpa izin.', style: TextStyle(color: Colors.orangeAccent, fontSize: 11))),
    ]), const SizedBox(height: 12),
    _section('TRADING RESEARCH', [
      _ToolCard(icon: Icons.radar, title: 'Market Intelligence Hub', subtitle: 'Radar • Risk Guardian • Trade Setup', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TradeIntelligenceHub()))),
      _ToolCard(icon: Icons.candlestick_chart, title: 'Live Trading Terminal', subtitle: 'Forex • Gold • Crypto • indikator • risk', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TradingScreen()))),
      const Padding(padding: EdgeInsets.only(top: 6), child: Text('Sinyal bersifat informasi, bukan nasihat finansial atau eksekusi order otomatis.', style: TextStyle(color: Colors.white38, fontSize: 11))),
    ]), const SizedBox(height: 12),
    _section('CONTENT LIBRARY', [
      const ListTile(leading: Icon(Icons.menu_book), title: Text('Quran / Ibadah'), subtitle: Text('Siapkan sumber teks/audio publik yang berlisensi sebelum menambahkan konten penuh.')),
      const ListTile(leading: Icon(Icons.auto_stories), title: Text('Kisah & pembelajaran'), subtitle: Text('Ruang untuk materi edukasi yang dapat dikurasi dan disimpan lokal.')),
    ]),
  ]);
}
class _ToolCard extends StatelessWidget { final IconData icon; final String title; final String subtitle; final VoidCallback onTap; const _ToolCard({required this.icon, required this.title, required this.subtitle, required this.onTap}); @override Widget build(BuildContext context) => ListTile(onTap: onTap, contentPadding: EdgeInsets.zero, leading: CircleAvatar(child: Icon(icon)), title: Text(title), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right)); }
