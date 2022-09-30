import 'package:flutter/material.dart';
import 'package:flutter_delivery/app/modules/product/provider/product_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductScreen extends ConsumerStatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProductScreen> createState() => _ProductTabState();
}

class _ProductTabState extends ConsumerState<ProductScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productProvider);


    return Container();
  }
}