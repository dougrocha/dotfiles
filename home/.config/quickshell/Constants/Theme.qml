pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string primaryMonitor: "DP-1"

    readonly property var primaryScreen: Quickshell.screens.find(s => s.name === primaryMonitor) ?? Quickshell.screens[0] ?? null

    readonly property var primaryScreens: primaryScreen ? [primaryScreen] : []

    readonly property int topBarHeight: 36

    property var paletteOverrides: ({})

    function loadPalette(source) {
        try {
            const parsed = JSON.parse(source);
            if (!parsed || typeof parsed !== "object" || Array.isArray(parsed))
                throw new Error("expected an object");
            const valid = {};
            for (const key of Object.keys(parsed)) {
                if (typeof parsed[key] !== "string" || !/^#[0-9a-fA-F]{6}$/.test(parsed[key]))
                    throw new Error("expected #RRGGBB for " + key);
                valid[key] = parsed[key];
            }
            paletteOverrides = valid;
        } catch (error) {
            console.warn("Ignoring invalid palette:", error.message);
        }
    }

    function paletteColor(name, fallback) {
        return paletteOverrides[name] ?? fallback;
    }

    FileView {
        id: paletteFile
        path: Quickshell.shellDir + "/palette.json"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.loadPalette(text())
        onLoadFailed: error => console.warn("Unable to load palette; retaining current colors:", error)
    }

    readonly property QtObject palette: QtObject {
        readonly property color bg: root.paletteColor("bg", "#16181a")
        readonly property color surface: root.paletteColor("surface", "#1e2124")
        readonly property color raised: root.paletteColor("raised", "#282c30")
        readonly property color overlay: root.paletteColor("overlay", "#31363b")
        readonly property color text: root.paletteColor("text", "#e6e8ea")
        readonly property color subtext: root.paletteColor("subtext", "#9aa0a6")
        readonly property color muted: root.paletteColor("muted", "#6b7075")
        readonly property color accent: root.paletteColor("accent", "#9bd4a2")
        readonly property color accentText: root.paletteColor("accentText", "#0c1f12")
        readonly property color danger: root.paletteColor("danger", "#ee9089")
    }

    function withAlpha(c, a) {
        return Qt.rgba(c.r, c.g, c.b, a);
    }

    function _lin(ch) {
        return ch <= 0.04045 ? ch / 12.92 : Math.pow((ch + 0.055) / 1.055, 2.4);
    }
    function _lum(c) {
        return 0.2126 * _lin(c.r) + 0.7152 * _lin(c.g) + 0.0722 * _lin(c.b);
    }
    function _contrast(a, b) {
        const hi = Math.max(_lum(a), _lum(b));
        const lo = Math.min(_lum(a), _lum(b));
        return (hi + 0.05) / (lo + 0.05);
    }
    readonly property bool lightMode: _lum(root.palette.bg) > _lum(root.palette.text)
    function foregroundFor(bg) {
        return _contrast(bg, Qt.color("#0c1512")) >= _contrast(bg, Qt.color("#ffffff")) ? Qt.color("#0c1512") : Qt.color("#ffffff");
    }

    readonly property QtObject colors: QtObject {
        readonly property color bg: root.palette.bg
        readonly property color surface: root.palette.surface
        readonly property color raised: root.palette.raised
        readonly property color overlay: root.palette.overlay
    }

    readonly property QtObject text: QtObject {
        readonly property color primary: root.palette.text
        readonly property color secondary: root.palette.subtext
        readonly property color tertiary: root.palette.muted
    }

    readonly property color accent: root.palette.accent
    readonly property color accentText: root.palette.accentText
    readonly property color danger: root.palette.danger
    readonly property color dangerText: root.foregroundFor(root.danger)
    readonly property color caution: "#e7b15e"
    readonly property color shadow: "#000000"

    readonly property QtObject fill: QtObject {
        readonly property color hover: root.withAlpha(root.text.primary, 0.06)
        readonly property color press: root.withAlpha(root.text.primary, 0.10)
        readonly property color selected: root.withAlpha(root.accent, 0.16)
        readonly property color selectedSolid: root.accent
    }

    readonly property QtObject stroke: QtObject {
        readonly property color hairline: root.withAlpha(root.text.primary, 0.08)
        readonly property color strong: root.withAlpha(root.text.primary, 0.16)
        readonly property color accent: root.accent
    }

    readonly property QtObject radius: QtObject {
        readonly property int xxs: 2
        readonly property int xs: 4
        readonly property int sm: 6
        readonly property int md: 8
        readonly property int lg: 12
        readonly property int xl: 16
        readonly property int xxl: 24
    }

    readonly property QtObject space: QtObject {
        readonly property int xxs: 2
        readonly property int xs: 4
        readonly property int sm: 6
        readonly property int md: 8
        readonly property int lg: 12
        readonly property int xl: 16
        readonly property int xxl: 24
    }

    readonly property QtObject icon: QtObject {
        readonly property int xxs: 12
        readonly property int xs: 14
        readonly property int sm: 16
        readonly property int md: 18
        readonly property int lg: 20
        readonly property int xl: 28
        readonly property int xxl: 40
    }

    readonly property QtObject motion: QtObject {
        readonly property int instant: 90
        readonly property int fast: 140
        readonly property int normal: 200
        readonly property int slow: 320
        readonly property int easeStandard: Easing.OutCubic
        readonly property int easeExit: Easing.InCubic
        readonly property int easeSmooth: Easing.InOutQuad
        readonly property int easeSoft: Easing.OutQuad
    }

    readonly property QtObject type: QtObject {
        readonly property QtObject display: QtObject {
            readonly property int size: 20
            readonly property int weight: Font.Medium
            readonly property real tracking: 0
        }
        readonly property QtObject title: QtObject {
            readonly property int size: 14
            readonly property int weight: Font.Medium
            readonly property real tracking: 0
        }
        readonly property QtObject body: QtObject {
            readonly property int size: 13
            readonly property int weight: Font.Normal
            readonly property real tracking: 0
        }
        readonly property QtObject label: QtObject {
            readonly property int size: 11
            readonly property int weight: Font.Medium
            readonly property real tracking: 0.3
        }
        readonly property QtObject caption: QtObject {
            readonly property int size: 11
            readonly property int weight: Font.Normal
            readonly property real tracking: 0
        }
        readonly property QtObject mono: QtObject {
            readonly property int size: 13
            readonly property int weight: Font.Normal
            readonly property real tracking: 0.5
        }
    }

    FontLoader {
        id: iconFont
        source: Quickshell.shellDir + "/assets/Phosphor.ttf"
    }

    FontLoader {
        id: filledIconFont
        source: Quickshell.shellDir + "/assets/Phosphor-Fill.ttf"
    }

    readonly property QtObject font: QtObject {
        readonly property string ui: "JetBrainsMono Nerd Font Propo"
        readonly property string mono: "JetBrainsMono Nerd Font"
        readonly property string icon: iconFont.name
        readonly property string iconFill: filledIconFont.name
    }
}
