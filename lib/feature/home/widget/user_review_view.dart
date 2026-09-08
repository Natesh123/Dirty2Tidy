import 'package:demandium/feature/web_landing/controller/web_landing_controller.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';

class UserReviewView extends StatelessWidget {
  const UserReviewView({super.key});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> staticReviews = [
      {
        "name": "Abhishek Sharma",
        "rating": 5,
        "comment": "Excellent service! The professional was very skilled and completed the task on time. Highly recommended.",
        "image": "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?ixlib=rb-4.1.2&auto=format&fit=crop&w=100&q=80"
      },
      {
        "name": "Priya Patel",
        "rating": 4,
        "comment": "Very satisfied with the plumbing fix. A bit expensive but worth the quality and peace of mind.",
        "image": "https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-4.1.2&auto=format&fit=crop&w=100&q=80"
      },
      {
        "name": "David Wilson",
        "rating": 5,
        "comment": "Amazing experience with the interior cleaning. My house looks brand new! Definitely using this service again.",
        "image": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?ixlib=rb-4.1.2&auto=format&fit=crop&w=100&q=80"
      },
      {
        "name": "Emma Brown",
        "rating": 5,
        "comment": "Prompt and efficient AC repair. The technician explained everything clearly. Great value for money.",
        "image": "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-4.1.2&auto=format&fit=crop&w=100&q=80"
      },
      {
        "name": "Liam Johnson",
        "rating": 4,
        "comment": "Professional electrician. Fixed the wiring issues quickly. Wish the appointment was earlier in the day.",
        "image": "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-4.1.2&auto=format&fit=crop&w=100&q=80"
      },
      {
        "name": "Sophie Garcia",
        "rating": 5,
        "comment": "The massage therapist was incredible. Very relaxing session. Perfect for stress relief after a long week.",
        "image": "https://images.unsplash.com/photo-1544005313-94ddf0286df2?ixlib=rb-4.1.2&auto=format&fit=crop&w=100&q=80"
      },
      {
        "name": "Noah Martinez",
        "rating": 5,
        "comment": "Excellent pest control service. Very thorough and informative. Haven't seen a single bug since the treatment.",
        "image": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-4.1.2&auto=format&fit=crop&w=100&q=80"
      },
      {
        "name": "Olivia Taylor",
        "rating": 4,
        "comment": "Good experience with the carpet cleaning. Most stains were removed. Professional service.",
        "image": "https://images.unsplash.com/photo-1487412720507-e7ab37603c6f?ixlib=rb-4.1.2&auto=format&fit=crop&w=100&q=80"
      },
      {
        "name": "James Anderson",
        "rating": 5,
        "comment": "Professional painting service. The finish is perfect and they cleaned up everything afterwards. Very happy.",
        "image": "https://images.unsplash.com/photo-1552058544-f2b08422138a?ixlib=rb-4.1.2&auto=format&fit=crop&w=100&q=80"
      },
      {
        "name": "Isabella White",
        "rating": 5,
        "comment": "Reliable and trustful handyman service. Helped with multiple small repairs around the house. Highly recommend.",
        "image": "https://images.unsplash.com/photo-1534528741775-53994a69daeb?ixlib=rb-4.1.2&auto=format&fit=crop&w=100&q=80"
      }
    ];

    return GetBuilder<WebLandingController>(
      // initState: (state) {
      //   Get.find<WebLandingController>().getWebLandingContent();
      // },
      builder: (webLandingController) {
        bool hasDynamicReviews = webLandingController.webLandingContent?.testimonial != null &&
            webLandingController.webLandingContent!.testimonial!.isNotEmpty;

        int itemCount = hasDynamicReviews 
            ? webLandingController.webLandingContent!.testimonial!.length 
            : staticReviews.length;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          color: Theme.of(context).cardColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Text(
                  "Most Trusted Cleaning Services Across Australia – 45,812+ Families".tr,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              CarouselSlider.builder(
                itemCount: itemCount,
                itemBuilder: (context, index, realIndex) {
                  String name, comment, image;
                  double rating;

                  if (hasDynamicReviews) {
                    var testimonial = webLandingController.webLandingContent!.testimonial![index];
                    name = testimonial.name ?? "";
                    comment = testimonial.review ?? "";
                    image = testimonial.imageFullPath ?? "";
                    rating = 5.0; // Testimonials usually don't have a star rating in the model, defaulting to 5
                  } else {
                    name = staticReviews[index]["name"];
                    comment = staticReviews[index]["comment"];
                    image = staticReviews[index]["image"];
                    rating = staticReviews[index]["rating"].toDouble();
                  }

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    width: 280,
                    decoration: BoxDecoration(
                      color: Theme.of(context).hoverColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Theme.of(context).primaryColor.withValues(alpha: 0.1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: CustomImage(
                                  image: image,
                                  height: 40, width: 40,
                                  fit: BoxFit.cover,
                                  placeholder: Images.userPlaceHolder,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    RatingBar(rating: rating, size: 12),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: Text(
                              comment,
                              style: robotoRegular.copyWith(
                                fontSize: 13,
                                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                options: CarouselOptions(
                  height: 140,
                  viewportFraction: 0.8,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 3),
                  autoPlayAnimationDuration: const Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  disableCenter: true,
                  scrollDirection: Axis.horizontal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class RatingBar extends StatelessWidget {
  final double rating;
  final double size;
  const RatingBar({super.key, required this.rating, this.size = 15});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor() ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: size,
        );
      }),
    );
  }
}
