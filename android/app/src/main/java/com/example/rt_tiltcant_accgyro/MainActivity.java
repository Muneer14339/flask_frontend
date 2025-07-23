package com.example.rt_tiltcant_accgyro;


import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.example.rifle_audio/audio";
    private RifleAudioFeedback rifleAudio;

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        rifleAudio = new RifleAudioFeedback();

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    switch (call.method) {
                        case "startCant":
                            String cantDir = call.argument("direction");
                            Integer cantInterval = call.argument("interval");
                            rifleAudio.startCant(cantDir, cantInterval != null ? cantInterval : 500);
                            result.success(null);
                            break;
                        case "stopCant":
                            rifleAudio.stopCant();
                            result.success(null);
                            break;
                        case "startTilt":
                            String tiltDir = call.argument("direction");
                            Integer tiltInterval = call.argument("interval");
                            rifleAudio.startTilt(tiltDir, tiltInterval != null ? tiltInterval : 500);
                            result.success(null);
                            break;
                        case "stopTilt":
                            rifleAudio.stopTilt();
                            result.success(null);
                            break;
                        case "setPulseInterval":
                            int interval = call.argument("interval");
                            rifleAudio.setPulseInterval(interval);
                            result.success(null);
                            break;
                        case "stopAll":
                            rifleAudio.stopAll();
                            result.success(null);
                            break;
                        default:
                            result.notImplemented();
                    }
                });
    }
}