import 'dart:async';
import 'dart:io';
import 'package:eshop/Helper/Color.dart';
import 'package:eshop/Set_Password.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'Helper/AppBtn.dart';
import 'Helper/Session.dart';
import 'Helper/String.dart';
import 'SignUp.dart';

class VerifyOtp extends StatefulWidget {
  final String mobileNumber, countryCode, title;

  VerifyOtp(
      {Key key, @required this.mobileNumber, this.countryCode, this.title})
      : assert(mobileNumber != null),
        super(key: key);

  @override
  _MobileOTPState createState() => new _MobileOTPState();
}

class _MobileOTPState extends State<VerifyOtp> with TickerProviderStateMixin {
  final dataKey = new GlobalKey();
  String password, mobile, countrycode;
  String otp;
  bool isCodeSent = false;
  String _verificationId;
  String signature = "";
  bool _isClickable = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FocusNode focusNode = FocusNode();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Animation buttonSqueezeanimation;
  AnimationController buttonController;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getUserDetails();
    getSingature();
    _onVerifyCode();
    Future.delayed(Duration(seconds: 60)).then((_) {
      _isClickable = true;
    });
    buttonController = new AnimationController(
        duration: new Duration(milliseconds: 2000), vsync: this);

    buttonSqueezeanimation = new Tween(
      begin: deviceWidth * 0.7,
      end: 50.0,
    ).animate(new CurvedAnimation(
      parent: buttonController,
      curve: new Interval(
        0.0,
        0.150,
      ),
    ));
  }

  Future<void> getSingature() async {
    signature = await SmsAutoFill().getAppSignature;
    await SmsAutoFill().listenForCode;
  }

  getUserDetails() async {
    mobile = await getPrefrence(MOBILE);
    countrycode = await getPrefrence(COUNTRY_CODE);
    if (mounted) setState(() {});
  }

  Future<void> checkNetworkOtp() async {
    bool avail = await isNetworkAvailable();
    if (avail) {
      if (_isClickable) {
        _onVerifyCode();
      } else {
        setSnackbar(getTranslated(context, 'OTPWR'));
      }
    } else {
      if (mounted) setState(() {});

      Future.delayed(Duration(seconds: 60)).then((_) async {
        bool avail = await isNetworkAvailable();
        if (avail) {
          if (_isClickable)
            _onVerifyCode();
          else {
            setSnackbar(getTranslated(context, 'OTPWR'));
          }
        } else {
          await buttonController.reverse();
          setSnackbar(getTranslated(context, 'somethingMSg'));
        }
      });
    }
  }

  verifyBtn() {
    return AppBtn(
        title: getTranslated(context, 'VERIFY_AND_PROCEED'),
        btnAnim: buttonSqueezeanimation,
        btnCntrl: buttonController,
        onBtnSelected: () async {
          _onFormSubmitted();
        });
  }

  setSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
      content: new Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: colors.fontColor),
      ),
      backgroundColor: colors.lightWhite,
      elevation: 1.0,
    ));
  }

  void _onVerifyCode() async {
    if (mounted)
      setState(() {
        isCodeSent = true;
      });
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _firebaseAuth
          .signInWithCredential(phoneAuthCredential)
          .then((UserCredential value) {
        if (value.user != null) {
          setSnackbar(getTranslated(context, 'OTPMSG'));
          setPrefrence(MOBILE, mobile);
          setPrefrence(COUNTRY_CODE, countrycode);
          if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
            Future.delayed(Duration(seconds: 2)).then((_) {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => SignUp()));
            });
          } else if (widget.title ==
              getTranslated(context, 'FORGOT_PASS_TITLE')) {
            Future.delayed(Duration(seconds: 2)).then((_) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SetPass(mobileNumber: mobile)));
            });
          }
        } else {
          setSnackbar(getTranslated(context, 'OTPERROR'));
        }
      }).catchError((error) {
        setSnackbar(error.toString());
      });
    };
    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      setSnackbar(authException.message);
      print(authException.message);
      if (mounted)
        setState(() {
          isCodeSent = false;
        });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      _verificationId = verificationId;
      if (mounted)
        setState(() {
          _verificationId = verificationId;
        });
    };
    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
      if (mounted)
        setState(() {
          _isClickable = true;
          _verificationId = verificationId;
        });
    };

    await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: "+${widget.countryCode}${widget.mobileNumber}",
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  void _onFormSubmitted() async {
    String code = otp.trim();

    if (code.length == 6) {
      _playAnimation();
      AuthCredential _authCredential = PhoneAuthProvider.credential(
          verificationId: _verificationId, smsCode: code);

      _firebaseAuth
          .signInWithCredential(_authCredential)
          .then((UserCredential value) async {
        if (value.user != null) {
          await buttonController.reverse();
          setSnackbar(getTranslated(context, 'OTPMSG'));
          setPrefrence(MOBILE, mobile);
          setPrefrence(COUNTRY_CODE, countrycode);
          if (widget.title == getTranslated(context, 'SEND_OTP_TITLE')) {
            Future.delayed(Duration(seconds: 2)).then((_) {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => SignUp()));
            });
          } else if (widget.title ==
              getTranslated(context, 'FORGOT_PASS_TITLE')) {
            Future.delayed(Duration(seconds: 2)).then((_) {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SetPass(mobileNumber: mobile)));
            });
          }
        } else {
          setSnackbar(getTranslated(context, 'OTPERROR'));
          await buttonController.reverse();
        }
      }).catchError((error) async {
        if (error
            .toString()
            .contains('firebase_auth/invalid-verification-code')) {
          print("ERROR of verify otp: " + error.toString());
          setSnackbar("Invalid OTP");
        }

        await buttonController.reverse();
      });
    } else {
      setSnackbar(getTranslated(context, 'ENTEROTP'));
    }
  }

  Future<Null> _playAnimation() async {
    try {
      await buttonController.forward();
    } on TickerCanceled {}
  }

  getImage() {
    return Container(
        height: deviceHeight * 0.15,
        width: deviceWidth * 0.765,
        child: new Image.asset('assets/images/homelogo.png'));
  }

  backBtn() {
    return Platform.isIOS || Platform.isAndroid
        ? Container(
            margin: EdgeInsets.only(left: 10, top: 20),
            padding: EdgeInsets.only(top: 20.0, left: 10.0),
            alignment: Alignment.topLeft,
            child: Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: InkWell(
                  child: Icon(Icons.keyboard_arrow_left, color: colors.primary),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ))
        : Container();
  }

  @override
  void dispose() {
    buttonController.dispose();
    super.dispose();
  }

  monoVarifyText() {
    return Padding(
        padding: EdgeInsetsDirectional.only(
          top: 30.0,
        ),
        child: Center(
          child: new Text(getTranslated(context, 'MOBILE_NUMBER_VARIFICATION'),
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                  color: colors.fontColor, fontWeight: FontWeight.bold)),
        ));
  }

  otpText() {
    return Padding(
        padding: EdgeInsetsDirectional.only(top: 50.0, start: 20.0, end: 20.0),
        child: Center(
          child: new Text(getTranslated(context, 'SENT_VERIFY_CODE_TO_NO_LBL'),
              style: Theme.of(context).textTheme.subtitle2.copyWith(
                  color: colors.fontColor, fontWeight: FontWeight.normal)),
        ));
  }

  mobText() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
          bottom: 10.0, start: 20.0, end: 20.0, top: 10.0),
      child: Center(
        child: Text("+$countrycode-$mobile",
            style: Theme.of(context).textTheme.subtitle1.copyWith(
                color: colors.fontColor, fontWeight: FontWeight.normal)),
      ),
    );
  }

  otpLayout() {
    return Padding(
        padding: EdgeInsetsDirectional.only(
          start: 50.0,
          end: 50.0,
        ),
        child: Center(
            child: InkWell(
          onTap: () {
            Future.delayed(Duration(seconds: 2), () {
              setState(() {
                _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: Duration(milliseconds: 100),
                    curve: Curves.bounceOut);
              });
            });

          },
          child: PinFieldAutoFill(
            decoration: UnderlineDecoration(
              textStyle: TextStyle(fontSize: 20, color: colors.fontColor),
              colorBuilder: FixedColorBuilder(colors.lightBlack2),
            ),
            currentCode: otp,
            codeLength: 6,
            //autofocus: true,
            focusNode: focusNode,
            onCodeChanged: (String code) {
              otp = code;
              setState(() {
                Future.delayed(Duration(seconds: 2), () {
                  _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: Duration(milliseconds: 100),
                      curve: Curves.bounceOut);
                  setState(() {});
                });
              });
            },
            onCodeSubmitted: (String code) {
              otp = code;
            },
          ),
        )));
  }

  resendText() {
    return Padding(
      padding: EdgeInsetsDirectional.only(
          bottom: 30.0, start: 25.0, end: 25.0, top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            getTranslated(context, 'DIDNT_GET_THE_CODE'),
            style: Theme.of(context).textTheme.caption.copyWith(
                color: colors.fontColor, fontWeight: FontWeight.normal),
          ),
          InkWell(
              onTap: () async {
                await buttonController.reverse();
                checkNetworkOtp();
              },
              child: Text(
                getTranslated(context, 'RESEND_OTP'),
                style: Theme.of(context).textTheme.caption.copyWith(
                    color: colors.fontColor,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.normal),
              ))
        ],
      ),
    );
  }

  expandedBottomView() {
    return Expanded(
      // flex: 6,
      child: Container(
        padding: EdgeInsets.only(top: 10),
        alignment: Alignment.center,
        child: ScrollConfiguration(
            behavior: MyBehavior(),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Card(
                elevation: 0.5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    monoVarifyText(),
                    otpText(),
                    mobText(),
                    otpLayout(),
                    verifyBtn(),
                    resendText(),
                  ],
                ),
              ),
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (focusNode.hasFocus) {
      setState(() {
        Future.delayed(Duration(seconds: 2), () {

          _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 100),
              curve: Curves.bounceOut);
          setState(() {
          });
        });
      });
    }
    return Scaffold(
        key: _scaffoldKey,
        body: Container(
          //color: colors.lightWhite,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  // Color(0xFF280F43),
                  // Color(0xffE5CCFF),
                  Color(0xFF200738),
                  Color(0xFF3B147A),
                  Color(0xFFF8F8FF),
                ]),
          ),
          padding: EdgeInsetsDirectional.only(
            bottom: 20.0,
          ),
          child: Column(
            children: <Widget>[
              backBtn(),
              getImage(),
              expandedBottomView(),
            ],
          ),
        ));
  }
}
