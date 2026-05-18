pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    readonly property string screenShare: String.fromCodePoint(0xE0E2)
    readonly property string screenRecord: String.fromCodePoint(0xF679)
    readonly property string capture: String.fromCodePoint(0xF727)

    readonly property string volumeDown: String.fromCodePoint(0xE04D)
    readonly property string volumeMute: String.fromCodePoint(0xE04E)
    readonly property string volumeOff: String.fromCodePoint(0xE04F)
    readonly property string volumeUp: String.fromCodePoint(0xE050)

    readonly property string settings: String.fromCodePoint(0xE8B8)
    readonly property string powerSettingsNew: String.fromCodePoint(0xE8AC)

    readonly property string mic: String.fromCodePoint(0xE029)
    readonly property string micOff: String.fromCodePoint(0xE02B)
    readonly property string speaker: String.fromCodePoint(0xE32D)
    readonly property string bluetooth: String.fromCodePoint(0xE1A7)
    readonly property string bluetoothConnected: String.fromCodePoint(0xE1A8)
    readonly property string settingsBluetooth: String.fromCodePoint(0xE8BB)

    readonly property string wbSunny: String.fromCodePoint(0xE430)
    readonly property string nightlight: String.fromCodePoint(0xF03D)

    readonly property string lockClock: String.fromCodePoint(0xEF57)
    readonly property string restartAlt: String.fromCodePoint(0xF053)
    readonly property string logout: String.fromCodePoint(0xE9BA)

    readonly property string play: String.fromCodePoint(0xE037)
    readonly property string pause: String.fromCodePoint(0xE034)
    readonly property string skipNext: String.fromCodePoint(0xE044)
    readonly property string skipPrevious: String.fromCodePoint(0xE045)

    readonly property string starRate: String.fromCodePoint(0xF0EC)
    readonly property string check: String.fromCodePoint(0xE5CA)
    readonly property string plus: String.fromCodePoint(0xE145)
    readonly property string musicNote: String.fromCodePoint(0xE405)
    readonly property string musicNote2: String.fromCodePoint(0xFFFD8)

    readonly property string close: String.fromCodePoint(0xE5CD)
    readonly property string closeSmall: String.fromCodePoint(0xF508)

    readonly property string chevronRight: String.fromCodePoint(0xE5CC)

    readonly property string cropFree: String.fromCodePoint(0xE3C9)
    readonly property string webAsset: String.fromCodePoint(0xE051)
    readonly property string monitor: String.fromCodePoint(0xF380)
    readonly property string videocam: String.fromCodePoint(0xE04B)
    readonly property string timer: String.fromCodePoint(0xE425)
    readonly property string mouse: String.fromCodePoint(0xE323)
    readonly property string expandMore: String.fromCodePoint(0xE5CF)
}
