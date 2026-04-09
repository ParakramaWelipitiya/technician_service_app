import 'package:flutter/material.dart';

class TechnicianReviewsScreen extends StatelessWidget {
  final String techName;

  const TechnicianReviewsScreen({super.key, required this.techName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reviews for $techName"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ReviewCard(
            reviewerName: "Sample review 1",
            reviewText: "Excellent work. Showed up exactly on time, knew exactly what to do, and completed the repair efficiently.",
            rating: 5,
            date: "2 days ago",
          ),
          ReviewCard(
            reviewerName: "Sample review 2",
            reviewText: "Very polite and cleaned up the workspace after the plumbing was fixed. Highly recommend!",
            rating: 5,
            date: "1 week ago",
          ),
          ReviewCard(
            reviewerName: "Sample review 3",
            reviewText: "Good job overall, but arrived 15 minutes late.",
            rating: 4,
            date: "2 weeks ago",
          ),
        ],
      ),
    );
  }
}

class ReviewCard extends StatefulWidget {
  final String reviewerName;
  final String reviewText;
  final int rating;
  final String date;

  const ReviewCard({
    super.key,
    required this.reviewerName,
    required this.reviewText,
    required this.rating,
    required this.date,
  });

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool _isLiked = false;
  int _likeCount = 12;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 0,
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.reviewerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(widget.date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  index < widget.rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(widget.reviewText, style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
            const SizedBox(height: 12),
            
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isLiked = !_isLiked;
                      _isLiked ? _likeCount++ : _likeCount--;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        _isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                        size: 16,
                        color: _isLiked ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Helpful ($_likeCount)",
                        style: TextStyle(
                          color: _isLiked ? Colors.blue : Colors.grey,
                          fontWeight: _isLiked ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}