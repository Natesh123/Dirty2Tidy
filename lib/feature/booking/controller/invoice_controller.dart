import 'dart:typed_data';
import 'package:demandium/utils/app_constants.dart';
import 'package:get/get.dart';
import 'package:demandium/helper/date_converter.dart';
import 'package:demandium/feature/booking/controller/booking_details_controller.dart';
import 'package:demandium/feature/booking/model/booking_details_model.dart';
import 'package:demandium/feature/booking/model/invoice.dart';
import 'package:demandium/feature/splash/controller/splash_controller.dart';
import 'package:demandium/utils/dimensions.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:http/http.dart' as http;
import 'package:demandium/helper/booking_helper.dart';


class InvoiceController {
   static Future<Uint8List> generateUint8List(
       BookingDetailsContent bookingDetailsContent,
       List<InvoiceItem> items,
       BookingDetailsController controller) async{
     final pdf = Document();
     ImageProvider? imageProvider;

     try {
       imageProvider = await downloadImage(Get.find<SplashController>().configModel.content!.logoFullPath ?? "");
     }catch (e){
       if (kDebugMode) {
         print(e.toString());
       }
     }


     var invoice = Invoice(
       provider: Provider(
       name: bookingDetailsContent.provider != null? bookingDetailsContent.provider!.companyName! :'',
       address: bookingDetailsContent.provider != null? bookingDetailsContent.provider!.companyAddress!: '',
       phone: bookingDetailsContent.provider != null? bookingDetailsContent.provider!.companyPhone!: '',
      ),
      serviceman: ServicemanInvoice(
        name: bookingDetailsContent.serviceman != null? "${bookingDetailsContent.serviceman!.user!.firstName!} ${bookingDetailsContent.serviceman!.user!.lastName!}":'',
        phone: bookingDetailsContent.serviceman != null? bookingDetailsContent.serviceman!.user!.phone!: '',
      ),
      info: InvoiceInfo(
        date: bookingDetailsContent.serviceSchedule,
        description: 'Payment Status : ',
        number: bookingDetailsContent.readableId.toString(),
        paymentStatus: bookingDetailsContent.partialPayments != null && bookingDetailsContent.partialPayments!.isNotEmpty && bookingDetailsContent.isPaid == 0 ? "Partially paid" : bookingDetailsContent.isPaid == 0 ?"Unpaid": 'Paid',
      ),
      items: items,
    );



    pdf.addPage(MultiPage(
      build: (context) => [
        buildInvoiceImage(imageProvider,bookingDetailsContent,invoice),
        SizedBox(height: 0.6 * PdfPageFormat.cm),
        invoiceIDSchedule(invoice.info.number,invoice.info.date),
        buildHeader(invoice,bookingDetailsContent),
        SizedBox(height: 0.8 * PdfPageFormat.cm),
        buildInvoice(invoice, bookingDetailsContent),
        SizedBox(height:Dimensions.paddingSizeDefault),
        buildTotal(bookingDetailsContent,controller,invoice.info.paymentStatus),
      ],
      footer: (context) => buildFooter(bookingDetailsContent),
    ));

    return pdf.save();
  }

