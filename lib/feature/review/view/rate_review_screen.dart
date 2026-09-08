import 'package:get/get.dart';
import 'package:demandium/feature/review/controller/submit_review_controller.dart';
import 'package:demandium/feature/review/widgets/select_rating.dart';
import 'package:demandium/feature/profile/controller/user_controller.dart';
import 'package:demandium/common/widgets/ldashed_line_printer.dart';
import 'package:demandium/utils/core_export.dart';
import 'package:readmore/readmore.dart';

class RateReviewScreen extends StatefulWidget{
  final String? id;
  const RateReviewScreen({super.key, this.id}) ;

  @override
  State<RateReviewScreen> createState() => _RateReviewScreenState();
}
class _RateReviewScreenState extends State<RateReviewScreen> {

  _loadData() async {
   if(widget.id !=null){
     Get.find<BookingDetailsController>().getBookingDetails(bookingId: widget.id!);
     await Get.find<SubmitReviewController>().getReviewList(widget.id!);
     if(Get.find<SubmitReviewController>().serviceReviewList == null || Get.find<SubmitReviewController>().serviceReviewList!.isEmpty) {
       if(Get.find<BookingDetailsController>().bookingDetailsContent != null) {
         Get.find<SubmitReviewController>().initializeReviewState(Get.find<BookingDetailsController>().bookingDetailsContent!.bookingDetails!);
       }
     }
   }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer:ResponsiveHelper.isDesktop(context) ? const MenuDrawer():null,
      appBar: CustomAppBar(title: 'review'.tr,),
      body: GetBuilder<BookingDetailsController>(builder: (bookingController){
        if(widget.id == null){
          return const NoDataScreen(text: "no_data_found", type: NoDataType.bookings,);
        } else if(bookingController.bookingDetailsContent!=null){
         return GetBuilder<SubmitReviewController>(builder: (submitReviewController){
           if(submitReviewController.loading){
             return const Center(child: CircularProgressIndicator(),);
           }else{

             bool hasReviewApiData = submitReviewController.serviceReviewList != null && submitReviewController.serviceReviewList!.isNotEmpty;
             List<dynamic> itemsToReview = hasReviewApiData 
                 ? submitReviewController.serviceReviewList! 
                 : (bookingController.bookingDetailsContent?.bookingDetails ?? []);

             if(!hasReviewApiData && itemsToReview.isNotEmpty) {
               submitReviewController.initializeReviewState(bookingController.bookingDetailsContent!.bookingDetails!);
             }

              return FooterBaseView(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Stack(children: [
                          Container(
                            height:ResponsiveHelper.isDesktop(context)? 280: 120.0,
                            width: Get.width,
                            decoration: BoxDecoration(
                                image: DecorationImage(fit: BoxFit.fill, image: AssetImage(Images.reviewTopBanner))
                            ),),
                          SizedBox(
                            height:ResponsiveHelper.isDesktop(context)? 280: 120.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ResponsiveHelper.isDesktop(context)?Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ReviewBookingDetailsCard(bookingDetailsContent: bookingController.bookingDetailsContent!),
                                ):const SizedBox(),
                              ],
                            ),
                          )
                        ],),

                        const SizedBox(height: Dimensions.paddingSizeLarge,),

                        // User Profile Header
                        GetBuilder<UserController>(builder: (userController) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                              boxShadow: Get.find<ThemeController>().darkTheme ? null : cardShadow,
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(30),
                                  child: CustomImage(
                                    image: userController.userProfileImage,
                                    height: 60, width: 60,
                                    placeholder: Images.userPlaceHolder,
                                  ),
                                ),
                                const SizedBox(width: Dimensions.paddingSizeDefault),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${userController.userInfoModel?.fName ?? ''} ${userController.userInfoModel?.lName ?? ''}",
                                      style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                                    ),
                                    Text(
                                      userController.userInfoModel?.email ?? '',
                                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).hintColor),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }),

                        const SizedBox(height: Dimensions.paddingSizeLarge,),

                        !ResponsiveHelper.isDesktop(context)
                            ? ReviewBookingDetailsCard(bookingDetailsContent: bookingController.bookingDetailsContent!):const SizedBox(),

                        ListView.builder(
                          itemCount: itemsToReview.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context,index) {
                            
                            Service? service;
                            String variations = "";
                            String? serviceId;
                            String? serviceName;

                            if (hasReviewApiData) {
                              service = itemsToReview[index] as Service;
                              serviceId = service.id;
                              List<String> variationList=[];
                              bookingController.bookingDetailsContent!.bookingDetails?.forEach((bookingDetailsItem) {
                                if(serviceId == bookingDetailsItem.serviceId){
                                  variationList.add(bookingDetailsItem.variantKey??"");
                                }
                              });
                              variations = variationList.toString().replaceAll('[', '').replaceAll(']', '');
                            } else {
                              ItemService item = itemsToReview[index] as ItemService;
                              service = item.service;
                              serviceId = item.serviceId ?? service?.id ?? item.id?.toString();
                              variations = item.variantKey ?? "";
                              serviceName = item.serviceName ?? service?.name ?? "";
                            }

                            if(serviceId == null) return const SizedBox();

                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeDefault),
                              child: (submitReviewController.isEditable[serviceId] ?? true)
                                  ? EditableReview(serviceReview: service, index: index, variations: variations, bookingId: widget.id, serviceId: serviceId, serviceName: serviceName,)
                                  : NonEditableReview(serviceReview: service, index: index, variations: variations, serviceId: serviceId,),
                            );
                          },
                        ),
                        if(itemsToReview.isEmpty)
                          const NoDataScreen(text: "no_review_found", type: NoDataType.bookings,),

                        const SizedBox(height: Dimensions.paddingSizeExtraLarge,)

                      ],
                    ),
                  ),
                ),
              );

           }
         }
         );
       }else{
         return const Center(child: CircularProgressIndicator(),);
       }
      }
      ),
    );
  }
}

