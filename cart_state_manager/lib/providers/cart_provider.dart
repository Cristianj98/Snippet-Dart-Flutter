import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_state.dart';

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  // Separar lógica de negocio en métodos específicos
  Future<void> addItem(CartItem newItem) async {
    try {
      _setLoading(true);

      // Simular validación asíncrona
      await Future.delayed(const Duration(milliseconds: 300));

      if (!newItem.isAvailable) {
        throw Exception('Producto no disponible');
      }

      final existingItemIndex =
          state.items.indexWhere((item) => item.id == newItem.id);

      if (existingItemIndex != -1) {
        // Actualizar cantidad si el item ya existe
        final updatedItems = List<CartItem>.from(state.items);
        final existingItem = updatedItems[existingItemIndex];
        updatedItems[existingItemIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + newItem.quantity,
        );
        state = state.copyWith(items: updatedItems);
      } else {
        // Agregar nuevo item
        state = state.copyWith(items: [...state.items, newItem]);
      }

      _calculateTotal();
    } catch (error) {
      state = state.copyWith(error: error.toString());
    } finally {
      _setLoading(false);
    }
  }

  void removeItem(String itemId) {
    final updatedItems =
        state.items.where((item) => item.id != itemId).toList();

    state = state.copyWith(items: updatedItems);
    _calculateTotal();
  }

  // No modificamos el estado, creamos uno nuevo
  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }

    final updatedItems = state.items.map((item) {
      return item.id == itemId ? item.copyWith(quantity: newQuantity) : item;
    }).toList();

    state = state.copyWith(items: updatedItems);
    _calculateTotal();
  }

  void clearCart() {
    state = const CartState();
  }

  // Métodos privados para responsabilidades específicas
  void _calculateTotal() {
    final total = state.items.fold(
      0.0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    state = state.copyWith(total: total);
  }

  void _setLoading(bool loading) {
    state =
        state.copyWith(isLoading: loading, error: loading ? null : state.error);
  }
}

// Provider global accesible desde cualquier widget
final cartProvider = StateNotifierProvider<CartNotifier, CartState>(
  (ref) => CartNotifier(),
);
