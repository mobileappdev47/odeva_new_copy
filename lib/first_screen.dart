import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eshop/SignInUpAcc.dart';
import 'package:eshop/web_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'Helper/Color.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({Key key}) : super(key: key);

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {

  FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isHide;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

      firestore.collection("accountHide").get().then((value) {
        print(value);

        for(int i=0; i<value.docs.length; i++){
          isHide = value.docs[i]["isHide"];
          setState(() {});
        }

      });


  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.darkColor,
                    colors.darkColor.withOpacity(0.8),
                    Color(0xFFF8F8FF),
                  ]),
            ),
          ),
          Center(
            child: Column(
              children: [
                SizedBox(
                  height: 85,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => WebViewScreen()));
                  },
                  child: Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                        color: colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepPurple,
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                    image: DecorationImage(
                      image:  AssetImage("assets/images/Frame 28.png"),fit: BoxFit.cover,
                    ),
                    ),

                  ),
                ),
                SizedBox(
                  height:10,
                ),
                Container(
                  height: 35,
                  width: 170,
                  decoration: BoxDecoration(
                      color: colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurple,
                          blurRadius: 50,
                          spreadRadius: 0.5,
                        ),
                      ]),
                  child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "My Business",
                        style: TextStyle(
                            color: colors.darkColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )),
                ),
                SizedBox(
                  height: 40,
                ),

                (isHide == true)
                    ? Column(
                 children: [
                   GestureDetector(
                     onTap: () async{
                       // await launchUrl(Uri.parse("https://businesspartnershipportal.com"));
                       Navigator.push(context, MaterialPageRoute(builder: (context) => SignInUpAcc(),));
                     },
                     child: Container(
                       height: 150,
                       width: 150,
                       decoration: BoxDecoration(
                         color: colors.white,
                         borderRadius: BorderRadius.circular(20),
                         boxShadow: [
                           BoxShadow(
                             color: Colors.deepPurple,
                             blurRadius: 30,
                             spreadRadius: 2,
                           ),
                         ],
                         image: DecorationImage(
                           image:  NetworkImage("https://media.istockphoto.com/id/1407787199/photo/portrait-of-young-asian-business-woman-using-digital-tablet-in-the-office.jpg?b=1&s=170667a&w=0&k=20&c=ASdZd3bww5_D6a5P5cOc3mA1k-rMeBImSj7YMwxtv2I="),fit: BoxFit.cover,
                         ),
                       ),
                     ),
                   ),
                   SizedBox(
                     height: 10,
                   ),
                   Container(
                     height: 35,
                     width: 170,
                     decoration: BoxDecoration(
                         color: colors.white,
                         borderRadius: BorderRadius.circular(20),
                         boxShadow: [
                           BoxShadow(
                             color: Colors.deepPurple,
                             blurRadius: 50,
                             spreadRadius: 0.5,
                           ),
                         ]),
                     child: Align(
                         alignment: Alignment.center,
                         child: Text(
                           "My Account",
                           style: TextStyle(
                               color: colors.darkColor,
                               fontSize: 20,
                               fontWeight: FontWeight.bold),
                         )),
                   ),
                 ],
               )
                    : SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
