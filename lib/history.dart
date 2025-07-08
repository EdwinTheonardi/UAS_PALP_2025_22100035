import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({ super.key });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<DocumentSnapshot> _allHistory = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final historySnapshot = await FirebaseFirestore.instance
        .collection('orderHistory')
        .get();

      setState(() {
        _allHistory = historySnapshot.docs;
        _loading = false;
      });
    } catch (e) {
      print("Gagal memuat data: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _loading
              ? Center(child: CircularProgressIndicator())
              : _allHistory.isEmpty
                  ? Center(child: Text('Tidak ada data history'))
                  : RefreshIndicator(
                      onRefresh: _loadHistory,
                      child: ListView.builder(
                        itemCount: _allHistory.length,
                        itemBuilder: (context, index) {
                          final history = _allHistory[index].data() as Map<String, dynamic>;

                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Nama Pelanggan: ${history['nama'] ?? '-'}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Nomor Telepon: ${history['no_hp'] ?? '-'}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Tipe Pembayaran: ${history['tipe_pembayaran'] ?? '-'}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Jumlah Helm: ${history['jumlah'] ?? '-'}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Tanggal Ambil: ${history['tanggal_ambil'] != null ? DateFormat('dd/MM/yyyy').format((history['tanggal_ambil'] as Timestamp).toDate()) : '-'}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.lightBlue),
                                        tooltip: "Edit History",
                                        onPressed: () async {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => EditPemesananForm(historyRef: _allHistory[index].reference),
                                          );
                                          await _loadHistory();
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.lightBlue),
                                        tooltip: "Hapus History",
                                        onPressed: () async {
                                          _showDeleteConfirmationDialog(
                                            context,
                                            _allHistory[index].reference,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ), 
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, DocumentReference ref) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Konfirmasi'),
        content: Text('Yakin ingin menghapus history ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await ref.delete();
        await _loadHistory();
      } catch (e) {
        print("Gagal menghapus history: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus history: $e')),
          );
        }
      }
    }
  }
}

class EditPemesananForm extends StatefulWidget {
  final DocumentReference historyRef;

  EditPemesananForm({required this.historyRef});

  @override
  _EditPemesananFormState createState() => _EditPemesananFormState();
}

class _EditPemesananFormState extends State<EditPemesananForm> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _namaController = TextEditingController();
  final _kontakController = TextEditingController();
  DateTime? tanggalAmbil;
  String? _selectedTipePembayaran;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final historySnap = await widget.historyRef.get();
      if (!historySnap.exists) return;

      final historyData = historySnap.data() as Map<String, dynamic>;

      setState(() {
        _jumlahController.text = historyData['jumlah'] ?? '';
        _namaController.text = historyData['nama'] ?? '';
        _kontakController.text = historyData['no_hp'] ?? '';
        tanggalAmbil = (historyData['tanggal_ambil'] as Timestamp).toDate();
        _selectedTipePembayaran = historyData['tipe_pembayaran'] ?? '';

        _loading = false; 
      });
    } catch (e) {
      debugPrint('Error loading history data: $e');
    }
  }

  Future<void> _updateHistory() async {
    if (!_formKey.currentState!.validate() ||
        tanggalAmbil == null) {
      return;
    }

    final updatedData = {
      'jumlah': _jumlahController.text.trim(),
      'nama': _namaController.text.trim(),
      'no_hp': _kontakController.text.trim(),
      'tanggal_ambil': tanggalAmbil,
      'tipe_pembayaran': _selectedTipePembayaran,
    };

    await widget.historyRef.update(updatedData);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit History'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Jumlah Helm'),
                keyboardType: TextInputType.number,
                controller: _jumlahController,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 30)),
                  );
                  if (picked != null) {
                    setState(() => tanggalAmbil = picked);
                  }
                },
                child: Text(
                  tanggalAmbil == null
                      ? 'Pilih Tanggal Ambil'
                      : 'Ambil: ${DateFormat('yyyy-MM-dd').format(tanggalAmbil!)}',
                ),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Nama'),
                controller: _namaController,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'No Hp'),
                controller: _kontakController,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Wajib diisi' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedTipePembayaran,
                items: ['Tunai', 'Transfer', 'QRIS']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedTipePembayaran = val!),
                decoration: InputDecoration(labelText: 'Tipe Pembayaran'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text('Batal')),
        ElevatedButton(
            onPressed: _updateHistory,
            child: Text('Update History')),
      ],
    );
  }
}