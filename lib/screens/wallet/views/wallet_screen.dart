import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';

import 'components/wallet_balance_card.dart';
import 'components/wallet_history_card.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Wallet"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(vertical: defaultPadding),
                sliver: SliverToBoxAdapter(
                  child: WalletBalanceCard(
                    balance: 384.90,
                    onTabChargeBalance: () {},
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(top: defaultPadding / 2),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    "Wallet history",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Padding(
                    padding: const EdgeInsets.only(top: defaultPadding),
                    child: WalletHistoryCard(
                      isReturn: index == 1,
                      date: "JUN 12, 2020",
                      amount: 10707, // 129 * 83
                      products: [
                        ProductModel(
                          image: productDemoImg1,
                          title: "Diamond Engagement Ring",
                          brandName: "BAETOWN",
                          price: 44820, // 540 * 83
                          priceAfetDiscount: 34860, // 420 * 83
                          dicountpercent: 20,
                        ),
                        ProductModel(
                          image: productDemoImg4,
                          title: "Gold Tennis Bracelet",
                          brandName: "BAETOWN",
                          price: 66400, // 800 * 83
                        ),
                      ],
                    ),
                  ),
                  childCount: 4,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
