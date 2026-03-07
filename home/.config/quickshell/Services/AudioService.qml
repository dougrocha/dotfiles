pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets

Singleton {
    id: root

    readonly property var nodes: Pipewire.nodes.values.reduce((acc, node) => {
        if (!node.isStream) {
            if (node.isSink)
                acc.sinks.push(node);
            else if (node.audio)
                acc.sources.push(node);
        } else if (node.isStream && node.audio) {
            acc.streams.push(node);
        }
        return acc;
    }, {
        sources: [],
        sinks: [],
        streams: []
    })

    readonly property var sinks: nodes.sinks
    readonly property var sources: nodes.sources
    readonly property var streams: nodes.streams

    // Default sink and source
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    // Sink (output/speakers/headphones) properties
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false
    readonly property real volume: sink && sink.audio ? (sink.audio.volume ?? 0) : 0

    // Source (input/microphone) properties
    readonly property bool sourceMuted: source && source.audio ? source.audio.muted : false
    readonly property real sourceVolume: source && source.audio ? (source.audio.volume ?? 0) : 0

    function setVolume(newVolume) {
        if (sink?.ready && sink?.audio) {
            sink.audio.muted = false;
            sink.audio.volume = Math.max(0, Math.min(1.5, newVolume));
        }
    }

    function incrementVolume(amount) {
        setVolume(volume + (amount || 0.05));
    }

    function decrementVolume(amount) {
        setVolume(volume - (amount || 0.05));
    }

    function toggleMute() {
        if (sink?.ready && sink?.audio) {
            sink.audio.muted = !sink.audio.muted;
        }
    }

    function setSourceVolumeValue(newVolume) {
        if (source?.ready && source?.audio) {
            source.audio.muted = false;
            source.audio.volume = Math.max(0, Math.min(1.5, newVolume));
        }
    }

    function incrementSourceVolume(amount) {
        setSourceVolumeValue(sourceVolume + (amount || 0.05));
    }

    function decrementSourceVolume(amount) {
        setSourceVolumeValue(sourceVolume - (amount || 0.05));
    }

    function toggleSourceMute() {
        if (source?.ready && source?.audio) {
            source.audio.muted = !source.audio.muted;
        }
    }

    function setAudioSink(newSink) {
        Pipewire.preferredDefaultAudioSink = newSink;
    }

    function setAudioSource(newSource) {
        Pipewire.preferredDefaultAudioSource = newSource;
    }

    function setStreamVolume(stream, newVolume) {
        if (stream?.ready && stream?.audio) {
            stream.audio.muted = false;
            stream.audio.volume = Math.max(0, Math.min(1.5, newVolume));
        }
    }

    function setStreamMuted(stream, muted) {
        if (stream?.ready && stream?.audio) {
            stream.audio.muted = muted;
        }
    }

    function getStreamVolume(stream) {
        return stream?.audio?.volume ?? 0;
    }

    function getStreamMuted(stream) {
        return !!stream?.audio?.muted;
    }

    function getStreamName(stream) {
        if (!stream)
            return "Unknown";
        return stream.applicationName || stream.description || stream.name || "Unknown Application";
    }

    PwObjectTracker {
        objects: [...root.sinks, ...root.sources, ...root.streams]
    }
}
