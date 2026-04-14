import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../shared/widgets/flow_summary_widgets.dart';

class RecoverySummaryStep extends StatelessWidget {
  final String? selectedPerson;
  final bool frontalUploaded; final bool traseraUploaded;
  final bool lateralIzqUploaded; final bool lateralDerUploaded;
  final bool kmUploaded;
  final String? fuelLevel; final bool? hasVisibleDamage;
  final bool tarjetaUploaded; final bool soatUploaded;
  final bool revisionUploaded; final bool actaUploaded;
  final bool? llaveOriginal; final bool? llaveRepuesto;
  final bool? gata; final bool? llantaRepuesto;
  final bool? extintor; final bool? triangulo; final bool? manualConductor;
  final VoidCallback onEditTaskInfo;
  final VoidCallback onEditWho;
  final VoidCallback onEditVehicle;
  final VoidCallback onEditDocs;
  final VoidCallback onEditAll;
  final VoidCallback onSend;

  const RecoverySummaryStep({
    super.key,
    this.selectedPerson,
    required this.frontalUploaded, required this.traseraUploaded,
    required this.lateralIzqUploaded, required this.lateralDerUploaded,
    required this.kmUploaded,
    this.fuelLevel, this.hasVisibleDamage,
    required this.tarjetaUploaded, required this.soatUploaded,
    required this.revisionUploaded, required this.actaUploaded,
    this.llaveOriginal, this.llaveRepuesto, this.gata, this.llantaRepuesto,
    this.extintor, this.triangulo, this.manualConductor,
    required this.onEditTaskInfo, required this.onEditWho,
    required this.onEditVehicle, required this.onEditDocs,
    required this.onEditAll, required this.onSend,
  });

  String _yesNo(bool? v) => v == true ? 'Si' : v == false ? 'No' : '---';

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
                Center(child: Text('Resumen de recupero', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002B4B)))),
                const SizedBox(height: 32),
                FlowSummarySection(title: 'Información de la tarea', onEdit: onEditTaskInfo, children: const [
                  FlowSummaryItem(label: 'Cliente', value: 'Carlos Mendoza'),
                  FlowSummaryItem(label: 'DNI', value: '45678912'),
                  FlowSummaryItem(label: 'Placa', value: 'ABC-392'),
                  FlowSummaryItem(label: 'Hora inicio', value: '10:00', secondLabel: 'Hora fin', secondValue: '12:00'),
                  FlowSummaryItem(label: 'Dirección', value: 'Calle Los Manzanos 341, Urb. Monterrico'),
                  FlowSummaryItem(label: 'Motivo', value: 'Mora en pagos - 3 cuotas vencidas'),
                ]),
                const SizedBox(height: 24),
                FlowSummarySection(title: '¿Quién entregó el vehículo?', onEdit: onEditWho, children: [
                  FlowSummaryStatus(label: selectedPerson ?? '---', isComplete: selectedPerson != null),
                ]),
                const SizedBox(height: 24),
                FlowSummarySection(title: 'Estado del vehículo', onEdit: onEditVehicle, children: [
                  FlowSummaryStatus(label: 'Foto frontal', isComplete: frontalUploaded),
                  FlowSummaryStatus(label: 'Foto trasera', isComplete: traseraUploaded),
                  FlowSummaryStatus(label: 'Foto lateral izquierdo', isComplete: lateralIzqUploaded),
                  FlowSummaryStatus(label: 'Foto lateral derecho', isComplete: lateralDerUploaded),
                  FlowSummaryStatus(label: 'Kilometraje', isComplete: kmUploaded),
                  FlowSummaryItem(label: 'Nivel de combustible', value: fuelLevel ?? '---'),
                  FlowSummaryItem(label: 'Daños visibles', value: _yesNo(hasVisibleDamage)),
                ]),
                const SizedBox(height: 24),
                FlowSummarySection(title: 'Documentación y accesorios', onEdit: onEditDocs, children: [
                  FlowSummaryStatus(label: 'Tarjeta de propiedad', isComplete: tarjetaUploaded),
                  FlowSummaryStatus(label: 'SOAT', isComplete: soatUploaded),
                  FlowSummaryStatus(label: 'Revisión técnica', isComplete: revisionUploaded),
                  FlowSummaryStatus(label: 'Acta de recupero', isComplete: actaUploaded),
                  FlowSummaryItem(label: 'Llave original', value: _yesNo(llaveOriginal)),
                  FlowSummaryItem(label: 'Llave repuesto', value: _yesNo(llaveRepuesto)),
                  FlowSummaryItem(label: 'Gata', value: _yesNo(gata)),
                  FlowSummaryItem(label: 'Llanta repuesto', value: _yesNo(llantaRepuesto)),
                  FlowSummaryItem(label: 'Extintor', value: _yesNo(extintor)),
                  FlowSummaryItem(label: 'Triángulo', value: _yesNo(triangulo)),
                  FlowSummaryItem(label: 'Manual conductor', value: _yesNo(manualConductor)),
                ]),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE5E9EB)))),
          child: Row(children: [
            Expanded(flex: 1, child: SizedBox(height: 48, child: OutlinedButton(onPressed: onEditAll, style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFCCD4DB)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: Text('Editar', style: GoogleFonts.inter(color: const Color(0xFF002B4B), fontWeight: FontWeight.bold))))),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: SizedBox(height: 48, child: ElevatedButton(onPressed: onSend, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27A376), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0), child: Text('Enviar registro', style: GoogleFonts.inter(fontWeight: FontWeight.bold))))),
          ]),
        ),
      ],
    );
  }
}
