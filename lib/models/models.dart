
class UserPersonalDataModel{
  dynamic activity;
  String? biography;
  int? bannedUntil;
  UserDMList? conversations;
  String deviceId;
  String email;
  bool? emailVerified;
  String? fullname;
  String? ipAddress;
  String lastSeen;
  String? nickname;
  Map? ownedSignPlates;
  PhoneSettings? phoneSettings;
  Preferences? preferences;
  String? premium;
  String? profilePicture;
  String registerDate;
  Tokens? tokens;

  UserPersonalDataModel({
    this.activity,
    this.biography,
    this.bannedUntil,
    this.conversations,
    required this.deviceId,
    required this.email,
    required this.emailVerified,
    this.fullname,
    this.ipAddress,
    required this.lastSeen,
    this.nickname,
    this.ownedSignPlates,
    this.phoneSettings,
    this.preferences,
    this.premium,
    this.profilePicture,
    required this.registerDate,
    this.tokens,
  });

//type 'Null' is not a subtype of type 'Map<dynamic, dynamic>
  UserPersonalDataModel.fromJson(Map<dynamic, dynamic> json)
      : activity = json['activity'],
        biography = json['biography'],
        bannedUntil = json['bannedUntil'],
        conversations = json["usersDMs"] == null ? null : UserDMList.fromJson(json['usersDMs']),
        deviceId = json['deviceId'],
        email = json['email'],
        emailVerified = json['emailVerified'],
        fullname = json['fullname'],
        ipAddress = json['ipAddress'],
        lastSeen = json['lastSeen'],
        nickname = json['nickname'],
        ownedSignPlates = json['ownedSignPlates'],
        phoneSettings = json["phoneSettings"] == null ? null : PhoneSettings.fromJson(json['phoneSettings']),
        preferences = json["preferences"] == null ? null : Preferences.fromJson(json['preferences']),
        premium = json['premium'],
        profilePicture = json['profilePicture'],
        registerDate = json['registerDate'],
        tokens = json["tokens"] == null ? null : Tokens.fromJson(json['tokens']);

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'activity' :activity,
    'biography' :biography,
    'bannedUntil' :bannedUntil,
    'conversations' :conversations,
    'deviceId' :deviceId,
    'email' :email,
    'emailVerified' :emailVerified,
    'fullname' :fullname,
    'ipAddress' :ipAddress,
    'lastSeen' :lastSeen,
    'nickname' :nickname,
    'ownedSignPlates' :ownedSignPlates,
    'phoneSettings' :phoneSettings,
    'preferences' :preferences,
    'premium' :premium,
    'profilePicture' :profilePicture,
    'registerDate' :registerDate,
    //'tokens' :tokens,
  };

/*UserPersonalDataModel.fromJson(Map<String, dynamic> json) {
    activity = json['activity'];
    biography = json['biography'];
    conversations = json['conversations'];
    deviceId = json['deviceId'];
    email = json['email'];
    emailVerified = json['emailVerified'];
    fullname = json['fullname'];
    ipAddress = json['ipAddress'];
    lastSeen = json['lastSeen'];
    nickname = json['nickname'];
    ownedSignPlates = json['ownedSignPlates'];
    phoneSettings = json['phoneSettings'];
    preferences = json['preferences'];
    premium = json['premium'];
    profilePicture = json['premium'];
    registerDate = json['premium'];
    tokens = json['premium'];
  }*/
}

class UserDMList{
  final Map<String, UserConversation> usersDMs;

  UserDMList({
    required this.usersDMs,
  });

  factory UserDMList.fromJson(Map<String, dynamic> json){
    var innerMap = json['conversations'];
    var tagMap = Map<String, UserConversation>();
    innerMap.forEach((key, value) {
      tagMap.addAll({key: UserConversation.fromJson(value)});
    });
    return UserDMList(
      usersDMs: tagMap,
    );
  }
}

class UserConversation{
  final String content;
  final String date;
  final bool isActive;
  final bool isRead;
  final bool? isUser;
  final String targetUseruid;
  final String type;
  final int unreadCount;
  final String useruid;

