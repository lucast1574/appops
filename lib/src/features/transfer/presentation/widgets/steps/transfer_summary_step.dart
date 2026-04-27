import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_summary_widgets.dart';

class TransferSummaryStep extends StatelessWidget {
  final String? placa;
  final String? originLocation;
  final String? destinationLocation;
  final bool exitPhotoUploaded;
  final bool kmStartPhotoUploaded;
  final bool deliveryPhotoUploaded;
  final bool kmEndPhotoUploaded;
  final String? deliveryName;
  
  final Map<String, String> sectionCounts;
  final bool isInventoryComplete;
  final int observationsCount;
  final bool hasOperarioSignature;
  final bool hasClientSignature;
  final bool isSubmitting;

  final VoidCallback onEditTaskInfo;
  final VoidCallback onEditTransferInfo;
  final VoidCallback onEditDeliveryInfo;
  final VoidCallback onEditInventory;
  final VoidCallback onEditInspection;
  final VoidCallback onEditSignatures;
  final VoidCallback onEditAll;
  final VoidCallback onSend;

  const TransferSummaryStep({
    super.key,
    this.placa, this.originLocation, this.destinationLocation,
    required this.exitPhotoUploaded, required this.kmStartPhotoUploaded,
    required this.deliveryPhotoUploaded, required this.kmEndPhotoUploaded,
    this.deliveryName,
    required this.sectionCounts,
    required this.isInventoryComplete,
    required this.observationsCount,
    required this.hasOperarioSignature,
    required this.hasClientSignature,
    required this.isSubmitting,
    required this.onEditTaskInfo, required this.onEditTransferInfo,
    required this.onEditDeliveryInfo, required this.onEditInventory,
    required this.onEditInspection, required this.onEditSignatures,
    required this.onEditAll, required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Resumen de tarea',
                      style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                _buildPlainSection(
                  title: 'Información de la tarea',
                  onEdit: onEditTaskInfo,
                  children: [
                    const FlowSummaryItem(label: 'Fecha', value: 'Miércoles, 18 de marzo de 2026'),
                    FlowSummaryItem(label: 'Placa', value: placa ?? 'ABC-392'),
                  ],
                ),

                _buildPlainSection(
                  title: 'Información de traslado',
                  onEdit: onEditTransferInfo,
                  children: [
                    FlowSummaryItem(label: 'Ubicación de inicio traslado', value: originLocation ?? '---'),
                    FlowSummaryItem(label: 'Ubicación final de traslado', value: destinationLocation ?? '---'),
                    FlowSummaryStatus(label: 'Salida de vehículo*', isComplete: exitPhotoUploaded),
                    FlowSummaryStatus(label: 'Kilometraje vehículo (inicio)*', isComplete: kmStartPhotoUploaded),
                  ],
                ),

                _buildPlainSection(
                  title: 'Información de entrega',
                  onEdit: onEditDeliveryInfo,
                  children: [
                    FlowSummaryStatus(label: 'Foto vehículo punto de entrega*', isComplete: deliveryPhotoUploaded),
                    FlowSummaryStatus(label: 'Kilometraje vehículo (final)*', isComplete: kmEndPhotoUploaded),
                    FlowSummaryStatus(label: 'Checklist entrega*', isComplete: isInventoryComplete),
                    FlowSummaryItem(label: 'Nombre a quien entrega', value: deliveryName ?? '---'),
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
                    _buildCountRow('Inspección de Daños', count: '$observationsCount registrados'),
                  ],
                ),

                _buildPlainSection(
                  title: 'Firmas de conformidad',
                  onEdit: onEditSignatures,
                  children: [
                    FlowSummaryStatus(label: 'Firma del Cliente', isComplete: hasClientSignature),
                    FlowSummaryStatus(label: 'Firma del Operario', isComplete: hasOperarioSignature),
                  ],
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
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: isSubmitting ? null : onEditAll,
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
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : onSend,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27A376),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: isSubmitting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Enviar registro', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
