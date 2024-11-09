import 'package:flutter/material.dart';
import 'package:loocator/pages/review_page.dart';

class InfoScreen extends StatefulWidget {
  final void Function()? onPressed;
  final int distance;
  final int time;
  final List<String> reviews;

  const InfoScreen({
    super.key,
    required this.onPressed,
    required this.distance,
    required this.time,
    required this.reviews,
  });

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  double rating = 2.75;
  int ratingAmount = 300;
  bool isAccesible = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: // Place's Name
            const Text(
          'Place Name',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColorLight,
      ),
      body: SizedBox(
        height: 500,
        width: double.infinity,
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Address
                  const Text(
                    'Address',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),

                  // Review Images
                  SizedBox(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        // TODO: Replace the widgets with [List.generate()] and generate
                        // a list of _imageContainers()
                        _imageContainer(),
                        const SizedBox(
                          width: 20,
                        ),
                        _imageContainer(),
                        const SizedBox(
                          width: 20,
                        ),
                        _imageContainer(),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Ratings
                          _ratingStarsWidget(),
                          const SizedBox(
                            width: 5,
                          ),
                          Text('$rating/5 ($ratingAmount)'),
                          const SizedBox(
                            width: 5,
                          ),
                          // Accessibilty Icon
                          isAccesible
                              ? const Icon(
                                  Icons.accessible_forward,
                                  size: 20,
                                )
                              : const SizedBox(),
                        ],
                      ),
                      // Distance
                      Text(
                        '${widget.distance} mi, ${widget.time} min',
                        textAlign: TextAlign.end,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),

                  // Reviews
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Reviews',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline),
                      ),
                      IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => ReviewPage(
                                reviews: widget.reviews,
                                rating: rating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.add)),
                    ],
                  ),
                  _reviewListWidget(),
                  const SizedBox(
                    height: 15,
                  ),

                  // Get Directions Button
                  ElevatedButton(
                      onPressed: widget.onPressed,
                      child: const Text('Get Directions')),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _imageContainer() {
    return Container(
      height: 200,
      width: 200,
      color: Colors.red,
    );
  }

  Widget _ratingStarsWidget() {
    return Row(
      children: List.generate(5, (index) => _buildStar(index)),
    );
  }

  Widget _buildStar(int index) {
    if (index >= rating) {
      return const Icon(
        Icons.star_border,
        color: Colors.amber,
      );
    } else if (index > rating - 1 && index < rating) {
      return const Icon(
        Icons.star_half,
        color: Colors.amber,
      );
    } else {
      return const Icon(
        Icons.star,
        color: Colors.amber,
      );
    }
  }

  Widget _reviewListWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(
          widget.reviews.length, (index) => _buildReviewList(index)),
    );
  }

  Widget _buildReviewList(int index) {
    return Text(
      widget.reviews[index],
      textAlign: TextAlign.start,
      style: TextStyle(fontSize: 12),
    );
  }
}
