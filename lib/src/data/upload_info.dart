import 'exception.dart';

class TwitterMediaUploadInfo {
  int mediaId, size, expiresAfterSecs;
  TwitterMediaUploadInfoImage image;
  TwitterMediaUploadInfoProcessingInfo processingInfo;
  TwitterMediaUploadInfoVideo video;

  String get mediaIdString => mediaId?.toString();

  TwitterMediaUploadInfo(
      {this.mediaId,
      this.size,
      this.expiresAfterSecs,
      this.image,
      this.processingInfo,
      this.video});

  factory TwitterMediaUploadInfo.fromJson(Map json) {
    return new TwitterMediaUploadInfo(
        mediaId: json['media_id'],
        size: json['size'],
        expiresAfterSecs: json['expires_after_secs'],
        image: json['image'] is Map
            ? new TwitterMediaUploadInfoImage.fromJson(json['image'])
            : null,
        processingInfo: json['processing_info'] is Map
            ? new TwitterMediaUploadInfoProcessingInfo.fromJson(
                json['processing_info'])
            : null,
        video: json['video'] is Map
            ? new TwitterMediaUploadInfoVideo.fromJson(json['video'])
            : null);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {
      'media_id': mediaId,
      'media_id_string': mediaIdString,
      'size': size,
      'expires_after_secs': expiresAfterSecs
    };

    if (image != null) result['image'] = image.toJson();
    if (image != null) result['processing_info'] = processingInfo.toJson();
    if (image != null) result['video'] = video.toJson();

    return result;
  }
}

class TwitterMediaUploadInfoImage {
  int w, h;
  String imageType;

  TwitterMediaUploadInfoImage({this.w, this.h, this.imageType});

  factory TwitterMediaUploadInfoImage.fromJson(Map json) =>
      new TwitterMediaUploadInfoImage(
          w: json['w'], h: json['h'], imageType: json['image_type']);

  Map<String, dynamic> toJson() {
    return {'w': w, 'h': h, 'image_type': imageType};
  }
}

class TwitterMediaUploadInfoVideo {
  String videoType;

  TwitterMediaUploadInfoVideo({this.videoType});

  factory TwitterMediaUploadInfoVideo.fromJson(Map json) =>
      new TwitterMediaUploadInfoVideo(videoType: json['video_type']);

  Map<String, dynamic> toJson() {
    return {'video_type': videoType};
  }
}

class TwitterMediaUploadInfoProcessingInfo {
  TwitterMediaUploadInfoProcessingInfoState state;
  int checkAfterSecs, progressPercent;
  TwitterException error;

  TwitterMediaUploadInfoProcessingInfo(
      {this.state, this.checkAfterSecs, this.progressPercent, this.error});

  factory TwitterMediaUploadInfoProcessingInfo.fromJson(Map json) {
    TwitterMediaUploadInfoProcessingInfoState state =
        TwitterMediaUploadInfoProcessingInfoState.UNKNOWN;

    switch (json['state']) {
      case 'pending':
        state = TwitterMediaUploadInfoProcessingInfoState.PENDING;
        break;
      case 'failed':
        state = TwitterMediaUploadInfoProcessingInfoState.PENDING;
        break;
      case 'succeeded':
        state = TwitterMediaUploadInfoProcessingInfoState.PENDING;
        break;
    }

    return new TwitterMediaUploadInfoProcessingInfo(
        state: state,
        checkAfterSecs: json['check_after_secs'],
        progressPercent: json['progress_percent'],
        error: json['error'] is Map
            ? new TwitterException.fromJson(json['error'])
            : null);
  }

  Map<String, dynamic> toJson() {
    String stateString;

    var result = {
      'state': stateString,
      'check_after_secs': checkAfterSecs,
      'progress_percent': progressPercent
    };

    if (error != null) result['error'] = error.toJson();

    return result;
  }
}

enum TwitterMediaUploadInfoProcessingInfoState {
  FAILED,
  PENDING,
  SUCCEEDED,
  UNKNOWN
}

class TwitterMediaUploadInfoException implements Exception {
  final String message;
  final TwitterException error;

  TwitterMediaUploadInfoException(this.message, this.error);

  @override
  toString() => message;
}
