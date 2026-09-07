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
    readonly property string toolbarHostMonitor: Theme.primaryScreen?.name ?? ""
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
    property string readoutEdgeAxis: "none"
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
    readonly property var desktopGeometry: calculateDesktopGeometry()

    function calculateDesktopGeometry(): var {
        const monitors = Hyprland.monitors.values;
        if (monitors.length === 0)
            return {
                left: 0,
                top: 0,
                right: 0,
                bottom: 0,
                width: 0,
                height: 0
            };

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
            bottom: bottom,
            width: right - left,
            height: bottom - top
        };
    }

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

    function isValidSavedToolbarPosition(pos): bool {
        return pos != null && Number.isFinite(pos.x) && Number.isFinite(pos.y) && pos.x >= 0 && pos.y >= 0;
    }

    function isValidSavedRegion(region, monitor): bool {
        if (region == null || monitor == null)
            return false;
        if (!Number.isFinite(region.x) || !Number.isFinite(region.y) || !Number.isFinite(region.width) || !Number.isFinite(region.height))
            return false;
        if (region.width < 2 || region.height < 2 || region.x < 0 || region.y < 0)
            return false;
        return region.x + region.width <= monitor.width && region.y + region.height <= monitor.height;
    }

    function selectionContainedByMonitor(monitor): bool {
        return hasSelection && selectionWidth >= 2 && selectionHeight >= 2 && selectionX >= monitor.x && selectionY >= monitor.y && selectionX + selectionWidth <= monitor.x + monitor.width && selectionY + selectionHeight <= monitor.y + monitor.height;
    }

    function restoreOverlayState() {
        toolbarMonitor = "";
        toolbarX = -1;
        toolbarY = -1;
        if (!SettingsService.loaded)
            return;

        const toolbarSaved = monitorEntry(toolbarHostMonitor)?.toolbar;
        if (isValidSavedToolbarPosition(toolbarSaved)) {
            toolbarMonitor = toolbarHostMonitor;
            toolbarX = toolbarSaved.x;
            toolbarY = toolbarSaved.y;
        }

        if (controlMonitor === "")
            return;
        const entry = monitorEntry(controlMonitor);
        if (entry == null)
            return;
        const monitor = Hyprland.monitors.values.find(m => m.name === controlMonitor);
        if (monitor == null)
            return;

        const regionSaved = entry.region;
        if (rememberLastSelection && isValidSavedRegion(regionSaved, monitor)) {
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
        if (selectionContainedByMonitor(monitor)) {
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
        if (!SettingsService.loaded || toolbarHostMonitor === "")
            return;
        const monitors = Object.assign({}, SettingsService.screenshotMonitors);
        const existing = Object.assign({}, monitors[toolbarHostMonitor]);
        existing.toolbar = {
            x: toolbarX,
            y: toolbarY
        };
        monitors[toolbarHostMonitor] = existing;
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
            manager.restoreOverlayState();
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
                manager.restoreOverlayState();
            }
            manager.overlayVisible = !manager.overlayVisible;
        }
    }

    IpcHandler {
        target: "screenshot-toast"

        function notify(path: string): void {
            ScreenshotToastService.show(path);
        }

        function notifyBatch(encodedPaths: string): void {
            ScreenshotToastService.showBatch(encodedPaths.split("|").map(path => decodeURIComponent(path)));
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
        if (!overlayVisible) {
            readoutVisible = false;
        }
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

    function isVisibleMappedToplevel(toplevel): bool {
        const data = toplevel.lastIpcObject;
        return data != null && data.mapped !== false && !data.hidden && toplevel.workspace != null && toplevel.workspace.active;
    }

    function toplevelGeometry(toplevel) {
        const data = toplevel.lastIpcObject;
        return {
            address: toplevel.address,
            x: data.at[0],
            y: data.at[1],
            width: data.size[0],
            height: data.size[1]
        };
    }

    function windowAt(px, py) {
        const candidates = Hyprland.toplevels.values.filter(isVisibleMappedToplevel).sort((a, b) => (a.lastIpcObject.focusHistoryID ?? 9999) - (b.lastIpcObject.focusHistoryID ?? 9999));

        for (let i = 0; i < candidates.length; ++i) {
            const geometry = toplevelGeometry(candidates[i]);
            if (px >= geometry.x && px < geometry.x + geometry.width && py >= geometry.y && py < geometry.y + geometry.height)
                return geometry;
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
        model: manager.overlayVisible ? Quickshell.screens.filter(screen => screen.name !== manager.toolbarHostMonitor) : []

        delegate: PanelWindow {
            id: visualWindow
            required property var modelData
            screen: modelData

            readonly property var monitor: Hyprland.monitorFor(modelData)

            color: "transparent"
            mask: Region {}

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "qs.screenshot_overlay_visuals"
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            WlrLayershell.exclusionMode: ExclusionMode.Ignore

            anchors.top: true
            anchors.bottom: true
            anchors.left: true
            anchors.right: true

            ScreenshotOverlayVisuals {
                anchors.fill: parent
                manager: manager
                monitorName: visualWindow.modelData.name
                monitorX: visualWindow.monitor?.x ?? 0
                monitorY: visualWindow.monitor?.y ?? 0
            }
        }
    }

    Variants {
        model: manager.overlayVisible && Theme.primaryScreen != null ? [Theme.primaryScreen] : []

        delegate: PanelWindow {
            id: overlayWindow
            required property var modelData
            screen: modelData

            readonly property var monitor: Hyprland.monitorFor(modelData)
            readonly property real monitorX: manager.desktopGeometry.left
            readonly property real monitorY: manager.desktopGeometry.top
            readonly property real toolbarHostX: monitor != null ? monitor.x - monitorX : 0
            readonly property real toolbarHostY: monitor != null ? monitor.y - monitorY : 0
            readonly property real toolbarHostWidth: monitor != null ? monitor.width : width
            readonly property real toolbarHostHeight: monitor != null ? monitor.height : height
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

            function isNearEdge(value, edge, hit): bool {
                return Math.abs(value - edge) <= hit;
            }

            function edgeHitDirection(px, py, left, right, top, bottom, hit): var {
                const withinX = px >= left - hit && px <= right + hit;
                const withinY = py >= top - hit && py <= bottom + hit;
                return {
                    horizontal: withinY && isNearEdge(px, left, hit) ? -1 : withinY && isNearEdge(px, right, hit) ? 1 : 0,
                    vertical: withinX && isNearEdge(py, top, hit) ? -1 : withinX && isNearEdge(py, bottom, hit) ? 1 : 0
                };
            }

            function isInsideSelection(px, py, left, right, top, bottom): bool {
                return px > left && px < right && py > top && py < bottom;
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
                const edge = edgeHitDirection(px, py, left, right, top, bottom, hit);

                if (edge.horizontal !== 0 || edge.vertical !== 0)
                    return {
                        mode: "resize",
                        horizontal: edge.horizontal,
                        vertical: edge.vertical
                    };
                if (isInsideSelection(px, py, left, right, top, bottom))
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
                return manager.desktopGeometry;
            }

            function axisReadoutDirection(pointer, resizeSign, initialStart, initialExtent, selectionStart, selectionExtent): int {
                if (resizeSign < 0)
                    return pointer <= initialStart + initialExtent ? -1 : 1;
                if (resizeSign > 0)
                    return pointer >= initialStart ? 1 : -1;
                return pointer < selectionStart + selectionExtent / 2 ? -1 : 1;
            }

            function updateReadoutDirection(px, py) {
                if (interaction === "create") {
                    manager.readoutDirectionX = px < dragStartX ? -1 : 1;
                    manager.readoutDirectionY = py < dragStartY ? -1 : 1;
                    manager.readoutEdgeAxis = "none";
                    return;
                }

                manager.readoutDirectionX = axisReadoutDirection(px, resizeHorizontal, initialX, initialWidth, manager.selectionX, manager.selectionWidth);
                manager.readoutDirectionY = axisReadoutDirection(py, resizeVertical, initialY, initialHeight, manager.selectionY, manager.selectionHeight);

                manager.readoutEdgeAxis = resizeHorizontal !== 0 && resizeVertical === 0 ? "horizontal" : resizeVertical !== 0 && resizeHorizontal === 0 ? "vertical" : "none";
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

            function currentResizeAxes(): var {
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
                return {
                    horizontal: h,
                    vertical: v
                };
            }

            function cursorForResize(horizontal, vertical): int {
                if (horizontal !== 0 && vertical !== 0)
                    return horizontal === vertical ? Qt.SizeFDiagCursor : Qt.SizeBDiagCursor;
                return horizontal !== 0 ? Qt.SizeHorCursor : Qt.SizeVerCursor;
            }

            function cursorForHit(hit): int {
                if (hit.mode === "move")
                    return Qt.SizeAllCursor;
                if (hit.mode !== "resize")
                    return Qt.CrossCursor;
                return cursorForResize(hit.horizontal, hit.vertical);
            }

            function cursorAt(px, py): int {
                if (interaction === "move")
                    return Qt.SizeAllCursor;
                if (interaction === "create")
                    return Qt.CrossCursor;
                if (interaction === "resize") {
                    const axes = currentResizeAxes();
                    return cursorForResize(axes.horizontal, axes.vertical);
                }

                return cursorForHit(hitTest(px, py));
            }

            function applyCreateInteraction(boundedX, boundedY) {
                manager.selectionX = Math.min(dragStartX, boundedX);
                manager.selectionY = Math.min(dragStartY, boundedY);
                manager.selectionWidth = Math.abs(boundedX - dragStartX);
                manager.selectionHeight = Math.abs(boundedY - dragStartY);
                manager.hasSelection = manager.selectionWidth >= 2 && manager.selectionHeight >= 2;
                updateReadoutDirection(boundedX, boundedY);
            }

            function applyMoveInteraction(bounds, dx, dy) {
                manager.selectionX = Math.max(bounds.left, Math.min(bounds.right - initialWidth, initialX + dx));
                manager.selectionY = Math.max(bounds.top, Math.min(bounds.bottom - initialHeight, initialY + dy));
            }

            function applyResizeInteraction(boundedX, boundedY) {
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
                    applyCreateInteraction(boundedX, boundedY);
                    return;
                }
                if (interaction === "move") {
                    applyMoveInteraction(bounds, dx, dy);
                    return;
                }
                applyResizeInteraction(boundedX, boundedY);
            }

            visible: manager.overlayVisible
            color: "transparent"
            implicitWidth: manager.desktopGeometry.width
            implicitHeight: manager.desktopGeometry.height

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
            WlrLayershell.margins.left: monitor != null ? manager.desktopGeometry.left - monitor.x : 0
            WlrLayershell.margins.top: monitor != null ? manager.desktopGeometry.top - monitor.y : 0

            anchors.top: true
            anchors.left: true

            onVisibleChanged: {
                if (visible) {
                    keyHandler.forceActiveFocus();
                }
            }

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
                onEntered: manager.pointerCursorShape = overlayWindow.cursorAt(overlayWindow.monitorX + mouseX, overlayWindow.monitorY + mouseY)
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

            ScreenshotOverlayVisuals {
                x: overlayWindow.toolbarHostX
                y: overlayWindow.toolbarHostY
                width: overlayWindow.toolbarHostWidth
                height: overlayWindow.toolbarHostHeight
                manager: manager
                monitorName: overlayWindow.modelData.name
                monitorX: overlayWindow.monitor?.x ?? 0
                monitorY: overlayWindow.monitor?.y ?? 0
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

            Rectangle {
                id: optionsPanel
                visible: manager.overlayVisible
                enabled: manager.optionsOpen

                x: Math.max(8, Math.min(parent.width - width - 8, toolbar.x + (toolbar.width - width) / 2))
                y: toolbar.y >= height + 8 ? toolbar.y - height - 8 : Math.min(parent.height - height - 8, toolbar.y + toolbar.height + 8)

                implicitWidth: 248
                implicitHeight: optionsColumn.implicitHeight + 16
                radius: Theme.radius.lg
                color: Theme.colors.surface
                border.width: 1
                border.color: Theme.stroke.hairline

                opacity: manager.optionsOpen ? 1.0 : 0.0
                scale: manager.optionsOpen ? 1.0 : 0.95
                transformOrigin: Item.Bottom

                Behavior on opacity {
                    NumberAnimation {
                        duration: Theme.motion.fast
                    }
                }
                Behavior on scale {
                    NumberAnimation {
                        duration: Theme.motion.fast
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
                        color: Theme.text.secondary
                        font.pixelSize: Theme.type.caption.size
                        font.family: Theme.font.ui
                        Layout.topMargin: 7
                        Layout.leftMargin: 6
                        Layout.bottomMargin: 3
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 28
                        radius: Theme.radius.sm
                        color: defaultSaveArea.containsMouse ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6

                            Text {
                                Layout.preferredWidth: 16
                                text: PhosphorIcons.check
                                color: Theme.accent
                                font.pixelSize: Theme.icon.sm
                                font.family: Theme.font.icon
                                opacity: manager.saveDirectory === "" ? 1 : 0
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Pictures/Screenshots"
                                color: Theme.text.primary
                                font.pixelSize: Theme.type.body.size
                                font.family: Theme.font.ui
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
                            radius: Theme.radius.sm
                            color: recentSaveArea.containsMouse ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 6
                                anchors.rightMargin: 6

                                Text {
                                    Layout.preferredWidth: 16
                                    text: PhosphorIcons.check
                                    color: Theme.accent
                                    font.pixelSize: Theme.icon.sm
                                    font.family: Theme.font.icon
                                    opacity: manager.saveDirectory === modelData ? 1 : 0
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: manager.locationLabel(modelData)
                                    color: Theme.text.primary
                                    font.pixelSize: Theme.type.body.size
                                    font.family: Theme.font.ui
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
                        radius: Theme.radius.sm
                        color: otherLocationArea.containsMouse ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 28
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Other Location…"
                            color: Theme.accent
                            font.pixelSize: Theme.type.body.size
                            font.weight: Font.Medium
                            font.family: Theme.font.ui
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
                        color: Theme.stroke.hairline
                        Layout.topMargin: 4
                        Layout.bottomMargin: 1
                    }

                    Text {
                        text: "Timer"
                        color: Theme.text.secondary
                        font.pixelSize: Theme.type.caption.size
                        font.family: Theme.font.ui
                        Layout.topMargin: 7
                        Layout.leftMargin: 6
                        Layout.bottomMargin: 3
                    }

                    RowLayout {
                        spacing: Theme.space.xxs
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
                                radius: Theme.radius.sm
                                color: manager.timerDelay === modelData.delay ? Theme.fill.selected : (timerOptArea.containsMouse ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0))

                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    color: manager.timerDelay === modelData.delay ? Theme.accent : Theme.text.secondary
                                    font.pixelSize: Theme.type.body.size
                                    font.family: Theme.font.ui
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
                        color: Theme.stroke.hairline
                        Layout.topMargin: 4
                        Layout.bottomMargin: 1
                    }

                    Text {
                        text: "Options"
                        color: Theme.text.secondary
                        font.pixelSize: Theme.type.caption.size
                        font.family: Theme.font.ui
                        Layout.topMargin: 7
                        Layout.leftMargin: 6
                        Layout.bottomMargin: 3
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 30
                        radius: Theme.radius.sm
                        color: notificationOptArea.containsMouse ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6

                            Text {
                                Layout.preferredWidth: 16
                                text: PhosphorIcons.check
                                color: Theme.accent
                                font.pixelSize: Theme.icon.md
                                font.family: Theme.font.icon
                                opacity: manager.showNotification ? 1 : 0
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Show Notification"
                                color: Theme.text.primary
                                font.pixelSize: Theme.type.body.size
                                font.family: Theme.font.ui
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
                        radius: Theme.radius.sm
                        color: rememberSelectionArea.containsMouse ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6

                            Text {
                                Layout.preferredWidth: 16
                                text: PhosphorIcons.check
                                color: Theme.accent
                                font.pixelSize: Theme.icon.md
                                font.family: Theme.font.icon
                                opacity: manager.rememberLastSelection ? 1 : 0
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Remember Last Selection"
                                color: Theme.text.primary
                                font.pixelSize: Theme.type.body.size
                                font.family: Theme.font.ui
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
                        radius: Theme.radius.sm
                        color: systemAudioOptArea.containsMouse ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)
                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.motion.fast
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6

                            Text {
                                Layout.preferredWidth: 16
                                text: PhosphorIcons.check
                                color: Theme.accent
                                font.pixelSize: Theme.icon.md
                                font.family: Theme.font.icon
                                opacity: manager.systemAudioEnabled ? 1 : 0
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "System Audio"
                                color: Theme.text.primary
                                font.pixelSize: Theme.type.body.size
                                font.family: Theme.font.ui
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
                        radius: Theme.radius.sm
                        color: micOptArea.containsMouse ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)
                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.motion.fast
                            }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6

                            Text {
                                Layout.preferredWidth: 16
                                text: PhosphorIcons.check
                                color: Theme.accent
                                font.pixelSize: Theme.icon.md
                                font.family: Theme.font.icon
                                opacity: manager.micEnabled ? 1 : 0
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Microphone"
                                color: Theme.text.primary
                                font.pixelSize: Theme.type.body.size
                                font.family: Theme.font.ui
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
                        color: Theme.stroke.hairline
                        Layout.topMargin: 4
                        Layout.bottomMargin: 1
                    }

                    Text {
                        text: "Capture"
                        color: Theme.text.secondary
                        font.pixelSize: Theme.type.caption.size
                        font.family: Theme.font.ui
                        Layout.topMargin: 7
                        Layout.leftMargin: 6
                        Layout.bottomMargin: 3
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 30
                        radius: Theme.radius.sm
                        color: cursorOptArea.containsMouse ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 6

                            Text {
                                Layout.preferredWidth: 16
                                text: PhosphorIcons.check
                                color: Theme.accent
                                font.pixelSize: Theme.icon.md
                                font.family: Theme.font.icon
                                opacity: manager.showCursor ? 1 : 0
                            }
                            Text {
                                Layout.fillWidth: true
                                text: "Show Cursor"
                                color: Theme.text.primary
                                font.pixelSize: Theme.type.body.size
                                font.family: Theme.font.ui
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

            Rectangle {
                id: toolbar
                visible: manager.overlayVisible

                implicitWidth: (manager.countdownActive ? countdownRow.implicitWidth : toolbarRow.implicitWidth) + 16
                implicitHeight: 52
                x: overlayWindow.toolbarHostX + (manager.toolbarMonitor === manager.toolbarHostMonitor && manager.toolbarX >= 0 ? Math.max(0, Math.min(overlayWindow.toolbarHostWidth - width, manager.toolbarX)) : (overlayWindow.toolbarHostWidth - width) / 2)
                y: overlayWindow.toolbarHostY + (manager.toolbarMonitor === manager.toolbarHostMonitor && manager.toolbarY >= 0 ? Math.max(0, Math.min(overlayWindow.toolbarHostHeight - height, manager.toolbarY)) : overlayWindow.toolbarHostHeight - height - 52)
                radius: Theme.radius.lg
                color: Theme.colors.surface
                border.width: 1
                border.color: Theme.stroke.hairline

                Behavior on implicitWidth {
                    NumberAnimation {
                        duration: Theme.motion.slow
                        easing.type: Theme.motion.easeStandard
                    }
                }

                layer.enabled: true
                layer.effect: null

                MouseArea {
                    anchors.fill: parent
                    cursorShape: pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                    drag.target: toolbar
                    drag.minimumX: overlayWindow.toolbarHostX
                    drag.maximumX: overlayWindow.toolbarHostX + overlayWindow.toolbarHostWidth - toolbar.width
                    drag.minimumY: overlayWindow.toolbarHostY
                    drag.maximumY: overlayWindow.toolbarHostY + overlayWindow.toolbarHostHeight - toolbar.height
                    onReleased: {
                        manager.toolbarMonitor = manager.toolbarHostMonitor;
                        manager.toolbarX = toolbar.x - overlayWindow.toolbarHostX;
                        manager.toolbarY = toolbar.y - overlayWindow.toolbarHostY;
                        manager.persistToolbarPosition();
                    }
                }

                RowLayout {
                    id: toolbarRow
                    anchors.centerIn: parent
                    spacing: Theme.space.xxs
                    visible: !manager.countdownActive

                    Item {
                        implicitWidth: 24
                        implicitHeight: 24
                        Layout.rightMargin: 1

                        Text {
                            anchors.centerIn: parent
                            text: PhosphorIcons.xCircle
                            color: Theme.text.tertiary
                            font.pixelSize: Theme.icon.lg
                            font.family: Theme.font.iconFill
                        }

                        MouseArea {
                            id: closeArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: manager.dismiss()
                        }
                    }

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
                            radius: Theme.radius.md
                            color: manager.selectedMode === modelData.mode || modeArea.containsMouse ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.motion.fast
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                color: manager.selectedMode === modelData.mode ? Theme.accent : Theme.text.secondary
                                font.pixelSize: Theme.icon.lg
                                font.family: Theme.font.icon
                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.motion.fast
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
                        color: Theme.stroke.hairline
                        Layout.leftMargin: 3
                        Layout.rightMargin: 3
                    }

                    Rectangle {
                        implicitWidth: 36
                        implicitHeight: 36
                        radius: Theme.radius.md
                        color: manager.selectedMode === "video" || videoArea.containsMouse ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.motion.fast
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: PhosphorIcons.videoCamera
                            color: manager.selectedMode === "video" ? Theme.accent : Theme.text.secondary
                            font.pixelSize: Theme.icon.lg
                            font.family: Theme.font.icon
                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.motion.fast
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
                        color: Theme.stroke.hairline
                        Layout.leftMargin: 3
                        Layout.rightMargin: 3
                    }

                    Rectangle {
                        implicitWidth: optionsLabel.implicitWidth + 16
                        implicitHeight: 36
                        radius: Theme.radius.md
                        color: manager.optionsOpen ? Theme.fill.hover : (optionsBtn.containsMouse ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0))

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.motion.fast
                            }
                        }

                        Row {
                            id: optionsLabel
                            anchors.centerIn: parent
                            spacing: Theme.space.xs

                            Text {
                                text: "Options"
                                color: Theme.text.primary
                                font.pixelSize: Theme.type.body.size
                                font.family: Theme.font.ui
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: PhosphorIcons.caretDown
                                color: Theme.text.secondary
                                font.pixelSize: Theme.icon.xs
                                font.family: Theme.font.icon
                                anchors.verticalCenter: parent.verticalCenter

                                rotation: manager.optionsOpen ? 180 : 0
                                Behavior on rotation {
                                    NumberAnimation {
                                        duration: Theme.motion.fast
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

                    Rectangle {
                        implicitWidth: captureLabel.implicitWidth + 22
                        implicitHeight: 36
                        radius: Theme.radius.md
                        readonly property bool canCapture: manager.selectedMode === "region" ? manager.hasSelection : manager.selectedMode === "windows" ? manager.selectedWindow != null : true
                        opacity: canCapture ? 1.0 : 0.45
                        color: captureBtn.containsMouse && captureBtn.enabled ? Qt.lighter(Theme.accent, 1.1) : Theme.accent
                        Layout.leftMargin: 3

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.motion.fast
                            }
                        }

                        Text {
                            id: captureLabel
                            anchors.centerIn: parent
                            text: "Capture"
                            color: Theme.accentText
                            font.pixelSize: Theme.type.body.size
                            font.weight: Font.Medium
                            font.family: Theme.font.ui
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
                    spacing: Theme.space.md
                    visible: manager.countdownActive

                    Rectangle {
                        implicitWidth: cancelCountdownLabel.implicitWidth + 16
                        implicitHeight: 32
                        radius: Theme.radius.sm
                        color: cancelCountdownArea.containsMouse ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

                        Text {
                            id: cancelCountdownLabel
                            anchors.centerIn: parent
                            text: "Cancel"
                            color: Theme.text.primary
                            font.pixelSize: Theme.type.body.size
                            font.family: Theme.font.ui
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
                        color: Theme.text.primary
                        font.pixelSize: Theme.type.title.size
                        font.weight: Font.Medium
                        font.family: Theme.font.ui
                        Layout.rightMargin: 6
                    }
                }
            }

        }
    }
}