  UserConversation({
    required this.content,
    required this.date,
    required this.isActive,
    required this.isRead,
    this.isUser,
    required this.targetUseruid,
    required this.type,
    required this.unreadCount,
    required this.useruid,
  });


  UserConversation.fromJson(Map<dynamic, dynamic> json)
      : content = json["content"] == null ? null : json['content'],
        date = json["date"] == null ? null : json['date'],
        isActive = json["isActive"] == null ? null : json['isActive'],
        isRead = json["isRead"] == null ? null : json['isRead'],
        isUser = json["isUser"] == null ? null : json['isUser'],
        targetUseruid = json["targetUseruid"] == null ? null : json['targetUseruid'],
        type = json["type"] == null ? null : json['type'],
        unreadCount = json["unreadCount"] == null ? null : json['unreadCount'],
        useruid = json["useruid"] == null ? null : json['useruid'];
}

class UserConversationChatInfo {
  final String content;
  final String date;
  final bool isActive;
  final String targetUseruid;
  final String type;
  final String useruid;
  bool? isUser;

  UserConversationChatInfo({
    required this.content,
    required this.date,
    required this.isActive,
    required this.targetUseruid,
    required this.type,
    required this.useruid,
    this.isUser,
  });


  UserConversationChatInfo.fromJson(Map<dynamic, dynamic> json)
      : content = json["content"] == null ? null : json['content'],
        date = json["date"] == null ? null : json['date'],
        isActive = json["isActive"] == null ? null : json['isActive'],
        targetUseruid = json["targetUseruid"] == null ? null : json['targetUseruid'],
        type = json["type"] == null ? null : json['type'],
        isUser = json["isUser"] == null ? null : json['isUser'],
        useruid = json["useruid"] == null ? null : json['useruid'];

  Map<dynamic, dynamic> toJson() => <dynamic, dynamic>{
    'content': content,
    'date': date,
    'isActive': isActive,
    'targetUseruid': targetUseruid,
    'type' : type,
    'isUser' : isUser,
    'useruid': useruid,
  };
}


class PhoneSettings{
  final String date;
  final String phoneNumber;
  final bool showNumber;

  PhoneSettings({
    required this.date,
    required this.phoneNumber,
    required this.showNumber,
  });

  PhoneSettings.fromJson(Map<dynamic, dynamic> json)
      : date = json["date"] == null ? null : json['date'],
        phoneNumber = json["phoneNumber"] == null ? null : json['phoneNumber'],
        showNumber = json["showNumber"] == null ? null : json['showNumber'];
}

class Preferences{
  final String forSaleLink;
  final bool isForSale;
  final bool onlyReadyMessages;

  Preferences({
    required this.forSaleLink,
    required this.isForSale,
    required this.onlyReadyMessages,
  });

  Preferences.fromJson(Map<dynamic, dynamic> json)
      : forSaleLink = json["forSaleLink"] == null ? null : json['forSaleLink'],
        isForSale = json["isForSale"] == null ? null : json['isForSale'],
        onlyReadyMessages = json["onlyReadyMessages"] == null ? null : json['onlyReadyMessages'];
}

class Tokens{
  final String lastFreeGivenDate;
  final String tokenCount;

  Tokens({
    required this.lastFreeGivenDate,
    required this.tokenCount,
  });


  Tokens.fromJson(Map<dynamic, dynamic> json)
      : lastFreeGivenDate = json["lastFreeGivenDate"] == null ? null : json['lastFreeGivenDate'],
        tokenCount = json["tokenCount"] == null ? null : json['tokenCount'];



  Map<String, dynamic> toJson() => (<String, dynamic>{
    'lastFreeGivenDate': lastFreeGivenDate,
    'tokenCount': tokenCount,
    //'email': null, email degistirilemez, yoruym satiri yapmak zorunlu...
    // yoksa edit profilde doldurmak gerekli ama ne gerek var?
  });
}

