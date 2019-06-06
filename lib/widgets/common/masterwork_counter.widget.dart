import 'package:bungie_api/models/destiny_item_component.dart';
import 'package:bungie_api/models/destiny_objective_definition.dart';
import 'package:bungie_api/models/destiny_objective_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:little_light/services/bungie_api/bungie_api.service.dart';
import 'package:little_light/services/manifest/manifest.service.dart';
import 'package:little_light/services/profile/profile.service.dart';

class MasterworkCounterWidget extends StatefulWidget {
  final ManifestService manifest = ManifestService();
  final ProfileService profile = ProfileService();
  final DestinyItemComponent item;

  MasterworkCounterWidget(this.item, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MasterworkCounterWidgetState();
  }
}

class MasterworkCounterWidgetState extends State<MasterworkCounterWidget>
    with AutomaticKeepAliveClientMixin {
  DestinyObjectiveProgress masterworkObjective;
  DestinyObjectiveDefinition masterworkObjectiveDefinition;

  initState() {
    super.initState();
    loadDefinitions();
  }

  loadDefinitions() async {
    if (widget.item == null) return;
    var itemSockets = widget.profile.getItemSockets(widget.item.itemInstanceId);
    if(itemSockets == null) return;
    for (var socket in itemSockets) {
      if (socket.plugObjectives != null) {
        for (var objective in socket.plugObjectives) {
          if (objective.visible) {
            masterworkObjective = objective;
            masterworkObjectiveDefinition = await widget.manifest
                .getDefinition<DestinyObjectiveDefinition>(
                    objective.objectiveHash);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (this.masterworkObjective == null || this.masterworkObjectiveDefinition == null){
      return Container();
    }
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 26,
              height: 26,
              child: Image(
                  image: AdvancedNetworkImage(BungieApiService.url(
                      masterworkObjectiveDefinition.displayProperties.icon))),
            ),
            Container(
              width: 4,
            ),
            Expanded(child:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(masterworkObjectiveDefinition.progressDescription,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    style: TextStyle(color: Colors.white, fontSize: 11)),
                Container(
                  width: 4,
                ),
                Text("${masterworkObjective.progress}",
                    style:
                        TextStyle(color: Colors.amber.shade200, fontSize: 15)),
              ],
            ))
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}
