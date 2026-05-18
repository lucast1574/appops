import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../home/data/task_service.dart';

/// Displays a read-only summary of a task using real data from the backend.
///
/// Behaviour:
/// - If [task] already contains full detail (photos + result), we render
///   directly and skip the network call.
/// - Otherwise we fetch `GET /tasks/<id>/` to pull the complete payload
///   (photos with presigned download URLs, result_data, etc.).
///
/// The page is intentionally generic — it renders any task type by
/// walking the `result_data` / `checklist_data` maps. That keeps a
/// single template working for all 8 task types (verificacion, recupero,
/// entrega, conversion, traslado, verificar_vehiculo, notaria,
/// gestiones) without hard-coding each shape.
class TaskSummaryPage extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskSummaryPage({super.key, required this.task});

  @override
  State<TaskSummaryPage> createState() => _TaskSummaryPageState();
}

class _TaskSummaryPageState extends State<TaskSummaryPage> {
  final TaskService _taskService = TaskService();
  Map<String, dynamic>? _fullTask;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    // If the caller already passed a "full" task (has photos+result keys),
    // skip the fetch — saves a round-trip when we come from a page that
    // already has the detail (unlikely today but future-proof).
    final t = widget.task;
    if (t.containsKey('photos') && t.containsKey('result')) {
      setState(() {
        _fullTask = t;
        _loading = false;
      });
      return;
    }

    final int? id = t['id'] is int ? t['id'] as int : int.tryParse('${t['id']}');
    if (id == null) {
      setState(() {
        _error = 'ID de tarea inv\u00e1lido';
        _loading = false;
      });
      return;
    }

