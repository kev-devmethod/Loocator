import 'package:flutter/material.dart';
import 'package:loocator/widgets/star_rating.dart';

// ignore: must_be_immutable
class ReviewPage extends StatefulWidget {
  final List<String> reviews;
  double rating;

  ReviewPage({super.key, required this.reviews, required this.rating});

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  bool updatedRating = false;
  TextEditingController description = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add a Review',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).primaryColorLight,
      ),
      body: SizedBox(
        height: 500,
        width: double.infinity,
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 75,
                      ),
                      Text(
                        '${widget.rating}/5.0',
                        style: const TextStyle(fontSize: 16),
                      ),
                      StarRating(
                          rating: widget.rating,
                          onRatingChanged: (rating) => setState(() {
                                widget.rating = rating;
                                updatedRating = true;
                              })),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text('Rate this Restroom'),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: description,
                        decoration: const InputDecoration(
                          labelText: 'Write a Description (Optional)',
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ElevatedButton(
                          onPressed: (updatedRating)
                              ? () {
                                  setState(() =>
                                      widget.reviews.add(description.text));
                                }
                              : null,
                          child: const Text('Submit Review')),
                    ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