  static Widget invoiceIDSchedule(String invoiceID, String? invoiceSchedule) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text("Invoice # $invoiceID",style: pw.TextStyle(fontWeight: FontWeight.bold)),
      Text("Service Schedule : ${DateConverter.dateMonthYearTimeTwentyFourFormat(DateTime.tryParse(invoiceSchedule ??"")!)}"),
    ]
  );

  static Widget buildHeader(Invoice invoice,BookingDetailsContent content) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(height: 1 * PdfPageFormat.cm),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          serviceAddress(
            name: "${content.customer?.firstName ?? ""} ${content.customer?.lastName ?? ""}",
            address: content.serviceAddress!.address?.replaceAll("null","") ?? "",
            email: content.customer?.email??"",
            phone: content.customer?.phone ?? "",
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
            SizedBox(height: Dimensions.paddingSizeSmall),
            buildProviderSection(invoice.provider,invoice.serviceman),
          ])
        ],
      ),
    ],
  );

  static Widget serviceAddress({
    required String name,
    required String email,
    required String phone,
    required String address}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Service Address", style: TextStyle(fontWeight: FontWeight.bold)),
        buildSimpleText(title: 'Customer Name', value: name),
        if(email!='')
        buildSimpleText(title: 'Email', value: email),
        if(phone!='')
        buildSimpleText(title: 'Phone', value: phone),
        if(address != '' )
          SizedBox(
              width: Get.width*.4,
            child: Text('Address: $address')
          )
    ]
  );

  static Widget buildProviderSection(Provider provider,ServicemanInvoice serviceman) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      if(serviceman.name != '' && serviceman.phone != '')
        Text("Serviceman Details", style: TextStyle(fontWeight: FontWeight.bold)),
      Text(serviceman.name),
      // Text(provider.address),
      Text(serviceman.phone),
      SizedBox(height: Dimensions.paddingSizeDefault),
      if(provider.name != '' && provider.phone != '')
        Text("Provider Details", style: TextStyle(fontWeight: FontWeight.bold)),
      Text(provider.name),
      // Text(provider.address),
      Text(provider.phone),
    ],
  );
  static Widget buildServiceManSection(Serviceman serviceman) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [

    ],
  );

  static Widget buildInvoiceInfo(InvoiceInfo info) {
    final titles = <String>[
      'Invoice Number:',
      'Invoice Date:',
      'Payment Status:',
    ];

    final data = <String?>[
      info.number,
      info.date,
      info.paymentStatus,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(titles.length, (index) {
        final title = titles[index];
        final value = data[index];
        return buildText(title: title, value: value, width: 200);
      }),
    );
  }



  static Widget buildSupplierAddress(Supplier supplier) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(supplier.name, style: TextStyle(fontWeight: FontWeight.bold)),
      SizedBox(height: 1 * PdfPageFormat.mm),
      Text(supplier.address),
    ],
  );

  static Widget buildTitle(Invoice invoice) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'INVOICE',
        style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold),
      ),
      SizedBox(height: 0.8 * PdfPageFormat.cm),
      //Text(invoice.info.description),
      SizedBox(height: 0.8 * PdfPageFormat.cm),
    ],
  );

  static Widget buildInvoice(Invoice invoice, BookingDetailsContent bookingDetailsContent) {
    final headers = [
      'SL',
      'Description',
      'Qty',
      'Unit price',
      'Total',
    ];

    List<List<dynamic>> data = [];
    double minPrice = bookingDetailsContent.bookingDetails?.first.service?.minBiddingPrice?.toDouble() ?? 0;
    String serviceName = bookingDetailsContent.bookingDetails?.first.service?.name ?? "Service";
    int sl = 1;

    String cleanDescription(String text) {
      List<String> parts = text.split('(');
      if (parts.length <= 1) return text;
      String clean = parts[0].trim();
      Set<String> seen = {};
      for (int i = 1; i < parts.length; i++) {
        String part = parts[i].replaceAll(')', '').trim();
        if (!seen.contains(part) && part.isNotEmpty) {
          seen.add(part);
          clean += " ($part)";
        }
      }
      return clean;
    }

    String buildVariantDescription(ItemService item) {
      String description = serviceName;
      String variantDisplay = '';
      if (item.variantKey != null && item.variantKey!.isNotEmpty) {
        variantDisplay = item.variantKey!.replaceAll('-', ' ').trim();
      }
      if (variantDisplay.isNotEmpty && !description.toLowerCase().contains(variantDisplay.toLowerCase())) {
        description = "$description ($variantDisplay)";
      }
      return cleanDescription(description);
    }

    double variantsTotal = 0;
    bookingDetailsContent.bookingDetails?.forEach((element) {
      variantsTotal += BookingHelper.getCleanItemCost(element, bookingDetailsContent);
    });

    double calculatedSubTotal = minPrice + variantsTotal;
    double subTotal;

    if (bookingDetailsContent.bookingDetails != null && bookingDetailsContent.bookingDetails!.length > 1) {
      subTotal = calculatedSubTotal;
    } else {
      if (bookingDetailsContent.totalBookingAmount != null &&
          bookingDetailsContent.totalBookingAmount! >= minPrice &&
          calculatedSubTotal > bookingDetailsContent.totalBookingAmount!) {
        subTotal = bookingDetailsContent.totalBookingAmount!;
      } else {
        subTotal = calculatedSubTotal;
      }
    }

    bool shouldMerge = (subTotal <= minPrice && bookingDetailsContent.bookingDetails?.length == 1);

    // Row 1: Base Service Row (only if not merged)
    if (!shouldMerge && minPrice > 0) {
      String baseDesc = cleanDescription(serviceName);
      data.add([
        sl.toString().padLeft(2, '0'),
        baseDesc,
        "1",
        "\$${minPrice.toStringAsFixed(2)}",
        "\$${minPrice.toStringAsFixed(2)}",
      ]);
      sl++;
    }

    // Rows 2+: All items in bookingDetails
    if (bookingDetailsContent.bookingDetails != null) {
      Set<String> seenRows = {};
      for (int i = 0; i < bookingDetailsContent.bookingDetails!.length; i++) {
        final item = bookingDetailsContent.bookingDetails![i];
        double itemPrice = BookingHelper.getCleanItemCost(item, bookingDetailsContent);
        if (shouldMerge && i == 0) {
          itemPrice = subTotal;
        }

        if (itemPrice > 0 || (shouldMerge && i == 0)) {
          String description;
          if (shouldMerge && i == 0) {
            description = cleanDescription(serviceName);
          } else {
            description = buildVariantDescription(item);
          }

          String rowKey = "${description}_${itemPrice.toStringAsFixed(2)}";
          if (seenRows.contains(rowKey)) continue;
          seenRows.add(rowKey);

          data.add([
            sl.toString().padLeft(2, '0'),
            description,
            item.quantity.toString(),
            "\$${(itemPrice / (item.quantity ?? 1)).toStringAsFixed(2)}",
            "\$${itemPrice.toStringAsFixed(2)}",
          ]);
          sl++;
        }
      }
    }

    return ClipRRect(
      horizontalRadius: Dimensions.paddingSizeExtraSmall,
      verticalRadius: Dimensions.paddingSizeExtraSmall,
      child:  Container(
          color:  PdfColors.white,
          child: TableHelper.fromTextArray(
            headers: headers,
            data: data,
            columnWidths: {
              0: FixedColumnWidth(40),
              1: FlexColumnWidth(3),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1.5),
            },
            border: null,
            headerStyle: TextStyle(fontWeight: FontWeight.bold,),
            headerDecoration: const BoxDecoration(color: PdfColor.fromInt(0xfff0f4f8)),
            cellHeight: 30,
            cellAlignments: {
              0: Alignment.centerLeft,
              1: Alignment.centerLeft,
              2: Alignment.center,
              3: Alignment.center,
              4: Alignment.centerRight,
            },
          )
      ),
    );
  }

  static Widget buildTotal(
      BookingDetailsContent bookingDetailsContent,
      BookingDetailsController controller,
      String paymentStatus) {
    double serviceDiscount = 0;
    bookingDetailsContent.bookingDetails?.forEach((service) {
      serviceDiscount = serviceDiscount + service.discountAmount!;
    });

    double paidAmount = 0;
    
    // SMART SYNC: Recalculate Subtotal to match UI truth
    double minPrice = bookingDetailsContent.bookingDetails?.first.service?.minBiddingPrice?.toDouble() ?? 0;
    double variantsTotal = 0;
    bookingDetailsContent.bookingDetails?.forEach((element) {
      variantsTotal += BookingHelper.getCleanItemCost(element, bookingDetailsContent);
    });
    
    double calculatedSubTotal = minPrice + variantsTotal;
    double subTotal;
    
    if (bookingDetailsContent.bookingDetails != null && bookingDetailsContent.bookingDetails!.length > 1) {
       subTotal = calculatedSubTotal;
    } else {
       if (bookingDetailsContent.totalBookingAmount != null && 
           bookingDetailsContent.totalBookingAmount! >= minPrice && 
           calculatedSubTotal > bookingDetailsContent.totalBookingAmount!) {
         subTotal = bookingDetailsContent.totalBookingAmount!;
       } else {
         subTotal = calculatedSubTotal;
       }
    }
    
    double totalBookingAmount = 0;
    if(bookingDetailsContent.isRepeatBooking == 1){
      totalBookingAmount = subTotal * (bookingDetailsContent.totalCount ?? 1);
    } else {
      totalBookingAmount = subTotal;
    }
    
    // Subtract discounts
    totalBookingAmount = totalBookingAmount - (bookingDetailsContent.totalCouponDiscountAmount ?? 0) 
                        - (bookingDetailsContent.totalCampaignDiscountAmount ?? 0)
                        - (bookingDetailsContent.totalReferralDiscountAmount ?? 0);
    
    bool isPartialPayment = bookingDetailsContent.partialPayments !=null && bookingDetailsContent.partialPayments!.isNotEmpty;
    if(isPartialPayment) {
      bookingDetailsContent.partialPayments?.forEach((element) {
        paidAmount = paidAmount + (element.paidAmount ?? 0);
      });
    }else{
      paidAmount  = totalBookingAmount - (bookingDetailsContent.additionalCharge ?? 0);
    }
    double dueAmount = totalBookingAmount - paidAmount;

    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Payment Status",style: pw.TextStyle(fontWeight: FontWeight.bold)),
              Text(paymentStatus),
            ]
          ),
          Spacer(flex: 3),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                buildText(
                  title: 'Subtotal',
                  value: "\$${subTotal.toStringAsFixed(2)}",
                  unite: true,
                ),
                if(serviceDiscount > 0)
                  buildText(
                    title: 'Service discount',
                    value: '(-) \$${serviceDiscount.toStringAsFixed(2)}',
                    unite: true,
                  ),
                if((bookingDetailsContent.totalCouponDiscountAmount ?? 0) > 0)
                  buildText(
                    title: 'Coupon discount',
                    value: '(-) \$${bookingDetailsContent.totalCouponDiscountAmount!.toStringAsFixed(2)}',
                    unite: true,
                  ),
                if((bookingDetailsContent.totalCampaignDiscountAmount ?? 0) > 0)
                  buildText(
                    title: 'Campaign discount',
                    value: '(-) \$${bookingDetailsContent.totalCampaignDiscountAmount!.toStringAsFixed(2)}',
                    unite: true,
                  ),
                if((bookingDetailsContent.totalReferralDiscountAmount ?? 0) > 0)
                  buildText(
                    title: 'Referral discount',
                    value: '(-) \$${bookingDetailsContent.totalReferralDiscountAmount!.toStringAsFixed(2)}',
                    unite: true,
                  ),
                if((bookingDetailsContent.extraFee ?? 0) > 0)
                  buildText(
                    title: Get.find<SplashController>().configModel.content?.additionalChargeLabelName ?? "",
                    value: "(+) \$${bookingDetailsContent.extraFee?.toStringAsFixed(2)}",
                    unite: true,
                  ),
                // Removed Vat/Tax based on user request

                Divider(),
                bookingDetailsContent.partialPayments != null && bookingDetailsContent.partialPayments!.isNotEmpty ?
                Column(children: [
                  buildText(
                    title: 'Grand Total',
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    value: totalBookingAmount.toStringAsFixed(2),
                    unite: true,
                  ),
                  ListView.builder(itemBuilder: (context, index){

                    String paidWith = bookingDetailsContent.partialPayments?[index].paidWith ?? "";

                    return buildText(
                        title: '${paidWith == "digital" && bookingDetailsContent.paymentMethod == "offline_payment" ? ""  : (paidWith == "wallet" || paidWith == "digital")  ? "Paid by '"  : ""}'
                            '${ paidWith == "digital" && bookingDetailsContent.paymentMethod =="offline_payment" ? "Offline Payment" : paidWith == "digital" ? bookingDetailsContent.paymentMethod :  paidWith =="wallet" ? "wallet" : "Cash After Service" }',
                        value: bookingDetailsContent.partialPayments?[index].paidAmount.toString() ?? "0"
                    );
                  },
                    itemCount: bookingDetailsContent.partialPayments!.length,
                  ),
                  bookingDetailsContent.partialPayments?.length == 1 &&  dueAmount > 0?
                  buildText(
                      title: "Due amount (Cash after service)", value: "$dueAmount"
                  )  : SizedBox(),



                  if(bookingDetailsContent.additionalCharge !=0 && bookingDetailsContent.paymentMethod != "cash_after_service")
                    buildText(
                      title:  bookingDetailsContent.additionalCharge != null
                          && bookingDetailsContent.additionalCharge! > 0 ? (bookingDetailsContent.bookingStatus == "pending" || bookingDetailsContent.bookingStatus == "accepted" || bookingDetailsContent.bookingStatus == "ongoing") ?'Due Amount (Cash after service)' : "Paid Amount (Cash after service)"  : "Refund amount",
                      titleStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.normal,
                      ),
                      value: (bookingDetailsContent.additionalCharge ?? 0).toStringAsFixed(2),
                      unite: true,
                    ),

                ]):
                Column(children: [
                  buildText(
                    title: 'Grand Total',
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    value: totalBookingAmount.toStringAsFixed(2),
                    unite: true,
                  ),
                  if(bookingDetailsContent.additionalCharge != null && bookingDetailsContent.additionalCharge! > 0 && bookingDetailsContent.paymentMethod != "cash_after_service")
                    Column(children: [
                      buildText(
                        title: 'Paid Amount (${bookingDetailsContent.paymentMethod =="offline_payment"? "Offline" : bookingDetailsContent.paymentMethod =="wallet_payment" ? "Wallet" : bookingDetailsContent.paymentMethod =="cash_after_service" ? "Cash After Service" : bookingDetailsContent.paymentMethod})',
                        titleStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                        value: (totalBookingAmount -(bookingDetailsContent.additionalCharge ?? 0)).toStringAsFixed(2),
                        unite: true,
                      ),
                      bookingDetailsContent.additionalCharge! > 0 ?
                      buildText(
                        title:   (bookingDetailsContent.bookingStatus == "pending" || bookingDetailsContent.bookingStatus == "accepted" || bookingDetailsContent.bookingStatus == "ongoing") ?'Due Amount (Cash after service)' : "Paid Amount (Cash after service)",
                        titleStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                        ),
                        value: (bookingDetailsContent.additionalCharge ?? 0).toStringAsFixed(2),
                        unite: true,
                      ): SizedBox(),

                    ])
                ]),
                SizedBox(height: 2 * PdfPageFormat.mm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildFooter(BookingDetailsContent bookingDetailsContent) => Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text("If you require any assistance or have feedback or suggestions about our site, you can call or email us.",textAlign: TextAlign.center),
      SizedBox(height: Dimensions.paddingSizeSmall),

      Container(
        color: PdfColors.grey100,
        width: double.infinity,
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(

          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(Get.find<SplashController>().configModel.content?.businessPhone ?? ""),
                SizedBox(width: 20),
                Text(Get.find<SplashController>().configModel.content?.businessEmail ?? ""),
              ]
            ),
            SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text(AppConstants.baseUrl),
            SizedBox(height: Dimensions.paddingSizeExtraSmall),
            Text(Get.find<SplashController>().configModel.content?.footerText ?? "",
             textAlign: TextAlign.center
           ),
          ]
        )
      ),
    ],
  );

  static buildSimpleText({
    required String title,
    required String value,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        Text(title, style: style),
        SizedBox(width: 2 * PdfPageFormat.mm),
        SizedBox(width: Get.width*.4,child: Text(value)),
      ],
    );
  }

  static buildText({
    required String title,
     String? value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style: unite ? style : null)),
          Text(value ??"", style: unite ? style : null),
        ],
      ),
    );
  }

   static Widget buildInvoiceImage(ImageProvider? netImage,BookingDetailsContent bookingDetailsContent,Invoice invoice) {
     return Container(
       width: Dimensions.invoiceImageWidth,
       height: Dimensions.invoiceImageHeight,
       child: netImage != null ? pw.Image(netImage) : SizedBox(),);
   }

   static Future<ImageProvider> downloadImage(String imageUrl) async {
    http.Response response = await http.get(
        Uri.parse(imageUrl)
     );
     return MemoryImage(response.bodyBytes);
   }
}
