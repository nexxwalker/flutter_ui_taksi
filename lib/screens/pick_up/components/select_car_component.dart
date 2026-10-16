import 'package:flutter/material.dart';

import '../../../config/pallete.dart';
import '../../../utils/currency.dart';
import '../../../widget/widget.dart';

class SelectCarComponent extends StatefulWidget {
  final List<Map<String, dynamic>> carList;
  final Function(double)? onSubmit;
  const SelectCarComponent({super.key, required this.carList, this.onSubmit});

  @override
  State<SelectCarComponent> createState() => _SelectCarComponentState();
}

class _SelectCarComponentState extends State<SelectCarComponent> {
  int activeIds = 0;
  double priceSelected = 0;
  void toggleItemById(int id) {
    setState(() {
      activeIds = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add another destination',
                style: TextStyle(color: Pallete.color5),
              ),
              Text(
                'Trip options',
                style: TextStyle(color: Pallete.color5),
              ),
            ],
          ),
        ),
        carListComponent(),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: AppButton(
            text: 'SUBMIT REQUEST',
            color: Pallete.color5,
            onTap: () {
              widget.onSubmit!(priceSelected);
            },
          ),
        ),
      ],
    );
  }

  Widget carListComponent() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.carList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = widget.carList[index];
          final isActive = activeIds == (item['id']); // Status aktif

          if (isActive) {
            priceSelected = item['price'];
          }

          EdgeInsets margin = EdgeInsets.only(
            left: index == 0 ? 20 : 0,
            right: index == widget.carList.length - 1 ? 20 : 0,
          );

          return GestureDetector(
              onTap: () => toggleItemById(item['id']),
              child: Container(
                margin: margin,
                child: cardComponent(
                  isActive: isActive,
                  imageCar: item['image'],
                  classes: item['classes'],
                  description: item['description'],
                  price: item['price'],
                  discount: item['discount'],
                ),
              ));
        },
      ),
    );
  }

  Stack cardComponent(
      {bool isActive = true,
      String imageCar = 'assets/car-white.png',
      String classes = 'Economy',
      String description = 'Fast and pocket friendly!',
      double price = 85000,
      double discount = 11.765}) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(top: 30, right: 5, left: 5),
          height: 121,
          width: 171,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFFE6B35).withOpacity(0.1)
                : const Color(0xFF21242A).withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Pallete.s),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFFFE6B35).withOpacity(0.3)
                        : Pallete.s,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: Pallete.s),
                  ),
                  child: isActive
                      ? const Icon(
                          Icons.check,
                          size: 12,
                        )
                      : Container(),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: Theme.of(context).textTheme.labelMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const SizedBox(height: 4),
              Text(
                discount != 0 ? formatToKES(price) : '',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(decoration: TextDecoration.lineThrough),
              ),
              const SizedBox(height: 4),
              Text(
                discount != 0
                    ? formatToKES(calculateDiscountedPrice(
                        originalPrice: price, discountPercentage: discount))
                    : formatToKES(price),
              ),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 20,
          child: Image.asset(
            imageCar,
            height: 72,
          ),
        ),
        Positioned(left: 100, child: Text(classes)),
      ],
    );
  }
}
