import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class AddressAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool? backButton;
  const AddressAppBar({super.key, this.backButton = true});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:Get.isDarkMode ? Theme.of(context).cardColor.withValues(alpha: .2):Theme.of(context).primaryColor,
      shape: Border(bottom: BorderSide(width: .4, color: Theme.of(context).primaryColorLight.withValues(alpha: .2))),
      elevation: 0, leadingWidth: backButton! ? Dimensions.paddingSizeLarge : 0,
      leading: backButton! ? IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        color: Theme.of(context).cardColor,
        onPressed: () => Navigator.pop(context),
      ):
      const SizedBox(),
      title: Row( children: [
        Expanded(
          child: InkWell(
            hoverColor: Colors.transparent,
            onTap: () => Get.toNamed(RouteHelper.getAccessLocationRoute('address')),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('services_in'.tr, style: robotoRegular.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall)),
              const SizedBox(height: Dimensions.paddingSizeTine),
              GetBuilder<LocationController>(builder: (locationController) {
                return Row(crossAxisAlignment: CrossAxisAlignment.center, mainAxisAlignment: MainAxisAlignment.start, children: [
                  if(locationController.getUserAddress() != null) Flexible(
                    child: Text(
                      locationController.getUserAddress()!.address!,
                      style: robotoMedium.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeSmall), maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 12),
                  const SizedBox(width: Dimensions.paddingSizeLarge,)
                ]);
              }),
            ]),
          ),
        ),
        GetBuilder<ConversationController>(builder: (conversationController) {
          int unreadCount = conversationController.unreadConversationCount;
          return InkWell(
            hoverColor: Colors.transparent,
            onTap: () => Get.toNamed(Get.find<AuthController>().isLoggedIn()
                ? RouteHelper.getInboxScreenRoute()
                : RouteHelper.getNotLoggedScreen(RouteHelper.chatInbox, "inbox")),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.chat_bubble_outline_rounded, size: 23, color: Colors.white),
                if (unreadCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        InkWell(
          hoverColor: Colors.transparent,
          onTap: () => Get.toNamed(RouteHelper.getNotificationRoute()),
          child: const Icon(Icons.notifications, size: 25, color: Colors.white),
        ),
      ]),
    );
  }
  @override
  Size get preferredSize => Size(Dimensions.webMaxWidth, GetPlatform.isDesktop ? 70 :  56);
}