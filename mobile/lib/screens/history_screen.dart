import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/scan_history_item.dart';
import '../services/history_service.dart';
import '../theme/app_theme.dart';
import '../widgets/risk_badge.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ScanHistoryItem> _items = [];
  bool _isLoading = true;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final history = await HistoryService.getHistory();
    setState(() {
      _items = history;
      _isLoading = false;
    });
  }

  Future<void> _deleteItem(int id) async {
    await HistoryService.deleteItem(id);
    _loadHistory();
  }

  Future<void> _confirmClearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Clear Scan History?'),
        content: const Text(
          'This will permanently remove all saved scans from this device. Raw messages were never stored.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.riskHigh),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await HistoryService.clearAll();
      _loadHistory();
    }
  }

  List<ScanHistoryItem> get _visibleItems {
    if (_filter == 'All') return _items;
    final type = switch (_filter) {
      'Messages' => 'message',
      'Links' => 'url',
      _ => 'qr',
    };
    return _items.where((item) => item.scanType.toLowerCase() == type).toList();
  }

  List<int> get _lastSevenDays {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 6));
    return List.generate(7, (index) {
      final day = start.add(Duration(days: index));
      return _items.where((item) {
        final date = DateTime.tryParse(item.timestamp.replaceFirst(' ', 'T'));
        return date != null && date.year == day.year && date.month == day.month && date.day == day.day;
      }).length;
    });
  }

  Future<void> _copyExport() async {
    String cell(String value) => '"${value.replaceAll('"', '""')}"';
    final csv = [
      'type,timestamp,preview,category,risk_level,risk_score,explanation',
      ..._visibleItems.map((item) => [
            item.scanType,
            item.timestamp,
            item.previewText,
            item.category,
            item.riskLevel,
            '${item.riskScore}',
            item.briefExplanation,
          ].map(cell).join(',')),
    ].join('\n');
    await Clipboard.setData(ClipboardData(text: csv));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activity CSV copied. Paste it into a file or spreadsheet to save.')),
    );
  }

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'url':
        return Icons.link_rounded;
      case 'qr':
        return Icons.qr_code_scanner_rounded;
      case 'message':
      default:
        return Icons.message_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.ios_share_outlined),
              tooltip: 'Copy activity as CSV',
              onPressed: _copyExport,
            ),
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded,
                  color: AppTheme.riskHigh),
              tooltip: 'Clear History',
              onPressed: _confirmClearAll,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.history_toggle_off_rounded,
                          size: 54, color: AppTheme.textMuted),
                      SizedBox(height: 16),
                      Text(
                        'No Scan History Yet',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Previous message and link analyses will appear here.',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                )
              : Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: _activitySummary(),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    child: Row(children: [
                      for (final filter in ['All', 'Messages', 'Links', 'QR']) ...[
                        if (filter != 'All') const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text(filter),
                          selected: _filter == filter,
                          onSelected: (_) => setState(() => _filter = filter),
                        ),
                      ],
                    ]),
                  ),
                  Expanded(child: _visibleItems.isEmpty
                    ? Center(child: Text('No ${_filter.toLowerCase()} checks yet.',
                        style: const TextStyle(color: AppTheme.textSecondary)))
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _visibleItems.length,
                  itemBuilder: (context, index) {
                    final item = _visibleItems[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(_getIconForType(item.scanType),
                                        size: 18, color: AppTheme.accentTeal),
                                    const SizedBox(width: 8),
                                    Text(
                                      item.scanType.toUpperCase(),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: AppTheme.textPrimary),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '•  ${item.timestamp}',
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textMuted),
                                    ),
                                  ],
                                ),
                                RiskBadge(
                                  riskLevel: item.riskLevel,
                                  riskScore: item.riskScore,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              item.previewText,
                              style: const TextStyle(
                                  fontSize: 14, color: AppTheme.textPrimary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.briefExplanation,
                              style: const TextStyle(
                                  fontSize: 12, color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () {
                                  if (item.id != null) _deleteItem(item.id!);
                                },
                                icon: const Icon(Icons.delete_outline,
                                    size: 16, color: AppTheme.textMuted),
                                label: const Text('Delete',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textMuted)),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                )),
                ]),
    );
  }

  Widget _activitySummary() {
    final counts = _lastSevenDays;
    final maxCount = counts.fold<int>(0, (max, value) => value > max ? value : max);
    final highRisk = _items.where((item) =>
        ['high', 'critical'].contains(item.riskLevel.toLowerCase())).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('Your activity', style: TextStyle(fontWeight: FontWeight.w700))),
            Text('${_items.length} total', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          ]),
          const SizedBox(height: 4),
          Text('$highRisk higher-risk result${highRisk == 1 ? '' : 's'} · Last 7 days',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
          const SizedBox(height: 14),
          SizedBox(
            height: 78,
            child: Row(crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final count = counts[index];
                final height = maxCount == 0 ? 3.0 : 8.0 + (count / maxCount) * 42.0;
                final day = DateTime.now().subtract(Duration(days: 6 - index));
                return Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Text('$count', style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
                  const SizedBox(height: 4),
                  Container(height: height, width: 18,
                    decoration: BoxDecoration(color: count == 0 ? AppTheme.surfaceLight : AppTheme.accentTeal,
                      borderRadius: BorderRadius.circular(5))),
                  const SizedBox(height: 4),
                  Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][day.weekday - 1],
                      style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                ]));
              }),
            ),
          ),
          const SizedBox(height: 5),
          const Text('This summary uses scan history saved on this device.',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
        ]),
      ),
    );
  }
}
