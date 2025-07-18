import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HelmServiceList extends StatelessWidget {
  final List<Map<String, dynamic>> helmShops = [
    {
      'nama': 'Standar',
      'keterangan': 'cuci manual dan pengeringan manual (2 x 24 jam)',
      'harga': '20.000'
    },
    {
      'nama': 'Advanced',
      'keterangan': 'cuci manual dan pengeringan mesin (1 x 24 jam)',
      'harga': '30.000'
    },
    {
      'nama': 'Pro',
      'keterangan': 'cuci dan pengeringan mesin (30 menit kelarr)',
      'harga': '50.000'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Layanan Cuci Helm')),
      body: ListView.builder(
        itemCount: helmShops.length,
        itemBuilder: (context, index) {
          final shop = helmShops[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(shop['nama']),
              subtitle:
                  Text('Jenis: ${shop['keterangan']} \nRp ${shop['harga']}'),
              trailing: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => PemesananForm(shopName: shop['nama']),
                  );
                },
                child: Text('Pesan'),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PemesananForm extends StatefulWidget {
  final String shopName;

  PemesananForm({required this.shopName});

  @override
  _PemesananFormState createState() => _PemesananFormState();
}

class _PemesananFormState extends State<PemesananForm> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _namaController = TextEditingController();
  final _kontakController = TextEditingController();
  DateTime? tanggalAmbil;
  String? _selectedTipePembayaran;

  Future<void> _saveHistory() async {
    if (!_formKey.currentState!.validate() ||
        tanggalAmbil == null) {
      return;
    }

    final history = {
      'jumlah': _jumlahController.text.trim(),
      'nama': _namaController.text.trim(),
      'no_hp': _kontakController.text.trim(),
      'tanggal_ambil': tanggalAmbil,
      'tipe_pembayaran': _selectedTipePembayaran,
    };

    final historyDoc = await FirebaseFirestore.instance
        .collection('orderHistory')
        .add(history);

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Pesan - ${widget.shopName}'),
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
            onPressed: _saveHistory,
            child: Text('Kirim')),
      ],
    );
  }
}