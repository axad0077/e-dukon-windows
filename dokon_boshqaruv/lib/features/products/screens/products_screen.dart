import '../widgets/category_picker.dart';
import '../../../src/adaptive_colors.dart';
import '../../../src/l10n/app_strings.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/products_provider.dart';
import '../models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/product_summary_cards.dart';
import '../widgets/empty_state.dart';
import 'add_product_screen.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String _viewMode = 'list'; // 'list' or 'grid'

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    final productsAsync = ref.watch(productsProvider);
    final filteredProducts = ref.watch(filteredProductsProvider);
    final summary = ref.watch(productSummaryProvider);
    final filters = ref.watch(productFiltersProvider);
    final productsStale = ref.watch(productsStaleProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tr('m255')),
            Text(
              tr('m260'),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          // View mode toggle (only on larger screens)
          if (MediaQuery.of(context).size.width > 600)
            IconButton(
              icon: Icon(
                _viewMode == 'list' ? Icons.grid_view : Icons.view_list,
              ),
              onPressed: () {
                setState(() {
                  _viewMode = _viewMode == 'list' ? 'grid' : 'list';
                });
              },
              tooltip: _viewMode == 'list' ? tr('m151') : tr('m232'),
            ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              ref.read(productsProvider.notifier).refresh();
            },
            tooltip: tr('m595'),
          ),
          IconButton(
            icon: Stack(
              children: [
                Icon(Icons.filter_list),
                if (filters.hasActiveFilters)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: adaptiveColor(context, Colors.red),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              _showFiltersSheet(context);
            },
            tooltip: tr('m140'),
          ),
        ],
      ),
      body: Column(
        children: [
          const CategoryToolbar(),
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return EmptyProductsState(
                    onAddProduct: () => _navigateToAddProduct(context),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () =>
                      ref.read(productsProvider.notifier).refresh(),
                  child: CustomScrollView(
                    slivers: [
                      // Summary cards
                      SliverToBoxAdapter(
                        child: ProductSummaryCards(summary: summary),
                      ),

                      if (productsStale)
                        SliverToBoxAdapter(child: _StaleInventoryNotice()),

                      SliverToBoxAdapter(
                        child: _StockWarnings(
                          products: products
                              .where(
                                (p) => p.active && p.stockStatus != 'mavjud',
                              )
                              .toList(),
                        ),
                      ),

                      // Search bar
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: tr('m388'),
                              prefixIcon: Icon(Icons.search),
                              suffixIcon:
                                  filters.searchQuery != null &&
                                      filters.searchQuery!.isNotEmpty
                                  ? IconButton(
                                      icon: Icon(Icons.clear),
                                      onPressed: () {
                                        ref
                                            .read(
                                              productFiltersProvider.notifier,
                                            )
                                            .state = filters.copyWith(
                                          searchQuery: '',
                                        );
                                      },
                                    )
                                  : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onChanged: (value) {
                              // Debouncing handled by provider
                              ref.read(productFiltersProvider.notifier).state =
                                  filters.copyWith(searchQuery: value);
                            },
                          ),
                        ),
                      ),

                      // Active filters chip
                      if (filters.hasActiveFilters)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Wrap(
                              spacing: 8,
                              children: [
                                if (filters.categoryId != null)
                                  Chip(
                                    label: Text(tr('m212')),
                                    onDeleted: () {
                                      ref
                                          .read(productFiltersProvider.notifier)
                                          .state = filters.copyWith(
                                        categoryId: null,
                                      );
                                    },
                                  ),
                                if (filters.stockStatus != null &&
                                    filters.stockStatus != 'all')
                                  Chip(
                                    label: Text(
                                      tr('m164', [filters.stockStatus]),
                                    ),
                                    onDeleted: () {
                                      ref
                                          .read(productFiltersProvider.notifier)
                                          .state = filters.copyWith(
                                        stockStatus: 'all',
                                      );
                                    },
                                  ),
                                if (filters.minPrice != null ||
                                    filters.maxPrice != null)
                                  Chip(
                                    label: Text(tr('m306')),
                                    onDeleted: () {
                                      ref
                                          .read(productFiltersProvider.notifier)
                                          .state = filters.copyWith(
                                        minPrice: null,
                                        maxPrice: null,
                                      );
                                    },
                                  ),
                                TextButton.icon(
                                  onPressed: () {
                                    ref
                                        .read(productFiltersProvider.notifier)
                                        .state = filters
                                        .clearFilters();
                                  },
                                  icon: Icon(Icons.clear_all, size: 16),
                                  label: Text(tr('m54')),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Products list/grid
                      if (filteredProducts.isEmpty)
                        SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: adaptiveColor(context, Colors.grey),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  tr('m158'),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: adaptiveColor(
                                      context,
                                      Colors.grey,
                                      foreground: true,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  tr('m141'),
                                  style: TextStyle(
                                    color: adaptiveColor(
                                      context,
                                      Colors.grey,
                                      foreground: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (_viewMode == 'grid' &&
                          MediaQuery.of(context).size.width > 600)
                        SliverPadding(
                          padding: EdgeInsets.all(16),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      MediaQuery.of(context).size.width > 1200
                                      ? 4
                                      : 2,
                                  mainAxisExtent:
                                      360 *
                                      (MediaQuery.textScalerOf(context)
                                                  .scale(16) /
                                              16)
                                          .clamp(1.0, 1.8),
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                ),
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final product = filteredProducts[index];
                              return ProductCard(
                                product: product,
                                onTap: () =>
                                    _navigateToDetail(context, product.id),
                              );
                            }, childCount: filteredProducts.length),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final product = filteredProducts[index];
                            return ProductListTile(
                              product: product,
                              onTap: () =>
                                  _navigateToDetail(context, product.id),
                            );
                          }, childCount: filteredProducts.length),
                        ),

                      // Bottom padding
                      SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
                );
              },
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: adaptiveColor(context, Colors.red),
                    ),
                    SizedBox(height: 16),
                    Text(friendlyFailure(error)),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(productsProvider.notifier).refresh();
                      },
                      icon: Icon(Icons.refresh),
                      label: Text(tr('m381')),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddProduct(context),
        icon: Icon(Icons.add),
        label: Text(tr('m248')),
      ),
    );
  }

  void _navigateToAddProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddProductScreen()),
    );
  }

  void _navigateToDetail(BuildContext context, int productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailScreen(productId: productId),
      ),
    );
  }

  void _showFiltersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ProductFiltersSheet(),
    );
  }
}

