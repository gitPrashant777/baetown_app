import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';

class QuantitySelector extends StatefulWidget {
  final ProductModel product;
  final int initialQuantity;
  final Function(int) onQuantityChanged;

  const QuantitySelector({
    super.key,
    required this.product,
    this.initialQuantity = 1,
    required this.onQuantityChanged,
  });

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int currentQuantity;
  int get maxAllowedQuantity => widget.product.getMaxAllowedQuantity();

  @override
  void initState() {
    super.initState();
    currentQuantity = widget.initialQuantity;
    
    // Ensure initial quantity doesn't exceed allowed maximum
    if (currentQuantity > maxAllowedQuantity) {
      currentQuantity = maxAllowedQuantity;
      widget.onQuantityChanged(currentQuantity);
    }
  }

  void _decreaseQuantity() {
    if (currentQuantity > 1) {
      setState(() {
        currentQuantity--;
      });
      widget.onQuantityChanged(currentQuantity);
    }
  }

  void _increaseQuantity() {
    if (currentQuantity < maxAllowedQuantity) {
      setState(() {
        currentQuantity++;
      });
      widget.onQuantityChanged(currentQuantity);
    } else {
      // Show message when limit is reached
      String limitMessage;
      if (widget.product.stockQuantity < widget.product.maxOrderQuantity) {
        limitMessage = "Only ${widget.product.stockQuantity} items available in stock";
      } else {
        limitMessage = "Maximum ${widget.product.maxOrderQuantity} items allowed per order";
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(limitMessage),
          backgroundColor: warningColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // If product is out of stock, show disabled state
    if (widget.product.isOutOfStock || maxAllowedQuantity == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: errorColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: errorColor.withOpacity(0.3)),
        ),
        child: const Text(
          "Out of Stock",
          style: TextStyle(
            color: errorColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: currentQuantity > 1 ? _decreaseQuantity : null,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.remove,
                  size: 20,
                  color: currentQuantity > 1 
                      ? Theme.of(context).iconTheme.color 
                      : Theme.of(context).disabledColor,
                ),
              ),
            ),
          ),
          
          // Quantity display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Text(
              currentQuantity.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          
          // Increase button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: currentQuantity < maxAllowedQuantity ? _increaseQuantity : null,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.add,
                  size: 20,
                  color: currentQuantity < maxAllowedQuantity
                      ? Theme.of(context).iconTheme.color 
                      : Theme.of(context).disabledColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
