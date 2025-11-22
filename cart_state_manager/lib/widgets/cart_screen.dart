import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cart_provider.dart';
import '../models/cart_state.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Carrito'),
        backgroundColor: Colors.blue[700],
        actions: [
          if (cartState.items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () => ref.read(cartProvider.notifier).clearCart(),
              tooltip: 'Limpiar carrito',
            ),
        ],
      ),
      body: Column(
        children: [
          // Header con resumen
          _buildCartSummary(cartState),

          // Lista de productos
          Expanded(
            child: _buildProductList(cartState, ref),
          ),

          // Botones de acción
          _buildActionButtons(ref),
        ],
      ),
    );
  }

  Widget _buildCartSummary(CartState cartState) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Items:', style: TextStyle(fontSize: 16)),
                Text(
                  cartState.items.length.toString(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total a Pagar:', style: TextStyle(fontSize: 18)),
                Text(
                  '\$${cartState.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            if (cartState.isLoading) ...[
              const SizedBox(height: 8),
              const LinearProgressIndicator(),
            ],
            if (cartState.error != null) ...[
              const SizedBox(height: 8),
              Text(
                'Error: ${cartState.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductList(CartState cartState, WidgetRef ref) {
    if (cartState.items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('El carrito está vacío', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: cartState.items.length,
      itemBuilder: (context, index) {
        final item = cartState.items[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: Text('\$${item.price.toInt()}'),
            ),
            title: Text(item.name),
            subtitle: Text('Cantidad: ${item.quantity}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () =>
                      ref.read(cartProvider.notifier).updateQuantity(
                            item.id,
                            item.quantity - 1,
                          ),
                ),
                Text(item.quantity.toString()),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () =>
                      ref.read(cartProvider.notifier).updateQuantity(
                            item.id,
                            item.quantity + 1,
                          ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () =>
                      ref.read(cartProvider.notifier).removeItem(item.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          ElevatedButton(
            child: const Text('💻 Agregar Laptop'),
            onPressed: () =>
                _addDemoProduct(ref, '1', 'Laptop Gaming', 1200.00),
          ),
          ElevatedButton(
            child: const Text('🖱️ Agregar Mouse'),
            onPressed: () =>
                _addDemoProduct(ref, '2', 'Mouse Inalámbrico', 45.50),
          ),
          ElevatedButton(
            child: const Text('⌨️ Agregar Teclado'), 
            onPressed: () =>
                _addDemoProduct(ref, '3', 'Teclado Mecánico', 89.99),
          ),
          ElevatedButton(
            child: const Text('📱 Agregar Teléfono'),
            onPressed: () => _addDemoProduct(ref, '4', 'Smartphone', 699.99),
          ),
        ],
      ),
    );
  }

  void _addDemoProduct(WidgetRef ref, String id, String name, double price) {
    ref.read(cartProvider.notifier).addItem(
          CartItem(
            id: id,
            name: name,
            price: price,
            quantity: 1,
            isAvailable: true,
          ),
        );
  }
}
