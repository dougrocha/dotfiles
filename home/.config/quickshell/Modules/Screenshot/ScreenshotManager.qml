pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.Constants
import qs.Services

Item {
    id: manager

    property bool overlayVisible: false
    property string controlMonitor: ""
    property string toolbarMonitor: ""
    property real toolbarX: -1
    property real toolbarY: -1
    property int timerDelay: 0
    property string selectedMode: "region"
    property string pendingMode: ""
    property string pendingGeometry: ""
    property bool pendingUsesUiCountdown: false
    property int countdown: 0
    property bool countdownActive: false
    property real selectionX: 0
    property real selectionY: 0
    property real selectionWidth: 0
    property real selectionHeight: 0
    property bool hasSelection: false
    property var hoveredWindow: null
    property var selectedWindow: null
    property real pointerGlobalX: 0
    property real pointerGlobalY: 0
    property int readoutDirectionX: 1
    property int readoutDirectionY: 1
    property string readoutMonitor: ""
    property bool readoutVisible: false
    property int pointerCursorShape: Qt.CrossCursor
    property bool showCursor: false
    property bool showNotification: true
    property bool rememberLastSelection: false
    property string saveDirectory: ""
    property var recentSaveLocations: []
    readonly property string defaultSaveDirectory: Quickshell.env("XDG_PICTURES_DIR") + "/Screenshots"
    property bool micEnabled: false
    property bool systemAudioEnabled: true
    property bool optionsOpen: false

    Connections {
        target: SettingsService
        function onLoadedChanged() {
            if (SettingsService.loaded)
                manager.hydrate();
        }
    }
    Component.onCompleted: if (SettingsService.loaded)
        manager.hydrate()

    function hydrate() {
        const validModes = ["region", "windows", "fullscreen", "video"];
        selectedMode = validModes.includes(SettingsService.screenshotCaptureMode) ? SettingsService.screenshotCaptureMode : "region";
        const validDelays = [0, 3, 5, 10];
        timerDelay = validDelays.includes(SettingsService.screenshotTimerDelay) ? SettingsService.screenshotTimerDelay : 0;
        showCursor = !!SettingsService.screenshotShowCursor;
        showNotification = !!SettingsService.screenshotShowNotification;
        micEnabled = !!SettingsService.screenshotMicEnabled;
        systemAudioEnabled = !!SettingsService.screenshotSystemAudioEnabled;
        rememberLastSelection = !!SettingsService.screenshotRememberLastSelection;
        saveDirectory = typeof SettingsService.screenshotSaveDirectory === "string" ? SettingsService.screenshotSaveDirectory : "";
        const saved = SettingsService.screenshotRecentSaveLocations;
        const sanitized = Array.isArray(saved) ? saved.filter(loc => typeof loc === "string" && loc !== "") : [];
        recentSaveLocations = [...new Set(sanitized)].slice(0, 3);
    }

    function setSelectedMode(mode) {
        selectedMode = mode;
        if (SettingsService.loaded)
            SettingsService.screenshotCaptureMode = mode;
    }

    function setTimerDelay(delay) {
        timerDelay = delay;
        if (SettingsService.loaded)
            SettingsService.screenshotTimerDelay = delay;
    }

    function monitorEntry(name) {
        const entry = SettingsService.screenshotMonitors[name];
        return entry != null && typeof entry === "object" ? entry : null;
    }

    function restoreForControlMonitor() {
        toolbarMonitor = "";
        toolbarX = -1;
        toolbarY = -1;
        if (!SettingsService.loaded || controlMonitor === "")
            return;
        const entry = monitorEntry(controlMonitor);
        if (entry == null)
            return;
        const monitor = Hyprland.monitors.values.find(m => m.name === controlMonitor);
        if (monitor == null)
            return;

        const toolbarSaved = entry.toolbar;
        if (toolbarSaved != null && Number.isFinite(toolbarSaved.x) && Number.isFinite(toolbarSaved.y) && toolbarSaved.x >= 0 && toolbarSaved.y >= 0) {
            toolbarMonitor = controlMonitor;
            toolbarX = toolbarSaved.x;
            toolbarY = toolbarSaved.y;
        }

        const regionSaved = entry.region;
        if (rememberLastSelection && regionSaved != null && Number.isFinite(regionSaved.x) && Number.isFinite(regionSaved.y) && Number.isFinite(regionSaved.width) && Number.isFinite(regionSaved.height) && regionSaved.width >= 2 && regionSaved.height >= 2 && regionSaved.x >= 0 && regionSaved.y >= 0 && regionSaved.x + regionSaved.width <= monitor.width && regionSaved.y + regionSaved.height <= monitor.height) {
            selectionX = monitor.x + regionSaved.x;
            selectionY = monitor.y + regionSaved.y;
            selectionWidth = regionSaved.width;
            selectionHeight = regionSaved.height;
            hasSelection = true;
        }
    }

    function commitRegion() {
        if (!rememberLastSelection || !SettingsService.loaded || controlMonitor === "")
            return;
        const monitor = Hyprland.monitors.values.find(m => m.name === controlMonitor);
        if (monitor == null)
            return;
        const monitors = Object.assign({}, SettingsService.screenshotMonitors);
        const existing = Object.assign({}, monitors[controlMonitor]);
        const contained = hasSelection && selectionWidth >= 2 && selectionHeight >= 2 && selectionX >= monitor.x && selectionY >= monitor.y && selectionX + selectionWidth <= monitor.x + monitor.width && selectionY + selectionHeight <= monitor.y + monitor.height;
        if (contained) {
            existing.region = {
                x: selectionX - monitor.x,
                y: selectionY - monitor.y,
                width: selectionWidth,
                height: selectionHeight
            };
        } else {
            delete existing.region;
        }
        monitors[controlMonitor] = existing;
        SettingsService.screenshotMonitors = monitors;
    }

    function persistToolbarPosition() {
        if (!SettingsService.loaded || controlMonitor === "")
            return;
        const monitors = Object.assign({}, SettingsService.screenshotMonitors);
        const existing = Object.assign({}, monitors[controlMonitor]);
        existing.toolbar = {
            x: toolbarX,
            y: toolbarY
        };
        monitors[controlMonitor] = existing;
        SettingsService.screenshotMonitors = monitors;
    }

    function clearAllSavedRegions() {
        const monitors = SettingsService.screenshotMonitors;
        const updated = {};
        for (const name in monitors) {
            const entry = Object.assign({}, monitors[name]);
            delete entry.region;
            updated[name] = entry;
        }
        SettingsService.screenshotMonitors = updated;
    }

    IpcHandler {
        target: "screenshot-overlay"

        function show(): void {
            manager.resetSelection();
            Hyprland.refreshToplevels();
            manager.controlMonitor = Hyprland.focusedMonitor?.name ?? "";
            manager.restoreForControlMonitor();
            manager.overlayVisible = true;
        }
        function hide(): void {
            manager.overlayVisible = false;
        }
        function toggle(): void {
            if (!manager.overlayVisible) {
                manager.resetSelection();
                Hyprland.refreshToplevels();
                manager.controlMonitor = Hyprland.focusedMonitor?.name ?? "";
                manager.restoreForControlMonitor();
            }
            manager.overlayVisible = !manager.overlayVisible;
        }
    }

    Process {
        id: screenshotProcess
    }
    Process {
        id: toggleRecordingProcess
    }
    Process {
        id: saveLocationProcess
        command: ["zenity", "--file-selection", "--directory", "--title=Save Screenshot To"]
        onExited: manager.overlayVisible = true
        stdout: SplitParser {
            onRead: data => {
                const path = data.trim();
                if (path !== "")
                    manager.selectSaveDirectory(path);
            }
        }
    }

    Timer {
        id: countdownTimer
        interval: 1000
        repeat: true
        onTriggered: {
            manager.countdown--;
            if (manager.countdown <= 0) {
                stop();
                manager.countdownActive = false;
                manager.overlayVisible = false;
            }
        }
    }

    onOverlayVisibleChanged: {
        if (!overlayVisible && pendingMode !== "") {
            executeAction();
        }
    }

    function capture() {
        if (countdownActive)
            return;
        if ((selectedMode === "region" && !hasSelection) || (selectedMode === "windows" && selectedWindow == null))
            return;
        pendingMode = selectedMode;
        pendingGeometry = selectedMode === "region" ? selectionGeometry() : selectedMode === "windows" ? windowGeometry(selectedWindow) : "";
        optionsOpen = false;
        if (timerDelay > 0) {
            pendingUsesUiCountdown = true;
            countdown = timerDelay;
            countdownActive = true;
            countdownTimer.restart();
            return;
        }
        overlayVisible = false;
    }

    function executeAction() {
        if (pendingMode === "video") {
            let args = ["toggle-recording"];
            if (systemAudioEnabled)
                args.push("--system-audio");
            if (micEnabled)
                args.push("--mic");
            toggleRecordingProcess.command = args;
            toggleRecordingProcess.running = true;
        } else {
            let args = ["screenshot"];
            if (timerDelay > 0 && !pendingUsesUiCountdown)
                args = args.concat(["--delay", timerDelay.toString()]);
            if (showCursor)
                args.push("--cursor");
            if (!showNotification)
                args.push("--no-notification");
            if (saveDirectory !== "")
                args = args.concat(["--output-dir", saveDirectory]);
            if (pendingGeometry !== "")
                args = args.concat(["--geometry", pendingGeometry]);
            args.push(pendingMode);
            screenshotProcess.command = args;
            screenshotProcess.running = true;
        }
        pendingMode = "";
        pendingGeometry = "";
        pendingUsesUiCountdown = false;
    }

    function resetSelection() {
        selectionX = 0;
        selectionY = 0;
        selectionWidth = 0;
        selectionHeight = 0;
        hasSelection = false;
        hoveredWindow = null;
        selectedWindow = null;
        readoutVisible = false;
        readoutMonitor = "";
    }

    function selectionGeometry() {
        return Math.round(selectionX) + "," + Math.round(selectionY) + " " + Math.round(selectionWidth) + "x" + Math.round(selectionHeight);
    }

    function windowGeometry(window) {
        return Math.round(window.x) + "," + Math.round(window.y) + " " + Math.round(window.width) + "x" + Math.round(window.height);
    }

    function selectSaveDirectory(path) {
        const normalized = path.replace(/\/+$/, "");
        const normalizedDefault = defaultSaveDirectory.replace(/\/+$/, "");
        const remaining = recentSaveLocations.filter(location => {
            const candidate = location.replace(/\/+$/, "");
            return candidate !== normalized && candidate !== normalizedDefault;
        });
        if (normalized === normalizedDefault) {
            saveDirectory = "";
            recentSaveLocations = remaining.slice(0, 3);
        } else {
            saveDirectory = normalized;
            recentSaveLocations = [normalized].concat(remaining).slice(0, 3);
        }
        if (SettingsService.loaded) {
            SettingsService.screenshotSaveDirectory = saveDirectory;
            SettingsService.screenshotRecentSaveLocations = recentSaveLocations;
        }
    }

    function locationLabel(path) {
        if (path === "")
            return "Pictures/Screenshots";
        const parts = path.split("/").filter(part => part !== "");
        return parts.length > 0 ? parts[parts.length - 1] : path;
    }

    function windowAt(px, py) {
        const candidates = Hyprland.toplevels.values.filter(toplevel => {
            const data = toplevel.lastIpcObject;
            return data != null && data.mapped !== false && !data.hidden && toplevel.workspace != null && toplevel.workspace.active;
        }).sort((a, b) => (a.lastIpcObject.focusHistoryID ?? 9999) - (b.lastIpcObject.focusHistoryID ?? 9999));

        for (let i = 0; i < candidates.length; ++i) {
            const data = candidates[i].lastIpcObject;
            const x = data.at[0];
            const y = data.at[1];
            const width = data.size[0];
            const height = data.size[1];
            if (px >= x && px < x + width && py >= y && py < y + height)
                return {
                    address: candidates[i].address,
                    x: x,
                    y: y,
                    width: width,
                    height: height
                };
        }
        return null;
    }

    function dismiss() {
        pendingMode = "";
        pendingGeometry = "";
        pendingUsesUiCountdown = false;
        countdownTimer.stop();
        countdownActive = false;
        countdown = 0;
        overlayVisible = false;
        optionsOpen = false;
    }

    Variants {
        model: manager.overlayVisible ? Quickshell.screens : []

        delegate: PanelWindow {
            id: overlayWindow
            required property var modelData
            screen: modelData

            readonly property bool isControlScreen: modelData.name === manager.controlMonitor
            readonly property var monitor: Hyprland.monitorFor(modelData)
            readonly property real monitorX: monitor != null ? monitor.x : 0
            readonly property real monitorY: monitor != null ? monitor.y : 0
            property real dragStartX: 0
            property real dragStartY: 0
            property real pointerX: 0
            property real pointerY: 0
            property real initialX: 0
            property real initialY: 0
            property real initialWidth: 0
            property real initialHeight: 0
            property string interaction: "idle"
            property int resizeHorizontal: 0
            property int resizeVertical: 0
            property bool interactionMoved: false

            function ownsSelection(): bool {
                return manager.hasSelection;
            }

            function hitTest(px, py): var {
                if (!ownsSelection())
                    return {
                        mode: "create",
                        horizontal: 0,
                        vertical: 0
                    };

                const hit = 10;
                const left = manager.selectionX;
                const right = left + manager.selectionWidth;
                const top = manager.selectionY;
                const bottom = top + manager.selectionHeight;
                const withinX = px >= left - hit && px <= right + hit;
                const withinY = py >= top - hit && py <= bottom + hit;
                const horizontal = withinY && Math.abs(px - left) <= hit ? -1 : withinY && Math.abs(px - right) <= hit ? 1 : 0;
                const vertical = withinX && Math.abs(py - top) <= hit ? -1 : withinX && Math.abs(py - bottom) <= hit ? 1 : 0;

                if (horizontal !== 0 || vertical !== 0)
                    return {
                        mode: "resize",
                        horizontal: horizontal,
                        vertical: vertical
                    };
                if (px > left && px < right && py > top && py < bottom)
                    return {
                        mode: "move",
                        horizontal: 0,
                        vertical: 0
                    };
                return {
                    mode: "create",
                    horizontal: 0,
                    vertical: 0
                };
            }

            function desktopBounds(): var {
                const monitors = Hyprland.monitors.values;
                let left = monitors[0].x;
                let top = monitors[0].y;
                let right = monitors[0].x + monitors[0].width;
                let bottom = monitors[0].y + monitors[0].height;
                for (let i = 1; i < monitors.length; ++i) {
                    left = Math.min(left, monitors[i].x);
                    top = Math.min(top, monitors[i].y);
                    right = Math.max(right, monitors[i].x + monitors[i].width);
                    bottom = Math.max(bottom, monitors[i].y + monitors[i].height);
                }
                return {
                    left: left,
                    top: top,
                    right: right,
                    bottom: bottom
                };
            }

            function updateReadoutDirection(px, py) {
                if (interaction === "create") {
                    manager.readoutDirectionX = px < dragStartX ? -1 : 1;
                    manager.readoutDirectionY = py < dragStartY ? -1 : 1;
                    return;
                }

                if (resizeHorizontal < 0)
                    manager.readoutDirectionX = px <= initialX + initialWidth ? -1 : 1;
                else if (resizeHorizontal > 0)
                    manager.readoutDirectionX = px >= initialX ? 1 : -1;
                else
                    manager.readoutDirectionX = px < manager.selectionX + manager.selectionWidth / 2 ? -1 : 1;

                if (resizeVertical < 0)
                    manager.readoutDirectionY = py <= initialY + initialHeight ? -1 : 1;
                else if (resizeVertical > 0)
                    manager.readoutDirectionY = py >= initialY ? 1 : -1;
                else
                    manager.readoutDirectionY = py < manager.selectionY + manager.selectionHeight / 2 ? -1 : 1;
            }

            function updateReadoutMonitor(px, py) {
                const monitors = Hyprland.monitors.values;
                let nearest = null;
                let nearestDistance = Infinity;
                for (let i = 0; i < monitors.length; ++i) {
                    const monitor = monitors[i];
                    if (px >= monitor.x && px < monitor.x + monitor.width && py >= monitor.y && py < monitor.y + monitor.height) {
                        manager.readoutMonitor = monitor.name;
                        return;
                    }
                    const distanceX = Math.max(monitor.x - px, 0, px - monitor.x - monitor.width);
                    const distanceY = Math.max(monitor.y - py, 0, py - monitor.y - monitor.height);
                    const distance = distanceX * distanceX + distanceY * distanceY;
                    if (distance < nearestDistance) {
                        nearest = monitor;
                        nearestDistance = distance;
                    }
                }
                manager.readoutMonitor = nearest != null ? nearest.name : "";
            }

            function labelPosition(pointer, extent, direction, available): real {
                const gap = 14;
                const preferred = direction < 0 ? pointer - gap - extent : pointer + gap;
                return Math.max(8, Math.min(available - extent - 8, preferred));
            }

            function labelIsClamped(pointer, extent, direction, available): bool {
                const gap = 14;
                const preferred = direction < 0 ? pointer - gap - extent : pointer + gap;
                return preferred < 8 || preferred > available - extent - 8;
            }

            function cursorAt(px, py): int {
                if (interaction === "move")
                    return Qt.SizeAllCursor;
                if (interaction === "create")
                    return Qt.CrossCursor;
                if (interaction === "resize") {
                    let h = resizeHorizontal;
                    let v = resizeVertical;
                    if (h < 0)
                        h = pointerX <= initialX + initialWidth ? -1 : 1;
                    else if (h > 0)
                        h = pointerX >= initialX ? 1 : -1;
                    if (v < 0)
                        v = pointerY <= initialY + initialHeight ? -1 : 1;
                    else if (v > 0)
                        v = pointerY >= initialY ? 1 : -1;
                    if (h !== 0 && v !== 0)
                        return h === v ? Qt.SizeFDiagCursor : Qt.SizeBDiagCursor;
                    return h !== 0 ? Qt.SizeHorCursor : Qt.SizeVerCursor;
                }

                const hit = hitTest(px, py);
                if (hit.mode === "move")
                    return Qt.SizeAllCursor;
                if (hit.mode !== "resize")
                    return Qt.CrossCursor;
                if (hit.horizontal !== 0 && hit.vertical !== 0)
                    return hit.horizontal === hit.vertical ? Qt.SizeFDiagCursor : Qt.SizeBDiagCursor;
                return hit.horizontal !== 0 ? Qt.SizeHorCursor : Qt.SizeVerCursor;
            }

            function updateInteraction(px, py) {
                const dx = px - dragStartX;
                const dy = py - dragStartY;
                const bounds = desktopBounds();
                const boundedX = Math.max(bounds.left, Math.min(bounds.right, px));
                const boundedY = Math.max(bounds.top, Math.min(bounds.bottom, py));
                pointerX = px;
                pointerY = py;
                manager.pointerCursorShape = cursorAt(px, py);
                manager.pointerGlobalX = boundedX >= bounds.right ? bounds.right - 0.001 : boundedX;
                manager.pointerGlobalY = boundedY >= bounds.bottom ? bounds.bottom - 0.001 : boundedY;
                updateReadoutMonitor(manager.pointerGlobalX, manager.pointerGlobalY);
                if (!interactionMoved && Math.hypot(dx, dy) < 3)
                    return;
                interactionMoved = true;
                manager.readoutVisible = interaction === "create" || interaction === "resize";

                if (interaction === "create") {
                    manager.selectionX = Math.min(dragStartX, boundedX);
                    manager.selectionY = Math.min(dragStartY, boundedY);
                    manager.selectionWidth = Math.abs(boundedX - dragStartX);
                    manager.selectionHeight = Math.abs(boundedY - dragStartY);
                    manager.hasSelection = manager.selectionWidth >= 2 && manager.selectionHeight >= 2;
                    updateReadoutDirection(boundedX, boundedY);
                    return;
                }

                if (interaction === "move") {
                    manager.selectionX = Math.max(bounds.left, Math.min(bounds.right - initialWidth, initialX + dx));
                    manager.selectionY = Math.max(bounds.top, Math.min(bounds.bottom - initialHeight, initialY + dy));
                    return;
                }

                let left = initialX;
                let right = initialX + initialWidth;
                let top = initialY;
                let bottom = initialY + initialHeight;
                if (resizeHorizontal < 0)
                    left = boundedX;
                else if (resizeHorizontal > 0)
                    right = boundedX;
                if (resizeVertical < 0)
                    top = boundedY;
                else if (resizeVertical > 0)
                    bottom = boundedY;

                manager.selectionX = Math.min(left, right);
                manager.selectionY = Math.min(top, bottom);
                manager.selectionWidth = Math.abs(right - left);
                manager.selectionHeight = Math.abs(bottom - top);
                manager.hasSelection = manager.selectionWidth >= 2 && manager.selectionHeight >= 2;
                updateReadoutDirection(boundedX, boundedY);
            }

            visible: manager.overlayVisible
            color: "transparent"

            // Every output must explicitly accept pointer input. Without a mask,
            // a transparent non-keyboard-owning layer can remain click-through.
            mask: Region {
                x: 0
                y: 0
                width: overlayWindow.width
                height: overlayWindow.height
            }

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "qs.screenshot_overlay"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            onVisibleChanged: {
                if (visible && overlayWindow.isControlScreen) {
                    keyHandler.forceActiveFocus();
                }
            }

            // A layer-shell window exists per monitor. Once a pointer grab leaves
            // its originating surface, Wayland may stop delivering motion events,
            // so sample Hyprland's global cursor position for the remainder of the drag.
            Process {
                id: cursorPositionProcess
                command: ["hyprctl", "cursorpos"]
                stdout: SplitParser {
                    onRead: data => {
                        if (!selectionArea.pressed)
                            return;
                        const coordinates = data.trim().split(",");
                        if (coordinates.length !== 2)
                            return;
                        const x = Number(coordinates[0]);
                        const y = Number(coordinates[1]);
                        if (Number.isFinite(x) && Number.isFinite(y))
                            overlayWindow.updateInteraction(x, y);
                    }
                }
            }

            Timer {
                interval: 16
                running: selectionArea.pressed
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    if (!cursorPositionProcess.running)
                        cursorPositionProcess.running = true;
                }
            }

            MouseArea {
                anchors.fill: parent
                enabled: manager.optionsOpen || (manager.selectedMode !== "region" && manager.selectedMode !== "windows")
                onClicked: {
                    if (manager.optionsOpen)
                        manager.optionsOpen = false;
                    else
                        manager.dismiss();
                }
            }

            MouseArea {
                id: windowSelectionArea
                anchors.fill: parent
                enabled: manager.selectedMode === "windows" && !manager.optionsOpen && !manager.countdownActive
                hoverEnabled: true
                cursorShape: manager.hoveredWindow != null ? Qt.PointingHandCursor : Qt.ArrowCursor
                onPositionChanged: mouse => {
                    const globalX = overlayWindow.monitorX + mouse.x;
                    const globalY = overlayWindow.monitorY + mouse.y;
                    manager.hoveredWindow = manager.windowAt(globalX, globalY);
                }
                onExited: manager.hoveredWindow = null
                onClicked: {
                    if (manager.hoveredWindow != null) {
                        manager.selectedWindow = manager.hoveredWindow;
                        manager.capture();
                    }
                }
            }

            MouseArea {
                id: selectionArea
                anchors.fill: parent
                enabled: manager.selectedMode === "region" && !manager.optionsOpen && !manager.countdownActive
                hoverEnabled: true
                cursorShape: manager.pointerCursorShape
                onEntered: {
                    manager.pointerCursorShape = overlayWindow.cursorAt(overlayWindow.monitorX + mouseX, overlayWindow.monitorY + mouseY);
                }
                onPressed: mouse => {
                    const globalX = overlayWindow.monitorX + mouse.x;
                    const globalY = overlayWindow.monitorY + mouse.y;
                    keyHandler.forceActiveFocus();
                    overlayWindow.dragStartX = globalX;
                    overlayWindow.dragStartY = globalY;
                    overlayWindow.pointerX = globalX;
                    overlayWindow.pointerY = globalY;
                    manager.pointerGlobalX = globalX;
                    manager.pointerGlobalY = globalY;
                    overlayWindow.initialX = manager.selectionX;
                    overlayWindow.initialY = manager.selectionY;
                    overlayWindow.initialWidth = manager.selectionWidth;
                    overlayWindow.initialHeight = manager.selectionHeight;
                    overlayWindow.interactionMoved = false;
                    const hit = overlayWindow.hitTest(globalX, globalY);
                    overlayWindow.interaction = hit.mode;
                    overlayWindow.resizeHorizontal = hit.horizontal;
                    overlayWindow.resizeVertical = hit.vertical;
                    manager.pointerCursorShape = overlayWindow.cursorAt(globalX, globalY);
                }
                onPositionChanged: mouse => {
                    const globalX = overlayWindow.monitorX + mouse.x;
                    const globalY = overlayWindow.monitorY + mouse.y;
                    if (!pressed) {
                        manager.pointerCursorShape = overlayWindow.cursorAt(globalX, globalY);
                        return;
                    }
                    overlayWindow.updateInteraction(globalX, globalY);
                }
                onReleased: {
                    if (overlayWindow.interaction === "create" && !overlayWindow.interactionMoved) {
                        manager.selectionX = overlayWindow.initialX;
                        manager.selectionY = overlayWindow.initialY;
                        manager.selectionWidth = overlayWindow.initialWidth;
                        manager.selectionHeight = overlayWindow.initialHeight;
                        manager.hasSelection = overlayWindow.initialWidth >= 2 && overlayWindow.initialHeight >= 2;
                    } else if (overlayWindow.interactionMoved) {
                        manager.commitRegion();
                    }
                    overlayWindow.interaction = "idle";
                    overlayWindow.interactionMoved = false;
                    manager.readoutVisible = false;
                    manager.pointerCursorShape = overlayWindow.cursorAt(overlayWindow.pointerX, overlayWindow.pointerY);
                }
                onCanceled: {
                    manager.selectionX = overlayWindow.initialX;
                    manager.selectionY = overlayWindow.initialY;
                    manager.selectionWidth = overlayWindow.initialWidth;
                    manager.selectionHeight = overlayWindow.initialHeight;
                    manager.hasSelection = overlayWindow.initialWidth >= 2 && overlayWindow.initialHeight >= 2;
                    overlayWindow.interaction = "idle";
                    overlayWindow.interactionMoved = false;
                    manager.readoutVisible = false;
                    manager.pointerCursorShape = overlayWindow.cursorAt(overlayWindow.pointerX, overlayWindow.pointerY);
                }
            }

            Rectangle {
                readonly property var targetWindow: manager.hoveredWindow ?? manager.selectedWindow
                visible: manager.selectedMode === "windows" && targetWindow != null
                x: targetWindow != null ? targetWindow.x - overlayWindow.monitorX : 0
                y: targetWindow != null ? targetWindow.y - overlayWindow.monitorY : 0
                width: targetWindow != null ? targetWindow.width : 0
                height: targetWindow != null ? targetWindow.height : 0
                radius: 8 // Matches decoration.rounding in Hyprland's looknfeel.lua.
                color: Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.055)
                border.width: 1
                border.color: Qt.rgba(Colors.primary.r, Colors.primary.g, Colors.primary.b, 0.7)
            }

            // Dim everything outside the selected region while leaving the capture visible.
            Item {
                anchors.fill: parent
                visible: manager.selectedMode === "region"
                clip: true

                readonly property real sx: manager.selectionX - overlayWindow.monitorX
                readonly property real sy: manager.selectionY - overlayWindow.monitorY
                readonly property real sw: manager.selectionWidth
                readonly property real sh: manager.selectionHeight
                readonly property real intersectionLeft: Math.max(0, sx)
                readonly property real intersectionTop: Math.max(0, sy)
                readonly property real intersectionRight: Math.min(width, sx + sw)
                readonly property real intersectionBottom: Math.min(height, sy + sh)
                readonly property bool hasIntersection: manager.hasSelection && intersectionRight > intersectionLeft && intersectionBottom > intersectionTop

                Rectangle {
                    anchors.fill: parent
                    visible: !parent.hasIntersection
                    color: "#66000000"
                }
                Rectangle {
                    x: 0
                    y: 0
                    width: parent.width
                    height: parent.intersectionTop
                    visible: parent.hasIntersection
                    color: "#66000000"
                }
                Rectangle {
                    x: 0
                    y: parent.intersectionTop
                    width: parent.intersectionLeft
                    height: parent.intersectionBottom - y
                    visible: parent.hasIntersection
                    color: "#66000000"
                }
                Rectangle {
                    x: parent.intersectionRight
                    y: parent.intersectionTop
                    width: parent.width - x
                    height: parent.intersectionBottom - y
                    visible: parent.hasIntersection
                    color: "#66000000"
                }
                Rectangle {
                    x: 0
                    y: parent.intersectionBottom
                    width: parent.width
                    height: parent.height - y
                    visible: parent.hasIntersection
                    color: "#66000000"
                }

                Rectangle {
                    x: parent.sx
                    y: parent.sy
                    width: parent.sw
                    height: parent.sh
                    color: "transparent"
                    border.width: manager.hasSelection && parent.sw > 0 ? 2 : 0
                    border.color: Colors.primary
                }

                Repeater {
                    model: manager.hasSelection ? [
                        {
                            x: parent.sx,
                            y: parent.sy
                        },
                        {
                            x: parent.sx + parent.sw / 2,
                            y: parent.sy
                        },
                        {
                            x: parent.sx + parent.sw,
                            y: parent.sy
                        },
                        {
                            x: parent.sx,
                            y: parent.sy + parent.sh / 2
                        },
                        {
                            x: parent.sx + parent.sw,
                            y: parent.sy + parent.sh / 2
                        },
                        {
                            x: parent.sx,
                            y: parent.sy + parent.sh
                        },
                        {
                            x: parent.sx + parent.sw / 2,
                            y: parent.sy + parent.sh
                        },
                        {
                            x: parent.sx + parent.sw,
                            y: parent.sy + parent.sh
                        }
                    ] : []

                    delegate: Rectangle {
                        required property var modelData
                        x: modelData.x - width / 2
                        y: modelData.y - height / 2
                        width: 8
                        height: 8
                        radius: 4
                        color: Colors.primary
                        border.width: 1
                        border.color: Colors.on_primary
                    }
                }

                Rectangle {
                    id: sizeReadout
                    readonly property real localPointerX: manager.pointerGlobalX - overlayWindow.monitorX
                    readonly property real localPointerY: manager.pointerGlobalY - overlayWindow.monitorY
                    readonly property bool clampedOnBothAxes: overlayWindow.labelIsClamped(localPointerX, width, manager.readoutDirectionX, parent.width) && overlayWindow.labelIsClamped(localPointerY, height, manager.readoutDirectionY, parent.height)
                    visible: manager.readoutVisible && manager.readoutMonitor === overlayWindow.modelData.name
                    x: overlayWindow.labelPosition(localPointerX, width, clampedOnBothAxes ? -manager.readoutDirectionX : manager.readoutDirectionX, parent.width)
                    y: overlayWindow.labelPosition(localPointerY, height, clampedOnBothAxes ? -manager.readoutDirectionY : manager.readoutDirectionY, parent.height)
                    width: sizeText.implicitWidth + 16
                    height: sizeText.implicitHeight + 10
                    radius: 6
                    color: Colors.surface_container
                    border.width: 1
                    border.color: Colors.outline_variant

                    Text {
                        id: sizeText
                        anchors.centerIn: parent
                        text: Math.round(manager.selectionWidth) + " × " + Math.round(manager.selectionHeight)
                        color: Colors.on_surface
                        font.pixelSize: 12
                        font.family: Fonts.font
                    }
                }
            }

            Item {
                id: keyHandler
                focus: overlayWindow.visible
                Keys.onEscapePressed: manager.dismiss()
                Keys.onReturnPressed: {
                    if (!manager.countdownActive)
                        manager.capture();
                }
                Keys.onEnterPressed: {
                    if (!manager.countdownActive)
                        manager.capture();
                }
            }

            // Options panel
            Rectangle {
                id: optionsPanel
                visible: overlayWindow.isControlScreen && manager.overlayVisible
                enabled: manager.optionsOpen

                x: Math.max(8, Math.min(parent.width - width - 8, toolbar.x + (toolbar.width - width) / 2))
                y: toolbar.y >= height + 8 ? toolbar.y - height - 8 : Math.min(parent.height - height - 8, toolbar.y + toolbar.height + 8)

                implicitWidth: 248
                implicitHeight: optionsColumn.implicitHeight + 16
                radius: 14
                color: Colors.surface_container
                border.width: 1
                border.color: Colors.outline_variant

                opacity: manager.optionsOpen ? 1.0 : 0.0
                scale: manager.optionsOpen ? 1.0 : 0.95
                transformOrigin: Item.Bottom

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.animations.fast
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: Theme.animations.fast
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {}
                }

                ColumnLayout {
                    id: optionsColumn
                    anchors {
                        top: parent.top
                        left: parent.left
                        right: parent.right
                        margins: 8
                    }
                    spacing: 0

                    Text {
                        text: "Save to"
                        color: Colors.on_surface_variant
                        font.pixelSize: 11
                        font.family: Fonts.font
                        Layout.topMargin: 7
                        Layout.leftMargin: 6
                        Layout.bottomMargin: 3
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: 6
                        color: defaultSaveArea.containsMouse ? Colors.surface_container_high : Colors.surface_container

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6

                            Text {
                                Layout.preferredWidth: 16
                                text: PhosphorIcons.check
                                color: Colors.primary
                                font.pixelSize: 17
                                font.family: Fonts.phosphorFont
                                opacity: manager.saveDirectory === "" ? 1 : 0
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Pictures/Screenshots"
                                color: Colors.on_surface
                                font.pixelSize: 12
                                font.family: Fonts.font
                            }
                        }

                        MouseArea {
                            id: defaultSaveArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: manager.selectSaveDirectory(manager.defaultSaveDirectory)
                        }
                    }

                    Repeater {
                        model: manager.recentSaveLocations

                        delegate: Rectangle {
                            required property string modelData
                            Layout.fillWidth: true
                            implicitHeight: 28
                            radius: 6
                            color: recentSaveArea.containsMouse ? Colors.surface_container_high : Colors.surface_container

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 6
                                anchors.rightMargin: 6

                                Text {
                                    Layout.preferredWidth: 16
                                    text: PhosphorIcons.check
                                    color: Colors.primary
                                    font.pixelSize: 17
                                    font.family: Fonts.phosphorFont
                                    opacity: manager.saveDirectory === modelData ? 1 : 0
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: manager.locationLabel(modelData)
                                    color: Colors.on_surface
                                    font.pixelSize: 12
                                    font.family: Fonts.font
                                    elide: Text.ElideMiddle
                                }
                            }

                            MouseArea {
                                id: recentSaveArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: manager.selectSaveDirectory(modelData)
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: 6
                        color: otherLocationArea.containsMouse ? Colors.surface_container_high : Colors.surface_container

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 28
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Other Location…"
                            color: Colors.primary
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            font.family: Fonts.font
                        }

                        MouseArea {
                            id: otherLocationArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                manager.optionsOpen = false;
                                manager.overlayVisible = false;
                                saveLocationProcess.running = true;
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Colors.outline_variant
                        Layout.topMargin: 4
                        Layout.bottomMargin: 1
                    }

                    Text {
                        text: "Timer"
                        color: Colors.on_surface_variant
                        font.pixelSize: 11
                        font.family: Fonts.font
                        Layout.topMargin: 7
                        Layout.leftMargin: 6
                        Layout.bottomMargin: 3
                    }

                    RowLayout {
                        spacing: 3
                        Layout.fillWidth: true

                        Repeater {
                            model: [
                                {
                                    delay: 0,
                                    label: "None"
                                },
                                {
                                    delay: 3,
                                    label: "3s"
                                },
                                {
                                    delay: 5,
                                    label: "5s"
                                },
                                {
                                    delay: 10,
                                    label: "10s"
                                }
                            ]

                            delegate: Rectangle {
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: 26
                                radius: 6
                                color: manager.timerDelay === modelData.delay ? Colors.surface_container_high : (timerOptArea.containsMouse ? Colors.surface_container_high : "transparent")

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    color: manager.timerDelay === modelData.delay ? Colors.primary : Colors.on_surface_variant
                                    font.pixelSize: 12
                                    font.family: Fonts.font
                                }

                                MouseArea {
                                    id: timerOptArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: manager.setTimerDelay(modelData.delay)
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Colors.outline_variant
                        Layout.topMargin: 4
                        Layout.bottomMargin: 1
                    }

                    Text {
                        text: "Options"
                        color: Colors.on_surface_variant
                        font.pixelSize: 11
                        font.family: Fonts.font
                        Layout.topMargin: 7
                        Layout.leftMargin: 6
                        Layout.bottomMargin: 3
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 30
                        radius: 6
                        color: notificationOptArea.containsMouse ? Colors.surface_container_high : Colors.surface_container

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6

                            Text {
                                Layout.preferredWidth: 16
                                text: PhosphorIcons.check
                                color: Colors.primary
                                font.pixelSize: 18
                                font.family: Fonts.phosphorFont
                                opacity: manager.showNotification ? 1 : 0
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Show Notification"
                                color: Colors.on_surface
                                font.pixelSize: 13
                                font.family: Fonts.font
                            }
                        }

                        MouseArea {
                            id: notificationOptArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                manager.showNotification = !manager.showNotification;
                                if (SettingsService.loaded)
                                    SettingsService.screenshotShowNotification = manager.showNotification;
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 30
                        radius: 6
                        color: rememberSelectionArea.containsMouse ? Colors.surface_container_high : Colors.surface_container

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6

                            Text {
                                Layout.preferredWidth: 16
                                text: PhosphorIcons.check
                                color: Colors.primary
                                font.pixelSize: 18
                                font.family: Fonts.phosphorFont
                                opacity: manager.rememberLastSelection ? 1 : 0
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Remember Last Selection"
                                color: Colors.on_surface
                                font.pixelSize: 13
                                font.family: Fonts.font
                            }
                        }

                        MouseArea {
                            id: rememberSelectionArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                manager.rememberLastSelection = !manager.rememberLastSelection;
                                if (SettingsService.loaded) {
                                    SettingsService.screenshotRememberLastSelection = manager.rememberLastSelection;
                                    if (!manager.rememberLastSelection)
                                        manager.clearAllSavedRegions();
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 30
                        radius: 6
                        color: systemAudioOptArea.containsMouse ? Colors.surface_container_high : Colors.surface_container
                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.animations.fast
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6

                            Text {
                                Layout.preferredWidth: 16
                                text: PhosphorIcons.check
                                color: Colors.primary
                                font.pixelSize: 18
                                font.family: Fonts.phosphorFont
                                opacity: manager.systemAudioEnabled ? 1 : 0
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "System Audio"
                                color: Colors.on_surface
                                font.pixelSize: 13
                                font.family: Fonts.font
                            }
                        }

                        MouseArea {
                            id: systemAudioOptArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                manager.systemAudioEnabled = !manager.systemAudioEnabled;
                                if (SettingsService.loaded)
                                    SettingsService.screenshotSystemAudioEnabled = manager.systemAudioEnabled;
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 30
                        radius: 6
                        color: micOptArea.containsMouse ? Colors.surface_container_high : Colors.surface_container
                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.animations.fast
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6

                            Text {
                                Layout.preferredWidth: 16
                                text: PhosphorIcons.check
                                color: Colors.primary
                                font.pixelSize: 18
                                font.family: Fonts.phosphorFont
                                opacity: manager.micEnabled ? 1 : 0
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Microphone"
                                color: Colors.on_surface
                                font.pixelSize: 13
                                font.family: Fonts.font
                            }
                        }

                        MouseArea {
                            id: micOptArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                manager.micEnabled = !manager.micEnabled;
                                if (SettingsService.loaded)
                                    SettingsService.screenshotMicEnabled = manager.micEnabled;
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: Colors.outline_variant
                        Layout.topMargin: 4
                        Layout.bottomMargin: 1
                    }

                    Text {
                        text: "Capture"
                        color: Colors.on_surface_variant
                        font.pixelSize: 11
                        font.family: Fonts.font
                        Layout.topMargin: 7
                        Layout.leftMargin: 6
                        Layout.bottomMargin: 3
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 30
                        radius: 6
                        color: cursorOptArea.containsMouse ? Colors.surface_container_high : Colors.surface_container

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6

                            Text {
                                Layout.preferredWidth: 16
                                text: PhosphorIcons.check
                                color: Colors.primary
                                font.pixelSize: 18
                                font.family: Fonts.phosphorFont
                                opacity: manager.showCursor ? 1 : 0
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Show Cursor"
                                color: Colors.on_surface
                                font.pixelSize: 13
                                font.family: Fonts.font
                            }
                        }

                        MouseArea {
                            id: cursorOptArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                manager.showCursor = !manager.showCursor;
                                if (SettingsService.loaded)
                                    SettingsService.screenshotShowCursor = manager.showCursor;
                            }
                        }
                    }

                    Item {
                        implicitHeight: 2
                    }
                }
            }

            // Toolbar
            Rectangle {
                id: toolbar
                visible: overlayWindow.isControlScreen && manager.overlayVisible

                implicitWidth: (manager.countdownActive ? countdownRow.implicitWidth : toolbarRow.implicitWidth) + 16
                implicitHeight: 52
                x: manager.toolbarMonitor === manager.controlMonitor && manager.toolbarX >= 0 ? Math.max(0, Math.min(parent.width - width, manager.toolbarX)) : (parent.width - width) / 2
                y: manager.toolbarMonitor === manager.controlMonitor && manager.toolbarY >= 0 ? Math.max(0, Math.min(parent.height - height, manager.toolbarY)) : parent.height - height - 52
                radius: 14
                color: Colors.surface_container
                border.width: 1
                border.color: Colors.outline_variant

                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: Theme.animations.slow
                        easing.type: Easing.OutCubic
                    }
                }

                layer.enabled: true
                layer.effect: null

                MouseArea {
                    anchors.fill: parent
                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                    drag.target: toolbar
                    drag.minimumX: 0
                    drag.maximumX: overlayWindow.width - toolbar.width
                    drag.minimumY: 0
                    drag.maximumY: overlayWindow.height - toolbar.height
                    onReleased: {
                        manager.toolbarMonitor = manager.controlMonitor;
                        manager.toolbarX = toolbar.x;
                        manager.toolbarY = toolbar.y;
                        manager.persistToolbarPosition();
                    }
                }

                RowLayout {
                    id: toolbarRow
                    anchors.centerIn: parent
                    spacing: 1
                    visible: !manager.countdownActive

                    // Close button
                    Item {
                        implicitWidth: 24
                        implicitHeight: 24
                        Layout.rightMargin: 1

                        Text {
                            anchors.centerIn: parent
                            text: PhosphorIcons.xCircle
                            color: Colors.outline
                            font.pixelSize: 20
                            font.family: Fonts.phosphorFill
                        }

                        MouseArea {
                            id: closeArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: manager.dismiss()
                        }
                    }

                    // Screenshot buttons
                    Repeater {
                        model: [
                            {
                                mode: "region",
                                icon: PhosphorIcons.selection
                            },
                            {
                                mode: "windows",
                                icon: PhosphorIcons.appWindow
                            },
                            {
                                mode: "fullscreen",
                                icon: PhosphorIcons.monitor
                            }
                        ]

                        delegate: Rectangle {
                            required property var modelData
                            implicitWidth: 36
                            implicitHeight: 36
                            radius: 8
                            color: manager.selectedMode === modelData.mode || modeArea.containsMouse ? Colors.surface_container_high : Colors.surface_container

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.animations.fast
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                color: manager.selectedMode === modelData.mode ? Colors.primary : Colors.on_surface_variant
                                font.pixelSize: 20
                                font.family: Fonts.phosphorFont
                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.animations.fast
                                    }
                                }
                            }

                            MouseArea {
                                id: modeArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: manager.setSelectedMode(modelData.mode)
                            }
                        }
                    }

                    Rectangle {
                        implicitWidth: 1
                        implicitHeight: 24
                        Layout.alignment: Qt.AlignVCenter
                        color: Colors.outline_variant
                        Layout.leftMargin: 3
                        Layout.rightMargin: 3
                    }

                    // Video button
                    Rectangle {
                        implicitWidth: 36
                        implicitHeight: 36
                        radius: 8
                        color: manager.selectedMode === "video" || videoArea.containsMouse ? Colors.surface_container_high : Colors.surface_container

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.animations.fast
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: PhosphorIcons.videoCamera
                            color: manager.selectedMode === "video" ? Colors.primary : Colors.on_surface_variant
                            font.pixelSize: 20
                            font.family: Fonts.phosphorFont
                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.animations.fast
                                }
                            }
                        }

                        MouseArea {
                            id: videoArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: manager.setSelectedMode("video")
                        }
                    }

                    Rectangle {
                        implicitWidth: 1
                        implicitHeight: 24
                        Layout.alignment: Qt.AlignVCenter
                        color: Colors.outline_variant
                        Layout.leftMargin: 3
                        Layout.rightMargin: 3
                    }

                    // Options text button
                    Rectangle {
                        implicitWidth: optionsLabel.implicitWidth + 16
                        implicitHeight: 36
                        radius: 8
                        color: manager.optionsOpen ? Colors.surface_container_high : (optionsBtn.containsMouse ? Colors.surface_container_high : Colors.surface_container)

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.animations.fast
                            }
                        }

                        Row {
                            id: optionsLabel
                            anchors.centerIn: parent
                            spacing: 4

                            Text {
                                text: "Options"
                                color: Colors.on_surface
                                font.pixelSize: 13
                                font.family: Fonts.font
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: PhosphorIcons.caretDown
                                color: Colors.on_surface_variant
                                font.pixelSize: 14
                                font.family: Fonts.phosphorFont
                                anchors.verticalCenter: parent.verticalCenter

                                rotation: manager.optionsOpen ? 180 : 0
                                Behavior on rotation {
                                    NumberAnimation {
                                        duration: Theme.animations.fast
                                    }
                                }
                            }
                        }

                        MouseArea {
                            id: optionsBtn
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: manager.optionsOpen = !manager.optionsOpen
                        }
                    }

                    // Capture button
                    Rectangle {
                        implicitWidth: captureLabel.implicitWidth + 22
                        implicitHeight: 36
                        radius: 8
                        readonly property bool canCapture: manager.selectedMode === "region" ? manager.hasSelection : manager.selectedMode === "windows" ? manager.selectedWindow != null : true
                        opacity: canCapture ? 1.0 : 0.45
                        color: captureBtn.containsMouse && captureBtn.enabled ? Qt.lighter(Colors.primary, 1.1) : Colors.primary
                        Layout.leftMargin: 3

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.animations.fast
                            }
                        }

                        Text {
                            id: captureLabel
                            anchors.centerIn: parent
                            text: "Capture"
                            color: Colors.on_primary
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            font.family: Fonts.font
                        }

                        MouseArea {
                            id: captureBtn
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: parent.canCapture && !manager.countdownActive
                            cursorShape: Qt.PointingHandCursor
                            onClicked: manager.capture()
                        }
                    }
                }

                RowLayout {
                    id: countdownRow
                    anchors.centerIn: parent
                    spacing: 8
                    visible: manager.countdownActive

                    Rectangle {
                        implicitWidth: cancelCountdownLabel.implicitWidth + 16
                        implicitHeight: 32
                        radius: 7
                        color: cancelCountdownArea.containsMouse ? Colors.surface_container_high : Colors.surface_container

                        Text {
                            id: cancelCountdownLabel
                            anchors.centerIn: parent
                            text: "Cancel"
                            color: Colors.on_surface
                            font.pixelSize: 13
                            font.family: Fonts.font
                        }

                        MouseArea {
                            id: cancelCountdownArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: manager.dismiss()
                        }
                    }

                    Text {
                        text: manager.countdown + "s"
                        color: Colors.on_surface
                        font.pixelSize: 16
                        font.weight: Font.DemiBold
                        font.family: Fonts.font
                        Layout.rightMargin: 6
                    }
                }
            }
        }
    }
}
