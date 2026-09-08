import 'package:demandium/helper/booking_helper.dart';
import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class BookingSummeryWidget extends StatelessWidget{
  final BookingDetailsContent bookingDetails;
  const BookingSummeryWidget({super.key, required this.bookingDetails}) ;

  @override
  Widget build(BuildContext context){
    double paidAmount = 0;
    bool isPartialPayment = bookingDetails.partialPayments !=null && bookingDetails.partialPayments!.isNotEmpty;

    // Force subtotal and total to match checkout experience (SafeSync)
    var service = bookingDetails.bookingDetails?.first.service;
    double minPrice = service?.minBiddingPrice?.toDouble() ?? 0;
    double variantsTotal = 0;
    bookingDetails.bookingDetails?.forEach((element) {
      variantsTotal += BookingHelper.getCleanItemCost(element, bookingDetails);
    });
    
    // Smart Sync: Calculate the theoretical total (SafeSync)
    double calculatedSubTotal = minPrice + variantsTotal;
    double subTotal;
    
    // Logic: 
    // 1. If there are multiple items, always trust the sum of rows ($290 case).
    // 2. If there's only one item, check if it's the 'automatic variant' mistake case ($100 vs $140).
    if (bookingDetails.bookingDetails != null && bookingDetails.bookingDetails!.length > 1) {
       subTotal = calculatedSubTotal;
    } else {
       if (bookingDetails.totalBookingAmount != null && 
           bookingDetails.totalBookingAmount! >= minPrice && 
           calculatedSubTotal > bookingDetails.totalBookingAmount!) {
         subTotal = bookingDetails.totalBookingAmount!;
       } else {
         subTotal = calculatedSubTotal;
       }
    }
    
    double totalBookingAmount = subTotal;

    if(isPartialPayment) {
      bookingDetails.partialPayments?.forEach((element) {
        paidAmount = paidAmount + (element.paidAmount ?? 0);
      });
    }else{
      paidAmount  = totalBookingAmount - (bookingDetails.additionalCharge ?? 0);
    }

    double dueAmount = totalBookingAmount - paidAmount;
    double additionalCharge = isPartialPayment ? totalBookingAmount - paidAmount : bookingDetails.additionalCharge ?? 0;

    return Container(
      decoration: BoxDecoration(color: Theme.of(context).cardColor , borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          boxShadow: Get.find<ThemeController>().darkTheme ? null : searchBoxShadow
      ),
      child: Column( crossAxisAlignment: CrossAxisAlignment.start, children: [

        Gaps.verticalGapOf(Dimensions.paddingSizeSmall),
        Padding(padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge) : const EdgeInsets.symmetric(horizontal:Dimensions.paddingSizeDefault),
            child: Text( 'booking_summery'.tr,
                style:robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color))
        ),
        Gaps.verticalGapOf(Dimensions.paddingSizeSmall),

        Container(
          padding: ResponsiveHelper.isDesktop(context) ? const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge) : const EdgeInsets.symmetric(horizontal:Dimensions.paddingSizeDefault),
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.07),
          child: SizedBox(
            height: 40,
            child:  Row( mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('service_info'.tr, style:robotoBold.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodyLarge!.color!,decoration: TextDecoration.none,
              )),
              Text('price'.tr,style:robotoBold.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).textTheme.bodyLarge!.color!,decoration: TextDecoration.none,
              )),
            ]),
          ),
        ),

        Padding(
          padding:  ResponsiveHelper.isDesktop(context) ?  const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeExtraSmall) :  EdgeInsets.zero,
          child: Column(children: [
            Builder(builder: (context) {
                // Merge logic remains the same: only for single-item bookings where price matches minPrice
                bool shouldMerge = (subTotal <= minPrice && bookingDetails.bookingDetails?.length == 1);

                return Column(children: [
                   // Base Service Row (only if not merged)
                   if(!shouldMerge && minPrice > 0) Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Expanded(child: Text("${bookingDetails.bookingDetails?.first.serviceName ?? ""}", 
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.9)),
                        overflow: TextOverflow.ellipsis,
                      )),
                      Text(PriceConverter.convertPrice(minPrice, isShowLongPrice: true),
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.9)),
                      ),
                    ]),
                  ),

                  ListView.builder(
                    itemBuilder: (context, index) {
                      double itemPrice = BookingHelper.getCleanItemCost(bookingDetails.bookingDetails?[index], bookingDetails);
                      
                      if (shouldMerge && index == 0) {
                        itemPrice = subTotal;
                      }

                      // Only show if it has a price or it's the merged first item
                      if (itemPrice > 0 || (shouldMerge && index == 0)) {
                        return _ServiceInfoItem(
                          bookingService: bookingDetails.bookingDetails?[index],
                          allServiceItems: bookingDetails.bookingDetails,
                          bookingDetails: bookingDetails,
                          index: index,
                          customPrice: itemPrice, 
                          hideVariantName: shouldMerge && index == 0,
                          hideServiceName: !shouldMerge,
                        );
                      }
                      return const SizedBox();
                    },
                    itemCount: bookingDetails.bookingDetails?.length,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                  ),
                ]);
            }),

            Gaps.verticalGapOf(Dimensions.paddingSizeSmall),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Divider(height: 2, color: Colors.grey,),
            ),
            Gaps.verticalGapOf(Dimensions.paddingSizeSmall),

            Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('sub_total'.tr,
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color),
                  overflow: TextOverflow.ellipsis,
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    PriceConverter.convertPrice(subTotal,isShowLongPrice: true),
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color),
                  ),
                ),
              ]),
            ),


            Gaps.verticalGapOf(Dimensions.paddingSizeSmall),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      'service_discount'.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color),
                      overflow: TextOverflow.ellipsis
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                        "(-) ${PriceConverter.convertPrice(bookingDetails.totalDiscountAmount ?? 0)}",
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color)),
                  ),
                ],
              ),
            ),
            Gaps.verticalGapOf(Dimensions.paddingSizeSmall),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'coupon_discount'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color!),
                    overflow: TextOverflow.ellipsis,),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text('(-) ${PriceConverter.convertPrice(bookingDetails.totalCouponDiscountAmount ?? 0)}',
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color!),),
                  ),
                ],
              ),
            ),

            Gaps.verticalGapOf(Dimensions.paddingSizeSmall),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'campaign_discount'.tr,
                    style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color),
                    overflow: TextOverflow.ellipsis,),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text('(-) ${PriceConverter.convertPrice(bookingDetails.totalCampaignDiscountAmount ?? 0)}',
                        style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color!)),
                  ),
                ],
              ),
            ),

            if(bookingDetails.totalReferralDiscountAmount != null && bookingDetails.totalReferralDiscountAmount! > 0)
              Gaps.verticalGapOf(Dimensions.paddingSizeSmall),

            if(bookingDetails.totalReferralDiscountAmount != null && bookingDetails.totalReferralDiscountAmount! > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'referral_discount'.tr,
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color),
                      overflow: TextOverflow.ellipsis,),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text('(-) ${PriceConverter.convertPrice(bookingDetails.totalReferralDiscountAmount ?? 0)}',
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color!)),
                    ),
                  ],
                ),
              ),

            Gaps.verticalGapOf(Dimensions.paddingSizeSmall),

            if(bookingDetails.extraFee != null && bookingDetails.extraFee! > 0)
              Padding(
                padding: const EdgeInsets.only(left : Dimensions.paddingSizeDefault , right: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeSmall),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text( Get.find<SplashController>().configModel.content?.additionalChargeLabelName ?? "",style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge?.color),overflow: TextOverflow.ellipsis,
                    ),
                    Text("(+) ${PriceConverter.convertPrice(bookingDetails.extraFee ?? 0,
                        isShowLongPrice:true)}",
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodyLarge!.color
                      ),
                    ),
                  ],
                ),
              ),

            if(bookingDetails.additionalCharge != null && additionalCharge < 0 && (bookingDetails.paymentMethod != "cash_after_service" || bookingDetails.partialPayments!.isNotEmpty ))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeSmall),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("refund".tr,style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                        color: Theme.of(context).textTheme.bodyLarge?.color),overflow: TextOverflow.ellipsis,
                    ),
                    Text(PriceConverter.convertPrice(additionalCharge, isShowLongPrice:true),
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodyLarge!.color
                      ),
                    ),
                  ],
                ),
              ),

            if(bookingDetails.additionalCharge != null && additionalCharge < 0 && (bookingDetails.paymentMethod != "cash_after_service" || bookingDetails.partialPayments!.isNotEmpty ))
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                child: Text("* If any refund was initiated, it must be stated",
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.error),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeExtraSmall),
                child: Text("No refund has been initiated",
                  style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Colors.green),
                ),
              ),

            Gaps.verticalGapOf(Dimensions.paddingSizeSmall),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Divider(height: 2, color: Colors.grey,),
            ),
            Gaps.verticalGapOf(Dimensions.paddingSizeExtraSmall),

            !isPartialPayment && bookingDetails.paymentMethod != "wallet_payment" ? (additionalCharge == 0) ||  bookingDetails.paymentMethod == "cash_after_service" ?
            Padding( padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('grand_total'.tr,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.primary),
                  overflow: TextOverflow.ellipsis,
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    PriceConverter.convertPrice(totalBookingAmount.toDouble(),isShowLongPrice: true),
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).colorScheme.primary),),
                ),
              ],),
            ) : Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: DottedBorder(
                dashPattern: const [8, 4],
                strokeWidth: 1.1,
                borderType: BorderType.RRect,
                color: Theme.of(context).colorScheme.primary,
                radius: const Radius.circular(Dimensions.radiusDefault),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.02),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                  child: Column(
                    children: [

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('grand_total'.tr,
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.primary,),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            PriceConverter.convertPrice( totalBookingAmount ,isShowLongPrice: true),
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color : Theme.of(context).colorScheme.primary,),),
                        ),
                      ],),

                      const SizedBox(height: Dimensions.paddingSizeSmall,),

                      additionalCharge > 0 ?
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text("${(bookingDetails.bookingStatus == "pending"  || bookingDetails.bookingStatus == "accepted" || bookingDetails.bookingStatus == "ongoing")
                            ? "due_amount".tr : "paid_amount".tr} (${"cash_after_service".tr})",
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color),
                          overflow: TextOverflow.ellipsis,),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text( PriceConverter.convertPrice (additionalCharge, isShowLongPrice: true),
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color),),
                        )]
                      ): const SizedBox()
                    ],
                  ),
                ),
              ),
            ) :

            !isPartialPayment && bookingDetails.paymentMethod == "wallet_payment" ?
            Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: Column( children: [

                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('grand_total'.tr,
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.primary,),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                        PriceConverter.convertPrice(totalBookingAmount.toDouble(),isShowLongPrice: true),
                        style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).colorScheme.primary,)),
                  ),
                ],),

                const SizedBox(height: Dimensions.paddingSizeSmall,),

                DottedBorder(
                  dashPattern: const [8, 4],
                  strokeWidth: 1.1,
                  borderType: BorderType.RRect,
                  color: Theme.of(context).colorScheme.primary,
                  radius: const Radius.circular(Dimensions.radiusDefault),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.02),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start ,children: [

                      Text( (bookingDetails.additionalCharge! <= 0) ? 'total_order_amount_has_been_paid_by_customer'.tr : "has_been_paid_by_customer".tr,
                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).colorScheme.primary,),
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: Dimensions.paddingSizeSmall,),

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Row(children: [

                          Image.asset(Images.walletSmall,width: 17,),
                          const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                          Text( 'via_wallet'.tr,
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color),
                            overflow: TextOverflow.ellipsis,),
                        ],),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            PriceConverter.convertPrice( paidAmount ,isShowLongPrice: true),
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color),),
                        )]
                      ),

                      if(additionalCharge > 0 )
                        Padding( padding: const EdgeInsets.only(top : 8.0),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text("${(bookingDetails.bookingStatus == "pending"  || bookingDetails.bookingStatus == "accepted" || bookingDetails.bookingStatus == "ongoing")
                                ? "due_amount".tr : "paid_amount".tr} (${"cash_after_service".tr})",
                              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color),
                              overflow: TextOverflow.ellipsis,),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                PriceConverter.convertPrice( additionalCharge, isShowLongPrice: true),
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color),),
                            )]
                          ),
                        )

                    ]),
                  ),
                ),
              ]),
            )  :

            isPartialPayment ?
            Padding(padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
              child: DottedBorder(
                dashPattern: const [8, 4],
                strokeWidth: 1.1,
                borderType: BorderType.RRect,
                color: Theme.of(context).colorScheme.primary,
                radius: const Radius.circular(Dimensions.radiusDefault),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.02),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal : Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeSmall),
                  child: Column(
                    children: [

                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('grand_total'.tr,
                          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.primary,),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            PriceConverter.convertPrice( totalBookingAmount, isShowLongPrice: true),
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color : Theme.of(context).colorScheme.primary,),),
                        ),
                      ],),

                      const SizedBox(height: Dimensions.paddingSizeSmall,),

                      ListView.builder(itemBuilder: (context, index){
                        String payWith = bookingDetails.partialPayments?[index].paidWith ?? "";

                        return  Padding(padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Row(children: [

                              Image.asset(Images.walletSmall, width: 15,),

                              const SizedBox(width: Dimensions.paddingSizeExtraSmall,),

                              Text( '${ payWith == "cash_after_service" ? "paid_amount".tr : payWith == "digital" && bookingDetails.paymentMethod == "offline_payment" ? ""  :'paid_by'.tr} ''${payWith == "digital" ? "${bookingDetails.paymentMethod}".tr : (payWith == "cash_after_service" ? "(${'cash_after_service'.tr})" : payWith).tr }',
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color),
                                overflow: TextOverflow.ellipsis,),
                            ],),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                PriceConverter.convertPrice( bookingDetails.partialPayments?[index].paidAmount ?? 0,isShowLongPrice: true),
                                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color),),
                            )]),
                        );
                      },itemCount: bookingDetails.partialPayments?.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                      ),

                      bookingDetails.partialPayments?.length == 1 && dueAmount > 0 ?
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text("${(bookingDetails.bookingStatus == "pending"  || bookingDetails.bookingStatus == "accepted" || bookingDetails.bookingStatus == "ongoing")
                            ? "due_amount".tr : "paid_amount".tr} (${"cash_after_service".tr})",
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodyLarge!.color),
                          overflow: TextOverflow.ellipsis,),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            PriceConverter.convertPrice( dueAmount, isShowLongPrice: true),
                            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color),),
                        )]) : const SizedBox(),

                    ],
                  ),
                ),
              ),
            ) : Padding(padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('grand_total'.tr,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.primary),
                  overflow: TextOverflow.ellipsis,
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    PriceConverter.convertPrice( totalBookingAmount,isShowLongPrice: true),
                    style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).colorScheme.primary),),
                ),
              ]),
            )],
          ),
        ),




        const SizedBox(height: Dimensions.paddingSizeExtraLarge),
      ],
      ),
    );
  }
}


