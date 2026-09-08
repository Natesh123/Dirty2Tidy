import 'dart:math';
import 'package:demandium/utils/core_export.dart';
import 'package:get/get.dart';
import 'package:demandium/feature/category/controller/category_controller.dart';
import 'package:demandium/feature/category/model/category_model.dart';

class RecommendedSearch extends StatefulWidget {
  const RecommendedSearch({super.key}) ;

  @override
  State<RecommendedSearch> createState() => _RecommendedSearchState();
}

class _RecommendedSearchState extends State<RecommendedSearch> {
  List<CategoryModel> _shuffledCategories = [];

  @override
  void initState() {
    super.initState();
    _shuffleCategories();
  }

  void _shuffleCategories() {
    final categoryList = Get.find<CategoryController>().categoryList;
    if (categoryList != null && categoryList.isNotEmpty) {
      _shuffledCategories = List.from(categoryList)..shuffle();
      if (_shuffledCategories.length > 10) {
        _shuffledCategories = _shuffledCategories.take(10).toList();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(
      builder: (categoryController){
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(
              'Recommended Categories For You'.tr,style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge -1),
              overflow: TextOverflow.ellipsis,
            )),

            const SizedBox(width: Dimensions.paddingSizeSmall,),

            categoryController.categoryList != null && categoryController.categoryList!.isEmpty ? const SizedBox() :InkWell(
              onTap: () {
                setState(() {
                  _shuffleCategories();
                });
              },
              child: Row(children: [
                Text('shuffle'.tr,style: robotoMedium.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .5),

                ),),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                Icon(Icons.cached,size: 16, color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .5),)
              ],),
            )
          ]),
          const SizedBox(height: Dimensions.paddingSizeDefault,),

          (_shuffledCategories.isNotEmpty) ? Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeSmall),
            child: SizedBox( height: 40,
              child: ListView.builder(
                shrinkWrap: true, scrollDirection: Axis.horizontal,
                itemBuilder: (context,index){
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(color: Theme.of(context).hintColor.withValues(alpha: 0.5)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
                  margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                  child: Center(
                    child: Padding(padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      child: InkWell(
                        hoverColor: Colors.transparent,
                        onTap: (){
                          Get.back();
                          FocusScope.of(context).unfocus();
                          CategoryModel category = _shuffledCategories[index];
                          Get.toNamed(RouteHelper.getCategoryServiceFormRoute(
                              category.id ?? '',
                              category.name ?? '',
                              category.imageFullPath ?? '',
                          ));
                          Get.find<AllSearchController>().populatedSearchController(category.name??'');
                         },
                        child: Text(
                          _shuffledCategories[index].name??"",
                          style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: .8)),
                        ),
                      ),
                    ),
                  ),
                );
               },
                itemCount: _shuffledCategories.length,
               ),
            ),
          ) : categoryController.categoryList != null && categoryController.categoryList!.isEmpty ?
          Padding(
            padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeSmall),
            child: Text("no_categories_available".tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor),),
          ) : const RecommendedSearchShimmer(),

        ]);
    });
  }
}

class RecommendedSearchShimmer extends StatelessWidget {
  const RecommendedSearchShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault, top: Dimensions.paddingSizeSmall),
      child: SizedBox( height: 40,
        child: ListView.builder(
          shrinkWrap: true, scrollDirection: Axis.horizontal,
          itemCount: 5,
          itemBuilder: (context, index) {
            return Shimmer(
              duration: const Duration(seconds: 3),
              interval: const Duration(seconds: 5),
              color: Theme.of(context).colorScheme.surface,
              colorOpacity: 0,
              enabled: true,
              child: Container(width: (Random().nextInt(150) + 100),
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                margin: const EdgeInsets.only(right: Dimensions.paddingSizeSmall),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: Theme.of(context).shadowColor,
                ),

                child: Row(children: [
                  const SizedBox(width: Dimensions.paddingSizeExtraSmall,),
                  Expanded(
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeEight,),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                    ),
                  ),
                ],),
              ),
            );
          },
        ),
      ),
    );
  }
}


