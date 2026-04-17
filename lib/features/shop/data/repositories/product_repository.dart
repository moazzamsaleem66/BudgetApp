import '../models/product_model.dart';

class ProductRepository {
  const ProductRepository();

  List<String> getCategories() {
    return const ['All', 'Sneakers', 'Jackets', 'Watches', 'Bags'];
  }

  List<ProductModel> getProducts() {
    return const [
      ProductModel(
        id: '1',
        name: 'Urban Runner',
        category: 'Sneakers',
        price: 129.0,
        rating: 4.8,
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
        description: 'Lightweight everyday sneakers with bold street style.',
        isFeatured: true,
      ),
      ProductModel(
        id: '2',
        name: 'Classic Leather',
        category: 'Bags',
        price: 148.0,
        rating: 4.6,
        imageUrl: 'https://images.unsplash.com/photo-1548036328-c9fa89d128fa',
        description: 'Minimal leather bag for work, travel, and daily carry.',
        isFeatured: true,
      ),
      ProductModel(
        id: '3',
        name: 'Coast Jacket',
        category: 'Jackets',
        price: 99.0,
        rating: 4.7,
        imageUrl: 'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab',
        description: 'Clean layering piece designed for all-day comfort.',
      ),
      ProductModel(
        id: '4',
        name: 'Silver Time',
        category: 'Watches',
        price: 215.0,
        rating: 4.9,
        imageUrl: 'https://images.unsplash.com/photo-1523170335258-f5ed11844a49',
        description: 'A modern watch with a refined stainless steel finish.',
      ),
    ];
  }
}
