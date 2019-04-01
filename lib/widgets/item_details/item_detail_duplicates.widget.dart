import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_instance_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:little_light/screens/item_detail.screen.dart';
import 'package:little_light/utils/item_with_owner.dart';
import 'package:little_light/widgets/common/destiny_item.widget.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:little_light/widgets/item_list/items/base/base_item_instance.widget.dart';

class ItemDetailDuplicatesWidget extends DestinyItemWidget {
  final List<ItemWithOwner> duplicates;

  ItemDetailDuplicatesWidget(
      DestinyItemComponent item,
      DestinyInventoryItemDefinition definition,
      DestinyItemInstanceComponent instanceInfo,
      {Key key,
      this.duplicates})
      : super(item, definition, instanceInfo, key: key);

  @override
  Widget build(BuildContext context) {
    if ((duplicates?.length ?? 0) < 1) {
      return Container();
    }
    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        children: <Widget>[
          HeaderWidget(
              child: Container(
            alignment: Alignment.centerLeft,
            child: TranslatedTextWidget(
              "Duplicates",
              uppercase: true,
              textAlign: TextAlign.left,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          )),
          Container(height: 8),
          buildDuplicatedItems(context)
        ],
      ),
    );
  }

  Widget buildDuplicatedItems(BuildContext context) {
    return StaggeredGridView.count(
        padding: EdgeInsets.all(0),
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        crossAxisCount: 2,
        staggeredTiles:
            duplicates.map((item) => StaggeredTile.extent(1, 110)).toList(),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: duplicates
            .map((item) => buildItemInstance(item, context))
            .toList());
  }

  Widget buildItemInstance(ItemWithOwner item, BuildContext context) {
    var instance = profile.getInstanceInfo(item.item.itemInstanceId);
    return BaseItemInstanceWidget(
      item.item,
      definition,
      instance,
      characterId: item.ownerId,
      uniqueId: null,
      onTap: (item, definition, instance, characterId) {
        if (this.instanceInfo != null) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDetailScreen(
                      item,
                      definition,
                      instance,
                      characterId: characterId,
                      uniqueId: null,
                    ),
              ));
        }else{
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ItemDetailScreen(
                      item,
                      definition,
                      instance,
                      characterId: characterId,
                      uniqueId: null,
                    ),
              ));
        }
      },
    );
  }
}