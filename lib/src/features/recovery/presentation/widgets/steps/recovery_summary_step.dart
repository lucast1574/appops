import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_summary_widgets.dart';

class RecoverySummaryStep extends StatelessWidget {
  final Map<String, dynamic> task;
  final bool? recoveryEfectuado;
  final List<Map<String, dynamic>> personalObjects;
  final List<Map<String, dynamic>> carPhotos;
  final Map<String, String> sectionCounts;
  
  final VoidCallback onEditTaskInfo;
  final VoidCallback onEditRecoveryEfectuado;
  final VoidCallback onEditInventory;
  final VoidCallback onEditPersonalObjects;
  final VoidCallback onEditCarPhotos;
  final VoidCallback onEditAll;
  final VoidCallback onSend;

  const RecoverySummaryStep({
    super.key,
    required this.task,
    required this.recoveryEfectuado,
    required this.personalObjects,
    required this.carPhotos,
    required this.sectionCounts,
    required this.onEditTaskInfo,
    required this.onEditRecoveryEfectuado,
    required this.onEditInventory,
    required this.onEditPersonalObjects,
    required this.onEditCarPhotos,
    required this.onEditAll,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final String scheduledDate = task['scheduled_date'] ?? '';
    final String address = task['address'] ?? '';
    final String placa = task['placa'] ?? '';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlainSection(
                  title: 'Información de la tarea',
                  onEdit: onEditTaskInfo,
                  children: [
                    if (scheduledDate.isNotEmpty)
                      FlowSummaryItem(label: 'Fecha', value: scheduledDate),
                    if (address.isNotEmpty)
                      FlowSummaryItem(label: 'Ubicación', value: address),
                    if (placa.isNotEmpty)
                      FlowSummaryItem(label: 'Placa', value: placa),
                  ],
                ),

                _buildPlainSection(
                  title: 'Recupero efectuado',
                  onEdit: onEditRecoveryEfectuado,
                  children: [
                    FlowSummaryItem(
                      label: 'Estado', 
                      value: recoveryEfectuado == true ? 'Si' : recoveryEfectuado == false ? 'No' : '---',
                    ),
                  ],
                ),

                _buildPlainSection(
                  title: 'Listado de entrega',
                  onEdit: onEditInventory,
                  children: [
                    _buildCountRow('Datos Generales', isComplete: true),
                    _buildCountRow('Entrega y Explicación de Documentación del Vehículo', count: sectionCounts['docs'] ?? '0/6'),
                    _buildCountRow('Instalaciones del Concesionario', count: sectionCounts['facilities'] ?? '0/3'),
                    _buildCountRow('Inspección del Vehículo', count: sectionCounts['inspection'] ?? '0/3'),
                    _buildCountRow('Detalle de Inventario', count: sectionCounts['inventory'] ?? '0/20'),
                    _buildCountRow('Descripción General', count: sectionCounts['general'] ?? '0/31'),
                  ],
                ),

                _buildPlainSection(
                  title: 'Objetos personales',
                  onEdit: onEditPersonalObjects,
                  children: [
                    FlowSummaryItem(
                      label: 'Objetos reportados', 
                      value: '${personalObjects.length}',
                    ),
                  ],
                ),

                _buildPlainSection(
                  title: 'Fotos unidad recuperada',
                  onEdit: onEditCarPhotos,
                  children: carPhotos.isEmpty
                      ? [
                          Text(
                            'No se registraron fotos',
                            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF668093)),
                          )
                        ]
                      : carPhotos.map((photo) {
                          final String tag = photo['tag']?.toString() ?? 'Foto';
                          return _buildCountRow(tag, isComplete: true);
                        }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        _buildBottomBar(),
      ],
    );
  }

  Widget _buildPlainSection({required String title, required List<Widget> children, required VoidCallback onEdit}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B)),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 22, color: Color(0xFF668093)),
              onPressed: onEdit,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
        const Divider(color: Color(0xFFF1F4F6), thickness: 1, height: 32),
      ],
    );
  }

  Widget _buildCountRow(String label, {String? count, bool isComplete = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF668093), fontWeight: FontWeight.w500),
            ),
          ),
          if (isComplete)
            const Icon(Icons.check, color: Color(0xFF27A376), size: 18)
          else
            Text(
              count ?? '---',
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF002B4B), fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E9EB))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: onEditAll,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFCCD4DB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text('Editar', style: GoogleFonts.inter(color: const Color(0xFF002B4B), fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27A376),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: Text('Enviar registro', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
