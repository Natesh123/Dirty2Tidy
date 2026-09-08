import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class PopularCategoryView extends StatelessWidget {
  const PopularCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceController>(builder: (serviceController) {
      
      if (serviceController.trendingServiceList == null || serviceController.trendingServiceList!.isEmpty) {
        return const SizedBox();
      }

      // Extract unique categories from trending services
      List<ServiceCategory> popularCategories = [];
      Set<String> categoryIds = {};

      for (var service in serviceController.trendingServiceList!) {
        if (service.category != null && !categoryIds.contains(service.category!.id)) {
          popularCategories.add(service.category!);
          categoryIds.add(service.category!.id!);
        }
      }

      if (popularCategories.isEmpty) {
        return const SizedBox();
      }

      return Center(
        child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleWidget(
                  title: 'popular_categories'.tr,
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                SizedBox(
                  height: ResponsiveHelper.isDesktop(context) ? 190 : 130,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: popularCategories.length > 10 ? 10 : popularCategories.length,
                    itemBuilder: (context, index) {
                      final category = popularCategories[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                        child: SizedBox(
                          width: ResponsiveHelper.isDesktop(context) ? 250 : 110,
                          child: TextHover(builder: (hovered) {
                            return Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Get.find<ThemeController>().darkTheme
                                        ? Theme.of(context).cardColor
                                        : Theme.of(context).colorScheme.primary.withValues(alpha: hovered ? 0.1 : 0.06),
                                    borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(height: (ResponsiveHelper.isMobile(context) || (kIsWeb && hovered)) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeExtraSmall),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                                              child: CustomImage(
                                                image: category.imageFullPath ?? "",
                                                fit: BoxFit.fitHeight,
                                                height: double.infinity,
                                                width: double.infinity,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: (ResponsiveHelper.isMobile(context) || (kIsWeb && hovered)) ? Dimensions.paddingSizeExtraSmall : Dimensions.paddingSizeExtraSmall),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 2),
                                          child: Text(
                                            category.name ?? "",
                                            style: robotoRegular.copyWith(
                                              fontSize: Dimensions.fontSizeDefault,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue[900],
                                            ),
                                            maxLines: 2,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned.fill(child: RippleButton(onTap: () {
                                  Get.toNamed(RouteHelper.getCategoryServiceFormRoute(
                                    category.id!,
                                    category.name!,
                                    category.imageFullPath ?? "",
                                  ));
                                }))
                              ],
                            );
                          }),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