class _StockWarnings extends StatelessWidget {
  final List<Product> products;
  const _StockWarnings({required this.products});

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    if (products.isEmpty) return SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Card(
        color: adaptiveColor(context, Color(0xFFFFF8E1)),
        child: Column(
          children: products.map((product) {
            final empty = product.stockStatus == 'tugagan';
            final color = empty ? Colors.red.shade700 : Colors.orange.shade800;
            final stock = product.stock;
            return ListTile(
              dense: true,
              leading: Icon(
                empty ? Icons.error_outline : Icons.warning_amber,
                color: color,
              ),
              title: Text(
                empty ? tr('m649', [product.name]) : tr('m637', [product.name]),
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                empty
                    ? tr('m342', [product.minStock, product.unit])
                    : tr('m345', [
                        stock,
                        product.unit,
                        product.minStock,
                        product.unit,
                      ]),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _StaleInventoryNotice extends StatelessWidget {
  const _StaleInventoryNotice();

  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Card(
        color: adaptiveColor(context, Color(0xFFFFF3E0)),
        child: ListTile(
          dense: true,
          leading: Icon(
            Icons.cloud_off,
            color: adaptiveColor(context, Colors.deepOrange, foreground: true),
          ),
          title: Text(tr('m173')),
          subtitle: Text(tr('m479')),
        ),
      ),
    );
  }
}

class ProductFiltersSheet extends ConsumerStatefulWidget {
  const ProductFiltersSheet({super.key});

  @override
  ConsumerState<ProductFiltersSheet> createState() =>
      _ProductFiltersSheetState();
}

class _ProductFiltersSheetState extends ConsumerState<ProductFiltersSheet> {
  @override
  Widget build(BuildContext context) {
    AppLocaleScope.of(context);
    final filters = ref.watch(productFiltersProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('m140'),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      ref.read(productFiltersProvider.notifier).state = filters
                          .clearFilters();
                    },
                    child: Text(tr('m533')),
                  ),
                ],
              ),
              Divider(),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Category filter
                    Text(
                      tr('m212'),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    categoriesAsync.when(
                      data: (categories) {
                        return Wrap(
                          spacing: 8,
                          children: [
                            FilterChip(
                              label: Text(tr('m53')),
                              selected: filters.categoryId == null,
                              onSelected: (selected) {
                                if (selected) {
                                  ref
                                      .read(productFiltersProvider.notifier)
                                      .state = filters.copyWith(
                                    categoryId: null,
                                  );
                                }
                              },
                            ),
                            ...categories.map((category) {
                              return FilterChip(
                                label: Text(category.name),
                                selected: filters.categoryId == category.id,
                                onSelected: (selected) {
                                  ref
                                      .read(productFiltersProvider.notifier)
                                      .state = filters.copyWith(
                                    categoryId: selected ? category.id : null,
                                  );
                                },
                              );
                            }),
                          ],
                        );
                      },
                      loading: () => CircularProgressIndicator(),
                      error: (_, __) => Text(tr('m213')),
                    ),
                    SizedBox(height: 16),

                    // Stock status filter
                    Text(
                      tr('m346'),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: Text(tr('m53')),
                          selected:
                              filters.stockStatus == null ||
                              filters.stockStatus == 'all',
                          onSelected: (selected) {
                            ref.read(productFiltersProvider.notifier).state =
                                filters.copyWith(stockStatus: 'all');
                          },
                        ),
                        FilterChip(
                          label: Text(tr('m270')),
                          selected: filters.stockStatus == 'mavjud',
                          onSelected: (selected) {
                            ref
                                .read(productFiltersProvider.notifier)
                                .state = filters.copyWith(
                              stockStatus: selected ? 'mavjud' : 'all',
                            );
                          },
                        ),
                        FilterChip(
                          label: Text(tr('m195')),
                          selected: filters.stockStatus == 'kam_qolgan',
                          onSelected: (selected) {
                            ref
                                .read(productFiltersProvider.notifier)
                                .state = filters.copyWith(
                              stockStatus: selected ? 'kam_qolgan' : 'all',
                            );
                          },
                        ),
                        FilterChip(
                          label: Text(tr('m557')),
                          selected: filters.stockStatus == 'tugagan',
                          onSelected: (selected) {
                            ref
                                .read(productFiltersProvider.notifier)
                                .state = filters.copyWith(
                              stockStatus: selected ? 'tugagan' : 'all',
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Sort by
                    Text(
                      tr('m428'),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(tr('m310')),
                          selected: filters.sortBy == 'name',
                          onSelected: (selected) {
                            ref.read(productFiltersProvider.notifier).state =
                                filters.copyWith(sortBy: 'name');
                          },
                        ),
                        ChoiceChip(
                          label: Text(tr('m471')),
                          selected: filters.sortBy == 'sale_price',
                          onSelected: (selected) {
                            ref.read(productFiltersProvider.notifier).state =
                                filters.copyWith(sortBy: 'sale_price');
                          },
                        ),
                        ChoiceChip(
                          label: Text(tr('m396')),
                          selected: filters.sortBy == 'stock',
                          onSelected: (selected) {
                            ref.read(productFiltersProvider.notifier).state =
                                filters.copyWith(sortBy: 'stock');
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    SwitchListTile(
                      title: Text(tr('m316')),
                      value: filters.sortAscending,
                      onChanged: (value) {
                        ref.read(productFiltersProvider.notifier).state =
                            filters.copyWith(sortAscending: value);
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(tr('m392')),
              ),
            ],
          ),
        );
      },
    );
  }
}
