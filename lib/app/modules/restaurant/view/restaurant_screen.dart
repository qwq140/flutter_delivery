import 'package:flutter/material.dart';
import 'package:flutter_delivery/app/common/components/pagination_list_view.dart';
import 'package:flutter_delivery/app/modules/restaurant/component/restaurant_card.dart';
import 'package:flutter_delivery/app/modules/restaurant/provider/restaurant_provider.dart';
import 'package:flutter_delivery/app/modules/restaurant/view/restaurant_detail_screen.dart';
import 'package:go_router/go_router.dart';


class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PaginationListView(
      provider: restaurantProvider,
      itemBuilder: <RestaurantModel>(_, index, model) {
        return GestureDetector(
          onTap: () {
            context.goNamed(RestaurantDetailScreen.routeName, params: {'rid' : model.id});
          },
          child: RestaurantCard.fromModel(model: model),
        );
      },
    );
  }
}
