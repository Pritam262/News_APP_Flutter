import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'model.dart';
import 'newsview.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SearchItemScreen extends StatefulWidget {
  late String query;

SearchItemScreen ({super.key, required this.query});

  @override
  State<SearchItemScreen> createState() => _SearchItemScreenState();
}

class _SearchItemScreenState extends State<SearchItemScreen> {

  bool isLoading = true;
  final api = dotenv.env['API'];
  TextEditingController searchController = TextEditingController();
  List<String> navBarItem = [
    'Top News',
    'Technology',
    'international',
    'Finance',
    "Health"
  ];
  List<NewsModel> newsModelList = <NewsModel>[];
  List<NewsModel> newsModelListCarousel = <NewsModel>[];
  Future<void> getNews(String query) async {
    late String? apiKey = api;
     var  getSecondUrl = 'https://newsapi.org/v2/everything?q=$query&sortBy=publishedAt&apiKey=$apiKey';

    // Api

    try {
      final response = await http.get(Uri.parse(getSecondUrl));
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
      body: SafeArea(child:
      Container(
        padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Search Container
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.white60),
                height: 60,
                child: Row(
                  children: [
                    Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: TextField(
                            controller: searchController,
                            textInputAction: TextInputAction.search,
                            onSubmitted: (value) {
                              if (kDebugMode) {
                                print('Search text: ${value}');
                              }
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SearchItemScreen(
                                        query: value,
                                      )));

                            },
                            decoration: const InputDecoration(
                                hintText: "Search news", border: InputBorder.none),
                          ),
                        )),
                    GestureDetector(
                        onTap: () {
                          if (searchController.text.replaceAll(' ', '') == "") {
                            if (kDebugMode) {
                              print('Blank search');
                            }
                          } else {
                            /*  Navigator.push(
                               context,
                               MaterialPageRoute(
                                 builder: (context) => Search(
                                     searchController.text.toString()),
                               ));*/
                          }
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(right: 20),
                          child: Icon(Icons.search),
                        )),
                  ],
                ),
              ),

              // News
              Container(
                // color: Colors.green,
                margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 8),
                      child: Row(
                        children: [
                          Flexible(
                            fit: FlexFit.tight,
                            child: Text(
                              widget.query.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    isLoading ? Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: const CircularProgressIndicator())
                        : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      // shrinkWrap: true use to solve verticle unbound height
                      shrinkWrap: true,
                      itemCount: newsModelList.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewsView(
                                      newsModelList[index].newsUrl),
                                ));
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
                                      borderRadius:
                                      BorderRadius.circular(15),
                                      child: Image.network(
                                        newsModelList[index].imageUrl,
                                        fit: BoxFit.cover,
                                      ),
                                      //Image.asset('assets/images/bg2.jpg',fit: BoxFit.cover,)),
                                    ),
                                    Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 7),
                                          // width: 100,
                                          decoration: const BoxDecoration(
                                            color: Colors.yellow,
                                            borderRadius:
                                            BorderRadius.only(
                                                bottomLeft:
                                                Radius.circular(
                                                    10)),
                                          ),
                                          child: Center(
                                              child: Text(
                                                  newsModelList[index]
                                                      .sourceName)),
                                        )),
                                    Positioned(
                                        bottom: 0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                          // height: 40,
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal: 10,
                                                vertical: 7),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              const BorderRadius.only(
                                                  bottomLeft:
                                                  Radius.circular(
                                                      15),
                                                  bottomRight:
                                                  Radius.circular(
                                                      15)),
                                              // color: Colors.yellow.shade600,
                                              /*    gradient: LinearGradient(colors: [Color(0xfff6d365), Color(0xfffda085)],
                                           begin: Alignment.topCenter,
                                           end: Alignment.bottomCenter,),*/
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.black12
                                                      .withOpacity(0),
                                                  Colors.black
                                                ],
                                                begin:
                                                Alignment.topCenter,
                                                end: Alignment
                                                    .bottomCenter,
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(
                                                    newsModelList[index]
                                                        .title,
                                                    style:
                                                    const TextStyle(
                                                        color: Colors
                                                            .white,
                                                        fontSize:
                                                        18)),
                                                Text(
                                               newsModelList[
                                                  index]
                                                      .desc,
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 15),
                                                )
                                              ],
                                            ))),
                                  ],
                                ),
                              )),
                        );
                      },
                    ),
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ElevatedButton(
                            onPressed: () {
                              // Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryScreen(query: 'Top News'),));
                            }, child: const Text('See More'))),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      ),
      backgroundColor: Colors.blue.shade50,
    );
  }
}
