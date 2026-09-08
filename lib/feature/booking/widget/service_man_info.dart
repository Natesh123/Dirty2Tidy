import 'package:demandium/common/models/user_model.dart';
import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';
class ServiceManInfo extends StatelessWidget {
  final User user;
  final String bookingId;
  final String userId;
  const ServiceManInfo({super.key, required this.user, required this.bookingId, required this.userId}) ;

  @override
  Widget build(BuildContext context) {
    return Container(
      width:double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
        color: Theme.of(context).hoverColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Text("service_man_info".tr, style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault,
                  color:Get.isDarkMode? Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .6): Theme.of(context).primaryColor))),
          Gaps.verticalGapOf(Dimensions.paddingSizeSmall),

          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(Dimensions.paddingSizeExtraLarge)),
            child: SizedBox(
              width: Dimensions.imageSize,
              height: Dimensions.imageSize,
              child:  CustomImage(image: user.profileImageFullPath ?? ""),

            ),
          ),
          Gaps.verticalGapOf(Dimensions.paddingSizeExtraSmall),
          Text("${user.firstName ?? ""} ${user.lastName ?? ""}",style:robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault,)),
          Gaps.verticalGapOf(Dimensions.paddingSizeExtraSmall),
          Text(user.phone ?? "",style:robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault,)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  String name = "${user.firstName ?? ""}" " ${user.lastName ?? ""}";
                  String phone = user.phone ?? "";
                  String image = user.profileImageFullPath ?? "";
                  Get.find<ConversationController>().createChannel(userId, bookingId, name: name, image: image, fromBookingDetailsPage: true, phone: phone);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.chat, color: Theme.of(context).primaryColorLight, size: 16),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text('chat'.tr, style: robotoMedium.copyWith(color: Theme.of(context).primaryColorLight)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              InkWell(
                onTap: () async {
                  final Uri url = Uri(scheme: 'tel', path: user.phone ?? "");
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    border: Border.all(color: Theme.of(context).colorScheme.primary),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.call, color: Theme.of(context).colorScheme.primary, size: 16),
                      const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                      Text('call'.tr, style: robotoMedium.copyWith(color: Theme.of(context).colorScheme.primary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
