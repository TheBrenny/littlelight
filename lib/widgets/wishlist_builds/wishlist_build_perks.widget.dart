import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:flutter/material.dart';
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/widgets/common/manifest_image.widget.dart';
import 'package:little_light/widgets/common/wishlist_badge.widget.dart';

class WishlistBuildPerksWidget extends StatelessWidget {
  final WishlistBuild wishlistBuild;
  final double perkIconSize;

  const WishlistBuildPerksWidget(
      {Key key, this.wishlistBuild, this.perkIconSize = 32})
      : super(key: key);

  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(.5),
            borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [buildTags(context), buildPlugs(context)],
        ));
  }

  Widget buildTags(BuildContext context) {
    var tags = wishlistBuild.tags.toList();
    tags.sort((a, b) => a.index.compareTo(b.index));
    return Container(
        child: Column(
            children: tags
                .map((t) => WishlistBadgeWidget(
                      tag: t,
                    ))
                .toList()));
  }

  Widget buildPlugs(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(left: 8),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: wishlistBuild.perks
                .map((perks) => Column(
                      children: perks
                          .map((p) => Container(
                              width: perkIconSize,
                              height: perkIconSize,
                              child: ManifestImageWidget<
                                  DestinyInventoryItemDefinition>(p)))
                          .toList(),
                    ))
                .toList()));
  }
}
