import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:task1/shared/MainCubit/cubit.dart';
import 'package:task1/shared/MainCubit/states.dart';

class PlayVideoFromYoutube extends StatefulWidget {
  final String videoUrl;
  const PlayVideoFromYoutube({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<PlayVideoFromYoutube> createState() => _PlayVideoFromYoutubeState();
}

class _PlayVideoFromYoutubeState extends State<PlayVideoFromYoutube> {
  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController;
  late AudioPlayer player ;

  @override
  void initState() {
    super.initState();
    var cubit = AppCubit.get(context);

    cubit.fetchVideoQualities(widget.videoUrl).then((value) {
      _initializePlayer();
    });
  }

  Future<void> _initializePlayer() async {
    var cubit = AppCubit.get(context);

    final qualityUrl = cubit.selectedVideoQuality['url']!;
    if (qualityUrl.isNotEmpty) {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(qualityUrl),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
      player = AudioPlayer();
      await player.setUrl(cubit.selectedAudioQuality);

      try {
        await _videoPlayerController.initialize();
        _videoPlayerController.addListener(() {
          if (_videoPlayerController.value.isInitialized) {
            if (_videoPlayerController.value.isPlaying) {
              _play();
            } else if (!_videoPlayerController.value.isPlaying) {
              _pause();
            }
            final videoPosition = _videoPlayerController.value.position;
            if (videoPosition > player.position + const Duration(seconds: 1) || player.position > videoPosition + const Duration(seconds: 1)) {
              player.seek(videoPosition);
            }
              if(_videoPlayerController.value.volume == 0.0){
                player.setVolume(0);
              }
            if(_videoPlayerController.value.volume != 0.0){
                player.setVolume(1);
              }

            if(_videoPlayerController.value.volume != 0.0){
              player.setVolume(1);
            }

            if (_videoPlayerController.value.playbackSpeed != player.speed) {
              player.setSpeed(_videoPlayerController.value.playbackSpeed);
            }
          }
        });

        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          aspectRatio: _videoPlayerController.value.aspectRatio,
          autoPlay: true,
          looping: false,
          showControlsOnInitialize: false,
          systemOverlaysOnEnterFullScreen: [],
          systemOverlaysAfterFullScreen: SystemUiOverlay.values,
          deviceOrientationsOnEnterFullScreen: [
            DeviceOrientation.landscapeRight,
            DeviceOrientation.landscapeLeft,
          ],
        );

        cubit.changInitializePlayerData(true);
      } catch (e) {
        //print('Error initializing video player: $e');
      }
    }
  }

  void _play() async {
    await player.play();
  }

  void _pause() async {
    await player.pause();
  }

  void _syncSeek() async {
    final currentPosition = _videoPlayerController.value.position;
      await player.seek(currentPosition);

  }

  void _showQualityDropdown() {
    var cubit = AppCubit.get(context);

    showDialog(
      context: context,
      builder: (context) {

        final Set<String> uniqueQualitySet = {};


        final uniqueQualities = cubit.videoQualities.where((quality) {
          return uniqueQualitySet.add(quality['quality']!);
        }).toList();

        return AlertDialog(
          title: const Text('Select Video Quality'),
          content: DropdownButton<String>(
            value: cubit.selectedVideoQuality['quality'],
            onChanged: (String? newQuality) {
              if (newQuality != null) {
                player.dispose();
                cubit.changInitializePlayerData(false);
                cubit.changeVideoQuality(newQuality);
                _initializePlayer();
                Navigator.of(context).pop();
              }
            },
            items: uniqueQualities
                .map((quality) => DropdownMenuItem(
              value: quality['quality'],
              child: Text(quality['quality']!),
            ))
                .toList(),
          ),
        );
      },
    );

  }

  @override
  void dispose() {
    _chewieController.dispose();
    _videoPlayerController.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var cubit = AppCubit.get(context);
    return BlocConsumer<AppCubit, AppState>(
      listener: (context, state) {
        if (state is FetchVideoQualitiesErrorState) {
          Fluttertoast.showToast(
            msg: state.error,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: cubit.fetchQuality && cubit.initializePlayerData
              ? Stack(
            children: [
              Chewie(
                controller: _chewieController,
              ),
              Positioned(
                top: 30.0,
                left: 10.0,
                child: Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: () {
                      _showQualityDropdown();
                    },
                    icon: const Icon(Icons.settings,
                        color: Colors.white, size: 30.0),
                  ),
                ),
              ),
            ],
          )
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
