import 'package:flutter/material.dart';

import 'details.dart';

class HomePage extends StatelessWidget {
  const HomePage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black54),
          leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {},
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {},
            )
          ],
        ),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Good Morning",
                          style: Theme.of(context).textTheme.body1,
                        ),
                        Text(
                          "Sun",
                          style: Theme.of(context).textTheme.headline,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    width: 40,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Image.asset(
                        "assets/logo/logo.png",
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Wrap(
              spacing: 10.0,
              runSpacing: 5.0,
              children: <Widget>[
                demo(context, storageBoxes, 0),
                demo(context, storageBoxes, 1),
                demo(context, storageBoxes, 2),
              ]
            ),
            Flexible(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                    color: Colors.white),
                padding: EdgeInsets.all(15.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "Recent Files",
                          style: Theme.of(context).textTheme.display1.apply(
                                color: Color(0xff0b1666),
                                fontWeightDelta: 2,
                              ),
                        ),
                        FlatButton(
                          child: Text(
                            "View All",
                            style: TextStyle(color: Colors.blue),
                          ),
                          onPressed: () {},
                        )
                      ],
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filesList.length,
                        itemBuilder: (ctx, i) {
                          String image;
                          Color color;
                          switch (filesList[i]['type']) {
                            case fileType.sheet:
                              {
                                image = 'assets/apps/docs/file_sheet.png';
                                color = Color(0xffe3f9f3);
                              }
                              break;

                            case fileType.document:
                              {
                                image = 'assets/apps/docs/file_word.png';
                                color = Color(0xffeaeaea);
                              }
                              break;
                            case fileType.pdf:
                              {
                                image = 'assets/apps/docs/file_pdf.png';
                                color = Color(0xfff8bdba);
                              }
                              break;
                            case fileType.video:
                              {
                                image = 'assets/apps/docs/file_video.png';
                                color = Color(0xfffceeeb);
                              }
                              break;
                            case fileType.image:
                              {
                                image = 'assets/apps/docs/file_image.png';
                                color = Color(0xfffceeeb);
                              }
                              break;
                            default:
                              {
                                image = 'assets/apps/docs/file_word.png';
                                color = Color(0xff939aef);
                              }
                          }
                          return ListTile(
                            onTap: () {},
                            leading: Container(
                              padding: EdgeInsets.all(11.0),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Image.asset(image),
                            ),
                            title: Text("${filesList[i]['name']}"),
                            subtitle: Text(
                                "${filesList[i]['date']} | ${filesList[i]['size']}"),
                            trailing: IconButton(
                              icon: Icon(Icons.more_vert),
                              onPressed: () {},
                            ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget demo(context, storageBoxes, i) {
  return GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(id: i),
      ),
    ),
    child: Container(
      width: 300,
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        color: storageBoxes[i].color,
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(9),
            child: Image.asset(
              "${storageBoxes[i].icon}",
              height: 51,
              width: 51,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "${storageBoxes[i].name}",
                  style: Theme.of(context)
                  .textTheme
                  .title
                  .copyWith(color: Colors.black),
                ),
                SizedBox(height: 9),
                Text(
                  "${storageBoxes[i].expiryDate}",
                  style: Theme.of(context)
                  .textTheme
                  .overline
                  .copyWith(
                    color: Colors.black.withOpacity(.75),
                  ),
                ),
                SizedBox(height: 9),
                Text(
                  "${storageBoxes[i].usedSpace} GB of ${storageBoxes[i].availableSpace} Gb used",
                  style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(
                    color: Colors.black.withOpacity(.75),
                  ),
                ),
                SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: LinearProgressIndicator(
                    value: storageBoxes[i].usedSpace /
                    storageBoxes[i].availableSpace,
                    backgroundColor: Colors.white,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    ),
  );
}

enum fileType { sheet, pdf, video, document, image }

Color blueColor = Color(0xff4e5af6);

List<Map<String, dynamic>> filesList = [
  {
    'name': 'sheet.xlsx',
    'date': '13/10/2019',
    'size': '10 KB',
    'type': fileType.sheet
  },
  {
    'name': 'Hello world.pdf',
    'date': '13/09/2019',
    'size': '29 MB',
    'type': fileType.pdf
  },
  {
    'name': 'Provider Video.mp4',
    'date': '04/10/2019',
    'size': '293 MB',
    'type': fileType.video
  },
  {
    'name': 'invoice.docx',
    'date': '04/10/2019',
    'size': '293 MB',
    'type': fileType.document
  },
  {
    'name': 'sheet.xlsx',
    'date': '13/10/2019',
    'size': '10 KB',
    'type': fileType.sheet
  },
  {
    'name': 'me.jpg',
    'date': '13/09/2019',
    'size': '29 MB',
    'type': fileType.image
  },
  {
    'name': 'Provider Video.mp4',
    'date': '04/10/2019',
    'size': '293 MB',
    'type': fileType.video
  },
  {
    'name': 'invoice.docx',
    'date': '04/10/2019',
    'size': '293 MB',
    'type': fileType.document
  },
];

class MyColors {
  static const lightBlue = Color(0xffe1f2ff),
      lightGrey = Color(0xfff5f6fc),
      blue = Color(0xff367ffa),
      orange = Color(0xffffefe1);
}

List<StorageBox> storageBoxes = [
  StorageBox(
    color: Color(0xffffefe1),
    availableSpace: 25,
    usedSpace: 6.3,
    expiryDate: "01/2021",
    icon: "assets/apps/docs/storage_distributed.png",
    name: "My Devices",
    stats: [
      StatsByDate(
        bandwidthUsage: 10.1,
        downloadsCount: 30393,
        pageViews: 35491,
        visitorsCount: 29300,
      ),
      StatsByDate(
        bandwidthUsage: 10.1,
        downloadsCount: 30393,
        pageViews: 35491,
        visitorsCount: 19300,
      ),
      StatsByDate(
        bandwidthUsage: 10.1,
        downloadsCount: 30393,
        pageViews: 35491,
        visitorsCount: 34300,
      ),
      StatsByDate(
        bandwidthUsage: 10.1,
        downloadsCount: 30393,
        pageViews: 35491,
        visitorsCount: 1300,
      ),
      StatsByDate(
        bandwidthUsage: 10.1,
        downloadsCount: 30393,
        pageViews: 35491,
        visitorsCount: 69300,
      ),
      StatsByDate(
        bandwidthUsage: 10.1,
        downloadsCount: 30393,
        pageViews: 35491,
        visitorsCount: 79300,
      ),
      StatsByDate(
        bandwidthUsage: 10.1,
        downloadsCount: 30393,
        pageViews: 35491,
        visitorsCount: 89300,
      ),
    ],
    storageFolders: [
      StorageFolder(
        creationDate: "01/2020",
        icon: "assets/apps/docs/dir_folder.png",
        name: "My Folders",
      ),
      StorageFolder(
        creationDate: "02/2020",
        icon: "assets/apps/docs/dir_favorites.png",
        name: "My Favorites",
      ),
      StorageFolder(
        creationDate: "03/2020",
        icon: "assets/apps/docs/file_video.png",
        name: "My Audio",
      ),
      StorageFolder(
        creationDate: "01/2020",
        icon: "assets/apps/docs/file_image.png",
        name: "My Pictures",
      ),
    ],
  ),
  StorageBox(
    color: Color(0xffe1f2ff),
    availableSpace: 15,
    usedSpace: 5.3,
    expiryDate: "01/2021",
    icon: "assets/apps/docs/storage_dropbox.webp",
    name: "Dropbox",
    stats: [
      StatsByDate(
        bandwidthUsage: 3.1,
        downloadsCount: 30393,
        pageViews: 35491,
        visitorsCount: 29300,
      ),
      StatsByDate(
        bandwidthUsage: 6.1,
        downloadsCount: 30393,
        pageViews: 35491,
        visitorsCount: 19300,
      ),
      StatsByDate(
        bandwidthUsage: 4.1,
        downloadsCount: 30393,
        pageViews: 35491,
        visitorsCount: 34300,
      ),
      StatsByDate(
        bandwidthUsage: 8.1,
        downloadsCount: 30393,
        pageViews: 35491,
        visitorsCount: 1300,
      ),
      StatsByDate(
        bandwidthUsage: 3.1,
        downloadsCount: 30393,
        pageViews: 35491,
        visitorsCount: 69300,
      ),
      StatsByDate(
        bandwidthUsage: 1.1,
        downloadsCount: 30393,
        pageViews: 35491,
        visitorsCount: 79300,
      ),
      StatsByDate(
        bandwidthUsage: 8.1,
        downloadsCount: 30393,
        pageViews: 35491,
        visitorsCount: 89300,
      ),
    ],
    storageFolders: [
      StorageFolder(
        creationDate: "01/2020",
        icon: "assets/apps/docs/dir_folder.png",
        name: "My Folders",
      ),
      StorageFolder(
        creationDate: "02/2020",
        icon: "assets/apps/docs/dir_favorites.png",
        name: "My Favorites",
      ),
      StorageFolder(
        creationDate: "03/2020",
        icon: "assets/apps/docs/file_video.png",
        name: "My Audio",
      ),
      StorageFolder(
        creationDate: "01/2020",
        icon: "assets/apps/docs/file_image.png",
        name: "My Pictures",
      ),
    ],
  ),
  StorageBox(
    color: Color(0xffe6e1ff),
    availableSpace: 15,
    usedSpace: 5.3,
    expiryDate: "01/2021",
    icon: "assets/apps/docs/storage_google_drive.png",
    name: "Google Drive",
    stats: [
      StatsByDate(
        bandwidthUsage: 10.1,
        downloadsCount: 30393,
        pageViews: 35491,
        visitorsCount: 29300,
      ),
      StatsByDate(
        bandwidthUsage: 10.1,
        downloadsCount: 30393,
        pageViews: 35491,
        visitorsCount: 19300,
      ),
      StatsByDate(
        bandwidthUsage: 10.1,
        downloadsCount: 30393,
        pageViews: 35491,
        visitorsCount: 34300,
      ),
      StatsByDate(
        bandwidthUsage: 10.1,
        downloadsCount: 30393,
        pageViews: 35491,
        visitorsCount: 1300,
      ),
      StatsByDate(
        bandwidthUsage: 10.1,
        downloadsCount: 30393,
        pageViews: 35491,
        visitorsCount: 69300,
      ),
      StatsByDate(
        bandwidthUsage: 10.1,
        downloadsCount: 30393,
        pageViews: 35491,
        visitorsCount: 79300,
      ),
      StatsByDate(
        bandwidthUsage: 10.1,
        downloadsCount: 30393,
        pageViews: 35491,
        visitorsCount: 89300,
      ),
    ],
    storageFolders: [
      StorageFolder(
        creationDate: "01/2020",
        icon: "assets/apps/docs/dir_folder.png",
        name: "My Folders",
      ),
      StorageFolder(
        creationDate: "02/2020",
        icon: "assets/apps/docs/dir_favorites.png",
        name: "My Favorites",
      ),
      StorageFolder(
        creationDate: "03/2020",
        icon: "assets/apps/docs/file_video.png",
        name: "My Audio",
      ),
      StorageFolder(
        creationDate: "01/2020",
        icon: "assets/apps/docs/file_image.png",
        name: "My Pictures",
      ),
    ],
  ),
];

class StorageBox {
  final String name, icon, expiryDate;
  final double availableSpace, usedSpace;
  final List<StatsByDate> stats;
  final List<StorageFolder> storageFolders;
  final Color color;
  StorageBox({
    this.color,
    this.storageFolders,
    this.name,
    this.icon,
    this.expiryDate,
    this.availableSpace,
    this.usedSpace,
    this.stats,
  });
}

class StorageFolder {
  final String name, icon, creationDate;

  StorageFolder({
    this.creationDate,
    this.name,
    this.icon,
  });
}

class StatsByDate {
  final double bandwidthUsage;
  final int downloadsCount, visitorsCount, pageViews;
  StatsByDate({
    this.bandwidthUsage,
    this.downloadsCount,
    this.visitorsCount,
    this.pageViews,
  });
}
