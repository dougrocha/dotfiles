import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
pragma Singleton

Singleton {
    id: root

    // Sink (output/speakers/headphones) properties
    property real sinkVolume: 0
    property bool sinkMuted: false
    // Source (input/microphone) properties
    property real sourceVolume: 0
    property bool sourceMuted: false

    function updateSink() {
        var sink = Pipewire.defaultAudioSink;
        if (!sink || !sink.audio) {
            sinkVolume = 0;
            sinkMuted = false;
            return ;
        }
        var vol = sink.audio.volume;
        if (vol !== undefined && vol !== null && !isNaN(vol))
            sinkVolume = vol * 100;
        else
            sinkVolume = 0;
        sinkMuted = sink.audio.muted || false;
    }

    function updateSource() {
        var source = Pipewire.defaultAudioSource;
        if (!source || !source.audio) {
            sourceVolume = 0;
            sourceMuted = false;
            return ;
        }
        var vol = source.audio.volume;
        if (vol !== undefined && vol !== null && !isNaN(vol))
            sourceVolume = vol * 100;
        else
            sourceVolume = 0;
        sourceMuted = source.audio.muted || false;
    }

    // Set sink (speaker) volume (0-100)
    function setSinkVolume(volume) {
        var sink = Pipewire.defaultAudioSink;
        if (!sink || !sink.audio)
            return ;

        sink.audio.volume = volume / 100;
    }

    // Toggle sink (speaker) mute
    function toggleSinkMute() {
        var sink = Pipewire.defaultAudioSink;
        if (!sink || !sink.audio)
            return ;

        sink.audio.muted = !sink.audio.muted;
    }

    // Set source (mic) volume (0-100)
    function setSourceVolume(volume) {
        var source = Pipewire.defaultAudioSource;
        if (!source || !source.audio)
            return ;

        source.audio.volume = volume / 100;
    }

    // Toggle source (mic) mute
    function toggleSourceMute() {
        var source = Pipewire.defaultAudioSource;
        if (!source || !source.audio)
            return ;

        source.audio.muted = !source.audio.muted;
    }

    Component.onCompleted: {
        updateSink();
        updateSource();
    }

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    // Watch for default sink device changes
    Connections {
        function onDefaultAudioSinkChanged() {
            root.updateSink();
        }

        target: Pipewire
    }

    // Watch for default source device changes
    Connections {
        function onDefaultAudioSourceChanged() {
            root.updateSource();
        }

        target: Pipewire
    }

    // Watch for sink (output) changes
    Connections {
        function onVolumeChanged() {
            root.updateSink();
        }

        function onMutedChanged() {
            root.updateSink();
        }

        target: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.audio : null
    }

    // Watch for source (input) changes
    Connections {
        function onVolumeChanged() {
            root.updateSource();
        }

        function onMutedChanged() {
            root.updateSource();
        }

        target: Pipewire.defaultAudioSource ? Pipewire.defaultAudioSource.audio : null
    }

}
