import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:news_app/categoryscreen.dart';
import 'package:news_app/newsview.dart';
import 'package:news_app/searchscreen.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  static var  api = dotenv.env['API'];
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

  // News fetch

  Future<void> getNews(String query) async {
    Map element;
    int i = 0;
    // Api
    late String? apiKey = api;
    var getSecondUrl =
        'https://newsapi.org/v2/top-headlines?country=in&category=$query&apiKey=$apiKey';
    try {
      final response = await http.get(Uri.parse(getSecondUrl));
      if (response.statusCode == 200) {
        Map resData = jsonDecode(response.body);

// For show only first 5 news in the home screen, if not than delete the elemant map and default int variable
        for (element in resData['articles']) {
          try {
            i++;
            NewsModel newsModel = NewsModel();
            newsModel = NewsModel.fromMap(element);
            newsModelList.add(newsModel);

            // We use setState for on fetch data the data show at that time in ui
            setState(() {
              isLoading = false;
            });
            if (i == 5) {
              break;
            }
          } catch (e) {
            print('Error $e');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error $e');
      }
    }

  }

  // Carosul news fetch
  Future<void> getNewsbyProvider(String provider) async {
    // Api
    late String? apiKey = api;
    var getSecondUrl =
        'https://newsapi.org/v2/top-headlines?sources=$provider&apiKey=$apiKey';
    try {
      final response = await http.get(Uri.parse(getSecondUrl));
      if (response.statusCode == 200) {
        Map resData = jsonDecode(response.body);
        resData['articles'].forEach((element) {
          NewsModel newsModel = NewsModel();
          newsModel = NewsModel.fromMap(element);
          newsModelListCarousel.add(newsModel);

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
    getNews('general');
    getNewsbyProvider('techcrunch');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News App'),
        centerTitle: true,
        backgroundColor: Colors.yellow,
      ),
      body: Container(
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
                          if (value.replaceAll(' ', '') == "") {
                            // ignore: avoid_print
                            print('Blank search');
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SearchItemScreen(
                                          query: value,
                                        )));
                          }
                        },
                        decoration: const InputDecoration(
                          hintText: "Search news",
                          border: InputBorder.none,
                          suffixIcon: Icon(Icons.search),
                        ),
                      ),
                    )),
                    // Search Icon
                  ],
                ),
              ),

              // Category
              Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    itemCount: navBarItem.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CategoryScreen(query: navBarItem[index]),
                              ));
                          print(navBarItem[index]);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            // color: Colors.grey,
                            gradient: const LinearGradient(
                                colors: [Color(0xfff6d365), Color(0xfffda085)]),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                              child: Text(
                            navBarItem[index],
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          )),
                        ),
                      );
                    },
                  )),

              // Slidebar
              isLoading
                  ? const CircularProgressIndicator()
                  : CarouselSlider(
                      items: newsModelListCarousel.map((instance) {
                        return Builder(
                          builder: (BuildContext context) {
                            try {
                              return Container(
                                // width: 350,
                                // height: 150,
                                decoration: const BoxDecoration(
                                    // color: itemColor,
                                    ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              NewsView(instance.newsUrl),
                                        ));
                                  },
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Image.network(
                                            instance.imageUrl,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 0,
                                          child: Container(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      10, 10, 0, 10),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        bottomLeft:
                                                            Radius.circular(10),
                                                        bottomRight:
                                                            Radius.circular(
                                                                10)),
                                                // color: Colors.grey
                                                gradient: LinearGradient(
                                                    colors: [
                                                      Colors.black12
                                                          .withOpacity(0),
                                                      Colors.black
                                                    ],
                                                    begin: Alignment.topCenter,
                                                    end:
                                                        Alignment.bottomCenter),
                                              ),
                                              child: Text(
                                                instance.title,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            } catch (e) {
                              print('Error $e');
                              return Container();
                            }
                            ;
                          },
                        );
                      }).toList(),
                      options: CarouselOptions(
                          height: 200,
                          autoPlay: true,
                          enlargeCenterPage: true)),

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
                          Text(
                            'Latest News'.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    isLoading
                        ? Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            child: const CircularProgressIndicator())
                        : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            // shrinkWrap: true use to solve verticle unbound height
                            shrinkWrap: true,
                            itemCount: newsModelList.length,
                            itemBuilder: (context, index) {
                              try {
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
                                          borderRadius:
                                              BorderRadius.circular(15),
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
                                                  width: 100,
                                                  decoration:
                                                      const BoxDecoration(
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
                                                          const BorderRadius
                                                                  .only(
                                                              bottomLeft: Radius
                                                                  .circular(15),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
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
                                                          newsModelList[index]
                                                              .desc,
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 15),
                                                        )
                                                      ],
                                                    ))),
                                          ],
                                        ),
                                      )),
                                );
                              } catch (e) {
                                print('Error $e');
                                return Container();
                              }
                            },
                          ),
                    Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CategoryScreen(query: 'Top News'),
                                  ));
                            },
                            child: const Text('See More'))),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      backgroundColor: Colors.blue.shade100,
    );
  }

  final List items = [
    Colors.blue,
    Colors.yellow,
    Colors.green,
    Colors.deepPurple,
    Colors.deepOrange
  ];
}
