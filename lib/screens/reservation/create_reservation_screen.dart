import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../repositories/reservation_repository.dart';

class CreateReservationScreen extends StatefulWidget {
  final String customerId;
  const CreateReservationScreen({Key? key, required this.customerId}) : super(key: key);

  @override
  _CreateReservationScreenState createState() => _CreateReservationScreenState();
}

class _CreateReservationScreenState extends State<CreateReservationScreen> {
  final _specialRequestsCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay(hour: 18, minute: 0);
  int _numberOfGuests = 2;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.deepOrange),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.deepOrange),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() => _selectedTime = picked);
    }
  }

  void _submit() async {
    setState(() => _isLoading = true);
    try {
      final repo = ReservationRepository();
      
      final DateTime reservationDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await repo.createReservation(
        widget.customerId,
        reservationDateTime,
        _numberOfGuests,
        _specialRequestsCtrl.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đặt bàn thành công!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('Đặt Bàn Mới'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.table_restaurant, size: 48, color: Colors.deepOrange),
                    SizedBox(height: 12),
                    Text(
                      'Thông tin đặt bàn',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Date & Time
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.calendar_today, color: Colors.deepOrange),
                    ),
                    title: Text('Ngày', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    subtitle: Text(
                      DateFormat('EEEE, dd/MM/yyyy', 'vi').format(_selectedDate),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    trailing: Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () => _selectDate(context),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.access_time, color: Colors.blue),
                    ),
                    title: Text('Giờ', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                    subtitle: Text(
                      _selectedTime.format(context),
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    trailing: Icon(Icons.chevron_right, color: Colors.grey),
                    onTap: () => _selectTime(context),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Number of guests
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.people, color: Colors.purple),
                        ),
                        SizedBox(width: 12),
                        Text('Số lượng khách', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _numberOfGuests > 1 ? () => setState(() => _numberOfGuests--) : null,
                          icon: Icon(Icons.remove_circle_outline),
                          iconSize: 36,
                          color: Colors.deepOrange,
                        ),
                        SizedBox(width: 24),
                        Text(
                          '$_numberOfGuests',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 24),
                        IconButton(
                          onPressed: _numberOfGuests < 20 ? () => setState(() => _numberOfGuests++) : null,
                          icon: Icon(Icons.add_circle_outline),
                          iconSize: 36,
                          color: Colors.deepOrange,
                        ),
                      ],
                    ),
                    Center(
                      child: Text('người', style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Special requests
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.note_alt, color: Colors.green),
                        ),
                        SizedBox(width: 12),
                        Text('Yêu cầu đặc biệt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _specialRequestsCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'VD: Bàn gần cửa sổ, ghế cho em bé...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Submit button
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle),
                          SizedBox(width: 8),
                          Text('Xác nhận đặt bàn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
