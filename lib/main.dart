import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as https;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primaryColor: Colors.deepPurple),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<List<Category>> getCategories() async {
    var url = "https://strapi-mongodb-cloudinary.herokuapp.com/categories";
    var response = await https.get(url);
    var jsonString = response.body;
    List<Category> categories = categoryFromJson(jsonString);
    //print(jsonString);
    return categories;
  }

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("موجز الاخبار"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FutureBuilder(
              future: getCategories(),
              builder: (context, snapshot) {
                return snapshot == null
                    ? Center(child: CircularProgressIndicator())
                    : Expanded(
                        child: GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2),
                            itemCount: snapshot.data == null
                                ? 0
                                : snapshot.data.length,
                            itemBuilder: (context, index) {
                              Category item = snapshot.data[index];
                              return InkWell(
                                  child: GridTile(
                                    child: Container(
                                      padding: EdgeInsets.all(5.0),
                                      child: Text(
                                        item.name,
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                            fontSize: 25.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      margin: EdgeInsets.all(5.0),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          image: DecorationImage(
                                              image:
                                                  NetworkImage(item.image.url),
                                              fit: BoxFit.cover)),
                                    ),
                                  ),
                                  onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ArticlesScreen(
                                              articlesList: item.articles,
                                              catName: item.name))));
                            }),
                      );
              })
        ],
      ),
    );
  }
}

class ArticlesScreen extends StatelessWidget {
  final List<Article> articlesList;
  final String catName;
  const ArticlesScreen({Key key, this.articlesList, this.catName})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(catName),
          centerTitle: true,
        ),
        body: ListView.builder(
            itemCount: articlesList.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  contentPadding: EdgeInsets.all(5),
                  title: Text(
                    articlesList[index].title,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        NetworkImage(articlesList[index].image.url),
                  ),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailsScreen(
                              articleDetails: articlesList[index]))),
                ),
              );
            }));
  }
}

class DetailsScreen extends StatelessWidget {
  final Article articleDetails;

