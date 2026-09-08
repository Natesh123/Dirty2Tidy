import 'package:demandium/common/models/popup_menu_model.dart';
import 'package:demandium/feature/booking/widget/booking_status_widget.dart';
import 'package:demandium/helper/booking_helper.dart';
import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class BookingItemCard extends StatelessWidget {
  final BookingModel bookingModel;
  final int index;
  const BookingItemCard({super.key, required this.bookingModel, required this.index}) ;

  @override
  Widget build(BuildContext context) {
    String bookingStatus = bookingModel.bookingStatus!;
    double displayTotal = (bookingModel.totalBookingAmount ?? 0) - (bookingModel.totalTaxAmount ?? 0);

    if(bookingModel.isRepeatBooking == 1 && bookingModel.repeatBookingList != null && bookingModel.repeatBookingList!.isNotEmpty){
      double totalManualSubTotal = 0;
      for (var repeat in bookingModel.repeatBookingList!) {
        double variantsTotal = 0;
        repeat.detail?.forEach((element) {
          variantsTotal += (element.serviceCost ?? 0) * (element.quantity ?? 1);
        });
        double minPrice = repeat.detail?.isNotEmpty == true ? (repeat.detail?.first.service?.minBiddingPrice?.toDouble() ?? 0) : 0;
        totalManualSubTotal += (minPrice + variantsTotal);
      }
      displayTotal = totalManualSubTotal;
    }

    return InkWell(
      onTap: () {
        if(bookingModel.isRepeatBooking == 1){
          Get.toNamed(RouteHelper.getRepeatBookingDetailsScreen(bookingId:bookingModel.id!));
        }else{
          Get.toNamed(RouteHelper.getBookingDetailsScreen(bookingID:bookingModel.id!));
        }
      },

      child: GetBuilder<ServiceBookingController>(builder: (serviceBookingController){
        return Container(
          decoration: BoxDecoration(color: Theme.of(context).cardColor , borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1), width: 0.5),
              boxShadow: Get.find<ThemeController>().darkTheme ? null : lightShadow
          ),//boxShadow: shadow),
          padding:  const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeEight,horizontal: Dimensions.paddingSizeDefault),
          margin:  const EdgeInsets.symmetric(horizontal: 2,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [


              Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(
                  children: [
                    Text('${'booking'.tr}# ${bookingModel.readableId}', style: robotoBold.copyWith()),
                    if(bookingModel.isRepeatBooking == 1)Container(
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.green),
                      padding: const EdgeInsets.all(2),
                      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall),
                      child: const Icon(Icons.repeat, color: Colors.white,size: 10,),
                    )
                  ],
                ),

                PopupMenuButton<PopupMenuModel>(
                  shape:  RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault,)),
                    side: BorderSide(color: Theme.of(context).hintColor.withValues(alpha: 0.1)),
                  ),
                  surfaceTintColor: Theme.of(context).cardColor,
                  position: PopupMenuPosition.under, elevation: 8,
                  shadowColor: Theme.of(context).hintColor.withValues(alpha: 0.3),
                  itemBuilder: (BuildContext context) {
                    return serviceBookingController.getPopupMenuList( status: bookingStatus, isRepeatBooking: bookingModel.isRepeatBooking == 1).map((PopupMenuModel option) {
                      return PopupMenuItem<PopupMenuModel>(
                        value: option,
                        height: 35,
                        onTap: () async {

                          if(option.title == "booking_details"){
                            if(bookingModel.isRepeatBooking == 1){
                              Get.toNamed(RouteHelper.getRepeatBookingDetailsScreen( bookingId :bookingModel.id!));
                            }else{
                              Get.toNamed(RouteHelper.getBookingDetailsScreen(bookingID :bookingModel.id!,));
                            }
                          }
                          if(option.title == "rebook"){
                            serviceBookingController.updateRebookIndex(index);

                           await serviceBookingController.checkCartSubcategory(bookingModel.id!, bookingModel.subCategoryId!);

                          }

                          else if(option.title == "reschedule"){
                            DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100)
                            );
                            if (pickedDate != null) {
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              );

                              if(pickedTime != null){
                                DateTime scheduledDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
                                serviceBookingController.rescheduleBooking(bookingModel.id!, DateConverter.dateToDateAndTime(scheduledDate));
                              }
                            }
                          }

                          else if(option.title == "download_invoice"){
                            String uri = "";
                            String languageCode = Get.find<LocalizationController>().locale.languageCode;
                            if(bookingModel.isRepeatBooking == 1){
                              uri = "${AppConstants.baseUrl}${AppConstants.repeatBookingInvoiceUrl}${bookingModel.id}/$languageCode";
                            }else{
                              uri = "${AppConstants.baseUrl}${AppConstants.regularBookingInvoiceUrl}${bookingModel.id}/$languageCode";
                            }
                            if (kDebugMode) {
                              print("Uri : $uri");
                            }
                            await _launchUrl(Uri.parse(uri));
                          } else if(option.title == "cancel"){
                            Get.dialog(
                              ConfirmationDialog(
                                icon: Images.warning,
                                title:  bookingModel.isRepeatBooking == 1 ? 'are_you_sure_to_cancel_this_full_booking'.tr : 'are_you_sure_to_cancel_your_order'.tr,
                                description: bookingModel.isRepeatBooking == 1 ? 'once_cancel_full_booking'.tr : 'your_order_will_be_cancel'.tr,
                                noButtonText: "yes_cancel".tr,
                                noButtonColor: Theme.of(context).colorScheme.primary,
                                noTextColor: Colors.white,
                                yesButtonText: "not_now".tr,
                                yesButtonColor: Theme.of(context).colorScheme.error,
                                yesTextColor: Colors.white,
                                buttonFontSize: Dimensions.fontSizeSmall + 1,
                                onYesPressed: () {
                                  Get.back();
                                },
                                onNoPressed: () async {
                                  Get.back();
                                  Get.dialog(const CustomLoader(), barrierDismissible: false);
                                  await Get.find<BookingDetailsController>().bookingCancel(
                                    bookingId: bookingModel.id ?? "", fromListScreen: true,
                                  );
                                  Get.back();
                                },
                              ),
                              useSafeArea: false,
                            );
                          }

                        },
                        child: Row(
                          children: [
                            const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                            Icon(option.icon, size: Dimensions.fontSizeLarge,),
                            const SizedBox(width: Dimensions.paddingSizeSmall,),
                            Text(option.title.tr, style: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeSmall
                            ),),
                          ],
                        ),
                      );
                    }).toList();
                  },
                  child:  Icon(Icons.more_vert_sharp, color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.6),),
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeEight,),

              Row( children: [
                Text('${'booking_date'.tr} : ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,  color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .6))),
                Text(DateConverter.dateMonthYearTimeTwentyFourFormat(DateConverter.isoUtcStringToLocalDate(bookingModel.createdAt.toString())),textDirection: TextDirection.ltr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,  color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .6))),],),
              const SizedBox(height: Dimensions.paddingSizeExtraSmall,),

              Row( children: [
                Text('${'service_date'.tr} : ', style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,  color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .6))),
                if(BookingHelper.getRepeatBookingCurrentSchedule(bookingModel) !=null) Text(DateConverter.dateMonthYearTimeTwentyFourFormat(DateTime.tryParse(BookingHelper.getRepeatBookingCurrentSchedule(bookingModel)!)!),
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,  color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .6)),
                  textDirection: TextDirection.ltr,
                ),
              ]),
              const SizedBox(height: Dimensions.paddingSizeSmall,),

              Row( mainAxisAlignment: MainAxisAlignment.spaceBetween,  children: [

                BookingStatusButtonWidget(bookingStatus: bookingModel.bookingStatus,),

                FutureBuilder(
                  future: Get.find<BookingDetailsRepo>().getBookingDetails(bookingID: bookingModel.id!),
                  builder: (context, snapshot) {
                    double finalTotal = displayTotal;
                    if (snapshot.hasData) {
                      Response response = snapshot.data as Response;
                      if(response.statusCode == 200){
                        var details = BookingDetailsModel.fromJson(response.body);
                        var content = details.content;
                        if (content != null) {
                          var service = content.bookingDetails?.first.service;
                          double minPrice = service?.minBiddingPrice?.toDouble() ?? 0;
                          double variantsTotal = 0;
                          content.bookingDetails?.forEach((element) {
                            variantsTotal += BookingHelper.getCleanItemCost(element, content);
                          });
                          
                          // Smart Sync Logic
                          double calculatedSubTotal = minPrice + variantsTotal;
                          double subTotal;
                          
                          if (content.bookingDetails != null && content.bookingDetails!.length > 1) {
                             subTotal = calculatedSubTotal;
                          } else {
                             if (content.totalBookingAmount != null && 
                                 content.totalBookingAmount! >= minPrice && 
                                 calculatedSubTotal > content.totalBookingAmount!) {
                               subTotal = content.totalBookingAmount!;
                             } else {
                               subTotal = calculatedSubTotal;
                             }
                          }

                          if(content.isRepeatBooking == 1){
                            finalTotal = subTotal * (content.totalCount ?? 1);
                          } else {
                            finalTotal = subTotal;
                          }
                        }
                      }
                    }
                    return Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(PriceConverter.convertPrice(finalTotal),
                        style: robotoBold.copyWith(color: Theme.of(context).colorScheme.primary),
                      ),
                    );
                  }
                ),
              ],),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw 'Could not launch $url';
    }
  }
}
