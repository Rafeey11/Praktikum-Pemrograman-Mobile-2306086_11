import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_page.dart';
import '../models/product_model.dart';
import 'product_page.dart';
import 'product_detail_page.dart';
import '../widgets/product_card.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

//membuat state untuk home page
  @override
  State<HomePage> createState() => _HomePageState();
}


//membuat class state untuk home page
class _HomePageState extends State<HomePage> {
  //inisialisasi variabel username
  String username = '';
  //Membuat vairiabel utama untuk menyimpan data
  List<ProductModel> products = [];
  int totalProducts = 0;

  //membuat init state untuk mengambil data username dari shared preferences
  @override
  void initState() {
    super.initState();
    getUser();
    loadProducts();
  }

  //membuat method loadProducts untuk menampilkan daftar product
  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> productJsonList = prefs.getStringList('products') ?? [];
    totalProducts = productJsonList.length;
    setState(() {
      products = productJsonList
      .reversed
      .take(3)
      .map((item) => ProductModel.fromJson(item))
      .toList();
    }); 
  }



  //membuat method getUser untuk mengambil data username dari shared preferences(lokal storage)
  Future<void> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? '';
    });
  }



  //Membuat method Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }


//membuat widget builder
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:Column(
            children: [
               Container(
                height: 100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(128),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: const NetworkImage(
                        'https://picsum.photos/seed/picsum/536/354',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Selamat Datang",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                username,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.verified,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(
                                    255,
                                    228,
                                    231,
                                    233,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withAlpha(128),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: logout,
                      child: Icon(
                        Icons.logout,
                        color: const Color.fromARGB(255, 200, 15, 15),
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),

             
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Produk : ${totalProducts.toString()}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductPage(),
                        ),
                      );
                    },
                    child: const Text("Lihat selengkapnya"),
                  ),
                ],
              ),

              SizedBox(height: 20),
              Expanded(
                child: products.isEmpty
                    ? const Center(child: Text('Belum ada produk'))
                    : ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return ProductCard(
                            product: product,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailPage(product: product),
                                ),
                              );
                            },
                          );
                        },
                      ),
              )
            ]
          )
        ),
      ),
    );
  }
}