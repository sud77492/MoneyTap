import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:money_tap/wikipedia_info.dart';
import 'models/wikipedia_detail.dart';
import 'styles.dart';

class WikiPediaScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _WikiPediaScreenState();
  }
}

class _WikiPediaScreenState extends State<WikiPediaScreen> {
  final List<WikiPediaDetail> items = [];
  final myController = TextEditingController();

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(title: Text("Wikipedia", style: Styles.navBarTitle,)),
        body: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                textDirection: TextDirection.rtl,
                children: <Widget>[
                  FlatButton(onPressed: () {getNews(myController.text);}, child: Text("Search")),
                  Expanded(child: new TextField(
                    controller: myController,
                    decoration: InputDecoration(
                        labelText: "Search",
                        hintText: "Search",
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(25.0)))),
                  ),)
                ],
              )
            ),
            Expanded(
              child: ListView.builder(
                itemCount: this.items.length,
                  itemBuilder: _listViewItemBuilder
              ),
            ),
          ],
        )
    //     body: Container(
    // child: ListView.builder(
    // itemCount: this.items.length,
    //     itemBuilder: _listViewItemBuilder
    // ),
    // )
    );
  }

  Widget _listViewItemBuilder(BuildContext context, int index){
    var newsDetail = this.items[index];
    return ListTile(
        contentPadding: EdgeInsets.all(10.0),
        leading: _itemThumbnail(newsDetail),
        title: _itemTitle(newsDetail),
        onTap: (){
          _navigationToNewsDetail(context, newsDetail);
        });
  }

  void _navigationToNewsDetail(BuildContext context, WikiPediaDetail newsDetail){
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context){return WikiPediaInfo(newsDetail);}
        ));
  }

  Widget _itemThumbnail(WikiPediaDetail newsDetail){
    return Container(
      constraints: BoxConstraints.tightFor(width: 100.0),
      child: newsDetail.url == null ? null : Image.network(newsDetail.url, fit: BoxFit.fitWidth),
    );
  }

  Widget _itemTitle(WikiPediaDetail newsDetail){
    return Text(newsDetail.title, style: Styles.textDefault);
  }

  void getNews(String query) async{
    print(query);
   // final http.Response response = await http.get("https://newsapi.org/v2/top-headlines?country=in&apiKey=d2eccaadb59e4fa0b3275a828607f722");
    final http.Response response = await http.get("https://en.wikipedia.org//w/api.php?action=query&format=json&prop=pageimages%7Cpageterms&generator=prefixsearch&redirects=1&formatversion=2&piprop=thumbnail&pithumbsize=50&pilimit=10&wbptterms=description&gpssearch="+query+"&gpslimit=10");
    debugPrint(response.body);
    items.clear();
    final Map<String, dynamic> responseData = json.decode(response.body);
    responseData['query']['pages'].forEach((newsDetail) {
      final WikiPediaDetail news = WikiPediaDetail(
          description: newsDetail['terms']['description'][0],
          title: newsDetail['title'],
          url: newsDetail['thumbnail']['source']
      );
      setState(() {
        items.add(news);
      });
    });
  }
}