class NewsModel {
  late String title;
  late String sourceName;
  late String desc;
  late String newsUrl;
  late String imageUrl;

  NewsModel({
    this.title = 'title',
    this.sourceName ='name',
    this.desc = 'desc',
    this.newsUrl = 'url',
    this.imageUrl = 'url',
  });
  factory NewsModel.fromMap(Map news) {
    return NewsModel(
      title: news['title'].toString().split('-').first,
      sourceName: news['source']['name'].toString(),
      desc: (news['description'] == null)? '':( news['description'].toString().length>50 ) ? news['description'].toString().substring(0,50) : news['description'].toString(),
      newsUrl:news['url'].toString(),
      imageUrl:(news['urlToImage'] == null) ?'https://images.pexels.com/photos/15286/pexels-photo.jpg'.toString(): news['urlToImage'].toString(),
    );
  }
}