class UserEditProfileInfo{
  String? fullname;
  String? nickname;
  String? biography;
  String? email;
  String? profilePicture;

  UserEditProfileInfo({
    this.fullname,
    this.nickname,
    this.biography,
    this.email,
    this.profilePicture,
  });

  Map<String, dynamic> toJson() => (<String, dynamic>{
    'fullname': fullname,
    'nickname': nickname,
    'biography': biography,
    'profilePicture': profilePicture,
    //'email': null, email degistirilemez, yoruym satiri yapmak zorunlu...
    // yoksa edit profilde doldurmak gerekli ama ne gerek var?
  });
}


class UserEditContactInfo{
  String date;
  String phoneNumber;
  bool showNumber;

  UserEditContactInfo({
    required this.date,
    required this.phoneNumber,
    required this.showNumber,
  });

  Map<String, dynamic> toJson() => (<String, dynamic>{
    'date': date,
    'phoneNumber': phoneNumber,
    'showNumber': showNumber,
  });


  UserEditContactInfo.fromJson(Map<dynamic, dynamic> json)
      : date = json['date'],
        phoneNumber = json['phoneNumber'],
        showNumber = json['showNumber'];

}



class UserPreferencesInfo{
  String forSaleLink;
  bool isForSale;
  bool onlyReadyMessages;

  UserPreferencesInfo({
    required this.forSaleLink,
    required this.isForSale,
    required this.onlyReadyMessages,
  });

  Map<String, dynamic> toJson() => (<String, dynamic>{
    'forSaleLink': forSaleLink,
    'isForSale': isForSale,
    'onlyReadyMessages': onlyReadyMessages,
  });


  UserPreferencesInfo.fromJson(Map<dynamic, dynamic> json)
      : forSaleLink = json['forSaleLink'],
        isForSale = json['isForSale'],
        onlyReadyMessages = json['onlyReadyMessages'];
}

class UserInAppNotifications{
  String content;
  String date;
  String kind;
  String senderid;
  String toPlaka;
  String? senderPpUrl;
  String? senderNickname;
  String? senderPhoneNumber;
  String? senderBiography;

  UserInAppNotifications({
    required this.content,
    required this.date,
    required this.kind,
    required this.senderid,
    required this.toPlaka,
  });

  Map<String, dynamic> toJson() => (<String, dynamic>{
    'content': content,
    'date': date,
    'kind': kind,
    'senderid': senderid,
    'toPlaka': toPlaka,
  });


  UserInAppNotifications.fromJson(Map<dynamic, dynamic> json)
      : content = json['content'],
        date = json['date'],
        kind = json['kind'],
        senderid = json['senderid'],
        senderPpUrl = json['senderPpUrl'],
        senderNickname = json['senderNickname'],
        senderBiography = json['senderBiography'],
        senderPhoneNumber = json['senderPhoneNumber'],
        toPlaka = json['toPlaka'];

}

class UserWallPosts{
  String content;
  String? isUser;
  String? moderationDate;
  String? moderator;
  String plaka;
  String postDate;
  String? senderIpAddress;
  String senderUuid;
  String? senderPpUrl;
  String? senderNickname;
  String? commentId;

  UserWallPosts({
    required this.content,
    required this.isUser,
    this.moderationDate,
    this.moderator,
    required this.plaka,
    required this.postDate,
    required this.senderIpAddress,
    required this.senderUuid,
  });

  Map<String, dynamic> toJson() => (<String, dynamic>{
    'content': content,
    'isUser': isUser,
    'moderationDate': moderationDate,
    'moderator': moderator,
    'plaka': plaka,
    'postDate': postDate,
    'senderIpAddress': senderIpAddress,
    'senderUuid': senderUuid,
  });

  UserWallPosts.fromJson(Map<dynamic, dynamic> json)
      : content = json['content'],
        isUser = json['isUser'],
        moderationDate = json['moderationDate'],
        moderator = json['moderator'],
        plaka = json['plaka'],
        postDate = json['postDate'],
        senderIpAddress = json['senderIpAddress'],
        senderUuid = json['senderUuid'],
        senderPpUrl = json['ppUrl'],
        commentId = json['commentId'],
        senderNickname = json['nickname'];
}

