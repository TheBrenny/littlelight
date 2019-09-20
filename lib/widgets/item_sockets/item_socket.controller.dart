import 'package:bungie_api/models/destiny_inventory_item_definition.dart';
import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_item_socket_state.dart';
import 'package:flutter/widgets.dart';
import 'package:little_light/services/profile/profile.service.dart';

class ItemSocketController extends ChangeNotifier{
  final DestinyItemComponent item;
  final DestinyInventoryItemDefinition definition;
  List<DestinyItemSocketState> _socketStates;
  List<int> _selectedSockets;
  
  List<int> get selectedSockets=>_selectedSockets;

  ItemSocketController({this.item, this.definition}){
    var entries = definition?.sockets?.socketEntries;
    this._socketStates = ProfileService().getItemSockets(item?.itemInstanceId);
    this._selectedSockets = entries?.map((e)=>socketEquippedPlugHash(entries.indexOf(e)))?.toList() ?? [];
    
  }

  List<int> socketPlugHashes(int socketIndex) {
    if (_socketStates != null) {
      var state = _socketStates?.elementAt(socketIndex);
      if (state.isVisible == false) return null;
      if (state.plugHash == null) return null;
      if((state?.reusablePlugHashes?.length ?? 0) > 0){
        return state?.reusablePlugHashes;
      }
      return [state?.plugHash].where((s) => s != null).toList();
    }
    var entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);
    if (entry?.reusablePlugItems != null) {
      return entry?.reusablePlugItems?.map((p) => p.plugItemHash)?.toList();
    }
    if (entry?.randomizedPlugItems != null) {
      return entry?.randomizedPlugItems?.map((p) => p.plugItemHash)?.toList();
    }
    return [];
  }

  int socketEquippedPlugHash(int socketIndex) {
    if (_socketStates != null) {
      var state = _socketStates?.elementAt(socketIndex);
      return state.plugHash ?? state?.reusablePlugHashes?.elementAt(0);
    }
    var entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);
    return entry?.singleInitialItemHash ??
        entry.reusablePlugItems?.elementAt(0)?.plugItemHash ??
        entry.randomizedPlugItems?.elementAt(0)?.plugItemHash;
  }

  int socketSelectedPlugHash(int socketIndex) {
    var selected = selectedSockets?.elementAt(socketIndex);
    if(selected != null) return selected;
    if (_socketStates != null) {
      var state = _socketStates?.elementAt(socketIndex);
      return state.plugHash ?? state?.reusablePlugHashes?.elementAt(0);
    }
    var entry = definition?.sockets?.socketEntries?.elementAt(socketIndex);
    return entry?.singleInitialItemHash ??
        entry.reusablePlugItems?.elementAt(0)?.plugItemHash ??
        entry.randomizedPlugItems?.elementAt(0)?.plugItemHash;
  }
}