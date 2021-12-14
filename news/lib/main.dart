import 'package:flutter/material.dart';
import 'package:webfeed/webfeed.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'database.dart';
import 'models/Feed.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: OrientationBuilder(builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return RSSDemo();
        } else {
          return RSSDemo();
        }
      }),
    );
  }
}

class RSSDemo extends StatefulWidget {
  RSSDemo() : super();

  final String title = 'News';

  @override
  RSSDemoState createState() => RSSDemoState();
}

class RSSDemoState extends State<RSSDemo> {
  late String FEED_URL;
  late List<Feed>? _feed = null;
  late String _title;
  static const String loadingFeedMsg = 'Loading Feed...';
  static const String feedLoadErrorMsg = 'Error Loading. Loaded last news';
  static const String feedOpenErrorMsg = 'Error Opening Feed.';
  static const String placeholderImg = 'images/no_image.png';
  late GlobalKey<RefreshIndicatorState> _refreshKey;

  updateTitle(title) {
    setState(() {
      _title = title;
    });
  }

  updateFeed(feed) async {
    var tempFeed = <Feed>[];
    for (RssItem item in feed.items) {
      tempFeed.add(new Feed(
          id: 1,
          title: item.title as String,
          icon: item.enclosure!.url.toString(),
          link: item.link as String));
    }
    _feed = tempFeed;
    await DBProvider.db.deleteAllFeed();
    for (var item in tempFeed) {
      await DBProvider.db.newFeed(item);
    }
    setState(() {
      _feed = tempFeed;
    });
  }

  Future<void> openFeed(String url) async {
    if (await canLaunch(url)) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => new WebView(
                  allowsInlineMediaPlayback: true,
                  initialUrl: url,
                  javascriptMode: JavascriptMode.unrestricted,
                  navigationDelegate: (NavigationRequest request) {
                    if (request.url.startsWith('https://dev.by')) {
                      return NavigationDecision.navigate;
                    } else {
                      launch(request.url);
                      return NavigationDecision.prevent;
                    }
                  },
                )),
      ).then((value) => setState(() {}));
      return;
    }
    updateTitle(feedOpenErrorMsg);
  }

  load() async {
    FEED_URL = await DBProvider.db.getUrl();
    updateTitle(loadingFeedMsg);
    var tempFeed = await DBProvider.db.getAllFeeds();
    loadFeed().then((result) {
      if (null == result || result.toString().isEmpty) {
        updateTitle(feedLoadErrorMsg);
        setState(() async {
          _feed = tempFeed;
        });
        return;
      }
      updateFeed(result);
      updateTitle(result.title);
    });
  }

  Future<RssFeed?> loadFeed() async {
    try {
      final client = http.Client();
      final response = await client.get(Uri.parse(FEED_URL));
      return RssFeed.parse(response.body);
    } catch (e) {}
    return null;
  }

  @override
  void initState() {
    super.initState();
    _refreshKey = GlobalKey<RefreshIndicatorState>();
    updateTitle(widget.title);
    load();
  }

  title(title) {
    return Text(
      title,
      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  subtitle(String subTitle) {
    return Text(
      subTitle,
      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w100),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  thumbnail(imageUrl) {
    return Padding(
      padding: EdgeInsets.only(left: 15.0),
      child: CachedNetworkImage(
        placeholder: (context, url) => Image.asset(placeholderImg),
        errorWidget: (context, url, error) => Image.asset(placeholderImg),
        imageUrl: imageUrl,
        height: 50,
        width: 70,
        alignment: Alignment.center,
        fit: BoxFit.fill,
      ),
    );
  }

  rightIcon() {
    return Icon(
      Icons.keyboard_arrow_right,
      color: Colors.grey,
      size: 30.0,
    );
  }

  list() {
    return ListView.builder(
      itemCount: _feed!.length,
      itemBuilder: (BuildContext context, int index) {
        final item = _feed![index];
        return ListTile(
          title: title(item.title),
          leading: thumbnail(item.icon),
          trailing: rightIcon(),
          contentPadding: EdgeInsets.all(5.0),
          onTap: () => openFeed(item.link),
        );
      },
    );
  }

  isFeedEmpty() {
    return null == _feed || 0 == _feed!.length;
  }

  body() {
    return isFeedEmpty()
        ? Center(
            child: CircularProgressIndicator(),
          )
        : RefreshIndicator(
            key: _refreshKey,
            child: list(),
            onRefresh: () => load(),
          );
  }

  TextEditingController _textFieldController = TextEditingController();

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('New RSS URL'),
          content: TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: FEED_URL),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('CANCEL'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                DBProvider.db.updateUrl(_textFieldController.text);
                FEED_URL = _textFieldController.text;
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
              onPressed: () {
                _displayTextInputDialog(context);
              },
              icon: Icon(Icons.settings))
        ],
      ),
      body: body(),
    );
  }
}
