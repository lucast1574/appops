import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  int _currentStep = 0;
  String? _selectedRecipient;
  String? _selectedRelationship;

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _previousStep() {
    if (_currentStep > 0) {
      if (_currentStep == 3 || _currentStep == 4) {
        // From validation or familiar form back to recipient
        setState(() {
          _currentStep = 2;
        });
      } else if (_currentStep == 5) {
        // From reschedule back to familiar form
        setState(() {
          _currentStep = 4;
        });
      } else {
        setState(() {
          _currentStep--;
        });
      }
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showAppBar = _currentStep == 0 || _currentStep == 2 || _currentStep == 3 || _currentStep == 4 || _currentStep == 5;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: showAppBar
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF002B4B)),
                onPressed: _previousStep,
              ),
              title: Text(
                'Verificación',
                style: GoogleFonts.inter(
                  color: const Color(0xFF002B4B),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: SvgPicture.asset(
                    'assets/alarm.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(Color(0xFFE35959), BlendMode.srcIn),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: Column(
                  children: [
                    Container(
                      color: const Color(0xFFE5E9EB).withValues(alpha: 0.5),
                      height: 1,
                    ),
                    const SizedBox(height: 12),
                    _buildProgressBar(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            )
          : null,
      body: _buildCurrentStep(),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildTaskInfoStep();
      case 1:
        return _buildBeforeStartingStep();
      case 2:
        return _buildWhoReceivedStep();
      case 3:
        return _buildDocumentValidationStep();
      case 4:
        return _buildFamiliarFormStep();
      case 5:
        return _buildRescheduleResultStep();
      default:
        return _buildTaskInfoStep();
    }
  }

  Widget _buildProgressBar() {
    int activeIndex = 0;
    if (_currentStep == 0) activeIndex = 0;
    else if (_currentStep == 2) activeIndex = 1;
    else if (_currentStep >= 3) activeIndex = 2; // All follow-up steps share segment 2 colors mostly? or incremental?
    // User image 2 shows Bar 2 active for reschedule too.

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: List.generate(6, (index) {
          bool isCompleted = index < activeIndex;
          bool isActive = index == activeIndex;

          return Expanded(
            child: Container(
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isCompleted ? const Color(0xFF27A376) : (isActive ? null : const Color(0xFFE5E9EB)),
                gradient: isActive
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF27A376),
                          Color(0xFFF1F4F5),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        stops: [0.3, 1.0],
                      )
                    : null,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTaskInfoStep() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información de la tarea',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002B4B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildFieldLabel('Fecha'),
                  const SizedBox(height: 8),
                  _buildValueContainer(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Miércoles, 18 de marzo de 2026',
                          style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                        ),
                        const Icon(Icons.check, color: Color(0xFF27A376), size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Hora inicio'),
                            const SizedBox(height: 8),
                            _buildValueContainer(
                              child: Text(
                                '16:00',
                                style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFieldLabel('Hora fin'),
                            const SizedBox(height: 8),
                            _buildValueContainer(
                              child: Text(
                                '18:00',
                                style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFieldLabel('Dirección'),
                  const SizedBox(height: 8),
                  _buildValueContainer(
                    child: Text(
                      'Avenida Pedro de Osma 789 Calle Centenario 156',
                      style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFieldLabel('Nombre del cliente'),
                  const SizedBox(height: 8),
                  _buildValueContainer(
                    child: Text(
                      'Juan Ramos',
                      style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFieldLabel('DNI cliente'),
                  const SizedBox(height: 8),
                  _buildValueContainer(
                    child: Text(
                      '12999312232',
                      style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFieldLabel('Observaciones'),
                  const SizedBox(height: 8),
                  TextField(
                    maxLines: 4,
                    style: GoogleFonts.inter(fontSize: 15, color: const Color(0xFF002B4B)),
                    decoration: InputDecoration(
                      hintText: 'Agregar observaciones',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 15,
                        color: const Color(0xFF99AAB7).withValues(alpha: 0.5),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF27A376)),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomButton('Comenzar tarea', _nextStep),
        ],
      ),
    );
  }

  Widget _buildBeforeStartingStep() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: _previousStep,
                child: Text(
                  'Volver',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF002B4B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const Spacer(),
            SvgPicture.asset(
              'assets/alarm.svg',
              width: 80,
              height: 80,
              colorFilter: const ColorFilter.mode(Color(0xFF002B4B), BlendMode.srcIn),
            ),
            const SizedBox(height: 32),
            Text(
              'Antes de comenzar',
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002B4B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Recuerda estar en la ubicación de la tarea antes de comenzar',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF002B4B),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            _buildBottomButton('Comenzar tarea', _nextStep),
          ],
        ),
      ),
    );
  }

  Widget _buildWhoReceivedStep() {
    final options = ['Cliente', 'Familiar', 'Nadie'];

    return Column(
      children: [
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '¿Quién te recibió?',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002B4B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cliente: Juan Ramos  -  DNI: 12999312232',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF99AAB7),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ...options.map((option) => Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedRecipient = option;
                            });
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: double.infinity,
                            height: 64,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: _selectedRecipient == option 
                                  ? const Color(0xFFB9DBE1) 
                                  : const Color(0xFFF8FBFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedRecipient == option 
                                    ? const Color(0xFF71B5C3) 
                                    : const Color(0xFFB9DBE1),
                                width: 2.0,
                              ),
                            ),
                            child: Text(
                              option,
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF002B4B),
                              ),
                            ),
                          ),
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
        _buildStepNavigation(
          isContinueEnabled: _selectedRecipient != null,
          onContinue: () {
            if (_selectedRecipient == 'Cliente') {
              _nextStep(); // Goes to step 3 (Validation)
            } else if (_selectedRecipient == 'Familiar') {
              setState(() {
                _currentStep = 4; // Familiar Form
              });
            } else {
              // Handle other recipients
            }
          },
        ),
      ],
    );
  }

  List<Offset?> _signaturePoints = [];

  Widget _buildFamiliarFormStep() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('DNI del familiar'),
                const SizedBox(height: 8),
                _buildFormTextField('Agregar DNI'),
                const SizedBox(height: 16),
                _buildFieldLabel('Nombre completo'),
                const SizedBox(height: 8),
                _buildFormTextField('Agregar nombre completo'),
                const SizedBox(height: 16),
                _buildFieldLabel('Parentesco con el cliente'),
                const SizedBox(height: 8),
                _buildRelationshipDropdown(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildFieldLabel('Firma de familiar'),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _signaturePoints = [];
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD9D9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      ),
                      child: Text(
                        'Borrar',
                        style: GoogleFonts.inter(color: const Color(0xFFE35959), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (details) {
                    setState(() {
                      _signaturePoints.add(details.localPosition);
                    });
                  },
                  onPanEnd: (details) => _signaturePoints.add(null),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFB9DBE1).withValues(alpha: 0.5),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomPaint(
                        painter: SignaturePainter(_signaturePoints),
                        child: _signaturePoints.isEmpty
                            ? Center(
                                child: Text(
                                  'Área de firma',
                                  style: GoogleFonts.inter(color: const Color(0xFF99AAB7).withValues(alpha: 0.5)),
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildStepNavigation(onContinue: () {
          setState(() {
            _currentStep = 5; // Reschedule result
          });
        }),
      ],
    );
  }

  Widget _buildRescheduleResultStep() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '¿Quién te recibió?',
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF002B4B),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _currentStep = 2;
                        });
                      },
                      child: Text(
                        'Cambiar',
                        style: GoogleFonts.inter(
                          color: const Color(0xFF002B4B),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB9DBE1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF71B5C3), width: 2.0),
                  ),
                  child: Text(
                    'Familiar',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF002B4B),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                SvgPicture.asset(
                  'assets/CalendarCheck.svg',
                  width: 64,
                  height: 64,
                  colorFilter: const ColorFilter.mode(Color(0xFF4FA4B5), BlendMode.srcIn),
                ),
                const SizedBox(height: 24),
                Text(
                  'Reprogramación automática',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4FA4B5),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Verificación no es posible de completar',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFF002B4B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'La verificación será marcada como rechazada automáticamente.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: const Color(0xFF002B4B),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        _buildStepNavigation(onContinue: () {
          // Send back home
          Navigator.pop(context);
        }),
      ],
    );
  }

  Widget _buildFormTextField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: const Color(0xFF99AAB7).withValues(alpha: 0.5)),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E9EB)),
        ),
      ),
    );
  }

  Widget _buildRelationshipDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: _selectedRelationship,
          hint: Text('Seleccionar', style: GoogleFonts.inter(color: const Color(0xFF002B4B))),
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF002B4B)),
          items: ['Padre/Madre', 'Hijo/a', 'Cónyuge', 'Otros'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedRelationship = val;
            });
          },
        ),
      ),
    );
  }

  Widget _buildDocumentValidationStep() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Validación de documentos',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002B4B),
                  ),
                ),
                const SizedBox(height: 24),
                _buildValidationSection(
                  'DNI',
                  child: Row(
                    children: [
                      Expanded(child: _buildUploadButton('Tomar foto', Icons.add_a_photo_outlined)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildUploadButton('Subir archivo', Icons.file_upload_outlined)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildValidationSection(
                  'Brevete',
                  child: _buildUploadButton('Tomar foto', Icons.add_a_photo_outlined, isFullWidth: true),
                ),
                const SizedBox(height: 16),
                _buildValidationSection(
                  'Recibo de servicios',
                  child: _buildUploadButton('Tomar foto', Icons.add_a_photo_outlined, isFullWidth: true),
                ),
              ],
            ),
          ),
        ),
        _buildStepNavigation(onContinue: () {
          // Next part of the flow
        }),
      ],
    );
  }

  Widget _buildValidationSection(String title, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002B4B),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildUploadButton(String text, IconData icon, {bool isFullWidth = false}) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      height: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFE3EFF2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF002B4B), size: 28),
          const SizedBox(height: 8),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002B4B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepNavigation({bool isContinueEnabled = true, VoidCallback? onContinue}) {
    return Container(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40, top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFCCD4DB)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Atrás',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF002B4B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: isContinueEnabled ? onContinue : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4FA4B5),
                  disabledBackgroundColor: const Color(0xFFCCD5DB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Continuar',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF002B4B),
      ),
    );
  }

  Widget _buildValueContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E9EB).withValues(alpha: 0.5)),
      ),
      child: child,
    );
  }

  Widget _buildBottomButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF27A376),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<Offset?> points;
  SignaturePainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF002B4B)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}
