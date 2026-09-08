import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class ProviderInfo extends StatelessWidget {
  final ProviderData ? provider;
  final String bookingId;
  const ProviderInfo({super.key, required this.provider, required this.bookingId}) ;

  @override
  Widget build(BuildContext context) {

    return Container(
      width:double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(Dimensions.radiusDefault)),
        color: Theme.of(context).hoverColor,
      ),
      padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
      child: Column( children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
          child: Text("provider_info".tr, style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeDefault,
          )),
        ),
        Gaps.verticalGapOf(Dimensions.paddingSizeSmall),

        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: SizedBox(
            width: Dimensions.imageSize,
            height: Dimensions.imageSize,
            child: CustomImage(image: provider?.logoFullPath ?? "", placeholder: Images.userPlaceHolder),
          ),
        ),
        Gaps.verticalGapOf(Dimensions.paddingSizeExtraSmall),
        if(provider?.companyName !=null) Text(provider?.companyName ??"",style:robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault,)),
        Gaps.verticalGapOf(Dimensions.paddingSizeExtraSmall),
        Text(provider == null ? "no_provider_assigned".tr : provider?.companyPhone ?? "",
          style:robotoRegular.copyWith(
            fontSize: provider == null ? Dimensions.fontSizeSmall : Dimensions.fontSizeDefault,
          ),
        ),
        Gaps.verticalGapOf(Dimensions.paddingSizeSmall),
        if(provider != null) Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                if(provider!.chatEligibility == true){
                  String name = provider!.companyName!;
                  String image = provider!.logoFullPath ?? "";
                  String phone = provider!.companyPhone??"";
                  Get.find<ConversationController>().createChannel(provider!.userId!, bookingId,name: name,image: image,fromBookingDetailsPage: true,phone: phone,userType: "provider");
                }else{
                  customSnackBar("this_provider_have_not_permission_to_chat".tr, showDefaultSnackBar: false);
                }
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
                final Uri url = Uri(scheme: 'tel', path: provider!.companyPhone ?? "");
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
      ]),
    );
  }
}
