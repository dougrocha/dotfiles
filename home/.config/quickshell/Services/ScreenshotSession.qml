pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Constants
import "ScreenshotGeometry.js" as Geometry

Singleton {
    id: root

    readonly property var modes: [
        {
            id: "region",
            glyph: PhosphorIcons.selection,
            group: "image",
            target: "selection"
        },
        {
            id: "windows",
            glyph: PhosphorIcons.appWindow,
            group: "image",
            target: "window"
        },
        {
            id: "fullscreen",
            glyph: PhosphorIcons.monitor,
            group: "image",
            target: "none"
        },
        {
            id: "video",
            glyph: PhosphorIcons.videoCamera,
            group: "video",
            target: "none"
        }
    ]
    readonly property var delays: [0, 3, 5, 10]
    readonly property var optionList: [
        {
            key: "showNotification",
            label: "Show notification",
            section: "Options",
            fallback: true
        },
        {
            key: "rememberLastSelection",
            label: "Remember last selection",
            section: "Options",
            fallback: false
        },
        {
            key: "systemAudioEnabled",
            label: "System audio",
            section: "Options",
            fallback: true
        },
        {
            key: "micEnabled",
            label: "Microphone",
            section: "Options",
            fallback: false
        },
        {
            key: "showCursor",
            label: "Show cursor",
            section: "Capture",
            fallback: false
        }
    ]

    readonly property bool selecting: _phase === "selecting"
    readonly property bool counting: _phase === "countdown"
    readonly property bool overlayVisible: selecting || counting
    readonly property string mode: _mode
    readonly property string visualMode: _quick ? (hasSelection ? "region" : "windows") : _mode
    readonly property var selection: _selection
    readonly property bool hasSelection: Geometry.isSelection(_selection)
    readonly property var highlightWindow: visualMode !== "windows" ? null : _quick ? _hoveredWindow : _targetWindow
    readonly property bool canCapture: selecting && !_quick && (_modeTarget === "none" || _captureRect() != null)
    readonly property int countdown: _countdown
    readonly property var readout: _readout
    readonly property int cursorShape: _optionsOpen ? Qt.ArrowCursor : _cursorShape
    readonly property var desktop: Geometry.desktopBounds(Quickshell.screens)
    readonly property bool optionsOpen: _optionsOpen
    readonly property int delay: _delay
    readonly property var options: _options
    readonly property var saveLocations: [""].concat(_recentSaveLocations).map(path => ({
                path: path,
                label: Geometry.directoryLabel(path, _defaultSaveDirectory),
                checked: _saveDirectory === path
            }))

    readonly property var _optionKeys: optionList.map(option => option.key)
    readonly property var _optionDefaults: optionList.reduce((defaults, option) => Object.assign(defaults, {
            [option.key]: option.fallback
        }), {})
    readonly property string _modeTarget: modes.find(entry => entry.id === _mode)?.target ?? "none"
    readonly property bool _picksRegion: _quick || _modeTarget === "selection"
    readonly property var _windows: overlayVisible ? Desktop.visibleWindows() : []
    readonly property var _toolbarHost: Desktop.primaryScreen
    readonly property string _toolbarScreen: _toolbarHost?.name ?? ""
    readonly property var _idleDrag: ({
            kind: "idle",
            startX: 0,
            startY: 0,
            pointerX: 0,
            pointerY: 0,
            initial: null,
            horizontal: 0,
            vertical: 0,
            moved: false
        })
    readonly property var _hiddenReadout: ({
            visible: false,
            screen: "",
            x: 0,
            y: 0,
            directionX: 1,
            directionY: 1,
            edgeAxis: "none"
        })
    readonly property var _emptyRect: ({
            x: 0,
            y: 0,
            width: 0,
            height: 0
        })
    readonly property var _unsetToolbar: ({
            x: -1,
            y: -1
        })

    property string _phase: "idle"
    property bool _quick: false
    property string _quickCommand: ""
    property string _mode: "region"
    property var _selection: _emptyRect
    property var _hoveredWindow: null
    property var _targetWindow: null
    property string _controlScreen: ""
    property var _toolbar: _unsetToolbar
    property bool _optionsOpen: false
    property int _delay: 0
    property int _countdown: 0
    property var _pendingArgv: []
    property var _options: _optionDefaults
    property string _saveDirectory: ""
    property var _recentSaveLocations: []
    property string _defaultSaveDirectory: ""
    property var _drag: _idleDrag
    property var _readout: _hiddenReadout
    property int _cursorShape: Qt.CrossCursor

    function open(): void {
        Visibilities.dismissAll();
        _beginSession(false, "");
        _restore();
        _phase = "selecting";
    }

    function openQuick(command: string): void {
        Visibilities.dismissAll();
        _beginSession(true, command);
        _phase = "selecting";
    }

    function dismiss(): void {
        _pendingArgv = [];
        _endSession();
    }

    function capture(): void {
        if (!canCapture)
            return;
        _pendingArgv = _argvFor(_mode, _captureRect());
        _optionsOpen = false;
        if (_delay > 0) {
            _countdown = _delay;
            _phase = "countdown";
            countdownTimer.restart();
            return;
        }
        _run();
    }

    function hoverAt(x: real, y: real): void {
        if (!selecting || _optionsOpen)
            return;
        const windowMode = !_quick && _modeTarget === "window";
        if (windowMode || (_quick && _quickCommand === "")) {
            const window = _windowAt(x, y);
            if (window?.address !== _hoveredWindow?.address)
                _hoveredWindow = window;
            if (windowMode && window?.address !== _targetWindow?.address)
                _targetWindow = window;
        }
        _cursorShape = _cursorFor(x, y);
    }

    function pointerLeft(): void {
        _hoveredWindow = null;
    }

    function beginDrag(x: real, y: real): void {
        if (!overlayVisible)
            return;
        const hit = _hitAt(x, y);
        _drag = {
            kind: hit.kind,
            startX: x,
            startY: y,
            pointerX: x,
            pointerY: y,
            initial: _selection,
            horizontal: hit.horizontal,
            vertical: hit.vertical,
            moved: false
        };
        _readout = _hiddenReadout;
        _cursorShape = _cursorFor(x, y);
    }

    function dragTo(x: real, y: real): void {
        const kind = _drag.kind;
        if (kind === "idle")
            return;
        const moved = _drag.moved || Geometry.pastDragThreshold(_drag, x, y);
        _drag = Object.assign({}, _drag, {
            pointerX: x,
            pointerY: y,
            moved: moved
        });
        if (!_isShapeDrag(kind))
            return;
        _cursorShape = _cursorFor(x, y);
        const bounded = Geometry.clampToDesktop(desktop, x, y);
        const shown = Geometry.insideDesktop(desktop, x, y);
        const placement = {
            x: shown.x,
            y: shown.y,
            screen: Geometry.nearestScreen(Quickshell.screens, shown.x, shown.y)
        };
        if (!moved) {
            _readout = Object.assign({}, _readout, placement);
            return;
        }
        if (kind === "create")
            _setSelection(Geometry.rectFromPoints(_drag.startX, _drag.startY, bounded.x, bounded.y));
        else if (kind === "move")
            _setSelection(Geometry.movedRect(_drag.initial, x - _drag.startX, y - _drag.startY, desktop));
        else
            _setSelection(Geometry.resizedRect(_drag.initial, _drag.horizontal, _drag.vertical, bounded.x, bounded.y));
        const direction = kind === "move" ? {} : Geometry.readoutDirection(_drag, _selection, bounded.x, bounded.y);
        _readout = Object.assign({}, _readout, placement, direction, {
            visible: kind !== "move"
        });
    }

    function endDrag(): void {
        const drag = _drag;
        if (drag.kind === "idle")
            return;
        _finishDrag(drag.pointerX, drag.pointerY);
        if (drag.kind === "background") {
            if (_optionsOpen)
                _optionsOpen = false;
            else
                dismiss();
        } else if (drag.kind === "pick") {
            const window = _windowAt(drag.pointerX, drag.pointerY);
            if (window) {
                _targetWindow = window;
                capture();
            }
        } else if (_quick) {
            _captureQuick(drag.pointerX, drag.pointerY);
        } else if (drag.kind === "create" && !drag.moved) {
            _setSelection(drag.initial);
        } else if (drag.moved) {
            _commitRegion();
        }
    }

    function cancelDrag(): void {
        const drag = _drag;
        if (drag.kind === "idle")
            return;
        if (_isShapeDrag(drag.kind))
            _setSelection(drag.initial);
        _finishDrag(drag.pointerX, drag.pointerY);
    }

    function setMode(mode: string): void {
        if (!modes.some(entry => entry.id === mode))
            return;
        _mode = mode;
        _hoveredWindow = null;
        _targetWindow = null;
        _persist("captureMode", mode);
    }

    function setDelay(seconds: int): void {
        if (!delays.includes(seconds))
            return;
        _delay = seconds;
        _persist("timerDelay", seconds);
    }

    function toggleOption(key: string): void {
        if (!_optionKeys.includes(key))
            return;
        const value = !_options[key];
        _options = Object.assign({}, _options, {
            [key]: value
        });
        _persist(key, value);
        if (key === "rememberLastSelection" && !value)
            _clearSavedRegions();
    }

    function toggleOptions(): void {
        if (selecting && !_quick)
            _optionsOpen = !_optionsOpen;
    }

    function chooseSaveLocation(path: string): void {
        const defaultDirectory = Geometry.normalizedDirectory(_defaultSaveDirectory);
        const normalized = path === "" ? defaultDirectory : Geometry.normalizedDirectory(path);
        const remaining = _recentSaveLocations.filter(location => {
            const candidate = Geometry.normalizedDirectory(location);
            return candidate !== normalized && candidate !== defaultDirectory;
        });
        const isDefault = normalized === defaultDirectory;
        _saveDirectory = isDefault ? "" : normalized;
        _recentSaveLocations = (isDefault ? remaining : [normalized].concat(remaining)).slice(0, 3);
        _persist("saveDirectory", _saveDirectory);
        _persist("recentSaveLocations", _recentSaveLocations);
    }

    function browseSaveLocation(): void {
        if (!selecting || saveLocationProcess.running)
            return;
        _optionsOpen = false;
        _phase = "choosingDirectory";
        saveLocationProcess.running = true;
    }

    function showsToolbarOn(screenName: string): bool {
        return !_quick && screenName === _toolbarScreen;
    }

    function toolbarPosition(width: real, height: real): point {
        if (!_toolbarHost)
            return Qt.point(0, 0);
        const placed = Geometry.clampToolbar(_toolbar, {
            width: width,
            height: height
        }, _toolbarHost);
        return Qt.point(placed.x, placed.y);
    }

    function optionsPosition(toolbarX: real, toolbarY: real, toolbarWidth: real, toolbarHeight: real, width: real, height: real): point {
        if (!_toolbarHost)
            return Qt.point(0, 0);
        const placed = Geometry.optionsPlacement({
            x: toolbarX,
            y: toolbarY,
            width: toolbarWidth,
            height: toolbarHeight
        }, {
            width: width,
            height: height
        }, _toolbarHost);
        return Qt.point(placed.x, placed.y);
    }

    function placeToolbar(x: real, y: real): void {
        _toolbar = {
            x: x,
            y: y
        };
        if (!SettingsService.loaded || _toolbarScreen === "")
            return;
        _updateMonitorEntry(_toolbarScreen, entry => {
            entry.toolbar = {
                x: x,
                y: y
            };
        });
    }

    function _beginSession(quick, command) {
        _resetInteraction();
        _pendingArgv = [];
        _quick = quick;
        _quickCommand = command;
        _setSelection(_emptyRect);
        _hoveredWindow = null;
        _targetWindow = null;
        _cursorShape = Qt.CrossCursor;
        Desktop.refresh();
        _controlScreen = Desktop.focusedScreen()?.name ?? "";
    }

    function _endSession() {
        _resetInteraction();
        _quick = false;
        _quickCommand = "";
        _phase = "idle";
    }

    function _run() {
        const argv = _pendingArgv;
        _pendingArgv = [];
        _endSession();
        if (argv.length > 0)
            Quickshell.execDetached(argv);
    }

    function _stopCountdown() {
        countdownTimer.stop();
        _countdown = 0;
    }

    function _resetInteraction() {
        _stopCountdown();
        _optionsOpen = false;
        _drag = _idleDrag;
        _readout = _hiddenReadout;
    }

    function _captureRect() {
        if (_modeTarget === "selection")
            return hasSelection ? _selection : null;
        if (_modeTarget === "window")
            return _targetWindow;
        return null;
    }

    function _argvFor(mode, rect) {
        if (mode === "video") {
            const recording = ["toggle-recording"];
            if (_options.systemAudioEnabled)
                recording.push("--system-audio");
            if (_options.micEnabled)
                recording.push("--mic");
            return recording;
        }
        let argv = ["screenshot"];
        if (_options.showCursor)
            argv.push("--cursor");
        if (!_options.showNotification)
            argv.push("--no-notification");
        if (_saveDirectory !== "")
            argv = argv.concat(["--output-dir", _saveDirectory]);
        if (rect != null)
            argv = argv.concat(["--geometry", Geometry.geometryString(rect)]);
        argv.push(mode);
        return argv;
    }

    function _captureQuick(x, y) {
        const regionOnly = _quickCommand !== "";
        if (regionOnly && !hasSelection)
            return;
        const rect = hasSelection ? _selection : _windowAt(x, y) ?? Geometry.screenAt(Quickshell.screens, x, y);
        if (rect == null)
            return;
        _pendingArgv = regionOnly ? [_quickCommand, "--geometry", Geometry.geometryString(rect)] : _argvFor("region", rect);
        _run();
    }

    function _windowAt(x, y) {
        return Geometry.windowAt(_windows, x, y);
    }

    function _setSelection(rect) {
        _selection = Geometry.normalizedRect(rect);
    }

    function _isShapeDrag(kind) {
        return kind === "create" || kind === "move" || kind === "resize";
    }

    function _hitAt(x, y) {
        if (_optionsOpen)
            return Geometry.hit("background");
        if (counting)
            return _modeTarget === "none" ? Geometry.hit("background") : Geometry.hit("idle");
        if (_picksRegion)
            return Geometry.hitTest(_selection, x, y);
        if (_modeTarget === "window")
            return Geometry.hit("pick");
        return Geometry.hit("background");
    }

    function _finishDrag(x, y) {
        _drag = _idleDrag;
        _readout = Object.assign({}, _readout, {
            visible: false
        });
        _cursorShape = _cursorFor(x, y);
    }

    function _resizeCursor(horizontal, vertical) {
        if (horizontal !== 0 && vertical !== 0)
            return horizontal === vertical ? Qt.SizeFDiagCursor : Qt.SizeBDiagCursor;
        return horizontal !== 0 ? Qt.SizeHorCursor : Qt.SizeVerCursor;
    }

    function _cursorFor(x, y) {
        const drag = _drag;
        if (drag.kind === "move")
            return Qt.SizeAllCursor;
        if (drag.kind === "create")
            return Qt.CrossCursor;
        if (drag.kind === "resize")
            return _resizeCursor(Geometry.resolvedResizeSign(drag.pointerX, drag.horizontal, drag.initial.x, drag.initial.width), Geometry.resolvedResizeSign(drag.pointerY, drag.vertical, drag.initial.y, drag.initial.height));
        if (drag.kind !== "idle" || !selecting)
            return Qt.ArrowCursor;
        if (_picksRegion) {
            const hit = Geometry.hitTest(_selection, x, y);
            if (hit.kind === "move")
                return Qt.SizeAllCursor;
            return hit.kind === "resize" ? _resizeCursor(hit.horizontal, hit.vertical) : Qt.CrossCursor;
        }
        return _modeTarget === "window" && _hoveredWindow != null ? Qt.PointingHandCursor : Qt.ArrowCursor;
    }

    function _persist(key, value) {
        if (SettingsService.loaded)
            SettingsService.screenshot[key] = value;
    }

    function _monitorEntry(name) {
        const entry = SettingsService.screenshot.monitors[name];
        return entry != null && typeof entry === "object" ? entry : null;
    }

    function _updateMonitorEntry(name, change) {
        const monitors = Object.assign({}, SettingsService.screenshot.monitors);
        const entry = Object.assign({}, monitors[name]);
        change(entry);
        monitors[name] = entry;
        SettingsService.screenshot.monitors = monitors;
    }

    function _restore() {
        _toolbar = _unsetToolbar;
        if (!SettingsService.loaded)
            return;
        const toolbarSaved = _monitorEntry(_toolbarScreen)?.toolbar;
        if (Geometry.isSavedToolbar(toolbarSaved))
            _toolbar = {
                x: toolbarSaved.x,
                y: toolbarSaved.y
            };
        const screen = Desktop.screenNamed(_controlScreen);
        const region = _monitorEntry(_controlScreen)?.region;
        if (_options.rememberLastSelection && screen != null && Geometry.isSavedRegion(region, screen))
            _setSelection(Geometry.fromOutput(region, screen));
    }

    function _commitRegion() {
        if (!_options.rememberLastSelection || !SettingsService.loaded || _controlScreen === "")
            return;
        const screen = Desktop.screenNamed(_controlScreen);
        if (screen == null)
            return;
        const contained = hasSelection && Geometry.containsRect(screen, _selection);
        _updateMonitorEntry(_controlScreen, entry => {
            if (contained)
                entry.region = Geometry.toOutput(_selection, screen);
            else
                delete entry.region;
        });
    }

    function _clearSavedRegions() {
        if (!SettingsService.loaded)
            return;
        const monitors = SettingsService.screenshot.monitors;
        const updated = {};
        for (const name in monitors) {
            const entry = Object.assign({}, monitors[name]);
            delete entry.region;
            updated[name] = entry;
        }
        SettingsService.screenshot.monitors = updated;
    }

    function _hydrate() {
        const saved = SettingsService.screenshot;
        _mode = modes.some(entry => entry.id === saved.captureMode) ? saved.captureMode : "region";
        _delay = delays.includes(saved.timerDelay) ? saved.timerDelay : 0;
        _options = optionList.reduce((options, option) => Object.assign(options, {
                [option.key]: !!(saved[option.key] ?? option.fallback)
            }), {});
        _saveDirectory = typeof saved.saveDirectory === "string" ? saved.saveDirectory : "";
        const recent = Array.isArray(saved.recentSaveLocations) ? saved.recentSaveLocations.filter(location => typeof location === "string" && location !== "") : [];
        _recentSaveLocations = [...new Set(recent)].slice(0, 3);
    }

    Connections {
        target: SettingsService

        function onLoadedChanged() {
            if (SettingsService.loaded)
                root._hydrate();
        }
    }

    Component.onCompleted: if (SettingsService.loaded)
        root._hydrate()

    Process {
        running: true
        command: ["sh", "-c", "f=\"${XDG_CONFIG_HOME:-$HOME/.config}/user-dirs.dirs\"; [ -f \"$f\" ] && . \"$f\"; printf '%s/Screenshots' \"${XDG_PICTURES_DIR:-$HOME/Pictures}\""]

        stdout: SplitParser {
            onRead: data => root._defaultSaveDirectory = data.trim()
        }
    }

    Process {
        id: saveLocationProcess

        command: ["zenity", "--file-selection", "--directory", "--title=Save Screenshot To"]
        onExited: if (root._phase === "choosingDirectory")
            root._phase = "selecting"

        stdout: SplitParser {
            onRead: data => {
                const path = data.trim();
                if (path !== "")
                    root.chooseSaveLocation(path);
            }
        }
    }

    Timer {
        id: countdownTimer

        interval: 1000
        repeat: true
        onTriggered: {
            root._countdown--;
            if (root._countdown <= 0)
                root._run();
        }
    }

    Timer {
        interval: 16
        repeat: true
        triggeredOnStart: true
        running: root._isShapeDrag(root._drag.kind)
        onTriggered: if (!cursorPositionProcess.running)
            cursorPositionProcess.running = true
    }

    Process {
        id: cursorPositionProcess

        command: ["hyprctl", "cursorpos"]

        stdout: SplitParser {
            onRead: data => {
                const point = Geometry.pointerFromCursorOutput(data);
                if (point && root._isShapeDrag(root._drag.kind))
                    root.dragTo(point.x, point.y);
            }
        }
    }

    IpcHandler {
        target: "screenshot-overlay"

        function show(): void {
            root.open();
        }
        function hide(): void {
            root.dismiss();
        }
        function toggle(): void {
            if (root.overlayVisible)
                root.dismiss();
            else
                root.open();
        }
        function toggleQuick(): void {
            toggleQuickWith("");
        }
        function toggleQuickWith(command: string): void {
            if (root.overlayVisible)
                root.dismiss();
            else
                root.openQuick(command);
        }
    }
}
