import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';


class HtmlViewerScreen extends StatefulWidget {
  final HtmlType? htmlType;
  const HtmlViewerScreen({super.key, @required this.htmlType});

  @override
  State<HtmlViewerScreen> createState() => _HtmlViewerScreenState();
}

class _HtmlViewerScreenState extends State<HtmlViewerScreen> {

  @override
  void initState() {
    super.initState();
    Get.find<HtmlViewController>().getPagesContent();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Scaffold(
      endDrawer:ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
      appBar: CustomAppBar(title: widget.htmlType == HtmlType.termsAndCondition ? 'terms_and_conditions'.tr
          : widget.htmlType == HtmlType.aboutUs ? 'about_us'.tr :
      widget.htmlType == HtmlType.privacyPolicy ? 'privacy_policy'.tr :
      widget.htmlType == HtmlType.cancellationPolicy ? 'cancellation_policy'.tr :
      widget.htmlType == HtmlType.refundPolicy ? 'refund_policy'.tr :
      'no_data_found'.tr),


      body: GetBuilder<HtmlViewController>(
        builder: (htmlViewController){
          String? data;
          String? image;
          if(htmlViewController.pagesContent != null){
             data = widget.htmlType == HtmlType.termsAndCondition ? htmlViewController.pagesContent?.termsAndConditions?.liveValues??""
                : widget.htmlType == HtmlType.aboutUs ? htmlViewController.pagesContent?.aboutUs?.liveValues??""
                : widget.htmlType == HtmlType.privacyPolicy ? htmlViewController.pagesContent?.privacyPolicy?.liveValues ?? ""
                : widget.htmlType == HtmlType.refundPolicy ? htmlViewController.pagesContent?.refundPolicy?.liveValues ?? ""
                : widget.htmlType == HtmlType.cancellationPolicy ? htmlViewController.pagesContent?.cancellationPolicy?.liveValues??""
                : null;

             image = widget.htmlType == HtmlType.termsAndCondition ? htmlViewController.pagesContent?.images?.termsAndConditions ??""
                 : widget.htmlType == HtmlType.aboutUs ? htmlViewController.pagesContent?.images?.aboutUs ?? ""
                 : widget.htmlType == HtmlType.privacyPolicy ? htmlViewController.pagesContent?.images?.privacyPolicy ?? ""
                 : widget.htmlType == HtmlType.refundPolicy ? htmlViewController.pagesContent?.images?.refundPolicy ?? ""
                 : widget.htmlType == HtmlType.cancellationPolicy ? htmlViewController.pagesContent?.images?.cancellationPolicy ?? ""
                 : null;

               if(data != null) {
                 data = data.replaceAll('href=', 'target="_blank" href=');

               return FooterBaseView(
                 child: Center(
                   child: SizedBox(
                     width: Dimensions.webMaxWidth,
                     child: Column(
                       children: [

                         const SizedBox(height: Dimensions.paddingSizeDefault),
                         Padding(
                           padding: EdgeInsets.all(isDesktop ? 0 : Dimensions.paddingSizeSmall),
                           child: ClipRRect(
                             borderRadius: BorderRadius.circular(
                               isDesktop ?
                               Dimensions.radiusDefault : Dimensions.radiusSmall
                             ),
                             child: Stack(
                               children: [
                                 SizedBox(
                                   height: isDesktop ? 185 : 70,
                                   width: double.infinity,
                                   child: CustomImage(
                                     fit: BoxFit.cover,
                                     image: image ?? "",
                                     placeHolderBoxFit: BoxFit.fill,
                                   ),
                                 ),

                                 if(isDesktop)...[
                                   Container(
                                     height: 185,
                                     width:  double.infinity,
                                     color: Colors.black.withValues(alpha: 0.30),
                                     child: Center(
                                       child: Text(
                                         widget.htmlType == HtmlType.termsAndCondition ? 'terms_and_conditions'.tr
                                             : widget.htmlType == HtmlType.aboutUs ? 'about_us'.tr :
                                         widget.htmlType == HtmlType.privacyPolicy ? 'privacy_policy'.tr :
                                         widget.htmlType == HtmlType.cancellationPolicy ? 'cancellation_policy'.tr :
                                         widget.htmlType == HtmlType.refundPolicy ? 'refund_policy'.tr:'',
                                         style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.white),
                                       ),
                                     ),
                                   ),
                                 ]

                               ],
                             )
                           ),
                         ),

                         Container(
                           padding:  const EdgeInsets.all(Dimensions.paddingSizeDefault),
                           margin: EdgeInsets.only(
                             left: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeSmall,
                             right: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeSmall,
                             top: Dimensions.paddingSizeLarge
                           ),
                           decoration: BoxDecoration(
                             color:  Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSeven),
                             boxShadow:  [ BoxShadow(
                               offset: const Offset(1, 1),
                               blurRadius: 5,
                               color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                             )],
                           ),
                         child: Column(
                           children: [
                             Html(
                               data: data,
                               style: {
                                 "p": Style(
                                   fontSize: FontSize.medium,
                                 ),

                               },
                             ),
                           ],
                         ),
                                                  )
                       ],
                     ),
                   ),
                 )
               );
             }else{
               return const SizedBox();
             }
          }else{
            return const Center(child: CircularProgressIndicator(),);
          }
        },
      ),
      floatingActionButton: null,
    );
  }
}
