import 'package:dio/dio.dart' hide Headers;
import 'package:flutter_delivery/app/common/const/data.dart';
import 'package:flutter_delivery/app/common/dio/dio.dart';
import 'package:flutter_delivery/app/common/model/cursor_pagination_model.dart';
import 'package:flutter_delivery/app/common/model/pagination_params.dart';
import 'package:flutter_delivery/app/common/repository/base_pagination_repository.dart';
import 'package:flutter_delivery/app/modules/order/model/order_model.dart';
import 'package:flutter_delivery/app/modules/order/model/post_order_body.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/http.dart';


part 'order_repository.g.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final dio = ref.watch(dioProvider);

  return OrderRepository(dio, baseUrl: 'http://$ip/order');
});

@RestApi()
abstract class OrderRepository implements IBasePaginationRepository<OrderModel>{
  factory OrderRepository(Dio dio, {String baseUrl}) = _OrderRepository;


  @override
  @GET('/')
  @Headers({
    'accessToken' : 'true'
  })
  Future<CursorPagination<OrderModel>> paginate({@Queries() PaginationParams? paginationParams = const PaginationParams()});

  @POST('/')
  @Headers({
    'accessToken' : 'true',
  })
  Future<OrderModel> postOrder({@Body() required PostOrderBody body,});
}