import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../main.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_client.dart';
import 'tagihan_spmb_screen.dart';
import 'package:dio/dio.dart';

class SpmbRegistrationScreen extends StatefulWidget {
  final String schoolId;
  final String schoolName;

  const SpmbRegistrationScreen({
    super.key,
    required this.schoolId,
    required this.schoolName,
  });

  @override
  State<SpmbRegistrationScreen> createState() => _SpmbRegistrationScreenState();
}

class _SpmbRegistrationScreenState extends State<SpmbRegistrationScreen> {
  // Current Stepper Step
  int _currentStep = 0;
  bool _isLoading = false;

  // Form Keys
  final _formKeyStudent = GlobalKey<FormState>();
  final _formKeyParent = GlobalKey<FormState>();
  final _formKeyMajor = GlobalKey<FormState>();

  // Student Details
  final TextEditingController _studentNameCtrl = TextEditingController();
  final TextEditingController _nisnCtrl = TextEditingController();
  final TextEditingController _previousSchoolCtrl = TextEditingController();
  final TextEditingController _regionCtrl = TextEditingController();
  final TextEditingController _studentPhoneCtrl = TextEditingController();
  String? _gender;
  String? _religion;

  // Parent Details
  final TextEditingController _fatherNameCtrl = TextEditingController();
  final TextEditingController _motherNameCtrl = TextEditingController();
  final TextEditingController _fatherPhoneCtrl = TextEditingController();
  final TextEditingController _motherPhoneCtrl = TextEditingController();
  final TextEditingController _fatherJobCtrl = TextEditingController();
  final TextEditingController _motherJobCtrl = TextEditingController();
  String? _fatherIncome;
  String? _motherIncome;

  // Major Details (Pilihan Jurusan)
  String? _major1;
  String? _major2;

  // Dummy Majors
  final List<String> _dummyMajors = ['MIPA (Sains)', 'IPS (Sosial)', 'Rekayasa Perangkat Lunak', 'Teknik Komputer Jaringan', 'Desain Komunikasi Visual'];
  final List<String> _incomeOptions = ['< Rp 2.000.000', 'Rp 2.000.000 - Rp 5.000.000', 'Rp 5.000.000 - Rp 10.000.000', '> Rp 10.000.000'];

  Future<void> _submitRegistration() async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiClient().dio.post(
        '/spmb/register', 
        data: {
          'tenant_id': widget.schoolId,
          'student_name': _studentNameCtrl.text,
          'nisn': _nisnCtrl.text,
          'previous_school': _previousSchoolCtrl.text,
          'region': _regionCtrl.text,
          'gender': _gender == 'Laki-laki' ? 'MALE' : (_gender == 'Perempuan' ? 'FEMALE' : _gender),
          'religion': _religion,
          'student_phone': _studentPhoneCtrl.text,
          'father_name': _fatherNameCtrl.text,
          'mother_name': _motherNameCtrl.text,
          'father_phone': _fatherPhoneCtrl.text,
          'mother_phone': _motherPhoneCtrl.text,
          'father_job': _fatherJobCtrl.text,
          'mother_job': _motherJobCtrl.text,
          'father_income': _fatherIncome,
          'mother_income': _motherIncome,
        }
      );

      if (!mounted) return;
      
      setState(() => _isLoading = false);
      
