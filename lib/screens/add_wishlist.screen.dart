import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:http/http.dart' as http;
import 'package:little_light/models/wish_list.dart';
import 'package:little_light/services/translate/translate.service.dart';
import 'package:little_light/services/user_settings/user_settings.service.dart';
import 'package:little_light/widgets/common/header.wiget.dart';
import 'package:little_light/widgets/common/translated_text.widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class AddWishlistScreen extends StatefulWidget {
  final UserSettingsService settings = new UserSettingsService();
  @override
  _AddWishlistScreenState createState() => _AddWishlistScreenState();
}

class _AddWishlistScreenState extends State<AddWishlistScreen> {
  final Map<String, TextEditingController> fieldControllers = Map();
  List<Wishlist> popular;
  Map<String, String> labelTranslations = Map();

  @override
  void initState() {
    super.initState();
    loadPopular();
    fetchTranslations();
  }

  fetchTranslations() async {
    TranslateService translate = new TranslateService();
    var labels = ["URL", "Name", "Description"];
    for (var l in labels) {
      labelTranslations[l] = await translate.getTranslation(l);
    }
    setState(() {});
  }

  loadPopular() async {
    var res = await http.get(
        "https://gist.githubusercontent.com/marquesinijatinha/7e91f59b666c0d9b65f50900cdd49831/raw/ed73e69929e89d03f624f872c7b8f71d1d38b257/popular_wishlists.json");
    List<dynamic> json = jsonDecode(res.body);
    popular = json.map((j) => Wishlist.fromJson(j)).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: TranslatedTextWidget("Add Wishlist"),
        ),
        body: SingleChildScrollView(
            padding: EdgeInsets.all(8),
            child: Column(children: <Widget>[
              buildTextField(context, "URL", maxLength: null),
              buildTextField(context, "Name"),
              buildTextField(context, "Description",
                  multiline: true, maxLength: 300),
              Container(
                  alignment: Alignment.centerRight,
                  child: buildButton(context, "Add Wishlist", () {
                    bool isValidUrl = Uri.parse(this.fieldControllers["URL"].text).isAbsolute;
                    if(!isValidUrl){
                      return;
                    }
                     Navigator.of(context).pop(
                       Wishlist(
                         url:this.fieldControllers["URL"].text,
                         name:this.fieldControllers["Name"].text,
                         description:this.fieldControllers["Description"].text,
                       )
                     );
                  })),
              buildDivider(context),
              Container(
                  padding: EdgeInsets.all(8),
                  child: TranslatedTextWidget(
                      "For more information on how wishlists works, or on how to create your own wishlist, please look at:")),
              Container(
                  padding: EdgeInsets.all(8),
                  child: Linkify(
                    text:
                        "https://github.com/DestinyItemManager/DIM/blob/master/docs/COMMUNITY_CURATIONS.md",
                    linkStyle: TextStyle(color: Colors.white),
                    onOpen: onLinkClick,
                  )),
              buildDivider(context),
              buildPopularWishlists(context),
            ])));
  }

  onLinkClick(LinkableElement link) {
    launch(link.url, forceSafariVC: true);
  }

  Widget buildTextField(BuildContext context, String label,
      {String initialValue = "", int maxLength = 50, bool multiline = false}) {
    var controller = fieldControllers[label];
    if (controller == null) {
      controller =
          fieldControllers[label] = TextEditingController(text: initialValue,);
    }
    return Container(
        padding: EdgeInsets.all(8),
        child: TextField(
          maxLines: multiline ? null : 1,
          maxLength: maxLength,
          autocorrect: false,
          controller: controller,
          decoration:
              InputDecoration(labelText: labelTranslations[label] ?? label),
        ));
  }

  Widget buildButton(BuildContext context, String label, Function onPressed) {
    return RaisedButton(
      child: Text(label),
      onPressed: onPressed,
    );
  }

  Widget buildDivider(BuildContext context) {
    return Container(
        color: Colors.white,
        height: 1,
        margin: EdgeInsets.symmetric(vertical: 16));
  }

  Widget buildPopularWishlists(BuildContext context) {
    if (popular == null) {
      return buildLoadingAnim(context);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      HeaderWidget(
          alignment: Alignment.centerLeft,
          child: TranslatedTextWidget(
            "Popular wishlists",
            uppercase: true,
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
      Container(
        height: 8,
      ),
      buildWishlistsList(context)
    ]);
  }

  Widget buildLoadingAnim(BuildContext context) {
    return Center(
        child: Container(
            width: 96,
            child: Shimmer.fromColors(
              baseColor: Colors.blueGrey.shade300,
              highlightColor: Colors.white,
              child: Image.asset("assets/anim/loading.webp"),
            )));
  }

  buildWishlistsList(BuildContext context) {
    return Column(
        children: popular
            .map((w) => Container(
                padding: EdgeInsets.all(8),
                child: Material(
                    color: Colors.blueGrey.shade600,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Material(
                              color: Colors.lightBlue.shade600,
                              child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    w.name,
                                    style:
                                        TextStyle(fontWeight: FontWeight.w700),
                                  ))),
                          Container(
                              padding: EdgeInsets.all(8).copyWith(bottom: 0),
                              child: Linkify(
                                  text: w.description,
                                  linkStyle: TextStyle(color: Colors.white),
                                  onOpen: onLinkClick)),
                          Container(
                              padding: EdgeInsets.all(8),
                              child: Row(children: [
                                Expanded(child: Container()),
                                RaisedButton(
                                    child: TranslatedTextWidget("Add Wishlist"),
                                    onPressed: () {
                                      Navigator.of(context).pop(w);
                                    })
                              ]))
                        ]))))
            .toList());
  }
}