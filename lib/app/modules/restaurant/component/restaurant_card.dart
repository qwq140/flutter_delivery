import 'package:flutter/material.dart';
import 'package:flutter_delivery/app/common/const/colors.dart';

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    Key? key,
    required this.image,
    required this.name,
    required this.tags,
    required this.ratingCount,
    required this.deliveryTime,
    required this.deliveryFee,
    required this.rating,
  }) : super(key: key);

  // 이미지
  final Widget image;

  // 레스토랑 이름
  final String name;

  // 태그
  final List<String> tags;

  // 평점 갯수
  final int ratingCount;

  // 배송 시간
  final int deliveryTime;

  // 배송 비용
  final int deliveryFee;

  // 평점
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: image,
        ),
        const SizedBox(height: 16.0),
        Text(
          name,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          tags.join(' · '),
          style: TextStyle(
            color: BODY_TEXT_COLOR,
            fontSize: 14,
          ),
        ),
        Row(
          children: [
            _IconText(
              icon: Icons.star,
              label: rating.toString(),
            ),
            renderDot(),
            _IconText(
              icon: Icons.receipt,
              label: ratingCount.toString(),
            ),
            renderDot(),
            _IconText(
              icon: Icons.timelapse,
              label: '$deliveryTime 분',
            ),
            renderDot(),
            _IconText(
              icon: Icons.monetization_on,
              label: deliveryFee == 0 ? '무료' : deliveryFee.toString(),
            ),
          ],
        )
      ],
    );
  }

  Widget renderDot() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '·',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _IconText extends StatelessWidget {
  const _IconText({Key? key, required this.icon, required this.label})
      : super(key: key);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: PRIMARY_COLOR,
          size: 14,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
