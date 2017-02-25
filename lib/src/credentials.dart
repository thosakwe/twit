class TwitterCredentials {
  String consumerKey, consumerSecret, accessToken, accessTokenSecret;

  TwitterCredentials(
      {this.consumerKey,
      this.consumerSecret,
      this.accessToken,
      this.accessTokenSecret});

  factory TwitterCredentials.fromJson(Map json) => new TwitterCredentials(
        consumerKey: json['consumer_key'],
        consumerSecret: json['consumer_secret'],
        accessToken: json['access_token'],
        accessTokenSecret: json['access_secret'],
      );

  Map toJson() {
    return {
      'consumer_key': consumerKey,
      'consumer_secret': consumerSecret,
      'access_token': accessToken,
      'access_secret': accessTokenSecret
    };
  }
}
