import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';

class ServiceVariantsGridWidget extends StatefulWidget {
  final Service service;
  const ServiceVariantsGridWidget({super.key, required this.service});

  @override
  State<ServiceVariantsGridWidget> createState() => _ServiceVariantsGridWidgetState();
}

class _ServiceVariantsGridWidgetState extends State<ServiceVariantsGridWidget> {
  @override
  void initState() {
    super.initState();
    Get.find<CartController>().setInitialCartList(widget.service);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartController) {
      if (cartController.initialCartList.isEmpty) {
        return const SizedBox();
      }

      // Filter indices to display
      List<int> visibleIndices = [];
      String serviceName = widget.service.name!.trim().toLowerCase();
      
      for(int i=0; i<cartController.initialCartList.length; i++) {
         String variantKey = cartController.initialCartList[i].variantKey;
         String variantName = variantKey.replaceAll('-', ' ').trim().toLowerCase();
         if(variantName != serviceName && variantKey != 'base_service') {
            visibleIndices.add(i);
         }
      }

      if (visibleIndices.isEmpty) {
         return const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveHelper.isDesktop(context) ? 4 : 2,
              crossAxisSpacing: Dimensions.paddingSizeSmall,
              mainAxisSpacing: Dimensions.paddingSizeSmall,
              childAspectRatio: ResponsiveHelper.isDesktop(context) ? 0.9 : 0.85, 
            ),
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: visibleIndices.length,
            itemBuilder: (context, index) {
              // Get actual index
              int realIndex = visibleIndices[index];
              final cartItem = cartController.initialCartList[realIndex];
              
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.2)),
                  boxShadow: Get.isDarkMode ? null : [BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 5,
                    spreadRadius: 1,
                  )],
                ),
                padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Variant Name
                    Text(
                      cartItem.variantKey.replaceAll('-', ' '),
                      style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                    
                    // Image
                    cartItem.variantImage != null && cartItem.variantImage!.isNotEmpty ?
                    CustomImage(
                      image: cartItem.variantImage!,
                      height: 40, width: 40, fit: BoxFit.cover,
                    ) :
                    Image.asset(Images.webAppbarLogo, height: 40),

                    const Spacer(),

                    // Quantity Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                             if (cartController.initialCartList[realIndex].quantity > 0) {
                                cartController.updateQuantity(realIndex, false);
                             }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.remove, size: 16, color: Colors.white),
                          ),
                        ),
                        
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                          child: Text(
                            cartItem.quantity.toString(),
                            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                          ),
                        ),
                        
                        InkWell(
                          onTap: () {
                             cartController.updateQuantity(realIndex, true);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.add, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      );
    });
  }
}
