// lib/views/task_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:saglik_personel_sistemi/data/tasks_model.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Task> _tasks = [];
  bool _isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    _loadSampleTasks();
  }

  /// Örnek görevleri yükler
  void _loadSampleTasks() {
    try {
      // Örnek görevler tanımlanıyor
      List<Task> sampleTasks = [
        Task(
          id: '1',
          title: 'Hasta Randevusu Oluştur',
          description: 'Yeni bir hasta için randevu oluşturun.',
          dueDate: DateTime(2024, 12, 25),
          isCompleted: false,
        ),
        Task(
          id: '2',
          title: 'Hasta Bilgilerini Güncelle',
          description: 'Mevcut hastaların bilgilerini güncelleyin.',
          dueDate: DateTime(2024, 12, 30),
          isCompleted: false,
        ),
        Task(
          id: '3',
          title: 'Aylık Rapor Hazırlama',
          description: 'Departman için aylık raporları hazırlayın.',
          dueDate: DateTime(2024, 12, 31),
          isCompleted: false,
        ),
        Task(
          id: '4',
          title: 'Ekip Toplantısı Düzenleme',
          description: 'Haftalık ekip toplantısını organize edin.',
          dueDate: DateTime(2024, 12, 28),
          isCompleted: false,
        ),
        Task(
          id: '5',
          title: 'Yeni Personel Eğitimi',
          description: 'Yeni işe alınan personel için oryantasyon programı düzenleyin.',
          dueDate: DateTime(2024, 12, 27),
          isCompleted: false,
        ),
      ];

      setState(() {
        _tasks = sampleTasks.where((task) => !task.isCompleted).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Görevler yüklenirken bir hata oluştu.';
        _isLoading = false;
      });
      print('Error loading tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aktif Görevler',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade600,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: SpinKitCircle(color: Colors.blue.shade600))
          : error.isNotEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            error,
            style: GoogleFonts.poppins(
              fontSize: 16.0,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      )
          : _tasks.isEmpty
          ? Center(
        child: Text(
          'Hiç aktif görev bulunmamaktadır.',
          style: GoogleFonts.poppins(
            fontSize: 16.0,
            color: Colors.grey[600],
          ),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return _buildTaskCard(task);
        },
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      elevation: 3.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        leading: Icon(
          task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: task.isCompleted ? Colors.green : Colors.grey,
          size: 30,
        ),
        title: Text(
          task.title,
          style: GoogleFonts.poppins(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Text(
          'Son Tarih: ${_formatDate(task.dueDate)}\n${task.description}',
          style: GoogleFonts.poppins(
            fontSize: 14.0,
            color: Colors.grey[700],
            decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        isThreeLine: true,
        trailing: IconButton(
          icon: Icon(
            task.isCompleted ? Icons.undo : Icons.check_circle,
            color: task.isCompleted ? Colors.orange : Colors.green,
          ),
          onPressed: () => _toggleTaskCompletion(task),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  /// Görev tamamlanma durumunu değiştirir
  void _toggleTaskCompletion(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
      _tasks = _tasks.where((t) => !t.isCompleted).toList();
    });
  }
}
