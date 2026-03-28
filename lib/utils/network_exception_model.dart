class NetworkExceptionModel {
  final String? message;
   final int? statusCode;
  NetworkExceptionModel({this.message,this.statusCode});

  factory NetworkExceptionModel.fromJson(Map<String,dynamic> json)=>
    NetworkExceptionModel(message:json["message"],
    statusCode:json["statusCode"]);
  }