class ReportCommentPost{
  final String content;
  final String date;
  final String selfUserUid;
  final String commentId;

  ReportCommentPost({
    required this.content,
    required this.date,
    required this.selfUserUid,
    required this.commentId,
  });

  Map<String, dynamic> toJson() => (<String, dynamic>{
    'content': content,
    'date': date,
    'selfUserUid': selfUserUid,
    'plaka': commentId,
  });

  ReportCommentPost.fromJson(Map<dynamic, dynamic> json)
      : content = json['content'],
        date = json['date'],
        selfUserUid = json['selfUserUid'],
        commentId = json['commentId'];
}

class ContactUsForm{
  final String content;
  final String date;
  final String selfUserUid;

  ContactUsForm({
    required this.content,
    required this.date,
    required this.selfUserUid,
  });

  Map<String, dynamic> toJson() => (<String, dynamic>{
    'content': content,
    'date': date,
    'selfUserUid': selfUserUid,
  });

  ContactUsForm.fromJson(Map<dynamic, dynamic> json)
      : content = json['content'],
        date = json['date'],
        selfUserUid = json['selfUserUid'];

}

class ReportUserAccount{
  final String content;
  final String date;
  final String selfUserUid;
  final String targetUseruid;

  ReportUserAccount({
    required this.content,
    required this.date,
    required this.selfUserUid,
    required this.targetUseruid,
  });

  Map<String, dynamic> toJson() => (<String, dynamic>{
    'content': content,
    'date': date,
    'selfUserUid': selfUserUid,
    'targetUseruid': targetUseruid,
  });

  ReportUserAccount.fromJson(Map<dynamic, dynamic> json)
      : content = json['content'],
        date = json['date'],
        selfUserUid = json['selfUserUid'],
        targetUseruid = json['targetUseruid'];
}



class EmojisCollection{
  final int? clap;
  final int? heart;
  final int? onehundret;
  final int? fire;
  final int? swearing;

  EmojisCollection({
    this.clap,
    this.heart,
    this.onehundret,
    this.fire,
    this.swearing,
  });


  Map<String, dynamic> toJson() => (<String, dynamic>{
    'clap': clap,
    'heart': heart,
    'onehundret': onehundret,
    'fire': fire,
    'swearing': swearing,
  });

  EmojisCollection.fromJson(Map<dynamic, dynamic> json)
      : clap = json['clap'],
        heart = json['heart'],
        onehundret = json['onehundret'],
        fire = json['fire'],
        swearing = json['swearing'];
}


class UserDrivingPointsGivenByInfo {
  final String date;
  final String plate;
  final int point;

  UserDrivingPointsGivenByInfo({
    required this.date,
    required this.plate,
    required this.point,
  });


}

class UserDrivingPointsInfo{
  final int? pointSendersCount;
  final int? totalDrivingPoints;

  UserDrivingPointsInfo({
    this.pointSendersCount,
    this.totalDrivingPoints,
  });


  Map<String, dynamic> toJson() => (<String, dynamic>{
    'totalDrivingPoints': totalDrivingPoints,
    'pointSendersCount': pointSendersCount,
  });

  UserDrivingPointsInfo.fromJson(Map<dynamic, dynamic> json)
      : pointSendersCount = json['pointSendersCount'],
        totalDrivingPoints = json['totalDrivingPoints'];
}


class UserDMListInfo{
  final String content;
  final String date;
  final bool isActive;
  late final bool isRead;
  final bool? isUser;
  final String targetUseruid;
  final String type;
  final int unreadCount;
  final String useruid;
  String? senderPpUrl;
  String? senderNickname;
  String? sendingToUid;

