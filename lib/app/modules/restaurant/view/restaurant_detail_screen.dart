import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_delivery/app/common/const/colors.dart';
import 'package:flutter_delivery/app/common/const/data.dart';
import 'package:flutter_delivery/app/common/dio/dio.dart';
import 'package:flutter_delivery/app/common/layout/default_layout.dart';
import 'package:flutter_delivery/app/common/model/cursor_pagination_model.dart';
import 'package:flutter_delivery/app/common/utils/pagination_utils.dart';
import 'package:flutter_delivery/app/modules/product/component/product_card.dart';
import 'package:flutter_delivery/app/modules/rating/component/rating_card.dart';
import 'package:flutter_delivery/app/modules/rating/model/rating_model.dart';
import 'package:flutter_delivery/app/modules/restaurant/component/restaurant_card.dart';
import 'package:flutter_delivery/app/modules/restaurant/model/restaurant_detail_model.dart';
import 'package:flutter_delivery/app/modules/restaurant/model/restaurant_model.dart';
import 'package:flutter_delivery/app/modules/restaurant/provider/restaurant_provider.dart';
import 'package:flutter_delivery/app/modules/restaurant/provider/restaurant_rating_provider.dart';
import 'package:flutter_delivery/app/modules/restaurant/repository/restaurant_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletons/skeletons.dart';

class RestaurantDetailScreen extends ConsumerStatefulWidget {
  final String id;
  static String get routeName => 'restaurantDetail';
  const RestaurantDetailScreen({Key? key, required this.id}) : super(key: key);

  @override
  ConsumerState<RestaurantDetailScreen> createState() =>
      _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends ConsumerState<RestaurantDetailScreen> {

  final ScrollController controller = ScrollController();
  @override
  void initState() {
    super.initState();
    ref.read(restaurantProvider.notifier).getDetail(id: widget.id);

    controller.addListener(listener);
  }

  void listener(){
    PaginationUtils.paginate(controller: controller, provider: ref.read(restaurantRatingProvider(widget.id).notifier));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(restaurantDetailProvider(widget.id));
    final ratingState = ref.watch(restaurantRatingProvider(widget.id));
    print(ratingState);

    if (state == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return DefaultLayout(
      title: '불타는 떡볶이',
      child: CustomScrollView(
        controller: controller,
        slivers: [
          renderTop(model: state),
          if (state is! RestaurantDetailModel) renderLoading(),
          if (state is RestaurantDetailModel) renderLabel(),
          if (state is RestaurantDetailModel)
            renderProducts(products: state.products),
          if (ratingState is CursorPagination<RatingModel>)
            renderRatings(models: ratingState.data),
        ],
      ),
    );
  }

  SliverPadding renderRatings({required List<RatingModel> models}) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: RatingCard.fromModel(
              model: models[index],
            ),
          ),
          childCount: models.length,
        ),
      ),
    );
  }

  SliverToBoxAdapter renderTop({required RestaurantModel model}) {
    return SliverToBoxAdapter(
      child: RestaurantCard.fromModel(
        model: model,
        isDetail: true,
      ),
    );
  }

  SliverPadding renderLabel() {
    return const SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: Text(
          '메뉴',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  SliverPadding renderProducts(
      {required List<RestaurantProductModel> products}) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ProductCard.fromRestaurantProductModel(model: products[index]),
          ),
          childCount: products.length,
        ),
      ),
    );
  }

  SliverPadding renderLoading() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          List.generate(
            3,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: SkeletonParagraph(
                style: const SkeletonParagraphStyle(
                  lines: 5,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
