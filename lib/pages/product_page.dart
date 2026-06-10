import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'product_detail_page.dart';
import '../widgets/product_card.dart';


class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  //inisialisasi Variabel
  List<ProductModel> products = [];


  //membuat method loadProducts untuk menampilkan daftar product
  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> productJsonList = prefs.getStringList('products') ?? [];
    setState(() {
      products = productJsonList
          .map((item) => ProductModel.fromJson(item))
          .toList();
    });
  }


  //membuat init state untuk mengambil data username dari shared preferences
  @override
  void initState() {
    super.initState();
    loadProducts();
  }


  //membuat method SaveProduct (untuk menyimpan perubahan produk)
  Future<void> saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> productJsonList = products
        .map((item) => item.toJson())
        .toList();
    await prefs.setStringList('products', productJsonList);
  }

  //membuat method addProduct (untuk menambahkan produk baru)
  Future<void> addProduct(ProductModel product) async {
    setState(() {
      products.add(product);
    });
    await saveProducts();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk berhasil ditambahkan')),
    );
  }

    //membuat method editProduct (untuk mengedit produk yang sudah ada)
  Future<void> editProduct(int index, ProductModel updatedProduct) async {
    setState(() {
      products[index] = updatedProduct;
    });
    await saveProducts();
  }

  //membuat method deleteProduct (untuk menghapus produk)
  Future<void> deleteProduct(int index) async {
    setState(() {
      products.removeAt(index);
    });
    await saveProducts();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Produk berhasil dihapus')));
  }



   //membuat method showDialog untuk menampilkan dialog form tambah produk
  void showForm(ProductModel? product, int? index) {
    //membuat controler
    TextEditingController nameController = TextEditingController(
      text: product?.name ?? '',
    );
    TextEditingController descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    TextEditingController priceController = TextEditingController(
      text: product?.price.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product == null ? 'Tambah Produk' : 'Edit Produk'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Produk'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Deskripsi Produk'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Harga Produk'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            child: const Text('Simpan'),
            onPressed: () {
              final newProduct = ProductModel(
                name: nameController.text,
                description: descriptionController.text,
                price: int.tryParse(priceController.text) ?? 0,
              );
              if (product == null) {
                addProduct(newProduct);
              } else {
                editProduct(index!, newProduct);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Produk', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blueAccent,
          leading: IconButton (
            icon: Icon(Icons.arrow_back, color: Colors.white
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container (
          margin: EdgeInsets.all(16),
          child: Column (
            children: [
               SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => showForm(null, null),
                    child: Text("Tambah Produk"),
                  ),
                ),
              ],
            ),
            Expanded(
                child: products.isEmpty
                ? const Center(child: Text('Belum ada produk'))
                : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      onDelete: () => deleteProduct(index),
                      onEdit: () => showForm(product, index),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailPage(product: product),
                        ),
                      ),
                    );
                  }
                )
              )
            ]
          ),
        )
      );
    }
}