      final String spmbRegistrationId = response.data['data']['id'] ?? '';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TagihanSpmbScreen(
            studentName: _studentNameCtrl.text.isEmpty ? 'Calon Siswa' : _studentNameCtrl.text,
            schoolName: widget.schoolName,
            major: _major1 ?? 'Jurusan Reguler',
            spmbRegistrationId: spmbRegistrationId,
          ),
        ),
      );
    } on DioException catch (e) {
      setState(() => _isLoading = false);
      String errorMsg = 'Terjadi kesalahan jaringan.';
      if (e.response != null) {
        errorMsg = e.response?.data['error'] ?? 'Gagal mendaftar SPMB.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.red),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan yang tidak terduga.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.teal,
        elevation: 0,
        title: Text('Form Pendaftaran', style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: AppColors.teal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pendaftaran Baru:', style: TextStyle(color: Colors.white70, fontFamily: 'Nunito')),
                Text(widget.schoolName, style: const TextStyle(color: Colors.white, fontFamily: 'Nunito', fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: Stepper(
              type: StepperType.vertical,
              physics: const BouncingScrollPhysics(),
              currentStep: _currentStep,
              onStepTapped: (step) => setState(() => _currentStep = step),
              onStepContinue: () {
                if (_currentStep == 0) {
                  if (_formKeyStudent.currentState!.validate()) setState(() => _currentStep += 1);
                } else if (_currentStep == 1) {
                  if (_formKeyParent.currentState!.validate()) setState(() => _currentStep += 1);
                } else if (_currentStep == 2) {
                  if (_formKeyMajor.currentState!.validate()) {
                    _submitRegistration();
                  }
                }
              },
              onStepCancel: () {
                if (_currentStep > 0) setState(() => _currentStep -= 1);
              },
              controlsBuilder: (context, details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isLoading ? null : details.onStepContinue,
                          child: _isLoading && _currentStep == 2
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(_currentStep == 2 ? 'Kirim Pendaftaran' : 'Selanjutnya', style: const TextStyle(color: Colors.white, fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
                        ),
                      ),
                      if (_currentStep > 0) const SizedBox(width: 12),
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              side: BorderSide(color: AppColors.border),
                            ),
                            onPressed: details.onStepCancel,
                            child: const Text('Kembali', style: TextStyle(color: AppColors.text, fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: const Text('Data Siswa', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 16)),
                  content: Form(
                    key: _formKeyStudent,
                    child: Column(
                      children: [
                        _buildTextField(_studentNameCtrl, 'Nama Lengkap Siswa'),
                        const SizedBox(height: 12),
                        _buildTextField(_nisnCtrl, 'NISN', isNumber: true),
                        const SizedBox(height: 12),
                        _buildTextField(_previousSchoolCtrl, 'Asal Sekolah'),
                        const SizedBox(height: 12),
                        _buildTextField(_regionCtrl, 'Alamat / Wilayah'),
                        const SizedBox(height: 12),
                        _buildTextField(_studentPhoneCtrl, 'No. HP Siswa', isNumber: true),
                        const SizedBox(height: 12),
                        _buildDropdown('Jenis Kelamin', ['Laki-laki', 'Perempuan'], _gender, (v) => setState(() => _gender = v)),
                        const SizedBox(height: 12),
                        _buildDropdown('Agama', ['Islam', 'Kristen', 'Katolik', 'Hindu', 'Buddha', 'Konghucu'], _religion, (v) => setState(() => _religion = v)),
                      ],
                    ),
                  ),
                  isActive: _currentStep >= 0,
                  state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Data Orang Tua', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 16)),
                  content: Form(
                    key: _formKeyParent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Data Ayah', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, color: AppColors.teal)),
                        const SizedBox(height: 8),
                        _buildTextField(_fatherNameCtrl, 'Nama Ayah'),
                        const SizedBox(height: 12),
                        _buildTextField(_fatherPhoneCtrl, 'No. HP Ayah', isNumber: true),
                        const SizedBox(height: 12),
                        _buildTextField(_fatherJobCtrl, 'Pekerjaan Ayah'),
                        const SizedBox(height: 12),
                        _buildDropdown('Penghasilan Ayah', _incomeOptions, _fatherIncome, (v) => setState(() => _fatherIncome = v)),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Divider(),
                        ),
                        
                        const Text('Data Ibu', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, color: AppColors.teal)),
                        const SizedBox(height: 8),
                        _buildTextField(_motherNameCtrl, 'Nama Ibu'),
                        const SizedBox(height: 12),
                        _buildTextField(_motherPhoneCtrl, 'No. HP Ibu', isNumber: true),
                        const SizedBox(height: 12),
                        _buildTextField(_motherJobCtrl, 'Pekerjaan Ibu'),
                        const SizedBox(height: 12),
                        _buildDropdown('Penghasilan Ibu', _incomeOptions, _motherIncome, (v) => setState(() => _motherIncome = v)),
                      ],
                    ),
                  ),
                  isActive: _currentStep >= 1,
                  state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Pilihan Jurusan', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 16)),
                  content: Form(
                    key: _formKeyMajor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Pilih jurusan/program studi yang diminati.', style: TextStyle(fontFamily: 'Nunito', color: AppColors.text2, fontSize: 13)),
                        const SizedBox(height: 16),
                        _buildDropdown('Pilihan Jurusan 1', _dummyMajors, _major1, (v) => setState(() => _major1 = v)),
                        const SizedBox(height: 16),
                        _buildDropdown('Pilihan Jurusan 2', _dummyMajors, _major2, (v) => setState(() => _major2 = v), isRequired: false),
                      ],
                    ),
                  ),
                  isActive: _currentStep >= 2,
                  state: _currentStep == 2 ? StepState.editing : StepState.complete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 13)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: (value) => value == null || value.isEmpty ? 'Wajib diisi' : null,
          style: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
          decoration: InputDecoration(
            hintText: label,
            hintStyle: const TextStyle(fontFamily: 'Nunito', color: AppColors.text3),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.teal, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? currentValue, Function(String?) onChanged, {bool isRequired = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, color: AppColors.text, fontSize: 13)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: currentValue,
          validator: (value) => isRequired && (value == null || value.isEmpty) ? 'Wajib dipilih' : null,
          decoration: InputDecoration(
            hintText: 'Pilih $label',
            hintStyle: const TextStyle(fontFamily: 'Nunito', color: AppColors.text3),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.teal, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontFamily: 'Nunito', fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
