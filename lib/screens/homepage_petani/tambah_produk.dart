import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_tengkulaku_app/screens/homepage_petani/kelola_produk.dart';

class TambahProduk extends StatefulWidget {
  static String routeName = "/tambah_produk";
  TambahProduk({Key? key}) : super(key: key);

  @override
  _TambahProdukState createState() => _TambahProdukState();
}

class _TambahProdukState extends State<TambahProduk> {
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;

  String gambar = '';
  String nama = '';
  double harga = 0.0;
  String deskripsi = '';
  String kategori = '';

  Future<void> _pickImage() async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _pickedImage = pickedImage;
    });
  }

  Future<String> _uploadImageToFirebase() async {
    if (_pickedImage == null) {
      return '';
    }

    try {
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('images')
          .child('produk_${DateTime.now()}.png');

      final UploadTask uploadTask =
          storageReference.putFile(File(_pickedImage!.path));
      final TaskSnapshot downloadUrl = await uploadTask;
      final String url = await downloadUrl.ref.getDownloadURL();

      return url;
    } catch (e) {
      print('Error uploading image to Firebase Storage: $e');
      return '';
    }
  }

  Future<void> _saveProduct(BuildContext context) async {
    final String imageUrl = await _uploadImageToFirebase();

    try {
      CollectionReference produkCollection =
          FirebaseFirestore.instance.collection('produk');

      await produkCollection.add({
        'gambar': imageUrl,
        'nama': nama,
        'harga': harga,
        'deskripsi': deskripsi,
        'kategori': kategori,
      });

      print('Produk berhasil disimpan ke Firestore');
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Gambar Produk'),
              readOnly: true,
              onTap: _pickImage,
            ),
            SizedBox(height: 10),
            _pickedImage != null
                ? Image.file(
                    File(_pickedImage!.path),
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  )
                : SizedBox(),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(labelText: 'Nama Produk'),
              onChanged: (value) {
                nama = value;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(labelText: 'Harga Produk'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                harga = double.tryParse(value) ?? 0.0;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              decoration: InputDecoration(labelText: 'Deskripsi Produk'),
              maxLines: 3,
              onChanged: (value) {
                deskripsi = value;
              },
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(labelText: 'Kategori'),
              items: ['Sayur', 'Buah'].map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? value) {
                kategori = value ?? '';
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _saveProduct(context);
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Notifikasi'),
                      content: Text('Data berhasil ditambahkan.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushNamed(
                                context, KelolaProduk.routeName);
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

// class KelolaProduk extends StatelessWidget {
//   const KelolaProduk({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         // Implement your KelolaProduk screen here
//         // ...
//         );
//   }
// }
