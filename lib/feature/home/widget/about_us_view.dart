import 'package:demandium/utils/core_export.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

class AboutUsView extends StatelessWidget {
  const AboutUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HtmlViewController>(
      builder: (htmlViewController) {
        String? data = htmlViewController.pagesContent?.aboutUs?.liveValues;
        
        // If content is null or empty, don't show anything
        if (data == null || data.isEmpty || data == "null") {
          return const SizedBox();
        }

        return Container(
          width: Dimensions.webMaxWidth,
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
          margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
            boxShadow: Get.isDarkMode ? null : [BoxShadow(color: Colors.grey[200]!, blurRadius: 5, spreadRadius: 1)],
          ),
          child: ResponsiveHelper.isMobile(context) ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'about_us'.tr,
                style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),

              if(htmlViewController.pagesContent?.images?.aboutUs != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: CustomImage(
                      image: htmlViewController.pagesContent?.images?.aboutUs ?? "",
                      height: 150, width: double.infinity, fit: BoxFit.cover,
                    ),
                  ),
                ),

              Html(
                data: data,
                style: {
                  "p": Style(
                    fontSize: FontSize.medium,
                    color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.7),
                  ),
                },
              ),
            ],
          ) : Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'about_us'.tr,
                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeExtraLarge, color: Theme.of(context).primaryColor),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    Html(
                      data: data,
                      style: {
                        "p": Style(
                          fontSize: FontSize.large,
                          color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.7),
                        ),
                      },
                    ),
                  ],
                ),
              ),
              if(htmlViewController.pagesContent?.images?.aboutUs != null) ...[
                const SizedBox(width: Dimensions.paddingSizeExtraLarge),
                Expanded(
                  flex: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    child: CustomImage(
                      image: htmlViewController.pagesContent?.images?.aboutUs ?? "",
                      height: 350, width: double.infinity, fit: BoxFit.cover,
                    ),
                  ),
                ),
              ]
            ],
          ),

        );
      },
    );
  }
}
