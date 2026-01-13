import 'package:flutter/material.dart';
import '../../models/customer_model.dart';
import '../../repositories/customer_repository.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  
  final List<String> _availablePreferences = ["vegetarian", "spicy", "seafood", "sweet", "sour"];
  final Map<String, String> _preferenceLabels = {
    "vegetarian": "🥬 Món chay",
    "spicy": "🌶️ Món cay",
    "seafood": "🦐 Hải sản",
    "sweet": "🍰 Món ngọt",
    "sour": "🍋 Món chua",
  };
  List<String> _selectedPreferences = [];
  bool _isLoading = false;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      print('🔄 Bắt đầu đăng ký...');
      final newCustomer = CustomerModel(
        email: _emailCtrl.text.trim(),
        fullName: _nameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        preferences: _selectedPreferences,
      );

      print('📝 Customer data: ${newCustomer.toFirestore()}');
      
      final repo = CustomerRepository();
      await repo.addCustomer(newCustomer);

      print('✅ Đăng ký thành công!');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      print('❌ Lỗi đăng ký: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade400,
              Colors.deepOrange.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar custom
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Đăng Ký Tài Khoản',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Icon header
                            Center(
                              child: Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.person_add,
                                  size: 40,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ),
                            SizedBox(height: 24),

                            // Email
                            TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'example@gmail.com',
                                prefixIcon: Icon(Icons.email_outlined, color: Colors.deepOrange),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.deepOrange, width: 2),
                                ),
                              ),
                              validator: (v) => v!.isEmpty ? 'Vui lòng nhập email' : null,
                            ),
                            SizedBox(height: 16),

                            // Full name
                            TextFormField(
                              controller: _nameCtrl,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                labelText: 'Họ và tên',
                                hintText: 'Nguyễn Văn A',
                                prefixIcon: Icon(Icons.person_outline, color: Colors.deepOrange),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.deepOrange, width: 2),
                                ),
                              ),
                              validator: (v) => v!.isEmpty ? 'Vui lòng nhập họ tên' : null,
                            ),
                            SizedBox(height: 16),

                            // Phone
                            TextFormField(
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'Số điện thoại',
                                hintText: '0901234567',
                                prefixIcon: Icon(Icons.phone_outlined, color: Colors.deepOrange),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.deepOrange, width: 2),
                                ),
                              ),
                              validator: (v) => v!.isEmpty ? 'Vui lòng nhập SĐT' : null,
                            ),
                            SizedBox(height: 16),

                            // Address
                            TextFormField(
                              controller: _addressCtrl,
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: 'Địa chỉ',
                                hintText: '123 Đường ABC, Quận XYZ',
                                prefixIcon: Icon(Icons.location_on_outlined, color: Colors.deepOrange),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.deepOrange, width: 2),
                                ),
                              ),
                              validator: (v) => v!.isEmpty ? 'Vui lòng nhập địa chỉ' : null,
                            ),
                            SizedBox(height: 24),

                            // Preferences section
                            Text(
                              'Sở thích ăn uống',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: 12),
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: _availablePreferences.map((pref) {
                                final isSelected = _selectedPreferences.contains(pref);
                                return FilterChip(
                                  label: Text(_preferenceLabels[pref] ?? pref),
                                  selected: isSelected,
                                  selectedColor: Colors.orange.shade200,
                                  checkmarkColor: Colors.deepOrange,
                                  backgroundColor: Colors.grey.shade100,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.deepOrange.shade700 : Colors.grey.shade700,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                  ),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedPreferences.add(pref);
                                      } else {
                                        _selectedPreferences.remove(pref);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 32),

                            // Register button
                            SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrange,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                ),
                                child: _isLoading
                                    ? SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        'ĐĂNG KÝ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
