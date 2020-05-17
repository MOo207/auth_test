import 'package:auth_test/Done.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        '/done': (BuildContext context) => Done(),
      },
      home: new Scaffold(
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
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
              Padding(padding: EdgeInsets.only(bottom: 70)),
              title(),
              Padding(padding: EdgeInsets.only(top: 90)),
              _otpTextField(
                  300,
                  (val) {
                    if (val.length == 0) {
                      return "Feild cannot be empty";
                    } else if (val.length > 13) {
                      return "Cannot Exceed length of 13 ";
                    }
                  },
                  "Enter Phone Number",
                  TextInputType.phone,
                  (phoneNum) {
                    this.phoneNum = phoneNum.trim();
                  }),
              Padding(padding: EdgeInsets.only(bottom: 100)),
              button("verify", 250, 50, () => verifyPhoneNum()),
            ],
          ),
        ),
      ),
    );
  }

  
  FirebaseAuth _auth = FirebaseAuth.instance;
  String verId;
  String smsOTP;
  String phoneNum;

  String message;

  Future<void> verifyPhoneNum() async {
    PhoneCodeSent phCoSe = (String verId, [int forceCodeResend]) {
      this.verId = verId;
      otpDialog(context).then((value) {
        print("CodeSent");
      });
    };

    PhoneVerificationCompleted phVerDone =
        (AuthCredential phoneAuthCredential) async {
      print(phoneAuthCredential);
      print("Done!");
      Navigator.of(context).pushReplacementNamed("/done");
    };

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: this.phoneNum,
        timeout: Duration(seconds: 60),
        codeSent: phCoSe,
        verificationCompleted: phVerDone,
        verificationFailed: (AuthException e) {
          print("Fail!");
          print('${e.message}');
        },
        codeAutoRetrievalTimeout: (String verid) {
          this.verId = verid;
          print("TimeOut");
        },
      );
    } catch (error) {
      print("Error");
      print('${error.toString()}');
      handleError(error);
    }
  }

  handleError(PlatformException error) {
    print(error);
    switch (error.code) {
      case 'ERROR_INVALID_VERIFICATION_CODE':
        FocusScope.of(context).requestFocus(new FocusNode());
        setState(() {
          message = 'Invalid Code';
        });
        Navigator.of(context).pop();
        break;
      default:
        setState(() {
          message = error.message;
        });

        break;
    }
  }

  signIn() async {
    try {
      final AuthCredential credential = PhoneAuthProvider.getCredential(
        verificationId: verId,
        smsCode: smsOTP,
      );
      final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      Navigator.of(context).pushReplacementNamed('/done');
    } catch (e) {
      handleError(e);
    }
  }
  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _auth.currentUser();
    return user;
  }

  Future<bool> otpDialog(BuildContext context) {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: Text('Enter SMS Code'),
            content: Container(
              height: 90,
              width: 120,
              child: Column(
                children: [
                  Padding(padding: EdgeInsets.only(top: 18)),
                  _otpTextField(
                      150,
                      (val) {
                        if (val.length == 0) {
                          return "Feild cannot be empty";
                        } else if (val.length > 13) {
                          return "Cannot Exceed length of 13 ";
                        }
                      },
                      "OTP",
                      TextInputType.number,
                      (otp) {
                        this.smsOTP = otp.trim();
                      }),
                ],
              ),
            ),
            //contentPadding: EdgeInsets.all(10),
            actions: <Widget>[
              FlatButton(
                onPressed: () {},
                child: Text(
                  "RESEND",
                  style: TextStyle(color: Colors.black),
                ),
                splashColor: Colors.black,
              ),
              button(
                "confirm",
                100.0,
                40.0,

               () {
                  _auth.currentUser().then((user) {
                    if (user != null) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed('/done');
                    } else {
                      signIn();
                    }
                  });
                },

              ),
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  "DISMISS",
                  style: TextStyle(color: Colors.black),
                ),
                splashColor: Colors.black,
              ),
            ],
          );
        });
  }
  Widget title() {
    return new Text(
      "Please Enter Phone Number",
      textAlign: TextAlign.center,
      style: new TextStyle(
          fontSize: 20, color: Colors.black, fontWeight: FontWeight.w600),
    );
  }

  Widget _otpTextField(double width, Function validator, String title,
      TextInputType type, Function onChnged) {
    return new Container(
      width: width,
      child: TextFormField(
        onChanged: onChnged,
        decoration: new InputDecoration(
          labelText: title,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderSide: BorderSide(),
            borderRadius: new BorderRadius.circular(25.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.black, width: 2.0),
            borderRadius: new BorderRadius.circular(25.0),
          ),
        ),
        validator: validator,
        keyboardType: type,
        style: new TextStyle(
          fontFamily: "Poppins",
        ),
      ),
    );
  }

  Widget button(String title, double width, double height, Function function) {
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
        onPressed: () {
          print(this.phoneNum);
          verifyPhoneNum();
        },
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
