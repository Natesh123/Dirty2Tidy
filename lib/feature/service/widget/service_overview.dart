import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';


import 'package:demandium/feature/service/widget/service_video_player.dart';
import 'package:demandium/feature/service/widget/service_variants_grid_widget.dart';

class ServiceOverview extends StatelessWidget {
  final Service service;
  const ServiceOverview({super.key, required this.service}) ;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: WebShadowWrap(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall,vertical: Dimensions.paddingSizeEight),
          width: Dimensions.webMaxWidth,
          constraints:  ResponsiveHelper.isDesktop(context) ? BoxConstraints(
            minHeight: !ResponsiveHelper.isDesktop(context) && Get.size.height < 600 ? Get.size.height : Get.size.height - 550,
          ) : null,
          child: Container(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
              color: ResponsiveHelper.isMobile(context) ?  Theme.of(context).cardColor:Colors.transparent,
              child: !ResponsiveHelper.isMobile(context)
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /*
                          HtmlWidget(
                            service.description ?? "",
                            textStyle: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeExtraLarge,
                            ),
                          ),
                          */
                           if(service.variationsAppFormat?.zoneWiseVariations != null && service.variationsAppFormat!.zoneWiseVariations!.isNotEmpty)
                             Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Center(
                                   child: Text(
                                     "${Get.find<SplashController>().configModel.content?.businessName ?? "App"}'s Professional Cleaning Services",
                                     style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.7)),
                                     textAlign: TextAlign.center,
                                   ),
                                 ),
                                 const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                                 Center(
                                   child: Text(
                                     "Get A Instant Quote or Book Online Now",
                                     style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5)),
                                     textAlign: TextAlign.center,
                                   ),
                                 ),
                                 const SizedBox(height: Dimensions.paddingSizeLarge),
                                 RichText(
                                   text: TextSpan(
                                     text: "Most of our clients who booked ",
                                     style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6)),
                                     children: [
                                       TextSpan(
                                         text: service.name ?? "",
                                         style: robotoBold.copyWith(color: Theme.of(context).primaryColor),
                                       ),
                                       const TextSpan(text: " also add:"),
                                     ],
                                   ),
                                 ),
                                 const SizedBox(height: Dimensions.paddingSizeSmall),
                                 ServiceVariantsGridWidget(service: service),
                               ],
                             ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeLarge),
                    Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                             if(service.promotionalVideoFullPath != null)
                             Padding(
                               padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                               child: AspectRatio(
                                 aspectRatio: 16/9,
                                 child: ServiceVideoPlayer(videoUrl: service.promotionalVideoFullPath!),
                               ),
                             ),
                             if(service.videoFullPath != null)
                             Padding(
                               padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                               child: AspectRatio(
                                 aspectRatio: 16/9,
                                 child: ServiceVideoPlayer(videoUrl: service.videoFullPath!, thumbUrl: service.coverImageFullPath ?? ""),
                               ),
                             ),
                          ],
                        ),
                    ),
                  ],
              ) : Column(
                children: [
                   if(service.promotionalVideoFullPath != null)
                   Padding(
                     padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                     child: SizedBox(
                         height: 200,
                         width: double.infinity,
                         child: ServiceVideoPlayer(videoUrl: service.promotionalVideoFullPath!)),
                   ),

                   if(service.videoFullPath != null)
                   Padding(
                     padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
                     child: SizedBox(
                         height: 200,
                         width: double.infinity,
                         child: ServiceVideoPlayer(videoUrl: service.videoFullPath!, thumbUrl: service.coverImageFullPath ?? "")),
                   ),

                  /*
                  HtmlWidget(
                    service.description ?? "",
                    textStyle: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge,
                    ),
                  ),
                  */
                  const SizedBox(height: Dimensions.paddingSizeLarge),
                   if(service.variationsAppFormat?.zoneWiseVariations != null && service.variationsAppFormat!.zoneWiseVariations!.isNotEmpty)
                     Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Center(
                           child: Text(
                             "${Get.find<SplashController>().configModel.content?.businessName ?? "App"}'s Professional Cleaning Services",
                             style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeOverLarge, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.7)),
                             textAlign: TextAlign.center,
                           ),
                         ),
                         const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                         Center(
                           child: Text(
                             "Get A Instant Quote or Book Online Now",
                             style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.5)),
                             textAlign: TextAlign.center,
                           ),
                         ),
                         const SizedBox(height: Dimensions.paddingSizeLarge),
                         RichText(
                           text: TextSpan(
                             text: "Most of our clients who booked ",
                             style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6)),
                             children: [
                               TextSpan(
                                 text: service.name ?? "",
                                 style: robotoBold.copyWith(color: Theme.of(context).primaryColor),
                               ),
                               const TextSpan(text: " also add:"),
                             ],
                           ),
                         ),
                         const SizedBox(height: Dimensions.paddingSizeSmall),
                         ServiceVariantsGridWidget(service: service),
                       ],
                     ),
                ],
              )),
        ),
      ),
    );
  }
}