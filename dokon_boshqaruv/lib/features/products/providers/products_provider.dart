import '../../../src/l10n/app_strings.dart';

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';

import '../../../src/api.dart';
import '../../../src/offline.dart';
import '../../../src/app.dart' show apiProvider, queueProvider;
import '../models/product.dart';
import '../../pos/providers/cart_provider.dart';

final productsStaleProvider = StateProvider<bool>((ref) => false);

final productsProvider =
    StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
      return ProductsNotifier(
        ref.read(apiProvider),
        ref.read(queueProvider),
        (value) => ref.read(productsStaleProvider.notifier).state = value,
        onRemoved: (id) => ref.read(cartProvider.notifier).removeProduct(id),
      );
    });

class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final Api _api;
  final OfflineQueue _queue;
  final void Function(bool) _setStale;
  final void Function(int)? onRemoved;
  Future<void>? _loading;

  ProductsNotifier(this._api, this._queue, this._setStale, {this.onRemoved})
    : super(AsyncValue.loading()) {
    loadProducts();
  }

  Future<void> loadProducts({bool forceRefresh = false}) async {
    if (_removing) return;
    final running = _loading;
    if (running != null) return running;
    if (!forceRefresh && state.hasValue) return;
    final future = _load();
    _loading = future;
    try {
      await future;
    } finally {
      _loading = null;
    }
  }

  Future<void> _load() async {
    if (!mounted) return;
    state = AsyncValue.loading();
    try {
      // Oldingi payment_dialog.dart lokal qoldiqni shu keshda kamaytiradi.
      // Navbat bor ekan uni server qoldig‘i bilan almashtirmaymiz.
      if (await _queue.pendingCount() > 0) {
        await _showReservedCache();
        return;
      }

      final removed = await _queue.removedProductIds();
      final fresh = (await _api.products())
          .where(
            (raw) =>
                raw['active'] != false &&
                !removed.contains(int.tryParse('${raw['id']}')),
          )
          .toList();
      final database = await _queue.db;
      final chosen = await database.transaction<List<dynamic>>((tx) async {
        final counts = await tx.rawQuery(
          "SELECT COUNT(*) AS n FROM operations "
          "WHERE status IN ('pending', 'conflict')",
        );
        final pending = (counts.first['n'] as num?)?.toInt() ?? 0;

        // HTTP so‘rovi davomida yangi offline savdo qo‘shilgan bo‘lishi mumkin.
        if (pending > 0) {
          final rows = await tx.query(
            'cache',
            where: 'key = ?',
            whereArgs: ['products'],
            limit: 1,
          );
          if (rows.isEmpty) {
            throw StateError(tr('m510'));
          }
          return List<dynamic>.from(
            jsonDecode(rows.first['payload'] as String) as List,
          );
        }

        // Noto‘g‘ri API javobi mavjud yaxshi keshni buzmasin.
        for (final raw in fresh) {
          Product.fromJson(Map<String, dynamic>.from(raw as Map));
        }
        await tx.insert('cache', {
          'key': 'products',
          'payload': jsonEncode(fresh),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
        return fresh;
      });

      final hidden = await _queue.removedProductIds();
      final parsed = chosen
          .where(
            (raw) =>
                raw['active'] != false &&
                !hidden.contains(int.tryParse('${raw['id']}')),
          )
          .map((raw) => Product.fromJson(Map<String, dynamic>.from(raw as Map)))
          .toList();
      final stale = await _queue.pendingCount() > 0;
      if (!mounted) return;
      _setStale(stale);
      state = AsyncValue.data(parsed);
    } catch (error, stack) {
      if (!mounted) return;
      // Ruxsat/avtorizatsiya xatosini offline rejim deb yashirmaymiz.
      if (Api.isNetworkError(error)) {
        try {
          await _showReservedCache();
          return;
        } catch (_) {
          // Asl tarmoq xatosini ko‘rsatamiz.
        }
      }
      if (!mounted) return;
      _setStale(false);
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> _showReservedCache() async {
    final raw = await _queue.cachedProducts();
    final parsed = raw
        .map((item) => Product.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
    if (!mounted) return;
    _setStale(true);
    state = AsyncValue.data(parsed);
  }

  Future<void> refresh() => loadProducts(forceRefresh: true);

  Future<void> _requireSynced() async {
    if (await _queue.pendingCount() > 0) {
      throw StateError(tr('m42'));
    }
  }

  Future<Product?> addProduct(
    Map<String, dynamic> data, {
    String? imagePath,
  }) async {
    await _requireSynced();
    final result = await _api.createProduct(data, imagePath: imagePath);
    final product = Product.fromJson(result);
    // Server yozuvi muvaffaqiyatli bo‘lganidan keyingi yuklash xatosi
    // mahsulotni qaytadan yaratishga sabab bo‘lmasin.
    await refresh();
    return product;
  }

  Future<void> updateProduct(
    int id,
    Map<String, dynamic> data, {
    String? imagePath,
  }) async {
    await _requireSynced();
    await _api.updateProduct(id, data, imagePath: imagePath);
    await refresh();
  }

  bool _removing = false;
  Future<void> deleteProduct(int id) => _removeProduct(id, archive: false);
  Future<void> archiveProduct(int id) => _removeProduct(id, archive: true);

  Future<void> _removeProduct(int id, {required bool archive}) async {
    if (_removing) throw StateError(tr('m231'));
    _removing = true;
    try {
      await _requireSynced();
      // Finish an earlier GET before DELETE, so an old response cannot restore it.
      if (_loading != null) await _loading;
      if (archive) {
        await _api.archiveProduct(id);
      } else {
        await _api.deleteProduct(id);
      }
      await _queue.removeConfirmedProduct(id, tombstone: !archive);
      if (!mounted) return;
      final products = state.asData?.value ?? [];
      state = AsyncValue.data(products.where((p) => p.id != id).toList());
      onRemoved?.call(id);
    } finally {
      _removing = false;
    }
  }

  // Kassa bazaga yozishni o‘zi bajaradi. Bu metodlar faqat joriy UI uchun.
  void updateStockLocally(int productId, double newStock) {
    if (!mounted || !newStock.isFinite || newStock < 0) return;
    final list = state.asData?.value;
    if (list == null) return;
    state = AsyncValue.data(
      list
          .map(
            (product) => product.id == productId
                ? product.copyWith(stock: newStock.toStringAsFixed(3))
                : product,
          )
          .toList(),
    );
  }

  void adjustStockLocally(int productId, double delta) {
    if (!mounted || !delta.isFinite) return;
    final list = state.asData?.value;
    if (list == null) return;
    for (final product in list) {
      if (product.id == productId) {
        final current = double.tryParse(product.stock);
        if (current == null) return;
        updateStockLocally(
          productId,
          (current + delta).clamp(0.0, double.infinity).toDouble(),
        );
        return;
      }
    }
  }
}

final productFiltersProvider = StateProvider<ProductFilters>((ref) {
  return ProductFilters();
});

final filteredProductsProvider = Provider<List<Product>>((ref) {
  final source = ref.watch(productsProvider).asData?.value;
  final filters = ref.watch(productFiltersProvider);
  if (source == null) return [];
  // Sort asl provider ro‘yxatining tartibini o‘zgartirmaydi.
  var list = source.where((p) => p.active).toList();
  final query = filters.searchQuery?.trim().toLowerCase() ?? '';
  if (query.isNotEmpty) {
    list = list
        .where(
          (p) =>
              p.name.toLowerCase().contains(query) ||
              p.sku.toLowerCase().contains(query) ||
              (p.barcode?.toLowerCase().contains(query) ?? false) ||
              (p.categoryName?.toLowerCase().contains(query) ?? false) ||
              p.locationLabel.toLowerCase().contains(query),
        )
        .toList();
  }
  if (filters.categoryId != null) {
    list = list.where((p) => p.categoryId == filters.categoryId).toList();
  }
  if (filters.stockStatus != null && filters.stockStatus != 'all') {
    list = list.where((p) => p.stockStatus == filters.stockStatus).toList();
  }
  if (filters.minPrice != null) {
    list = list
        .where((p) => (double.tryParse(p.salePrice) ?? 0) >= filters.minPrice!)
        .toList();
  }
  if (filters.maxPrice != null) {
    list = list
        .where((p) => (double.tryParse(p.salePrice) ?? 0) <= filters.maxPrice!)
        .toList();
  }
  list.sort((a, b) {
    int compared;
    switch (filters.sortBy) {
      case 'sale_price':
        compared = (double.tryParse(a.salePrice) ?? 0).compareTo(
          double.tryParse(b.salePrice) ?? 0,
        );
        break;
      case 'purchase_price':
        compared = (double.tryParse(a.purchasePrice) ?? 0).compareTo(
          double.tryParse(b.purchasePrice) ?? 0,
        );
        break;
      case 'stock':
        compared = (double.tryParse(a.stock) ?? 0).compareTo(
          double.tryParse(b.stock) ?? 0,
        );
        break;
      default:
        compared = a.name.compareTo(b.name);
    }
    return filters.sortAscending ? compared : -compared;
  });
  return list;
});

final productSummaryProvider = Provider<ProductSummary>((ref) {
  return ProductSummary.fromProducts(ref.watch(filteredProductsProvider));
});

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final api = ref.read(apiProvider);
  final queue = ref.read(queueProvider);
  List<dynamic> data;
  try {
    data = await api.getCategories();
    for (final item in data) {
      Category.fromJson(Map<String, dynamic>.from(item as Map));
    }
  } catch (error) {
    if (!Api.isNetworkError(error)) rethrow;
    final database = await queue.db;
    final rows = await database.query(
      'cache',
      where: 'key = ?',
      whereArgs: ['categories'],
      limit: 1,
    );
    if (rows.isEmpty) rethrow;
    data = List<dynamic>.from(
      jsonDecode(rows.first['payload'] as String) as List,
    );
    return data
        .map(
          (item) => Category.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }
  final database = await queue.db;
  await database.insert('cache', {
    'key': 'categories',
    'payload': jsonEncode(data),
  }, conflictAlgorithm: ConflictAlgorithm.replace);
  return data
      .map((item) => Category.fromJson(Map<String, dynamic>.from(item as Map)))
      .toList();
});

final productProvider = FutureProvider.family<Product?, int>((ref, id) async {
  if ((await ref.read(queueProvider).removedProductIds()).contains(id)) {
    return null;
  }
  final current = ref.watch(productsProvider);
  final loaded = current.asData?.value;
  if (loaded != null) {
    for (final product in loaded) {
      if (product.id == id) return product;
    }
  }
  final queue = ref.read(queueProvider);
  if (await queue.pendingCount() > 0) {
    final cached = await queue.cachedProducts();
    for (final raw in cached) {
      final product = Product.fromJson(Map<String, dynamic>.from(raw as Map));
      if (product.id == id) return product;
    }
    return null;
  }
  try {
    final raw = await ref.read(apiProvider).getProduct(id);
    return raw == null ? null : Product.fromJson(raw);
  } catch (error) {
    if (!Api.isNetworkError(error)) rethrow;
    final cached = await queue.cachedProducts();
    for (final raw in cached) {
      final product = Product.fromJson(Map<String, dynamic>.from(raw as Map));
      if (product.id == id) return product;
    }
    rethrow;
  }
});
