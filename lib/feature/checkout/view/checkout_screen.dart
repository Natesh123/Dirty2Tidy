// ignore_for_file: deprecated_member_use
import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';


class CheckoutScreen extends StatefulWidget {
  final String pageState;
  final String addressId;
  final bool? reload;
  final String? token;
  final String? amount;
  const CheckoutScreen(this.pageState, this.addressId, {super.key,this.reload = true, this.token, this.amount}) ;
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();}

class _CheckoutScreenState extends State<CheckoutScreen> {

  final tooltipController = JustTheController();

  @override
  void initState() {
    if(widget.pageState == 'complete') {
      Get.find<CheckOutController>().updateState(PageState.complete,shouldUpdate: false);
    }
    Get.find<CheckOutController>().getOfflinePaymentMethod(true);

    Get.find<CheckOutController>().changePaymentMethod(shouldUpdate: false);

    if(widget.pageState == 'orderDetails'){
      Get.find<CartController>().getCartListFromServer(shouldUpdate: false);
      Get.find<ScheduleController>().resetScheduleData(shouldUpdate: false);
      Get.find<CheckOutController>().resetCreateAccountWithExistingInfo();
      Get.find<CheckOutController>().toggleTerms(value: false, shouldUpdate: false);
      Get.find<ScheduleController>().resetSchedule();
      Get.find<LocationController>().updateSelectedServiceLocationType();
    }else{
      Get.find<CheckOutController>().toggleTerms(value: true, shouldUpdate: false);
    }
    if(widget.token !=null && widget.token != "null" && widget.token != ""){
      Get.find<CheckOutController>().parseToken(widget.token!);
    }
    Get.find<CartController>().updateWalletPaymentStatus(false, shouldUpdate: false);

    Get.find<CouponController>().getCouponList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CheckOutController>().showPendingCredentialsDialog();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()  => _exitApp(),
      child: GetBuilder<CheckOutController>(builder: (checkoutController){
        return Scaffold(
          resizeToAvoidBottomInset: false,
          endDrawer: ResponsiveHelper.isDesktop(context) ? const MenuDrawer() : null,
          appBar: CustomAppBar( title: 'checkout'.tr,
            onBackPressed: () {
              if(widget.pageState == 'payment' || checkoutController.currentPageState == PageState.payment) {
                if(widget.pageState == 'payment'){
                  Get.back();
                }else{
                  checkoutController.changePaymentMethod();
                  checkoutController.updateState(PageState.orderDetails);
                  if(ResponsiveHelper.isWeb()) {
                    Get.toNamed(RouteHelper.getCheckoutRoute('cart','orderDetails','null'));
                  }
                }
              } else if(widget.pageState == 'complete' || Get.find<CheckOutController>().currentPageState == PageState.complete){
                Get.offAllNamed(RouteHelper.getMainRoute('home'));
                return false;
              } else {
                checkoutController.updateState(PageState.orderDetails);
                Get.back();
              }
            }
          ),
          body: SafeArea(child: FooterBaseView( child: WebShadowWrap(
            child: SizedBox(width: Dimensions.webMaxWidth, child:  Column(mainAxisAlignment: MainAxisAlignment.start, children: [

              const SizedBox(height: Dimensions.paddingSizeDefault,),
              CheckoutHeaderWidget(pageState: widget.pageState,),

              (checkoutController.currentPageState == PageState.complete || widget.pageState == 'complete') ? 
              CompletePage(token: widget.token,) :
              (checkoutController.currentPageState == PageState.payment || widget.pageState == 'payment') ?
              PaymentPage(addressId: widget.addressId, tooltipController: tooltipController,fromPage: "checkout", bookingAmount: double.tryParse(widget.amount ?? ""),) :
              (ResponsiveHelper.isDesktop(context) ? OrderDetailsPageWeb(pageState: widget.pageState,addressId: widget.addressId) :  const OrderDetailsPage()),


              (!ResponsiveHelper.isMobile(context) && widget.pageState != 'complete') ?
              ProceedToCheckoutButtonWidget(pageState: widget.pageState,addressId: widget.addressId, amount: double.tryParse(widget.amount ?? ""),) : const SizedBox(height: 120,)

            ]))
          ))),

          bottomSheet:  (ResponsiveHelper.isMobile(context)) ? SafeArea( child: SizedBox( height: checkoutController.currentPageState.name=="complete"? 70 : 100,
            child: (checkoutController.currentPageState == PageState.complete || widget.pageState == 'complete') ?
            const SizedBox() : ProceedToCheckoutButtonWidget(pageState: widget.pageState,addressId: widget.addressId, amount: double.tryParse(widget.amount ?? ""),),
          )): const SizedBox(),
        );
      }),
    );
  }


  Future<bool> _exitApp() async {
    if(widget.pageState == 'payment' || Get.find<CheckOutController>().currentPageState == PageState.payment) {
      if(widget.pageState == 'payment'){
        return true;
      }
      Get.find<CheckOutController>().changePaymentMethod();
      Get.find<CheckOutController>().updateState(PageState.orderDetails);
      Get.find<CheckOutController>().getOfflinePaymentMethod(true);
      Get.find<CheckOutController>().changePaymentMethod(shouldUpdate: true);
      if(ResponsiveHelper.isWeb()) {
        Get.toNamed(RouteHelper.getCheckoutRoute('cart','orderDetails','null',reload: false));
      }
      return false;
    } else if(widget.pageState == 'complete' || Get.find<CheckOutController>().currentPageState == PageState.complete){
      Get.offAllNamed(RouteHelper.getMainRoute('home'));
      return false;
    }else {
      return true;
    }
  }
}



