import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Витрина товаров',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ProductShowcaseScreen(),
    );
  }
}

class ProductShowcaseScreen extends StatefulWidget {
  const ProductShowcaseScreen({super.key});

  @override
  _ProductShowcaseScreenState createState() => _ProductShowcaseScreenState();
}

class _ProductShowcaseScreenState extends State<ProductShowcaseScreen> {
  List<Map<String, dynamic>> products = [];

  // Функция для удаления товара с подтверждением
  void _confirmDeleteProduct(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Подтверждение удаления'),
          content: const Text('Вы уверены, что хотите удалить товар?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Закрыть диалог
              },
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  products.removeAt(index);
                });
                Navigator.of(context).pop(); // Закрыть диалог
              },
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  // Переход на экран добавления товара
  void _navigateToAddProduct() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );
    if (result != null) {
      setState(() {
        products.insert(0, result); // Добавляем товар в начало списка
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Витрина товаров'),
      ),
      body: products.isEmpty
          ? const Center(child: Text('Нет добавленных товаров'))
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Картинка сверху
                Image.file(
                  File(product['imagePath']),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                // Название товара
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    product['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                // Описание товара
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(product['description']),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDeleteProduct(index),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddProduct,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// Экран добавления товара
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;

  // Метод для выбора изображения с устройства
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Метод для завершения добавления товара
  void _addProduct() {
    if (_nameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, заполните все поля')),
      );
      return;
    }

    final newProduct = {
      'name': _nameController.text,
      'description': _descriptionController.text,
      'imagePath': _imageFile!.path,
    };

    Navigator.of(context).pop(newProduct);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить товар'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Название товара'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Описание товара'),
            ),
            const SizedBox(height: 20),
            _imageFile == null
                ? const Text('Изображение не выбрано.')
                : Image.file(
              _imageFile!,
              height: 150,
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Выбрать изображение товара'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addProduct,
              child: const Text('Добавить товар'),
            ),
          ],
        ),
      ),
    );
  }
}