  const DetailsScreen({Key key, this.articleDetails}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(articleDetails.title),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(5),
        children: [
          Text(
            articleDetails.title,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
          ),
          Container(
            padding: EdgeInsets.all(5.0),
            height: 200,
            decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(articleDetails.image.url),
                ),
                border: Border.all(color: Colors.black)),
          ),
          Text(
            articleDetails.content,
            textDirection: TextDirection.rtl,
          ),
          ElevatedButton(
            onPressed: () {
              launch(articleDetails.source);
            },
            child: Text(
              "رابط الخبر",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }
}

List<Category> categoryFromJson(String str) =>
    List<Category>.from(json.decode(str).map((x) => Category.fromJson(x)));

String categoryToJson(List<Category> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Category {
  Category({
    this.id,
    this.name,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.image,
    this.articles,
    this.categoryId,
  });

  String id;
  String name;
  DateTime createdAt;
  DateTime updatedAt;
  int v;
  Image image;
  List<Article> articles;
  String categoryId;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["_id"],
        name: json["name"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        image: Image.fromJson(json["image"]),
        articles: List<Article>.from(
            json["articles"].map((x) => Article.fromJson(x))),
        categoryId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
        "image": image.toJson(),
        "articles": List<dynamic>.from(articles.map((x) => x.toJson())),
        "id": categoryId,
      };
}

class Article {
  Article({
    this.id,
    this.source,
    this.title,
    this.description,
    this.content,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.category,
    this.image,
    this.articleId,
  });

  String id;
  String source;
  String title;
  String description;
  String content;
  DateTime createdAt;
  DateTime updatedAt;
  int v;
  String category;
  Image image;
  String articleId;

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        id: json["_id"],
        source: json["source"],
        title: json["title"],
        description: json["description"],
        content: json["content"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        category: json["category"],
        image: Image.fromJson(json["image"]),
        articleId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "source": source,
        "title": title,
        "description": description,
        "content": content,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
        "category": category,
        "image": image.toJson(),
        "id": articleId,
      };
}

class Image {
  Image({
    this.id,
    this.name,
    this.alternativeText,
    this.caption,
    this.hash,
    this.ext,
    this.mime,
    this.size,
    this.url,
    this.providerMetadata,
    this.formats,
    this.provider,
    this.width,
    this.height,
    this.related,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.imageId,
  });

  String id;
  String name;
  String alternativeText;
  String caption;
  String hash;
  Ext ext;
  Mime mime;
  double size;
  String url;
  ProviderMetadata providerMetadata;
  Formats formats;
  Provider provider;
  int width;
  int height;
  List<String> related;
  DateTime createdAt;
  DateTime updatedAt;
  int v;
  String imageId;

  factory Image.fromJson(Map<String, dynamic> json) => Image(
        id: json["_id"],
        name: json["name"],
        alternativeText:
            json["alternativeText"] == null ? null : json["alternativeText"],
        caption: json["caption"] == null ? null : json["caption"],
        hash: json["hash"],
        ext: extValues.map[json["ext"]],
        mime: mimeValues.map[json["mime"]],
        size: json["size"].toDouble(),
        url: json["url"],
        providerMetadata: ProviderMetadata.fromJson(json["provider_metadata"]),
        formats: Formats.fromJson(json["formats"]),
        provider: providerValues.map[json["provider"]],
        width: json["width"],
        height: json["height"],
        related: List<String>.from(json["related"].map((x) => x)),
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        imageId: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
        "alternativeText": alternativeText == null ? null : alternativeText,
        "caption": caption == null ? null : caption,
        "hash": hash,
        "ext": extValues.reverse[ext],
        "mime": mimeValues.reverse[mime],
        "size": size,
        "url": url,
        "provider_metadata": providerMetadata.toJson(),
        "formats": formats.toJson(),
        "provider": providerValues.reverse[provider],
        "width": width,
        "height": height,
        "related": List<dynamic>.from(related.map((x) => x)),
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
        "id": imageId,
      };
}

enum Ext { JPEG, PNG }

final extValues = EnumValues({".jpeg": Ext.JPEG, ".png": Ext.PNG});

class Formats {
  Formats({
    this.thumbnail,
  });

  Thumbnail thumbnail;

  factory Formats.fromJson(Map<String, dynamic> json) => Formats(
        thumbnail: Thumbnail.fromJson(json["thumbnail"]),
      );

  Map<String, dynamic> toJson() => {
        "thumbnail": thumbnail.toJson(),
      };
}

class Thumbnail {
  Thumbnail({
    this.hash,
    this.ext,
    this.mime,
    this.width,
    this.height,
    this.size,
    this.path,
    this.url,
    this.providerMetadata,
  });

  String hash;
  Ext ext;
  Mime mime;
  int width;
  int height;
  double size;
  dynamic path;
  String url;
  ProviderMetadata providerMetadata;

  factory Thumbnail.fromJson(Map<String, dynamic> json) => Thumbnail(
        hash: json["hash"],
        ext: extValues.map[json["ext"]],
        mime: mimeValues.map[json["mime"]],
        width: json["width"],
        height: json["height"],
        size: json["size"].toDouble(),
        path: json["path"],
        url: json["url"],
        providerMetadata: ProviderMetadata.fromJson(json["provider_metadata"]),
      );

  Map<String, dynamic> toJson() => {
        "hash": hash,
        "ext": extValues.reverse[ext],
        "mime": mimeValues.reverse[mime],
        "width": width,
        "height": height,
        "size": size,
        "path": path,
        "url": url,
        "provider_metadata": providerMetadata.toJson(),
      };
}

enum Mime { IMAGE_JPEG, IMAGE_PNG }

final mimeValues =
    EnumValues({"image/jpeg": Mime.IMAGE_JPEG, "image/png": Mime.IMAGE_PNG});

class ProviderMetadata {
  ProviderMetadata({
    this.publicId,
    this.resourceType,
  });

  String publicId;
  ResourceType resourceType;

  factory ProviderMetadata.fromJson(Map<String, dynamic> json) =>
      ProviderMetadata(
        publicId: json["public_id"],
        resourceType: resourceTypeValues.map[json["resource_type"]],
      );

  Map<String, dynamic> toJson() => {
        "public_id": publicId,
        "resource_type": resourceTypeValues.reverse[resourceType],
      };
}

enum ResourceType { IMAGE }

final resourceTypeValues = EnumValues({"image": ResourceType.IMAGE});

enum Provider { CLOUDINARY }

final providerValues = EnumValues({"cloudinary": Provider.CLOUDINARY});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
