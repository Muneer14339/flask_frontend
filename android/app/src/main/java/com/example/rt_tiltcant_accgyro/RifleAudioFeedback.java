package com.example.rt_tiltcant_accgyro;

import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;

public class RifleAudioFeedback {
    private final int SAMPLE_RATE = 44100;
    private final int TONE_DURATION_MS = 130;

    private int pulseInterval = 500;

    private String activeCantDirection = null;
    private String activeTiltDirection = null;

    private final Map<String, AudioTrack> cantTracks = new HashMap<>();
    private final Map<String, AudioTrack> tiltTracks = new HashMap<>();

    private final String TAG = "RifleAudioFeedback";

    public void setPulseInterval(int intervalMs) {
        this.pulseInterval = intervalMs;

        // Restart both if active → for real-time interval change:
//        if (activeCantDirection != null) startCant(activeCantDirection);
//        if (activeTiltDirection != null) startTilt(activeTiltDirection);
    }

    // ---- Cant ----
    public void startCant(String direction, int intervalMs) {
        stopCant();
        activeCantDirection = direction;
        pulseInterval = intervalMs;

        double freq = direction.equals("left") ? 900.0 : 1100.0;
        float pan = direction.equals("left") ? -1.0f : 1.0f;

        AudioTrack track = buildLoopingTrack(freq, pan, false);
        cantTracks.put(direction, track);
        track.play();
    }

    public void stopCant() {
        if (activeCantDirection != null && cantTracks.containsKey(activeCantDirection)) {
            AudioTrack track = cantTracks.remove(activeCantDirection);
            try {
                track.stop();
                track.release();
            } catch (Exception e) {
                Log.e(TAG, "Error stopping cant track: " + e.getMessage());
            }
        }
        activeCantDirection = null;
    }

    // ---- Tilt ----
    public void startTilt(String direction, int intervalMs) {
        stopTilt();
        activeTiltDirection = direction;
        pulseInterval = intervalMs;

        double freq = direction.equals("up") ? 1300.0 : 650.0;
        float pan = 0.0f;

        AudioTrack track = buildLoopingTrack(freq, pan, true);
        tiltTracks.put(direction, track);
        track.play();
    }

    public void stopTilt() {
        if (activeTiltDirection != null && tiltTracks.containsKey(activeTiltDirection)) {
            AudioTrack track = tiltTracks.remove(activeTiltDirection);
            try {
                track.stop();
                track.release();
            } catch (Exception e) {
                Log.e(TAG, "Error stopping tilt track: " + e.getMessage());
            }
        }
        activeTiltDirection = null;
    }

    // ---- Build Looping Tone with Silence ----
    private AudioTrack buildLoopingTrack(double freqHz, float pan, boolean isTriangle) {
        int toneSamples = (int) (SAMPLE_RATE * (TONE_DURATION_MS / 1000.0));
        int silenceMs = Math.max(pulseInterval - TONE_DURATION_MS, 0);
        int silenceSamples = (int) (SAMPLE_RATE * (silenceMs / 1000.0));
        int totalSamples = toneSamples + silenceSamples;

        short[] samples = new short[totalSamples * 2]; // Stereo interleaved

        double twoPiF = 2 * Math.PI * freqHz;

        float leftGain = pan <= 0 ? 1.0f : 1.0f - pan;   // Left channel strength
        float rightGain = pan >= 0 ? 1.0f : 1.0f + pan;  // Right channel strength

        // Envelope: 0.01s attack, 0.13s decay (total matches TONE_DURATION_MS)
        double attackDuration = 0.01;
        double decayDuration = 0.13;
        int attackSamples = (int) (SAMPLE_RATE * attackDuration);
        int decaySamples = (int) (SAMPLE_RATE * decayDuration);

        for (int i = 0; i < toneSamples; i++) {
            double t = (double) i / SAMPLE_RATE;

            double wave;
            if (isTriangle) {
                wave = 2 * Math.abs(2 * ((t * freqHz) - Math.floor((t * freqHz) + 0.5))) - 1; // Triangle wave
            } else {
                wave = Math.sin(twoPiF * i / SAMPLE_RATE);
            }

            double envelope;
            if (i < attackSamples) {
                envelope = (double) i / attackSamples;
            } else if (i > toneSamples - decaySamples) {
                envelope = (double) (toneSamples - i) / decaySamples;
            } else {
                envelope = 1.0;
            }

            short sample = (short) (wave * Short.MAX_VALUE * 0.18 * envelope);
            samples[i * 2] = (short) (sample * leftGain);
            samples[i * 2 + 1] = (short) (sample * rightGain);
        }

        // Remaining samples (silenceSamples * 2 entries) are left at 0 → pure silence

        AudioTrack audioTrack = new AudioTrack(
                AudioManager.STREAM_MUSIC,
                SAMPLE_RATE,
                AudioFormat.CHANNEL_OUT_STEREO,
                AudioFormat.ENCODING_PCM_16BIT,
                samples.length * 2,
                AudioTrack.MODE_STATIC
        );
        audioTrack.write(samples, 0, samples.length);
        audioTrack.setLoopPoints(0, totalSamples, -1);

        return audioTrack;
    }

    public void stopAll() {
        stopCant();
        stopTilt();
    }
}
