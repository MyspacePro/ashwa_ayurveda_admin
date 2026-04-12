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

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ReviewProvider>().listenReviews(widget.productId);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // =========================
  // 🔥 SUBMIT REVIEW
  // =========================
  Future<void> _submitReview() async {
    if (controller.text.trim().isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      await context.read<ReviewProvider>().addReview(
            userId: widget.userId,
            productId: widget.productId,
            rating: rating,
            review: controller.text.trim(),
          );

      controller.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review added")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // =========================
  // 🧱 UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reviews")),
      body: Column(
        children: [
          _buildAddReview(),

          Expanded(
            child: Consumer<ReviewProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.reviews.isEmpty) {
                  return const Center(child: Text("No reviews yet"));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    provider.listenReviews(widget.productId);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: provider.reviews.length,
                    itemBuilder: (context, index) {
                      final review = provider.reviews[index];
                      return _reviewCard(review, provider);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // ✍️ ADD REVIEW
  // =========================
  Widget _buildAddReview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey)),
      ),
      child: Column(
        children: [
          /// ⭐ RATING
          Row(
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                ),
                onPressed: _isSubmitting
                    ? null
                    : () {
                        setState(() => rating = index + 1);
                      },
              );
            }),
          ),

          /// ✍️ INPUT
          TextField(
            controller: controller,
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              hintText: "Write your review...",
              border: OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 8),

          /// 🚀 BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Submit Review"),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // 🧾 REVIEW CARD
  // =========================
  Widget _reviewCard(review, ReviewProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ⭐ RATING
          Row(
            children: List.generate(
              5,
              (i) => Icon(
                i < review.rating ? Icons.star : Icons.star_border,
                color: Colors.orange,
                size: 16,
              ),
            ),
          ),

          const SizedBox(height: 6),

          /// 💬 REVIEW TEXT
          Text(
            review.review,
            style: const TextStyle(color: Colors.white),
          ),

          const SizedBox(height: 6),

          /// 📅 DATE
          Text(
            review.createdAt.toDate().toString().substring(0, 16),
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white54,
            ),
          ),

          /// ❌ DELETE
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteReview(review.id, provider),
            ),
          )
        ],
      ),
    );
  }

  // =========================
  // ❌ DELETE
  // =========================
  Future<void> _deleteReview(
    String id,
    ReviewProvider provider,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Review"),
        content: const Text("Are you sure?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      provider.deleteReview(id);
    }
  }
}