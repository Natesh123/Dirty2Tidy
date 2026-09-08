import 'package:get/get.dart';
import 'package:demandium/utils/core_export.dart';

class GuestAccountCreatedDialog extends StatelessWidget {
  final Map<String, dynamic> credentials;
  const GuestAccountCreatedDialog({super.key, required this.credentials});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge)),
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: ResponsiveHelper.isWeb() ? Dimensions.webMaxWidth / 2.5 : double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Gradient
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radiusExtraLarge),
                  topRight: Radius.circular(Dimensions.radiusExtraLarge),
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white, size: 50),
                  const SizedBox(height: 10),
                  Text(
                    "Your guest account has been created".tr,
                    style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge),
              child: Column(
                children: [
                  Text(
                   "These are your login credentials".tr,
                    textAlign: TextAlign.center,
                    style: robotoRegular.copyWith(
                      color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.7),
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  // Username Field
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.email_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("User Name".tr, style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).hintColor)),
                            Text(credentials['user_name'] ?? "", style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Dimensions.paddingSizeDefault),
                  
                  // Password Field
                  Container(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                      border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.primary, size: 20),
                        const SizedBox(width: Dimensions.paddingSizeSmall),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Password".tr, style: robotoRegular.copyWith(fontSize: 10, color: Theme.of(context).hintColor)),
                            Text(credentials['password'] ?? "", style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // OK Button
                  CustomButton(
                    buttonText: 'OK'.tr,
                    onPressed: () => Get.back(),
                    radius: Dimensions.radiusLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
