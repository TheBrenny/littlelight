import 'dart:async';

import 'package:bungie_api/enums/destiny_item_type_enum.dart';
import 'package:bungie_api/models/destiny_character_component.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:little_light/screens/search.screen.dart';
import 'package:little_light/services/bungie_api/enums/destiny_item_category.enum.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/notification/notification.service.dart';
import 'package:little_light/services/profile/profile.service.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/utils/selected_page_persistence.dart';
import 'package:little_light/widgets/common/animated_character_background.widget.dart';
import 'package:little_light/widgets/flutter/passive_tab_bar_view.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab.widget.dart';
import 'package:little_light/widgets/inventory_tabs/character_tab_header.widget.dart';
import 'package:little_light/widgets/inventory_tabs/inventory_notification.widget.dart';
import 'package:little_light/widgets/inventory_tabs/selected_items.widget.dart';
import 'package:little_light/widgets/inventory_tabs/tabs_character_menu.widget.dart';
import 'package:little_light/widgets/inventory_tabs/tabs_item_type_menu.widget.dart';
import 'package:little_light/widgets/inventory_tabs/vault_tab.widget.dart';
import 'package:little_light/widgets/inventory_tabs/vault_tab_header.widget.dart';

class EquipmentScreen extends StatefulWidget {
  final profile = new ProfileService();
  final manifest = new ManifestService();
  final NotificationService broadcaster = new NotificationService();

  final List<int> itemTypes = [
    DestinyItemCategory.Weapon,
    DestinyItemCategory.Armor,
    DestinyItemCategory.Inventory
  ];

  @override
  EquipmentScreenState createState() => new EquipmentScreenState();
}

class EquipmentScreenState extends State<EquipmentScreen>
    with TickerProviderStateMixin {
  int currentGroup = DestinyItemType.Weapon;
  Map<int, double> scrollPositions = new Map();

  TabController charTabController;
  TabController typeTabController;
  StreamSubscription<NotificationEvent> subscription;

  get totalCharacterTabs =>
      characters?.length != null ? characters.length + 1 : 4;

  @override
  void initState() {
    SelectedPagePersistence.saveLatestScreen(SelectedPagePersistence.equipment);

    typeTabController = typeTabController ??
        TabController(
          initialIndex: 0,
          length: widget.itemTypes.length,
          vsync: this,
        );
    charTabController = charTabController ??
        TabController(
          initialIndex: 0,
          length: totalCharacterTabs,
          vsync: this,
        );

    widget.itemTypes.forEach((type) {
      scrollPositions[type] = 0;
    });
    super.initState();

    subscription = widget.broadcaster.listen((event) {
      if (!mounted) return;
      if (event.type == NotificationType.receivedUpdate) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (characters == null) {
      return Container();
    }
    EdgeInsets screenPadding = MediaQuery.of(context).padding;
    var topOffset = screenPadding.top + kToolbarHeight;
    return Material(
      child: Stack(
        children: <Widget>[
          buildBackground(context),
          buildItemTypeTabBarView(context),
          Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: topOffset + 16,
              child: buildCharacterHeaderTabView(context)),
          Positioned(
            top: screenPadding.top,
            width: kToolbarHeight,
            height: kToolbarHeight,
            child: IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
          ),
          Positioned(
              top: MediaQuery.of(context).padding.top + kToolbarHeight - 52,
              right: 8,
              child: buildCharacterMenu(context)),
          ItemTypeMenuWidget(widget.itemTypes, controller: typeTabController),
          InventoryNotificationWidget(
              key: Key('inventory_notification_widget')),
          Positioned(
              bottom: screenPadding.bottom,
              left: 0,
              right: 0,
              child: SelectedItemsWidget()),
        ],
      ),
    );
  }

  Widget buildCharacterHeaderTabView(BuildContext context) {
    var headers = characters
        .map((character) => TabHeaderWidget(
              character,
              key: Key("${character.emblemHash}"),
            ))
        .toList();
    headers.add(VaultTabHeaderWidget());
    return TabBarView(controller: charTabController, children: headers);
  }

  Widget buildBackground(BuildContext context) {
    return AnimatedCharacterBackgroundWidget(
      tabController: charTabController,
    );
  }

  Widget buildItemTypeTabBarView(BuildContext context) {
    return TabBarView(
        controller: typeTabController, children: buildItemTypeTabs(context));
  }

  List<Widget> buildItemTypeTabs(BuildContext context) {
    return widget.itemTypes
        .map((type) => buildCharacterTabBarView(context, type))
        .toList();
  }

  Widget buildCharacterTabBarView(BuildContext context, int group) {
    return PassiveTabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: charTabController,
        children: buildCharacterTabs(group));
  }

  List<Widget> buildCharacterTabs(int group) {
    List<Widget> characterTabs = characters.map((character) {
      return CharacterTabWidget(character, group,
          key: Key("character_tab_${character.characterId}"),
          scrollPositions: scrollPositions);
    }).toList();
    characterTabs.add(VaultTabWidget(group));
    return characterTabs;
  }

  List<DestinyCharacterComponent> get characters {
    return widget.profile
        .getCharacters(UserSettingsService().characterOrdering);
  }

  buildCharacterMenu(BuildContext context) {
    return Row(children: [
      IconButton(
          icon: Icon(FontAwesomeIcons.search, color: Colors.white),
          onPressed: () {
            SearchTabData searchData;
            switch (typeTabController.index) {
              case 0:
                searchData = SearchTabData.weapons();
                break;
              case 1:
                int classType;
                if(charTabController.index < characters.length){
                  DestinyCharacterComponent char = characters[charTabController.index];
                  classType = char?.classType;
                }
                searchData = SearchTabData.armor(classType);
                break;
              case 2:
                searchData = SearchTabData.flair();
                break;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SearchScreen(
                  tabData: searchData,
                ),
              ),
            );
          }),
      TabsCharacterMenuWidget(characters, controller: charTabController)
    ]);
  }
}
