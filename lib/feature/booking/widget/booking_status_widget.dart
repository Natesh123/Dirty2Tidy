import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';

class BookingStatusButtonWidget extends StatelessWidget {
  final String? bookingStatus;
  const BookingStatusButtonWidget({super.key, this.bookingStatus});

  @override
  Widget build(BuildContext context) {
    String? status = bookingStatus == 'pending' ? 'accepted' : bookingStatus;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeTine, horizontal: Dimensions.paddingSizeEight),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(3),
        color: ColorResources.buttonBackgroundColorMap[status],
      ),
      child: Text( status?.tr ?? "",
        style:robotoMedium.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: Dimensions.fontSizeSmall,
          color: ColorResources.buttonTextColorMap[status],
        ),
      ),
    );
  }
}
