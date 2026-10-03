
import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../models/category.dart';
import '../../models/plat.dart';
import '../../services/cart_service.dart';
import '../../services/menu_service.dart';
import '../cart/cart_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({
    super.key,
  });

  @override
  State<MenuScreen> createState() =>
      _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final MenuService _menuService = MenuService();

  final CartService _cartService =
      CartService.instance;

  List<Category> _categories = [];

  bool _loading = true;

  String? _error;

  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();

    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final categories =
          await _menuService.getMenu();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error =
            'Yon erè rive pandan n ap chaje menu a.';
        _loading = false;
      });
    }
  }

  List<Category> get _visibleCategories {
    if (_selectedCategoryId == null) {
      return _categories;
    }

    return _categories
        .where(
          (category) =>
              category.id ==
              _selectedCategoryId,
        )
        .toList();
  }

  void _addToCart(Plat plat) {
    setState(() {
      _cartService.add(plat);
    });

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${plat.nom} ajoute nan panier 🛒',
        ),
        duration:
            const Duration(seconds: 1),
        action: SnackBarAction(
          label: 'WÈ PANIER',
          onPressed: _openCart,
        ),
      ),
    );
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const CartScreen(),
      ),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Menu Resto Kay-Y',
        ),

        centerTitle: true,

        actions: [
          IconButton(
            onPressed: _loadMenu,
            tooltip: 'Rafrechi',
            icon: const Icon(
              Icons.refresh,
            ),
          ),

          _buildCartButton(),
        ],
      ),

      body: _buildBody(),
    );
  }

  Widget _buildCartButton() {
    final totalItems =
        _cartService.totalItems;

    return Padding(
      padding:
          const EdgeInsets.only(right: 8),

      child: Stack(
        clipBehavior: Clip.none,

        children: [
          IconButton(
            onPressed: _openCart,
            tooltip: 'Panier',
            icon: const Icon(
              Icons.shopping_cart_outlined,
            ),
          ),

          if (totalItems > 0)
            Positioned(
              right: 1,
              top: 3,

              child: Container(
                constraints:
                    const BoxConstraints(
                  minWidth: 19,
                  minHeight: 19,
                ),

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 4,
                ),

                decoration: BoxDecoration(
                  color:
                      const Color(0xFFE91E63),

                  borderRadius:
                      BorderRadius.circular(20),

                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                ),

                child: Text(
                  totalItems > 99
                      ? '99+'
                      : '$totalItems',

                  textAlign:
                      TextAlign.center,

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return _buildError();
    }

    if (_categories.isEmpty) {
      return const Center(
        child: Text(
          'Pa gen plat disponib pou kounye a.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMenu,

      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(),
          ),

          SliverToBoxAdapter(
            child: _buildCategoryFilter(),
          ),

          ..._visibleCategories.map(
            (category) =>
                _buildCategorySection(
              category,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        10,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            'Bonjou 👋🏽',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Kisa ou anvi manje jodi a?',
            style: TextStyle(
              fontSize: 25,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Dekouvri bon gou plat Resto Kay-Y yo 🍽️',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 55,

      child: ListView(
        scrollDirection:
            Axis.horizontal,

        padding:
            const EdgeInsets.symmetric(
          horizontal: 20,
        ),

        children: [
          _categoryChip(
            label: 'Tout',
            selected:
                _selectedCategoryId == null,

            onTap: () {
              setState(() {
                _selectedCategoryId =
                    null;
              });
            },
          ),

          ..._categories.map(
            (category) =>
                _categoryChip(
              label: category.nom,

              selected:
                  _selectedCategoryId ==
                      category.id,

              onTap: () {
                setState(() {
                  _selectedCategoryId =
                      category.id;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        right: 10,
      ),

      child: ChoiceChip(
        label: Text(label),

        selected: selected,

        onSelected: (_) => onTap(),

        labelStyle: TextStyle(
          fontWeight: selected
              ? FontWeight.bold
              : FontWeight.normal,

          color: selected
              ? Colors.white
              : Colors.black87,
        ),

        selectedColor:
            const Color(0xFF008C95),

        backgroundColor:
            Colors.grey.shade100,

        side: BorderSide.none,
      ),
    );
  }

  Widget _buildCategorySection(
    Category category,
  ) {
    if (category.plats.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox.shrink(),
      );
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding:
            const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          0,
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [
                Text(
                  category.nom,

                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                Text(
                  '${category.plats.length} plat(s)',

                  style: TextStyle(
                    fontSize: 13,
                    color:
                        Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ...category.plats.map(
              (plat) =>
                  _buildPlatCard(plat),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlatCard(Plat plat) {
    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),

      elevation: 2,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),

      clipBehavior:
          Clip.antiAlias,

      child: InkWell(
        onTap: () {
          debugPrint(
            'Plat chwazi: ${plat.nom}',
          );
        },

        child: Padding(
          padding:
              const EdgeInsets.all(12),

          child: Row(
            children: [
              _buildPlatImage(plat),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    if (plat.isPopulaire)
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),

                        decoration:
                            BoxDecoration(
                          color: Colors
                              .amber
                              .shade100,

                          borderRadius:
                              BorderRadius
                                  .circular(
                            8,
                          ),
                        ),

                        child:
                            const Text(
                          '⭐ Popilè',

                          style:
                              TextStyle(
                            fontSize: 11,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),

                    if (plat.isPopulaire)
                      const SizedBox(
                        height: 6,
                      ),

                    Text(
                      plat.nom,

                      maxLines: 2,

                      overflow:
                          TextOverflow
                              .ellipsis,

                      style:
                          const TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),

                    if (plat.description !=
                            null &&
                        plat.description!
                            .isNotEmpty)
                      Padding(
                        padding:
                            const EdgeInsets
                                .only(
                          top: 5,
                        ),

                        child: Text(
                          plat.description!,

                          maxLines: 2,

                          overflow:
                              TextOverflow
                                  .ellipsis,

                          style: TextStyle(
                            fontSize: 13,
                            color: Colors
                                .grey
                                .shade600,
                          ),
                        ),
                      ),

                    const SizedBox(
                      height: 8,
                    ),

                    Row(
                      children: [
                        if (plat.prixPromo !=
                            null) ...[
                          Text(
                            '${plat.prix.toStringAsFixed(0)} HTG',

                            style:
                                TextStyle(
                              fontSize: 12,
                              color: Colors
                                  .grey
                                  .shade500,

                              decoration:
                                  TextDecoration
                                      .lineThrough,
                            ),
                          ),

                          const SizedBox(
                            width: 7,
                          ),
                        ],

                        Text(
                          '${plat.prixEffectif.toStringAsFixed(0)} HTG',

                          style:
                              const TextStyle(
                            fontSize: 16,
                            fontWeight:
                                FontWeight
                                    .bold,
                            color:
                                Color(
                              0xFFE91E63,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Container(
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFF008C95,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),

                child: IconButton(
                  onPressed: () {
                    _addToCart(plat);
                  },

                  tooltip:
                      'Ajoute nan panier',

                  icon: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatImage(Plat plat) {
    print('================================');
    print('PLAT: ${plat.nom}');
    print('IMAGE DB: ${plat.image}');
    print('IMAGE URL: ${plat.imageUrl}');
    print('================================');

    if (plat.imageUrl == null ||
        plat.imageUrl!.isEmpty) {
      return Container(
        width: 105,
        height: 105,

        decoration:
            BoxDecoration(
          color:
              Colors.grey.shade100,

          borderRadius:
              BorderRadius.circular(15),
        ),

        child: Icon(
          Icons.restaurant,
          size: 40,
          color:
              Colors.grey.shade400,
        ),
      );
    }

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(15),

      child: Image.network(
        plat.imageUrl!,

        width: 105,
        height: 105,

        fit: BoxFit.cover,

        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          print(
            '❌ IMAGE ERROR: ${plat.imageUrl}',
          );

          print(
            '❌ ERROR: $error',
          );

          print(
            '❌ STACK: $stackTrace',
          );

          return Container(
            width: 105,
            height: 105,

            color:
                Colors.grey.shade100,

            child: Icon(
              Icons.broken_image,
              color:
                  Colors.grey.shade400,
            ),
          );
        },

        loadingBuilder: (
          context,
          child,
          loadingProgress,
        ) {
          if (loadingProgress ==
              null) {
            print(
              '✅ IMAGE LOADED: ${plat.imageUrl}',
            );

            return child;
          }

          return Container(
            width: 105,
            height: 105,

            color:
                Colors.grey.shade100,

            child:
                const Center(
              child:
                  CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),

        child: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [
            Icon(
              Icons
                  .wifi_off_rounded,

              size: 60,

              color:
                  Colors.grey.shade500,
            ),

            const SizedBox(
              height: 15,
            ),

            const Text(
              'Nou pa kapab chaje menu a.',

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              _error ?? '',

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                color:
                    Colors.grey.shade600,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton.icon(
              onPressed:
                  _loadMenu,

              icon: const Icon(
                Icons.refresh,
              ),

              label:
                  const Text(
                'Eseye ankò',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
