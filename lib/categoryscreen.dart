import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'model.dart';
import 'package:http/http.dart' as http;

import 'newsview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CategoryScreen extends StatefulWidget {
  late String query;
  CategoryScreen({super.key, required this.query});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {

  List<NewsModel> newsModelList = <NewsModel>[];
  bool isLoading = true;
  final  api = dotenv.env['API'];

  Future<void> getNews(String query) async {
    var url = '';
    if (query == 'Top News' || query == 'India') {
      var apiKey = api;
      url =
      'https://newsapi.org/v2/top-headlines?country=in&category=general&apiKey=$apiKey';
    } else {
      var apiKey = api;
      url =
      'https://newsapi.org/v2/top-headlines?country=in&category=$query&apiKey=$apiKey';
    }
    // Api

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map resData = jsonDecode(response.body);
        resData['articles'].forEach((element) {
          NewsModel newsModel = NewsModel();
          newsModel = NewsModel.fromMap(element);
          newsModelList.add(newsModel);

          // We use setState for on fetch data the data show at that time in ui
          setState(() {
            isLoading = false;
          });
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error $e');
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getNews(widget.query);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*    appBar: AppBar(
        title: Text('Category news'),
        centerTitle: true,
      ),*/
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            // color: Colors.green,
            margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    children: [
                      Text(widget.query.toUpperCase(), style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.w700),),
                    ],
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  // shrinkWrap: true use to solve verticle unbound height
                  shrinkWrap: true,
                  itemCount: newsModelList.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) =>
                              NewsView(newsModelList[index].newsUrl),));
                      },
                      child: Container(
                          width: double.infinity,
                          height: 240,
                          margin: const EdgeInsets.only(top: 10),
                          // decoration: BoxDecoration(
                          //   borderRadius: BorderRadius.circular(20),
                          //   color: Colors.deepPurple.shade300
                          // ),
                          // Image.network('https://wallpapercave.com/wp/wp7342177.jpg', fit: BoxFit.fill,),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 3.0,
                            child: Stack(
                              // To fit image in any stack
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    newsModelList[index].imageUrl,
                                    fit: BoxFit.cover,),
                                  //Image.asset('assets/images/bg2.jpg',fit: BoxFit.cover,)),
                                ),
                                Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      width: 100,
                                      decoration: const BoxDecoration(
                                        color: Colors.yellow,
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(10)),
                                      ),
                                      child: Center(child: Text(
                                          newsModelList[index].sourceName)),
                                    )),
                                Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      // height: 40,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 7),
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(15),
                                              bottomRight: Radius.circular(15)),
                                          // color: Colors.yellow.shade600,
                                          /*    gradient: LinearGradient(colors: [Color(0xfff6d365), Color(0xfffda085)],
                                               begin: Alignment.topCenter,
                                               end: Alignment.bottomCenter,),*/
                                          gradient: LinearGradient(colors: [
                                            Colors.black12.withOpacity(0),
                                            Colors.black
                                          ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: [
                                            Text(newsModelList[index].title,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18)),
                                            Text(newsModelList[index].desc,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15),)
                                          ],
                                        ))),
                              ],
                            ),
                          )
                      ),
                    );
                  },),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.blue.shade50,
    );
  }
}
