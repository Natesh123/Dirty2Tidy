import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class MostViewedCategoryView extends StatelessWidget {
  const MostViewedCategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceController>(builder: (serviceController) {
      
      if (serviceController.popularServiceList == null || serviceController.popularServiceList!.isEmpty) {
        return const SizedBox();
      }

      // Extract unique categories from popular services
      List<ServiceCategory> mostViewedCategories = [];
      Set<String> categoryIds = {};

      for (var service in serviceController.popularServiceList!) {
        if (service.category != null && !categoryIds.contains(service.category!.id)) {
          mostViewedCategories.add(service.category!);
          categoryIds.add(service.category!.id!);
        }
      }

      if (mostViewedCategories.isEmpty) {
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
                  title: 'most_viewed_categories'.tr,
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveHelper.isDesktop(context) ? 4 : ResponsiveHelper.isTab(context) ? 4 : 3,
                    crossAxisSpacing: Dimensions.paddingSizeSmall,
                    mainAxisSpacing: Dimensions.paddingSizeSmall,
                    childAspectRatio: ResponsiveHelper.isDesktop(context) ? 1.3 : MediaQuery.of(context).size.width < 400 ? 1.0 : 1.1,
                  ),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mostViewedCategories.length > 6 ? 6 : mostViewedCategories.length, // Limit to 6 for home page
                  itemBuilder: (context, index) {
                    final category = mostViewedCategories[index];
                    return TextHover(builder: (hovered) {
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
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