class ReviewBookingDetailsCard extends StatelessWidget {
  const ReviewBookingDetailsCard({
    super.key,
    required this.bookingDetailsContent,
  }) ;
  final BookingDetailsContent bookingDetailsContent;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall,vertical: Dimensions.paddingSizeSmall),
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: Get.find<ThemeController>().darkTheme ? null : cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${'booking_no'.tr} # ${bookingDetailsContent.readableId}",
                style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).colorScheme.primary),),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                    PriceConverter.convertPrice(bookingDetailsContent.totalBookingAmount!.toDouble()),
                    style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context).textTheme.bodyLarge!.color
                    )
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  DateConverter.formatDate(DateConverter.isoUtcStringToLocalDate(bookingDetailsContent.createdAt!)),
                  style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6)
                  ),
              ),
              Text("${bookingDetailsContent.bookingStatus}".tr, style: robotoMedium.copyWith(color: Colors.green),),
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall,)
        ],

      ),
    );
  }
}

class EditableReview extends StatefulWidget {
  final Service? serviceReview;
  final int index;
  final String variations;
  final String? bookingId;
  final String serviceId;
  final String? serviceName;
  const EditableReview({super.key,this.serviceReview, required this.index, required this.variations, this.bookingId, required this.serviceId, this.serviceName}) ;

  @override
  State<EditableReview> createState() => _EditableReviewState();
}

class _EditableReviewState extends State<EditableReview> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  GetBuilder<SubmitReviewController>(builder: (submitReviewController){

      return Column(
        children: [
          const SizedBox(height: Dimensions.paddingSizeDefault,),
          Text( widget.serviceName ?? widget.serviceReview?.name ?? "",
            style: robotoMedium.copyWith(
              fontSize: Dimensions.fontSizeLarge,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall,),
          Text(
            widget.variations,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              SelectRating(revivedId: widget.serviceId,),
              const SizedBox()
            ],
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall,),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                color: Theme.of(context).hoverColor),
            child: Center(
              child: TextFormField(maxLines: 4,
                controller: submitReviewController.textControllers[widget.serviceId] ?? TextEditingController(),
                decoration: InputDecoration(
                  hintText: 'write_your_review'.tr,
                  border: InputBorder.none,
                  hintStyle: robotoRegular,
                ),
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault,),
          CustomButton(
            height: ResponsiveHelper.isDesktop(context) ? 45 : 40,
            width: ResponsiveHelper.isDesktop(context) ? 200:ResponsiveHelper.isTab(context)?150:120,
            radius: 50,
            isLoading: submitReviewController.selectedIndex== widget.index && submitReviewController.isLoading,
            buttonText: 'submit'.tr,
            onPressed: (){
              String review =  (submitReviewController.textControllers[widget.serviceId]?.value.text) ?? "";
              if(isRedundentClick(DateTime.now())){
                return;
              }
              submitReviewController.setIndex(widget.index);
              bool isUuid = RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$', caseSensitive: false).hasMatch(widget.serviceId);
              ReviewBody  reviewBody = ReviewBody(
                bookingID: widget.bookingId ?? "",
                serviceID: isUuid ? widget.serviceId : null,
                rating: (submitReviewController.selectedRating[widget.serviceId] ?? 5).toString(),
                comment: review,
              );
              submitReviewController.submitReview(reviewBody,  widget.serviceId, review, widget.index );

            },
          )
        ],
      );
    });
  }
}


