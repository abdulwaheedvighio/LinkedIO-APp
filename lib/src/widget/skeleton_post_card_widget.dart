import 'package:flutter/material.dart';
import 'package:card_loading/card_loading.dart';

class PostCardLoadingWidget extends StatelessWidget {
  const PostCardLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Profile row (DP + Name)
            Row(
              children: [
                const CardLoading(
                  height: 40,
                  width: 40,
                  borderRadius: BorderRadius.all(Radius.circular(100)),
                  margin: EdgeInsets.only(right: 10),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    CardLoading(
                      height: 10,
                      width: 120,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      margin: EdgeInsets.only(bottom: 6),
                    ),
                    CardLoading(
                      height: 10,
                      width: 80,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                  ],
                )
              ],
            ),

            const SizedBox(height: 12),

            /// 🔹 Post text placeholder
            const CardLoading(
              height: 12,
              width: double.infinity,
              borderRadius: BorderRadius.all(Radius.circular(8)),
              margin: EdgeInsets.only(bottom: 8),
            ),
            const CardLoading(
              height: 12,
              width: 200,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),

            const SizedBox(height: 12),

            /// 🔹 Post image placeholder
            const CardLoading(
              height: 180,
              width: double.infinity,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),

            const SizedBox(height: 12),

            /// 🔹 Like / Comment / Share Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                CardLoading(
                  height: 20,
                  width: 60,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                CardLoading(
                  height: 20,
                  width: 60,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                CardLoading(
                  height: 20,
                  width: 60,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
