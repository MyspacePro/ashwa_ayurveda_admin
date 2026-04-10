import 'package:admin_control/providers/review_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReviewScreen extends StatefulWidget {
  final String productId;
  final String userId;

  const ReviewScreen({
    super.key,
    required this.productId,
    required this.userId,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int rating = 5;
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ReviewProvider>().listenReviews(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reviews")),
      body: Column(
        children: [
          /// ADD REVIEW BOX
          _buildAddReview(),

          /// LIST
          Expanded(
            child: Consumer<ReviewProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.reviews.isEmpty) {
                  return const Center(child: Text("No reviews yet"));
                }

                return ListView.builder(
                  itemCount: provider.reviews.length,
                  itemBuilder: (context, index) {
                    final review = provider.reviews[index];
                    return _buildReviewCard(review, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// ADD REVIEW UI
  Widget _buildAddReview() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                ),
                onPressed: () {
                  setState(() {
                    rating = index + 1;
                  });
                },
              );
            }),
          ),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Write your review...",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isEmpty) return;

              context.read<ReviewProvider>().addReview(
                    userId: widget.userId,
                    productId: widget.productId,
                    rating: rating,
                    review: controller.text.trim(),
                  );

              controller.clear();
            },
            child: const Text("Submit Review"),
          )
        ],
      ),
    );
  }

  /// REVIEW CARD
  Widget _buildReviewCard(review, ReviewProvider provider) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        title: Row(
          children: List.generate(
            5,
            (i) => Icon(
              i < review.rating ? Icons.star : Icons.star_border,
              color: Colors.orange,
              size: 18,
            ),
          ),
        ),
        subtitle: Text(review.review),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            provider.deleteReview(review.id);
          },
        ),
      ),
    );
  }
}