class _ServiceInfoItem extends StatelessWidget {
  final int index;
  final ItemService? bookingService;
  final List<ItemService>? allServiceItems;
  final BookingDetailsContent bookingDetails;
  final double? customPrice;
  final bool hideVariantName;
  final bool hideServiceName;

  const _ServiceInfoItem({
    required this.bookingService,
    required this.allServiceItems,
    required this.bookingDetails,
    required this.index,
    this.customPrice,
    this.hideVariantName = false,
    this.hideServiceName = false,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        const SizedBox(height:Dimensions.paddingSizeSmall),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
            child: Text(bookingService?.serviceName ?? "",
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault,
                  color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.9)
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeDefault,),
          Text(PriceConverter.convertPrice(customPrice ?? BookingHelper.getBookingServiceUnitConst(bookingService, allServiceItems, bookingDetails), isShowLongPrice:true,),
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,
                color: Theme.of(context).textTheme.bodyLarge!.color?.withValues(alpha: 0.9)
            ),
          ),
        ],
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall-2,),
        if(bookingService?.variantKey!=null && !hideVariantName)
          Padding(padding: const EdgeInsets.only( bottom: Dimensions.paddingSizeExtraSmall),
            child: Row(children: [

              Text(bookingService?.variantKey?.replaceAll("-", " ").capitalizeFirst ?? "",
                style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7)
                ),
              ),

              Container(
                height: 10, width: 0.5,
                color: Theme.of(context).hintColor,
                margin : const EdgeInsets.only(left : Dimensions.paddingSizeSmall, right:  Dimensions.paddingSizeSmall, top: 5),
              ),

              Row(children: [
                Text("${"qty".tr} : ${bookingService?.quantity}",
                  style: robotoRegular.copyWith(
                    fontSize: Dimensions.fontSizeSmall,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                  ),
                ),
              ]),

            ]),
          ),

        if(!hideServiceName)
        _ServiceItemText(
          title: "unit_price".tr, 
          amount: ((customPrice ?? BookingHelper.getBookingServiceUnitConst(bookingService, allServiceItems, bookingDetails)) / (bookingService?.quantity ?? 1)), 
        ),
      ]),
    );
  }
}


class _ServiceItemText extends StatelessWidget {
  final String title;
  final double amount;

  const _ServiceItemText({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeExtraSmall),
      child: Row(
        children: [
          Text("$title : ",
            style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7)
            ),
          ),
          Text(PriceConverter.convertPrice(amount,isShowLongPrice:true),
            style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall,color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }
}
