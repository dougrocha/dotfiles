pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
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
        } else if (node.isSink && node.audio) {
            // Capture-only streams have no playback volume, so they are kept apart.
            acc.streams.push(node);
        } else if (node.audio) {
            acc.captures.push(node);
        }
        return acc;
    }, {
        sources: [],
        sinks: [],
        streams: [],
        captures: []
    })

    readonly property var sinks: nodes.sinks
    readonly property var sources: nodes.sources
    readonly property var streams: nodes.streams
    readonly property var captures: nodes.captures

    // Something is listening. A capture stream fed by a sink is recording desktop
    // audio, not you, and the screen recorder already has its own indicator.
    readonly property bool micInUse: Pipewire.linkGroups.values.some(group => {
        const target = group.target;
        const source = group.source;
        if (!target || !source || !target.isStream || target.isSink || source.isSink)
            return false;
        return !getStreamBinary(target).includes("gpu-screen-recorder");
    })

    // Default sink and source
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    // Sink (output/speakers/headphones) properties
    readonly property bool muted: sink && sink.audio ? sink.audio.muted : false
    readonly property real volume: sink && sink.audio ? (sink.audio.volume ?? 0) : 0

    // Source (input/microphone) properties
    readonly property bool sourceMuted: source && source.audio ? source.audio.muted : false
    readonly property real sourceVolume: source && source.audio ? (source.audio.volume ?? 0) : 0

    // Master stops at 100%; only per-app streams may boost past it.
    function setVolume(newVolume) {
        if (sink?.ready && sink?.audio) {
            sink.audio.muted = false;
            sink.audio.volume = Math.max(0, Math.min(1, newVolume));
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
            source.audio.volume = Math.max(0, Math.min(1, newVolume));
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

    function shortLabel(node) {
        if (!node)
            return "Unknown";
        var desc = (node.description || node.nickname || node.name || "Unknown").trim();

        var paren = desc.match(/\(([^)]+)\)\s*$/);
        if (paren && !/gen\.?$/i.test(paren[1])) {
            var tag = paren[1].toUpperCase();
            if (tag === "IEC958")
                return "Digital (S/PDIF)";
            // Nvidia reports DisplayPort under the HDMI profile; the nickname is more useful.
            if (tag === "HDMI" && node.nickname)
                return node.nickname;
            return tag;
        }

        desc = desc.replace(/\s*\(\d+(?:st|nd|rd|th)\s+gen\.?\)/i, "");

        var portMatch = desc.match(/^(.*?)\s+Input\s+\d+\s+(.+)$/i);
        if (portMatch)
            return portMatch[1].trim() + " (" + portMatch[2].trim() + ")";

        var outMatch = desc.match(/^(.*?)\s+(Headphones\s*\/\s*Line[\w\s-]*|Line Out|Speakers)$/i);
        if (outMatch)
            return outMatch[1].trim();

        return desc;
    }

    // A replaced on-disk binary shows as " (deleted)", which breaks MPRIS name matching.
    function getStreamBinary(stream) {
        if (!stream || !stream.properties)
            return "";
        const binary = stream.properties["application.process.binary"] ?? "";
        return binary.replace(/\s*\(deleted\)$/, "");
    }

    function getStreamPid(stream) {
        return stream?.properties?.["application.process.id"] ?? "";
    }

    function isSharedRuntime(binary) {
        return /^electron\d*$/.test(binary);
    }

    property var appNames: ({})

    readonly property var unresolvedPids: streams.reduce((acc, stream) => {
        const pid = getStreamPid(stream);
        if (pid !== "" && appNames[pid] === undefined && isSharedRuntime(getStreamBinary(stream)) && acc.indexOf(pid) === -1)
            acc.push(pid);
        return acc;
    }, [])

    // App named by its --user-data-dir; a miss caches "" so it isn't re-read.
    function rememberAppName(pid, cmdline) {
        const match = cmdline.match(/--user-data-dir=([^\0]+)/);
        appNames[pid] = match ? match[1].replace(/\/+$/, "").split("/").pop() : "";
        appNamesChanged();
    }

    Instantiator {
        model: root.unresolvedPids

        delegate: FileView {
            required property var modelData

            path: "/proc/" + modelData + "/cmdline"
            printErrors: false
            onLoaded: root.rememberAppName(modelData, text())
            onLoadFailed: root.rememberAppName(modelData, "")
        }
    }

    function getStreamAppId(stream) {
        const binary = getStreamBinary(stream);
        if (isSharedRuntime(binary))
            return appNames[getStreamPid(stream)] ?? "";
        return binary;
    }

    // A desktop entry can't change under a running stream, so resolve each app id once.
    // Deliberately not signalled: this is a memo, not state anything should re-render on.
    property var appLookups: ({})

    function lookupFor(appId) {
        if (appLookups[appId] === undefined) {
            const entry = DesktopEntries.byId(appId.toLowerCase());
            appLookups[appId] = {
                name: entry ? entry.name : appId.charAt(0).toUpperCase() + appId.slice(1),
                icon: entry ? Quickshell.iconPath(entry.icon, true) : ""
            };
        }
        return appLookups[appId];
    }

    // Every Electron app reports "Chromium"; the desktop entry yields the real name.
    function getStreamName(stream) {
        if (!stream)
            return "Unknown";

        const appId = getStreamAppId(stream);
        if (appId !== "")
            return lookupFor(appId).name;

        return stream.applicationName || stream.description || stream.name || "Unknown Application";
    }

    function getStreamIcon(stream) {
        const appId = getStreamAppId(stream);
        if (appId === "")
            return "";
        return lookupFor(appId).icon;
    }

    // Chromium opens a node per sound under one process; group them so the app isn't repeated.
    readonly property var streamGroups: {
        const groups = [];
        const seen = {};
        for (const stream of streams) {
            const key = getStreamPid(stream) || ("node" + stream.id);
            if (seen[key] === undefined) {
                seen[key] = groups.length;
                groups.push({
                    key: key,
                    name: getStreamName(stream),
                    icon: getStreamIcon(stream),
                    streams: [stream]
                });
            } else {
                groups[seen[key]].streams.push(stream);
            }
        }
        return groups;
    }

    function getGroupVolume(group) {
        return group.streams.reduce((loudest, stream) => Math.max(loudest, getStreamVolume(stream)), 0);
    }

    function getGroupMuted(group) {
        return group.streams.length > 0 && group.streams.every(stream => getStreamMuted(stream));
    }

    function setGroupVolume(group, newVolume) {
        for (const stream of group.streams)
            setStreamVolume(stream, newVolume);
    }

    function setGroupMuted(group, muted) {
        for (const stream of group.streams)
            setStreamMuted(stream, muted);
    }

    PwObjectTracker {
        objects: [...root.sinks, ...root.sources, ...root.streams, ...root.captures]
    }
}
