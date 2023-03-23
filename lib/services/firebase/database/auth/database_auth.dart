import 'dart:core';
import 'dart:developer';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sscarapp/helper/user_defaults_functions.dart';

class DatabaseAuth{
  final FirebaseAuth authInstance = FirebaseAuth.instance;
  final dbInstance = FirebaseDatabase.instance;
  final usersChildInstances = FirebaseDatabase.instance.ref().child("kullanicilar");


  Future<String?> registerWithEmailAndPassword(String email, String password) async {
    try{
      return await authInstance.createUserWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        final userUid = value.user?.uid;
        if (userUid != null) {
          print("register was success $userUid");
          UserDefaultsFunctions.setUserLoggedInStatus(true);
          UserDefaultsFunctions.saveUserUidSF(userUid);
          //uuuid = userUid;
          return userUid;
        }else{
          throw "Coulnt get uuid";
        }
      });
    } on FirebaseAuthException  catch (e) {
      throw getMessageFromErrorCode(e.code);
    } catch (e) {
      throw "456 $e";
    }
  }

  Future<String?> loginWithEmailAndPassword(String email, String password) async {
    try{
      return await authInstance.signInWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        final userUid = value.user?.uid;
        if (userUid != null) {
          print("login was success $userUid");
          UserDefaultsFunctions.setUserLoggedInStatus(true);
          UserDefaultsFunctions.saveUserUidSF(userUid);
          //uuuid = userUid;
          //asd
          return userUid;
        }else{
          throw "Coulnt get uuid";
        }
      });
    } on FirebaseAuthException catch (e) {
      throw  getMessageFromErrorCode(e.code);
    } catch (e) {
      throw "312 $e";
    }
  }

  Future<String?> disableAccountEmail(String email, String password) async {
    try{
      return await authInstance.signInWithEmailAndPassword(email: email, password: password)
          .then((value) async {
        final userUid = value.user?.uid;
        if (userUid != null) {
          print("login was success $userUid");
          UserDefaultsFunctions.setUserLoggedInStatus(true);
          UserDefaultsFunctions.saveUserUidSF(userUid);
          //uuuid = userUid;
          //asd
          return userUid;
        }else{
          throw "Coulnt get uuid";
        }
      });
    } on FirebaseAuthException catch (e) {
      throw  getMessageFromErrorCode(e.code);
    } catch (e) {
      throw "312 $e";
    }
  }

  // signout
  Future signOut() async {
    try {
      await UserDefaultsFunctions.removeUserLoggedInStatus();
      await UserDefaultsFunctions.removeUserUidSF();
      await UserDefaultsFunctions.removeUserUsernameSF();
      await UserDefaultsFunctions.removeUserIsPremiumSF();
      await UserDefaultsFunctions.removeUserPremiumCheckDateSF();
      //await UserDefaultsFunctions.removeUserTokenDataSF();
      await UserDefaultsFunctions.removeUserFullnameSF();
      await authInstance.signOut();
    } catch (e) {
      return e;
    }
  }

  Future<bool> resetPasswordByEmail({required String email}) async {
    try{
      await authInstance.sendPasswordResetEmail(email: email);
      return true;
    } catch (e){
      log("error resetting $e");
      return false;
    }
  }

  Future<bool> isUsernameAlreadyExisting(String nickname)async{
    final result = await usersChildInstances
        .orderByChild("nickname")
        .equalTo(nickname)
        .once();
    //If the name is available

    if (result.snapshot.value != null) {
      return true;
    }
    return false;
  }

}

String getMessageFromErrorCode(String errorCode) {
  switch (errorCode) {
    case "ERROR_EMAIL_ALREADY_IN_USE":
    case "account-exists-with-different-credential":
    case "email-already-in-use":
      return "Email already used. Go to login page.";
    case "ERROR_WRONG_PASSWORD":
    case "wrong-password":
      return "Wrong email/password combination.";
    case "ERROR_USER_NOT_FOUND":
    case "user-not-found":
      return "No user found with this email.";
    case "ERROR_USER_DISABLED":
    case "user-disabled":
      return "User disabled.";
    case "ERROR_TOO_MANY_REQUESTS":
    case "operation-not-allowed":
      return "Too many requests to log into this account.";
    case "ERROR_OPERATION_NOT_ALLOWED":
      return "Server error, please try again later.";
    case "ERROR_INVALID_EMAIL":
    case "invalid-email":
      return "Email address is invalid.";
    default:
      return "Login failed. Please try again.";
  }
}