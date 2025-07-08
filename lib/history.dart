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
                                          // final updated = await Navigator.push(
                                          //   context,
                                          //   MaterialPageRoute(
                                          //     builder: (context) => EditProductPage(
                                          //       productRef: _allProducts[index].reference,
                                          //     ),
                                          //   ),
                                          // );
                                          // await _loadProductsForStore();
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Colors.lightBlue),
                                        tooltip: "Hapus History",
                                        onPressed: () async {
                                          // _showDeleteConfirmationDialog(
                                          //   context,
                                          //   _allProducts[index].reference,
                                          // );
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
}