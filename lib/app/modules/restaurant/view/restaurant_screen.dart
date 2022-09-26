import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_delivery/app/common/const/data.dart';
import 'package:flutter_delivery/app/modules/restaurant/component/restaurant_card.dart';
import 'package:flutter_delivery/app/modules/restaurant/model/restaurant_model.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({Key? key}) : super(key: key);

  Future<List> paginateRestaurant() async {
    final dio = Dio();

    final accessToken = await storage.read(key: ACCESS_TOKEN_KEY);

    final resp = await dio.get(
      'http://$ip/restaurant',
      options: Options(headers: {
        'authorization': 'Bearer $accessToken',
      }),
    );

    return resp.data['data'];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FutureBuilder<List>(
            future: paginateRestaurant(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Container();
              }
              return ListView.separated(
                itemBuilder: (context, index) {
                  final item = snapshot.data![index];

                  final pItem = RestaurantModel.fromJson(json: item);

                  return RestaurantCard(
                    image: Image.network(
                      'http://$ip${pItem.thumbUrl}',
                      fit: BoxFit.fill,
                    ),
                    name: pItem.name,
                    tags: pItem.tags,
                    ratingsCount: pItem.ratingsCount,
                    deliveryTime: pItem.deliveryTime,
                    deliveryFee: pItem.deliveryFee,
                    ratings: pItem.ratings,
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 16);
                },
                itemCount: snapshot.data!.length,
              );
            },
          ),
        ),
      ),
    );
  }
}
