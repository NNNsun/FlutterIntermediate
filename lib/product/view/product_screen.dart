import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:infren/common/component/pagination_list_view.dart';
import 'package:infren/product/component/product_card.dart';
import 'package:infren/product/model/product_model.dart';
import 'package:infren/product/provider/product_provider.dart';
import 'package:infren/restaurant/view/restaurant_detail__screen.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PaginationListView<ProductModel>(
      provider: productProvider,
      itemBuilder: <ProductModel>(_, index, model) {
        return GestureDetector(
            onTap: () {
              context.goNamed(RestaurantDetailScreen.routeName, params: {
                'rid': model.restaurant.id,
              });
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      RestaurantDetailScreen(id: model.restaurant.id),
                ),
              );
            },
            child: ProductCard.fromProductModel(model: model));
      },
    );
  }
}
