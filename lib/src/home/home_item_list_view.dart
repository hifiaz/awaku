import 'package:awaku/src/home/apple_watch.dart';
import 'package:awaku/src/home/ble_page.dart';
import 'package:flutter/material.dart';

import '../settings/settings_view.dart';
import 'home_item.dart';
import 'home_item_details_view.dart';

/// Displays a list of SampleItems.
class SampleItemListView extends StatelessWidget {
  const SampleItemListView({
    super.key,
    this.items = const [SampleItem(1), SampleItem(2), SampleItem(3)],
  });

  static const routeName = '/';

  final List<SampleItem> items;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hello'),
        // title: Text(AppLocalizations.of(context)!.appTitle),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              // Navigate to the settings page. If the user leaves and returns
              // to the app after it has been killed while running in the
              // background, the navigation stack is restored.
              Navigator.restorablePushNamed(context, SettingsView.routeName);
              //
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => const AppleWatch()),
              // );
            },
          ),
        ],
      ),

      // To work with lists that may contain a large number of items, it’s best
      // to use the ListView.builder constructor.
      //
      // In contrast to the default ListView constructor, which requires
      // building all Widgets up front, the ListView.builder constructor lazily
      // builds Widgets as they’re scrolled into view.
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '75',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.favorite,
                            size: 20, color: Colors.pink),
                        Text(
                          'BPM',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '56',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.monitor_weight_outlined,
                            size: 20, color: Colors.green),
                        Text(
                          'KG',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '20',
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_outward,
                            size: 20, color: Colors.purple),
                        Text(
                          'BMI',
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ],
                    ),
                  ],
                ),
                IconButton(
                    onPressed: () => Navigator.restorablePushNamed(
                        context, AppleWatch.routeName),
                    icon: const Icon(Icons.add)),
                IconButton(
                    onPressed: () => Navigator.restorablePushNamed(
                        context, FlutterFTMSApp.routeName),
                    icon: const Icon(Icons.bluetooth))
              ],
            ),
          ),
          ListTile(
            title: const Text('History'),
            trailing: TextButton(
              onPressed: () {},
              child: const Text('See All'),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            // Providing a restorationId allows the ListView to restore the
            // scroll position when a user leaves and returns to the app after it
            // has been killed while running in the background.
            restorationId: 'sampleItemListView',
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              final item = items[index];

              return ListTile(
                  title: Text('SampleItem ${item.id}'),
                  leading: const CircleAvatar(
                    // Display the Flutter Logo image asset.
                    foregroundImage:
                        AssetImage('assets/images/flutter_logo.png'),
                  ),
                  onTap: () {
                    // Navigate to the details page. If the user leaves and returns to
                    // the app after it has been killed while running in the
                    // background, the navigation stack is restored.
                    Navigator.restorablePushNamed(
                      context,
                      SampleItemDetailsView.routeName,
                    );
                  });
            },
          ),
        ],
      ),
    );
  }
}
