pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Components
import qs.Constants
import qs.Services

FloatingWindow {
    id: editor

    title: "Screenshot Markup"
    visible: ScreenshotToastService.editorPath !== ""
    color: Theme.colors.bg

    readonly property int controlSize: 32
    readonly property int toolbarHeight: controlSize + Theme.space.md * 2
    readonly property int canvasPadding: Theme.space.xl
    readonly property bool hasImage: photo.sourceSize.width > 0 && photo.sourceSize.height > 0
    readonly property real initialFit: hasImage ? Math.min(1000 / photo.sourceSize.width, 672 / photo.sourceSize.height, 1) : 1
    readonly property real minimumEditorWidth: Math.ceil(toolbarRow.implicitWidth + Theme.space.md * 2)

    implicitWidth: hasImage ? Math.max(minimumEditorWidth, Math.round(photo.sourceSize.width * initialFit) + canvasPadding * 2) : 1000
    implicitHeight: hasImage ? Math.max(240, Math.round(photo.sourceSize.height * initialFit) + canvasPadding * 2 + toolbarHeight) : 720
    minimumSize: Qt.size(minimumEditorWidth, 240)

    readonly property var tools: [
        {
            name: "Pen",
            glyph: PhosphorIcons.pencilSimple
        },
        {
            name: "Line",
            glyph: PhosphorIcons.lineSegment
        },
        {
            name: "Arrow",
            glyph: PhosphorIcons.arrowUpRight
        },
        {
            name: "Rectangle",
            glyph: PhosphorIcons.rectangle
        },
        {
            name: "Ellipse",
            glyph: PhosphorIcons.circle
        }
    ]

    property string tool: "Pen"
    property color ink: Theme.markupInks[0]
    property var marks: []
    property var draft: null
    property bool saving: false

    property bool statusShown: false
    property bool statusOk: true
    property string statusTitle: ""
    property string statusDetail: ""

    onVisibleChanged: {
        if (!visible && ScreenshotToastService.editorPath !== "")
            ScreenshotToastService.editorPath = "";
    }

    Connections {
        target: ScreenshotToastService
        function onEditorPathChanged() {
            editor.marks = [];
            editor.draft = null;
            editor.statusShown = false;
            markup.requestPaint();
        }
    }

    function point(position) {
        return {
            x: Math.max(0, Math.min(1, position.x / page.width)),
            y: Math.max(0, Math.min(1, position.y / page.height))
        };
    }

    function undo() {
        marks = marks.slice(0, -1);
        markup.requestPaint();
    }

    function close() {
        ScreenshotToastService.editorPath = "";
    }

    function report(ok, title, detail) {
        statusOk = ok;
        statusTitle = title;
        statusDetail = detail;
        statusShown = true;
        statusTimer.restart();
    }

    function exportImage(copy) {
        if (saving || photo.status !== Image.Ready || !hasImage)
            return;
        saving = true;
        const input = ScreenshotToastService.editorPath;
        const output = input.replace(/\.png$/i, "") + "-annotated-" + Date.now() + ".png";
        const fileName = output.split("/").pop();
        if (!page.grabToImage(result => {
            if (result.saveToFile(output)) {
                if (copy)
                    Quickshell.execDetached(["bash", "-c", "wl-copy --type image/png < \"$1\"", "screenshot-markup", output]);
                editor.report(true, copy ? "Saved and copied" : "Saved", fileName);
            } else {
                editor.report(false, "Could not save the image", "Check that " + output.slice(0, output.length - fileName.length) + " is writable.");
            }
            editor.saving = false;
        }, photo.sourceSize)) {
            report(false, "Could not render the image", "Wait for the image to load, then save again.");
            saving = false;
        }
    }

    component ToolButton: Rectangle {
        id: toolButton

        required property string glyph
        property bool selected: false

        signal tapped

        implicitWidth: editor.controlSize
        implicitHeight: editor.controlSize
        radius: Theme.radius.md
        color: selected ? Theme.fill.selected : toolHover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }

        Text {
            anchors.centerIn: parent
            text: toolButton.glyph
            color: !toolButton.enabled ? Theme.text.tertiary : toolButton.selected || toolHover.hovered ? Theme.text.primary : Theme.text.secondary
            font.family: toolButton.selected ? Theme.font.iconFill : Theme.font.icon
            font.pixelSize: Theme.icon.md

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }
        }

        HoverHandler {
            id: toolHover
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: toolButton.tapped()
        }
    }

    component ActionButton: Rectangle {
        id: actionButton

        required property string glyph
        required property string label
        property bool primary: false

        signal tapped

        implicitWidth: actionContent.implicitWidth + Theme.space.lg * 2
        implicitHeight: editor.controlSize
        radius: Theme.radius.md
        color: primary ? Theme.accent : Theme.withAlpha(Theme.fill.hover, 0)

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: actionHover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }
        }

        Row {
            id: actionContent
            anchors.centerIn: parent
            spacing: Theme.space.sm

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: actionButton.glyph
                color: actionButton.primary ? Theme.accentText : Theme.text.secondary
                font.family: Theme.font.icon
                font.pixelSize: Theme.icon.sm
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: actionButton.label
                color: actionButton.primary ? Theme.accentText : Theme.text.primary
                font.family: Theme.font.ui
                font.pixelSize: Theme.type.body.size
                font.weight: Theme.type.title.weight
            }
        }

        HoverHandler {
            id: actionHover
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: actionButton.tapped()
        }
    }

    component ToolbarDivider: Rectangle {
        implicitWidth: 1
        implicitHeight: editor.controlSize - Theme.space.md
        Layout.leftMargin: Theme.space.md
        Layout.rightMargin: Theme.space.md
        color: Theme.stroke.hairline
    }

    Item {
        anchors.fill: parent
        focus: true

        Keys.onPressed: event => {
            if (event.key === Qt.Key_Escape)
                editor.close();
            else if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_Z)
                editor.undo();
            else if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_S)
                editor.exportImage(false);
            else
                return;
            event.accepted = true;
        }

        Rectangle {
            id: toolbar
            anchors.left: parent.left
            anchors.right: parent.right
            height: editor.toolbarHeight
            color: Theme.colors.surface

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1
                color: Theme.stroke.hairline
            }

            RowLayout {
                id: toolbarRow
                anchors.fill: parent
                anchors.leftMargin: Theme.space.md
                anchors.rightMargin: Theme.space.md
                spacing: Theme.space.xxs

                ToolButton {
                    glyph: PhosphorIcons.x
                    onTapped: editor.close()
                }

                ToolbarDivider {}

                Repeater {
                    model: ScriptModel {
                        values: editor.tools
                        objectProp: "name"
                    }
                    delegate: ToolButton {
                        required property var modelData
                        glyph: modelData.glyph
                        selected: editor.tool === modelData.name
                        onTapped: editor.tool = modelData.name
                    }
                }

                ToolbarDivider {}

                Repeater {
                    model: Theme.markupInks
                    delegate: Item {
                        id: swatch

                        required property color modelData
                        readonly property bool selected: Qt.colorEqual(editor.ink, modelData)

                        implicitWidth: ring.width + Theme.space.xs
                        implicitHeight: editor.controlSize

                        Rectangle {
                            id: ring
                            anchors.centerIn: parent
                            width: dot.width + Theme.space.md
                            height: width
                            radius: width / 2
                            color: "transparent"
                            border.width: 2
                            border.color: swatch.selected ? Theme.text.primary : Theme.stroke.strong
                            opacity: swatch.selected || swatchHover.hovered ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: Theme.motion.fast
                                }
                            }
                        }

                        Rectangle {
                            id: dot
                            anchors.centerIn: parent
                            width: Theme.icon.xs
                            height: width
                            radius: width / 2
                            color: swatch.modelData
                            border.width: 1
                            border.color: Theme.stroke.strong
                        }

                        HoverHandler {
                            id: swatchHover
                            cursorShape: Qt.PointingHandCursor
                        }
                        TapHandler {
                            onTapped: editor.ink = swatch.modelData
                        }
                    }
                }

                ToolbarDivider {}

                ToolButton {
                    glyph: PhosphorIcons.arrowCounterClockwise
                    enabled: editor.marks.length > 0 && !editor.saving
                    onTapped: editor.undo()
                }

                Item {
                    Layout.fillWidth: true
                    Layout.minimumWidth: Theme.space.xxl
                }

                ActionButton {
                    glyph: PhosphorIcons.floppyDisk
                    label: "Save"
                    enabled: !editor.saving
                    onTapped: editor.exportImage(false)
                }

                ActionButton {
                    Layout.leftMargin: Theme.space.xs
                    glyph: PhosphorIcons.copy
                    label: "Save & copy"
                    primary: true
                    enabled: !editor.saving
                    onTapped: editor.exportImage(true)
                }
            }
        }

        Item {
            id: canvasArea
            anchors.top: toolbar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip: true

            Rectangle {
                anchors.fill: page
                anchors.margins: -1
                color: "transparent"
                border.width: 1
                border.color: Theme.stroke.hairline
            }

            Item {
                id: page

                readonly property real fit: editor.hasImage ? Math.min(Math.max(1, canvasArea.width - editor.canvasPadding * 2) / photo.sourceSize.width, Math.max(1, canvasArea.height - editor.canvasPadding * 2) / photo.sourceSize.height) : 1

                width: Math.max(1, photo.sourceSize.width * fit)
                height: Math.max(1, photo.sourceSize.height * fit)
                anchors.centerIn: parent

                Image {
                    id: photo
                    anchors.fill: parent
                    source: ScreenshotToastService.editorPath ? ScreenshotToastService.localFileUrl(ScreenshotToastService.editorPath) : ""
                    cache: false
                    fillMode: Image.Stretch
                    asynchronous: false
                }

                Canvas {
                    id: markup
                    anchors.fill: parent
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()
                    onPaint: {
                        const c = getContext("2d");
                        c.clearRect(0, 0, width, height);
                        const all = editor.draft ? editor.marks.concat([editor.draft]) : editor.marks;
                        for (const mark of all) {
                            if (!mark.points.length)
                                continue;
                            const first = mark.points[0];
                            const last = mark.points[mark.points.length - 1];
                            const x = first.x * width, y = first.y * height;
                            const x2 = last.x * width, y2 = last.y * height;
                            c.strokeStyle = mark.color;
                            c.lineWidth = Math.max(2, width / 500);
                            c.lineCap = "round";
                            c.lineJoin = "round";
                            c.beginPath();
                            if (mark.tool === "Rectangle") {
                                c.rect(x, y, x2 - x, y2 - y);
                            } else if (mark.tool === "Ellipse") {
                                c.save();
                                c.translate((x + x2) / 2, (y + y2) / 2);
                                c.scale(Math.max(0.01, Math.abs(x2 - x) / 2), Math.max(0.01, Math.abs(y2 - y) / 2));
                                c.arc(0, 0, 1, 0, Math.PI * 2);
                                c.restore();
                            } else {
                                c.moveTo(x, y);
                                if (mark.tool === "Pen") {
                                    for (const p of mark.points)
                                        c.lineTo(p.x * width, p.y * height);
                                } else {
                                    c.lineTo(x2, y2);
                                    if (mark.tool === "Arrow") {
                                        const angle = Math.atan2(y2 - y, x2 - x), size = Math.max(12, width / 55);
                                        c.moveTo(x2 - size * Math.cos(angle - 0.5), y2 - size * Math.sin(angle - 0.5));
                                        c.lineTo(x2, y2);
                                        c.lineTo(x2 - size * Math.cos(angle + 0.5), y2 - size * Math.sin(angle + 0.5));
                                    }
                                }
                            }
                            c.stroke();
                        }
                    }
                }

                HoverHandler {
                    enabled: drawHandler.enabled
                    cursorShape: Qt.CrossCursor
                }

                DragHandler {
                    id: drawHandler
                    target: null
                    enabled: photo.status === Image.Ready && !editor.saving
                    onActiveChanged: {
                        if (active) {
                            editor.statusShown = false;
                            editor.draft = {
                                tool: editor.tool,
                                color: String(editor.ink),
                                points: [editor.point(centroid.pressPosition), editor.point(centroid.position)]
                            };
                        } else if (editor.draft) {
                            editor.marks = editor.marks.concat([editor.draft]);
                            editor.draft = null;
                        }
                        markup.requestPaint();
                    }
                    onCentroidChanged: {
                        if (!active || !editor.draft)
                            return;
                        const points = editor.draft.points.slice();
                        if (editor.draft.tool === "Pen")
                            points.push(editor.point(centroid.position));
                        else
                            points[1] = editor.point(centroid.position);
                        editor.draft = {
                            tool: editor.draft.tool,
                            color: editor.draft.color,
                            points: points
                        };
                        markup.requestPaint();
                    }
                    onCanceled: {
                        editor.draft = null;
                        markup.requestPaint();
                    }
                }
            }

            Rectangle {
                id: statusHud
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: editor.canvasPadding + Theme.space.md
                width: Math.min(canvasArea.width - Theme.space.xxl * 2, statusRow.implicitWidth + Theme.space.lg * 2)
                height: statusRow.implicitHeight + Theme.space.md * 2
                radius: Theme.radius.lg
                color: Theme.colors.raised
                border.width: 1
                border.color: Theme.stroke.strong
                opacity: editor.statusShown ? 1 : 0
                visible: opacity > 0
                enabled: opacity > 0

                ContentFade on opacity {}

                transform: Translate {
                    y: (1 - statusHud.opacity) * Theme.motion.nudge
                }

                RowLayout {
                    id: statusRow
                    anchors.fill: parent
                    anchors.leftMargin: Theme.space.lg
                    anchors.rightMargin: Theme.space.lg
                    spacing: Theme.space.md

                    Text {
                        text: editor.statusOk ? PhosphorIcons.checkCircle : PhosphorIcons.warningCircle
                        color: editor.statusOk ? Theme.text.primary : Theme.danger
                        font.family: Theme.font.iconFill
                        font.pixelSize: Theme.icon.sm
                    }
                    Text {
                        text: editor.statusTitle
                        color: Theme.text.primary
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.body.size
                        font.weight: Theme.type.title.weight
                    }
                    Text {
                        Layout.fillWidth: true
                        text: editor.statusDetail
                        color: Theme.text.tertiary
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.caption.size
                        elide: Text.ElideMiddle
                    }
                }

                HoverHandler {
                    onHoveredChanged: hovered ? statusTimer.stop() : statusTimer.restart()
                }
                TapHandler {
                    onTapped: editor.statusShown = false
                }
            }

            Timer {
                id: statusTimer
                interval: ScreenshotToastService.duration
                onTriggered: editor.statusShown = false
            }
        }
    }
}
