import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';
import '../services/openrouter.dart';
import '../services/storage.dart';
import '../services/ghost_mode.dart';
import 'journal.dart';
import 'settings.dart';
import 'tools.dart';
import 'ops/ops_center.dart';
import 'dashboard.dart';
import 'market_center.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();
  late List<Map<String, String>> _messages;
  bool _loading = false;
  int _tab = 1;
  String? _attachmentName;
  Map<String, dynamic>? _attachmentContent;

  @override void initState() { super.initState(); _messages = List<Map<String, String>>.from(Store.history); }
  @override void dispose() { _controller.dispose(); _scrollController.dispose(); super.dispose(); }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    setState(() {
      _attachmentName = image.name;
      _attachmentContent = {'type': 'image_url', 'image_url': {'url': 'data:image/${image.path.split('.').last};base64,${base64Encode(bytes)}'}};
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;
    final file = result.files.single;
    final bytes = file.bytes ?? (file.path == null ? null : await File(file.path!).readAsBytes());
    if (bytes == null) return;
    final isText = ['txt', 'md', 'json', 'csv', 'dart', 'py', 'js', 'ts', 'html', 'css', 'yaml', 'yml'].contains(file.extension?.toLowerCase());
    setState(() {
      _attachmentName = file.name;
      _attachmentContent = isText
          ? {'type': 'text_attachment', 'name': file.name, 'text': utf8.decode(bytes, allowMalformed: true)}
          : {'type': 'file_attachment', 'name': file.name, 'size': bytes.length};
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if ((text.isEmpty && _attachmentContent == null) || _loading) return;
    final display = text + (_attachmentName == null ? '' : '\n\n📎 $_attachmentName');
    final history = List<Map<String, String>>.from(_messages)..add({'role': 'user', 'content': display});
    final requestMessages = history.sublist(0, history.length - 1).map<Map<String, dynamic>>((m) => {'role': m['role']!, 'content': m['content']!}).toList();
    final content = <dynamic>[{'type': 'text', 'text': text.isEmpty ? 'Analisis attachment ini.' : text}];
    if (_attachmentContent?['type'] == 'image_url') content.add(_attachmentContent);
    if (_attachmentContent?['type'] == 'text_attachment') content[0] = {'type': 'text', 'text': '$text\n\nIsi file ${_attachmentContent!['name']}:\n${_attachmentContent!['text']}'};
    requestMessages.add({'role': 'user', 'content': content.length == 1 && content.first['type'] == 'text' ? content.first['text'] : content});
    setState(() { _loading = true; _messages = history; _controller.clear(); _attachmentName = null; _attachmentContent = null; });
    Store.history = List<Map<String, String>>.from(_messages);
    _messages.add({'role': 'assistant', 'content': ''});
    if (mounted) setState(() {});
    try {
      await for (final chunk in OpenRouter.chatStream(requestMessages)) {
        if (!mounted) return;
        final current = _messages.last['content'] ?? '';
        setState(() => _messages[_messages.length - 1] = {'role': 'assistant', 'content': current + chunk});
        if (_scrollController.hasClients) await _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 80), curve: Curves.easeOut);
      }
      Store.history = List<Map<String, String>>.from(_messages);
    } catch (error) {
      if (!mounted) return;
      setState(() => _messages[_messages.length - 1] = {'role': 'assistant', 'content': '⚠️ $error'});
      Store.history = List<Map<String, String>>.from(_messages);
    } finally { if (mounted) setState(() => _loading = false); }
  }

  void _newChat() { setState(() => _messages = []); Store.clearHistory(); }

  Widget _buildChat() => Column(children: [
    Expanded(child: _messages.isEmpty
      ? const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Tanyakan apa saja tentang coding, security defensif, trading research, OSINT publik, atau workflow lu.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16))))
      : ListView.builder(controller: _scrollController, padding: const EdgeInsets.fromLTRB(14, 10, 14, 18), itemCount: _messages.length, itemBuilder: (_, index) {
          final item = _messages[index]; final user = item['role'] == 'user'; final accent = GhostMode.accent;
          return Align(alignment: user ? Alignment.centerRight : Alignment.centerLeft, child: Container(constraints: const BoxConstraints(maxWidth: 620), margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: user ? LinearGradient(colors: [accent, const Color(0xFF7C4DFF)]) : LinearGradient(colors: [GhostMode.card, const Color(0xFF202033)]), borderRadius: BorderRadius.circular(18), border: Border.all(color: accent.withValues(alpha: .22))), child: user ? Text(item['content'] ?? '') : MarkdownBody(data: item['content'] ?? '')));
        })),
    if (_loading) const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: Align(alignment: Alignment.centerLeft, child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)))),
    if (_attachmentName != null) Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Align(alignment: Alignment.centerLeft, child: Chip(avatar: const Icon(Icons.attach_file, size: 16), label: Text(_attachmentName!), onDeleted: () => setState(() { _attachmentName = null; _attachmentContent = null; })))),
    SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 10), child: Row(children: [
      IconButton(tooltip: 'Gambar', onPressed: _loading ? null : _pickImage, icon: const Icon(Icons.image_outlined)),
      IconButton(tooltip: 'Berkas', onPressed: _loading ? null : _pickFile, icon: const Icon(Icons.attach_file_outlined)),
      Expanded(child: TextField(controller: _controller, textInputAction: TextInputAction.send, onSubmitted: (_) => _send(), minLines: 1, maxLines: 5, decoration: const InputDecoration(hintText: 'Ketik pesan...'))),
      const SizedBox(width: 8), IconButton.filled(onPressed: _loading ? null : _send, icon: const Icon(Icons.send_rounded)),
    ]))),
  ]);

  @override Widget build(BuildContext context) {
    final pages = [const DashboardScreen(), _buildChat(), const MarketCenterScreen(), const JournalScreen(), const SettingsScreen(), const ToolsScreen()];
    return ValueListenableBuilder<bool>(valueListenable: GhostMode.active, builder: (_, ghost, __) => Scaffold(
      backgroundColor: GhostMode.bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: ghost ? Text('[REDACTED]', style: TextStyle(color: GhostMode.accent, fontFamily: 'monospace')) : const Text('MAZKIPLAY AI', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)), actions: [
        if (_tab == 1) IconButton(tooltip: 'Chat baru', onPressed: _newChat, icon: const Icon(Icons.add_comment_outlined)),
        IconButton(tooltip: 'Ops Center', onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OpsCenter())), icon: const Icon(Icons.terminal)),
        IconButton(tooltip: 'Ghost Mode', icon: Icon(Icons.visibility_off, color: ghost ? const Color(0xFF00FF41) : Colors.white54), onPressed: () { GhostMode.toggle(); final on = GhostMode.active.value; ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: GhostMode.card, content: Text(on ? 'GHOST MODE AKTIF.' : 'Ghost Mode off.'))); }),
      ],),
      body: SafeArea(top: false, child: AnimatedSwitcher(duration: const Duration(milliseconds: 180), child: KeyedSubtree(key: ValueKey(_tab), child: pages[_tab]))),
      bottomNavigationBar: NavigationBar(selectedIndex: _tab, onDestinationSelected: (value) => setState(() => _tab = value), destinations: const [
        NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Dashboard'),
        NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'),
        NavigationDestination(icon: Icon(Icons.radar_outlined), selectedIcon: Icon(Icons.radar), label: 'Market'),
        NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book), label: 'Journal'),
        NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        NavigationDestination(icon: Icon(Icons.widgets_outlined), selectedIcon: Icon(Icons.widgets), label: 'Tools'),
      ]),
    ));
  }
}
