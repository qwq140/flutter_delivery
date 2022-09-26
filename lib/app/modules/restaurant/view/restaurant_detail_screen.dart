import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_delivery/app/common/const/colors.dart';
import 'package:flutter_delivery/app/common/const/data.dart';
import 'package:flutter_delivery/app/common/layout/default_layout.dart';
import 'package:flutter_delivery/app/modules/product/component/product_card.dart';
import 'package:flutter_delivery/app/modules/restaurant/component/restaurant_card.dart';
import 'package:flutter_delivery/app/modules/restaurant/model/restaurant_detail_model.dart';

class RestaurantDetailScreen extends StatelessWidget {
  final String id;

  const RestaurantDetailScreen({Key? key, required this.id}) : super(key: key);

  Future<Map<String, dynamic>> getRestaurantDetail() async {
    final dio = Dio();

    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

    final resp = await dio.get(
      'http://$ip/restaurant/$id',
      options: Options(headers: {
        'authorization': 'Bearer $accessToken',
      }),
    );

    return resp.data;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultLayout(
      title: '불타는 떡볶이',
      child: FutureBuilder<Map<String, dynamic>>(
        future: getRestaurantDetail(),
        builder: (context, snapshot) {
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(color: PRIMARY_COLOR,),
            );
          }

          final item = RestaurantDetailModel.fromJson(snapshot.data!);

          return CustomScrollView(
            slivers: [
              renderTop(model: item),
              renderLabel(),
              renderProducts(products: item.products),
            ],
          );
        }
      ),
    );
  }

  SliverToBoxAdapter renderTop({required RestaurantDetailModel model}) {
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

  SliverPadding renderProducts({required List<RestaurantProductModel> products}) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ProductCard.fromModel(model: products[index]),
          ),
          childCount: products.length,
        ),
      ),
    );
  }
}
