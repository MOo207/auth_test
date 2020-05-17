import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:auth_test/main.dart';
class Done extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth _auth = FirebaseAuth.instance;
     Size scr = MediaQuery.of(context).size;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.black,
      ),
      home: new Scaffold(
        resizeToAvoidBottomPadding: false,
        body: new Container(
          height: scr.height,
          width: scr.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                Text("Done"),
                Padding(padding: EdgeInsets.all(20),),
                button("SIGNOUT", 100, 50, (){_auth.signOut();
                Navigator.pop(context);
                Route route = MaterialPageRoute(builder: (context)=> MyHomePage());
                Navigator.of(context).push(route);}),
          ],
        ),
      ),),
    );
  }

  Widget button(String title, double width, double height,Function onpress) {
    return new SizedBox(
      width: width,
      height: height,
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        color: Colors.black,
        textColor: Colors.black,
        padding: EdgeInsets.all(8.0),
        onPressed: onpress,
        splashColor: Colors.white,
        elevation: 23,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.0,
          ),
        ),
      ),
    );
  }
}