    try {
      final detail = await _taskService.getTaskDetail(id);
      if (mounted) {
        setState(() {
          _fullTask = detail;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error al cargar el detalle de la tarea';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF002B4B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Resumen de tarea',
          style: GoogleFonts.inter(
            color: const Color(0xFF002B4B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE5E9EB),
            height: 1,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Error desconocido',
              style: GoogleFonts.inter(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadDetail,
              child: Text(
                'Reintentar',
                style: GoogleFonts.inter(
                  color: const Color(0xFF4FA4B5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final t = _fullTask!;
    final type = t['type'] as Map<String, dynamic>?;
    final typeName = type?['name'] ?? 'Tarea';
    final statusLabel = TaskService.getStatusLabel(t['status'] as String?);
    final statusColor = _statusColor(statusLabel);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------- Header with task type + status --------
          Row(
            children: [
              Expanded(
                child: Text(
                  typeName,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // -------- Basic info --------
          _buildSectionHeader('Informaci\u00f3n de la tarea'),
          const SizedBox(height: 16),
          if ((t['client_name'] ?? '').toString().isNotEmpty)
            _buildInfoField('Cliente', t['client_name']),
          if ((t['client_dni'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoField('DNI cliente', t['client_dni']),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildInfoField(
                  'Hora inicio',
                  _orDash(TaskService.formatTime(t['start_time'] as String?)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoField(
                  'Hora fin',
                  _orDash(TaskService.formatTime(t['end_time'] as String?)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoField('Fecha', _orDash(t['scheduled_date'])),
          if ((t['address'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoField('Direcci\u00f3n', t['address']),
          ],
          if (_hasVehicleInfo(t)) ...[
            const SizedBox(height: 16),
            _buildInfoField('Veh\u00edculo', _vehicleSummary(t)),
          ],
          if ((t['observations'] ?? '').toString().isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildInfoField('Observaciones', t['observations']),
          ],

          // -------- Result data (dynamic, per task type) --------
          if (t['result'] != null) ..._buildResultSection(t['result']),

          // -------- Photos --------
          ..._buildPhotosSection(t['photos']),

          // -------- Timestamps (footer) --------
          const SizedBox(height: 32),
          const Divider(color: Color(0xFFE5E9EB)),
          const SizedBox(height: 16),
          _buildTimestampsFooter(t),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ================================================================
  // Result section (result_data + checklist_data rendered generically)
  // ================================================================
  List<Widget> _buildResultSection(dynamic result) {
    if (result is! Map) return const [];
    final resultData = result['result_data'] as Map<String, dynamic>?;
    final checklistData = result['checklist_data'] as Map<String, dynamic>?;

    final hasResult = resultData != null && resultData.isNotEmpty;
    final hasChecklist = checklistData != null && checklistData.isNotEmpty;
    if (!hasResult && !hasChecklist) return const [];

    return [
      const SizedBox(height: 32),
      const Divider(color: Color(0xFFE5E9EB)),
      const SizedBox(height: 24),
      if (hasResult) ...[
        _buildSectionHeader('Resultado'),
        const SizedBox(height: 16),
        ..._renderMap(resultData),
      ],
      if (hasResult && hasChecklist) const SizedBox(height: 24),
      if (hasChecklist) ...[
        _buildSectionHeader('Checklist'),
        const SizedBox(height: 16),
        ..._renderMap(checklistData),
      ],
    ];
  }

  static const Map<String, String> _translations = {
    'start_time': 'Hora inicio',
    'end_time': 'Hora fin',
    'verification_result': 'Resultado de Verificación Domiciliaria',
    'management_type': 'Tipo de gestión',
    'fine_type': 'Tipo de multa',
    'selected_municipality': 'Municipalidad',
    'motivo': 'Motivo',
    'is_visible': '¿Vehículo visible?',
    'observations': 'Observaciones',
    'photo_uploaded': 'Foto subida',
  };

  /// Walk a `Map<String, dynamic>` and emit one widget per entry.
  List<Widget> _renderMap(Map<dynamic, dynamic> map, {String prefix = ''}) {
    final widgets = <Widget>[];

    // Sort keys: start_time should always come before end_time
    final keys = map.keys.toList();
    keys.sort((a, b) {
      final ka = a.toString();
      final kb = b.toString();
      
      int getPriority(String k) {
        if (k == 'start_time') return 1;
        if (k == 'end_time') return 2;
        return 99;
      }
      
      final pa = getPriority(ka);
      final pb = getPriority(kb);
      if (pa != pb) return pa.compareTo(pb);
      
      // Fallback to alphabetical for other keys
      return ka.compareTo(kb);
    });

    for (final rawKey in keys) {
      final value = map[rawKey];
      if (value == null) continue;

      final kStr = rawKey.toString();
      final translatedLabel = _translations[kStr] ?? _humanize(kStr);
      final key = '$prefix$translatedLabel';

      if (value is bool) {
        widgets.add(_buildStatusField(key, value));
        widgets.add(const SizedBox(height: 16));
      } else if (value is Map) {
        widgets.addAll(_renderMap(value, prefix: '$key \u2014 '));
      } else if (value is List) {
        if (value.isEmpty) continue;
        widgets.add(_buildInfoField(key, value.join(', ')));
        widgets.add(const SizedBox(height: 16));
      } else {
        final s = value.toString();
        if (s.isEmpty) continue;
        widgets.add(_buildInfoField(key, s));
        widgets.add(const SizedBox(height: 16));
      }
    }

    if (widgets.isNotEmpty && widgets.last is SizedBox) {
      widgets.removeLast();
    }
    return widgets;
  }

  // ================================================================
  // Photos
  // ================================================================
  List<Widget> _buildPhotosSection(dynamic photos) {
    if (photos is! List || photos.isEmpty) return const [];
    return [
      const SizedBox(height: 32),
      const Divider(color: Color(0xFFE5E9EB)),
      const SizedBox(height: 24),
      _buildSectionHeader('Fotos (${photos.length})'),
      const SizedBox(height: 16),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
        children: photos.map<Widget>((p) {
          final url = p['download_url'] as String?;
          final label = (p['tag'] ?? p['label'] ?? '') as String;
          return GestureDetector(
            onTap: url != null ? () => _openPhoto(url, label) : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (url != null)
                    CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      placeholder: (c, _) => Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (c, _, e) => Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Icon(Icons.broken_image_outlined,
                            color: Color(0xFF99AAB7)),
                      ),
                    )
                  else
                    Container(color: const Color(0xFFF1F5F9)),
                  if (label.isNotEmpty)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        color: Colors.black.withValues(alpha: 0.55),
                        child: Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ];
  }

  void _openPhoto(String url, String label) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                placeholder: (c, _) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (c, _, e) => const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white,
                  size: 64,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // Timestamps footer
  // ================================================================
  Widget _buildTimestampsFooter(Map<String, dynamic> t) {
    final items = <Widget>[];
    final created = _formatDateTime(t['created_at'] as String?);
    final started = _formatDateTime(t['started_at'] as String?);
    final completed = _formatDateTime(t['completed_at'] as String?);

    if (created != null) items.add(_tsRow('Creada', created));
    if (started != null) items.add(_tsRow('Iniciada', started));
    if (completed != null) items.add(_tsRow('Completada', completed));

    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 6),
          items[i],
        ],
      ],
    );
  }

  Widget _tsRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF99AAB7),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFF668093),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // Shared presentational helpers
  // ================================================================
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF002B4B),
      ),
    );
  }

  Widget _buildInfoField(String label, dynamic value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF99AAB7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value?.toString() ?? '\u2014',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF002B4B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusField(String label, bool isSuccess) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF002B4B),
            ),
          ),
        ),
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSuccess
                ? const Color(0xFF23A26D)
                : const Color(0xFFFF5252),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // Small utility helpers
  // ================================================================
  String _orDash(dynamic v) {
    final s = v?.toString() ?? '';
    return s.isEmpty ? '\u2014' : s;
  }

  bool _hasVehicleInfo(Map<String, dynamic> t) {
    for (final k in ['placa', 'marca', 'modelo', 'color', 'vehicle_type']) {
      final v = t[k]?.toString() ?? '';
      if (v.isNotEmpty) return true;
    }
    return false;
  }

  String _vehicleSummary(Map<String, dynamic> t) {
    final parts = <String>[];
    final placa = (t['placa'] ?? '').toString();
    final marca = (t['marca'] ?? '').toString();
    final modelo = (t['modelo'] ?? '').toString();
    final color = (t['color'] ?? '').toString();
    final vtype = (t['vehicle_type'] ?? '').toString();
    if (placa.isNotEmpty) parts.add(placa);
    final brandModel = [marca, modelo].where((s) => s.isNotEmpty).join(' ');
    if (brandModel.isNotEmpty) parts.add(brandModel);
    if (color.isNotEmpty) parts.add(color);
    if (vtype.isNotEmpty) parts.add(vtype);
    return parts.join(' \u00b7 ');
  }

  /// Turn snake_case / camelCase keys into human-friendly labels.
  /// Keeps things like "DNI" uppercase when already uppercase.
  String _humanize(String key) {
    if (key.isEmpty) return key;
    final spaced = key
        .replaceAll('_', ' ')
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .trim();
    if (spaced == spaced.toUpperCase()) return spaced;
    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  /// "2026-04-17T12:34:56Z" → "17/04/2026 12:34" (local time).
  String? _formatDateTime(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    try {
      final dt = DateTime.parse(iso).toLocal();
      final d = '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
      final h = '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
      return '$d $h';
    } catch (_) {
      return iso;
    }
  }

  Color _statusColor(String label) {
    switch (label) {
      case 'Pendiente':
        return const Color(0xFFFBC108);
      case 'En curso':
        return const Color(0xFFF104DD);
      case 'Completada':
        return const Color(0xFF23A26D);
      case 'Rechazada':
        return const Color(0xFFE53935);
      case 'Reprogramada':
        return const Color(0xFF4FA4B5);
      default:
        return const Color(0xFF002B4B);
    }
  }
}
