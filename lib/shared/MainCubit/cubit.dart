

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'package:task1/shared/MainCubit/states.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';



class AppCubit extends Cubit<AppState> {
  AppCubit() : super(InitialAppState());

  static AppCubit get(context) {
    return BlocProvider.of(context);
  }

  bool changeQuality=false;
  bool showThumbnail=true;
  var yt = YoutubeExplode();
  bool fetchQuality = false;
  bool initializePlayerData=false;
  List<Map<String, String>> videoQualities = [];
  String selectedAudioQuality = '';
  Map<String, String> selectedVideoQuality = {'': ''};
  String videoThumbnail='' ;

  Future<void> getVideoThumbnail(String videoUrl) async {
    var videoId = VideoId.parseVideoId(videoUrl);
    videoThumbnail= 'https://img.youtube.com/vi/$videoId/0.jpg';
    emit(GetVideoThumbnailSuccessState());
  }
  void changeShowThumbnail(val){
    showThumbnail=val;
    emit(ChangeShowThumbnailSuccessState());
  }
  Future<void> fetchVideoQualities(String videoUrl) async {
    emit(FetchVideoQualitiesLoadingState());


    try {
      var videoId = VideoId.parseVideoId(videoUrl);
      var manifest = await yt.videos.streams.getManifest(videoId);

      // Clear the previous list
      videoQualities.clear();




      for (var video in manifest.videoOnly) {
        videoQualities.add({
          'url': video.url.toString(),
          'quality': video.qualityLabel,
        });
      }



      // Set default selected quality
      selectedVideoQuality = videoQualities.firstWhere(
            (quality) => quality['quality'] == '360p',
        orElse: () => videoQualities.first,
      );
      selectedAudioQuality = manifest.audioOnly.first.url.toString();

      fetchQuality=true;
      emit(FetchVideoQualitiesSuccessState());
    } catch (e) {
      print('Error: $e');
      emit(FetchVideoQualitiesErrorState(e.toString()));
    } finally {
      yt.close();
    }
  }



  void changeVideoQuality(String qualityLabel) {
    final streamInfo = videoQualities.firstWhere(
          (stream) => stream['quality'] == qualityLabel,
      orElse: () => videoQualities.first,
    );
    selectedVideoQuality =
    {'url': streamInfo['url']!, 'quality': streamInfo['quality']!};
    changeQuality=true;
    emit(ChangeVideoQualitySuccessState());
  }

  void changInitializePlayerData(val){
    initializePlayerData=val;
    emit(ChangInitializePlayerDataSuccessState());
  }







  MqttServerClient? client;

  Future<void> connectToMqtt() async {
    client = MqttServerClient('eceb90434a904f10afd19ebcba38fac9.s1.eu.hivemq.cloud', '');
    client!.port = 8883; // Use TLS port
    client!.secure = true; // Enable TLS

    // Create the connection message
    final connectionMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client') // Replace with a unique client ID
        .withWillTopic('willtopic') // Optional: Set a will topic
        .withWillMessage('will message') // Optional: Set a will message
        .startClean(); // Connect clean session
    client!.connectionMessage = connectionMessage;

    // Set username and password if the broker requires authentication
    client!.setProtocolV311(); // Ensure you use the correct protocol version
    client!.connect('abdelaziz', '1234567Aa');

    try {
      await client!.connect();

      if (client!.connectionStatus!.state == MqttConnectionState.connected) {
        print('Connected to MQTT broker');

        // Prepare and publish the message
        const topic = 'test';
        const message = 'up';
        final builder = MqttClientPayloadBuilder();
        builder.addString(message);

        client!.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
        print('Message sent to topic $topic: $message');
      } else {
        print('Connection failed with status: ${client!.connectionStatus}');
      }
    } catch (e) {
      print('Connection or message sending failed: $e');
    }
  }





}