  UserDMListInfo({
    required this.content,
    required this.date,
    required this.isActive,
    required this.isRead,
    this.isUser,
    required this.targetUseruid,
    required this.type,
    required this.unreadCount,
    required this.useruid,
    this.sendingToUid,
  });


  Map<String, dynamic> toJson() => (<String, dynamic>{
    'content': content,
    'date': date,
    'isActive': isActive,
    'isRead': isRead,
    'isUser': isUser,
    'targetUseruid': targetUseruid,
    'type': type,
    'unreadCount': unreadCount,
    'useruid': useruid,
  });

  UserDMListInfo.fromJson(Map<dynamic, dynamic> json)
      : content = json["content"] == null ? null : json['content'],
        date = json["date"] == null ? null : json['date'],
        isActive = json["isActive"] == null ? null : json['isActive'],
        isRead = json["isRead"] == null ? null : json['isRead'],
        isUser = json["isUser"] == null ? null : json['isUser'],
        targetUseruid = json["targetUseruid"] == null ? null : json['targetUseruid'],
        type = json["type"] == null ? null : json['type'],
        unreadCount = json["unreadCount"] == null ? null : json['unreadCount'],
        useruid = json["useruid"] == null ? null : json['useruid'],
        senderPpUrl = json["senderPpUrl"] == null ? null : json['senderPpUrl'],
        sendingToUid = json["sendingToUid"] == null ? null : json['sendingToUid'],
        senderNickname = json['senderNickname'];
}

class PremiumAccountDetails {
  final String title;
  final String oldPrice;
  final String newPrice;
  late final String discountPercent;


  PremiumAccountDetails({
  required this.title,
  required this.oldPrice,
  required this.newPrice,
  required this.discountPercent,
  });

}


enum DirectMessageKinds{
  text,
  photo,
}

extension DirectMessageKindsExtension on DirectMessageKinds {
  String get nameByKind {
    switch (this) {
      case DirectMessageKinds.text:
        return 'text';
      case DirectMessageKinds.photo:
        return 'photo';
      default:
        return "";
    }
  }

}


extension DirectMessageKindsStringExtension on String {
  DirectMessageKinds get kindByName {
    switch (this) {
      case "text":
        return DirectMessageKinds.text;
      case "photo":
        return DirectMessageKinds.photo;
      default:
        return DirectMessageKinds.text;
    }
  }
}

enum NotificationKinds{
  emoji,
  driverPoints,
  wallpost,
}

extension NotificationKindsExtension on NotificationKinds {
  String get nameByKind {
    switch (this) {
      case NotificationKinds.emoji:
        return 'emoji';
      case NotificationKinds.driverPoints:
        return 'driverPoints';
      default:
        return "";
    }
  }

}


enum EmojiKinds{
  clap,
  heart,
  onehundret,
  fire,
  swearing,
}

extension EmojiKindsExtension on EmojiKinds {
  String get name {
    switch (this) {
      case EmojiKinds.clap:
        return 'clap';
      case EmojiKinds.heart:
        return 'heart';
      case EmojiKinds.onehundret:
        return 'onehundret';
      case EmojiKinds.fire:
        return 'fire';
      case EmojiKinds.swearing:
        return 'swearing';
      default:
        return "";
    }
  }

  String get emojiItself {
    switch (this) {
      case EmojiKinds.clap:
        return '👏';
      case EmojiKinds.heart:
        return '❤️';
      case EmojiKinds.onehundret:
        return '💯';
      case EmojiKinds.fire:
        return '🔥';
      case EmojiKinds.swearing:
        return '🤬';
      default:
        return "";
    }
  }
}


extension EmojiKindsStringExtension on String {
  EmojiKinds get kindByEmojiString {
    switch (this) {
      case 'clap':
        return EmojiKinds.clap;
      case 'heart':
        return EmojiKinds.heart ;
      case  'onehundret':
        return EmojiKinds.onehundret;
      case  'fire':
        return EmojiKinds.fire;
      case  'swearing':
        return EmojiKinds.swearing;
      default:
        return EmojiKinds.clap;
    }
  }
}


