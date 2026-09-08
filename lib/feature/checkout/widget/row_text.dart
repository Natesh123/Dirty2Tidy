import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class RowText extends StatelessWidget {
  final String title;
  final int? quantity;
  final int? days;
  final double price;
  final bool isMainService;

  const RowText({super.key,required this.title,required this.price,this.quantity, this.days, this.isMainService = false}) ;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: ResponsiveHelper.isWeb() ? 200 : Get.width / 2,
                  child: RichText(
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).textTheme.bodyLarge!.color),
                      children: [
                        TextSpan(text: title),
                        if(isMainService)
                          TextSpan(text: " (Main Service)", style: robotoBold),
                      ]
                    )
                  ),
                ),
                Text( quantity == null ? "" : " x $quantity"),
                if(days != null && days! > 1)
                  Text(" ($days ${'days'.tr})", style: robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),),
              ],
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text('${title.contains('Discount') || title.contains('خصم') ? '(-)': title == 'VAT' || title == 'برميل'? '(+)':''} ${PriceConverter.convertPrice(double.parse(price.toString()),isShowLongPrice:true)}',
              textAlign: TextAlign.right,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
            ),
          )
        ],
      ),
    );
  }
}