class NonEditableReview extends StatelessWidget {
  final Service? serviceReview;
  final int index;
  final String variations;
  final String serviceId;
  const NonEditableReview({super.key, this.serviceReview, required this.index, required this.variations, required this.serviceId}) ;

  @override
  Widget build(BuildContext context) {

    String? reviewReply;
    String updatedAt = "";
    if(serviceReview!=null && serviceReview!.review !=null && serviceReview!.review!.isNotEmpty && serviceReview!.review!.first.reviewReply != null){
      reviewReply = serviceReview?.review?.first.reviewReply?.reply;
      updatedAt = serviceReview!.review!.first.reviewReply!.updatedAt!;
    }
    return  GetBuilder<SubmitReviewController>(builder: (submitReviewController){
      return Stack(
          children:[
            Column(
              children: [
                const SizedBox(height: Dimensions.paddingSizeDefault,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text( serviceReview?.name ?? "",
                      style: robotoMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),

                    const SizedBox(width: Dimensions.paddingSizeSmall,),

                    Image.asset(Images.accepted,width: 15,),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeExtraSmall,),
                Text(
                  variations,
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: 0.6),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    SelectRating(revivedId: serviceId, clickable: false,),
                    const SizedBox()
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall,),
                (submitReviewController.reviewComments[serviceId] != null && submitReviewController.reviewComments[serviceId]!.isNotEmpty) ? Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault,vertical: Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReadMoreText(
                        submitReviewController.reviewComments[serviceId] ?? "",
                        trimCollapsedText : "see_more".tr,
                        trimExpandedText: "  ${"see_less".tr}",
                        trimMode: TrimMode.Line,
                        trimLines: 3,
                        style: robotoRegular.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                            fontSize: Dimensions.fontSizeSmall,
                            height: 1.5
                        ),
                        textAlign: TextAlign.justify,
                        moreStyle: robotoMedium.copyWith(color: Theme.of(context).colorScheme.primary),
                        lessStyle: robotoMedium.copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                      if(reviewReply !=null && submitReviewController.reviewComments[serviceId]!.isNotEmpty) Padding(
                        padding: const EdgeInsets.only(top: Dimensions.paddingSizeEight),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const SizedBox(width: Dimensions.paddingSizeEight,),
                          CustomPaint(
                            size: const Size(20, 50), // Adjust size as needed
                            painter: LDashedLinePainter(),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Theme.of(context).cardColor,
                              ),
                              padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                              margin: const EdgeInsets.only(top: Dimensions.paddingSizeSmall),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        Image.asset(Images.reviewReply, width: 25,),
                                        const SizedBox(width: Dimensions.paddingSizeSmall,),
                                        Text("replied_by_provider".tr, style: robotoRegular,),
                                      ]),

                                      Text(DateConverter.dateStringMonthYear(DateConverter.isoUtcStringToLocalDate(updatedAt)),
                                        style: robotoRegular.copyWith(color:  Theme.of(context).hintColor, fontSize: Dimensions.fontSizeSmall + 1),
                                        textDirection: TextDirection.ltr,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: Dimensions.paddingSizeExtraSmall,),
                                  ReadMoreText(
                                    reviewReply,
                                    trimCollapsedText : "see_more".tr,
                                    trimExpandedText: "  ${"see_less".tr}",
                                    trimMode: TrimMode.Line,
                                    trimLines: 3,
                                    style: robotoRegular.copyWith(
                                        color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                                        fontSize: Dimensions.fontSizeSmall,
                                        height: 1.5
                                    ),
                                    textAlign: TextAlign.justify,
                                    moreStyle: robotoMedium.copyWith(color: Theme.of(context).colorScheme.primary),
                                    lessStyle: robotoMedium.copyWith(color: Theme.of(context).colorScheme.primary),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],),
                      ),
                    ],
                  ),
                ) : const SizedBox(),
                const SizedBox(height: Dimensions.paddingSizeExtraMoreLarge,),
              ],
            ),
            Get.find<LocalizationController>().isLtr ? Positioned(
                right: 0, child: IconButton(
                onPressed:() {
                  Get.find<SubmitReviewController>().updateEditableValue(serviceId, true,isUpdate: true);}, icon: Image.asset(Images.edit,width: 15,)
            )): Positioned(left: 0,
              child: IconButton(
                  onPressed:() {
                    Get.find<SubmitReviewController>().updateEditableValue(serviceId, true,isUpdate: true);
                  }, icon: Image.asset(Images.edit,width: 15,)
              ),
            ),
          ]
      );
    });
  }
}


