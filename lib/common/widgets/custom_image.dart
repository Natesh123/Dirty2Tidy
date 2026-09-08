import 'package:demandium/utils/core_export.dart';

class CustomImage extends StatelessWidget {
  final String? image;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final BoxFit? placeHolderBoxFit;
  final String? placeholder;
  const CustomImage({super.key, @required this.image, this.height, this.width, this.fit = BoxFit.cover, this.placeholder, this.placeHolderBoxFit });

  @override
  Widget build(BuildContext context) {
    bool isUrlInvalid = image == null || image!.isEmpty || image!.contains('null');

    final Widget placeholderWidget = Container(
      color: Theme.of(context).hintColor.withValues(alpha: 0.1),
      child: Center(
        child: Image.asset(
          placeholder ?? Images.placeholder,
          height: height != null ? height! / 2 : null,
          width: width != null ? width! / 2 : null,
          fit: BoxFit.contain,
          errorBuilder: (c, e, s) => Icon(Icons.image_outlined, size: height != null ? height! / 2 : 24, color: Theme.of(context).hintColor),
        ),
      ),
    );

    if (isUrlInvalid) {
      return placeholderWidget;
    }

    return kIsWeb ? Image.network(
        image!,
        height: height, width: width, fit: fit,
        filterQuality: FilterQuality.low, // Improves performance for large images on web
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholderWidget;
        },
        errorBuilder: (context, error, stackTrace) {
          return placeholderWidget;
        }) : CachedNetworkImage(
      imageUrl: image!,
      height: height, width: width, fit: fit,
      placeholder: (context, url) => placeholderWidget,
      errorWidget: (context, url, error) => placeholderWidget,
    );
  }
}
