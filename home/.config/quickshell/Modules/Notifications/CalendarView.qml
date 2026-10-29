pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Components
import qs.Constants
import qs.Services
import "CalendarDates.js" as CalendarDates

Item {
    id: root

    implicitWidth: 280
    implicitHeight: col.implicitHeight

    property int monthOffset: 0
    property int selectedDay: 0
    property var baseDate: new Date()
    property int slideDirection: 0

    readonly property int weekStart: SettingsService.weekStart

    readonly property int dayCellWidth: width > 0 ? Math.floor(width / 7) : 40
    readonly property int dayCellHeight: 34
    readonly property int dayPillWidth: 32
    readonly property int dayPillHeight: 28
    readonly property int dayMarkerWidth: 12
    readonly property int dayMarkerHeight: 2
    readonly property int dayMarkerInset: 3
    readonly property int headerRowHeight: 20
    readonly property int headerGap: Theme.space.md

    readonly property var weekdayLabels: CalendarDates.weekdayLabels(weekStart)

    readonly property var displayDate: new Date(baseDate.getFullYear(), baseDate.getMonth() + monthOffset, 1)
    readonly property int displayYear: displayDate.getFullYear()
    readonly property int displayMonth: displayDate.getMonth()
    readonly property string monthName: Qt.formatDate(displayDate, "MMMM")
    readonly property var cells: CalendarDates.buildCells(displayYear, displayMonth, baseDate, weekStart)

    function reset() {
        baseDate = new Date();
        selectedDay = baseDate.getDate();
        if (monthOffset !== 0)
            slide(-Math.sign(monthOffset));
        monthOffset = 0;
    }

    function shiftMonth(delta: int): void {
        monthOffset += delta;
        selectedDay = monthOffset === 0 ? baseDate.getDate() : 0;
        slide(delta);
    }

    function slide(direction: int): void {
        slideDirection = direction;
        monthSlide.restart();
    }

    readonly property string selectedDayDetail: {
        if (selectedDay <= 0)
            return "";
        return Qt.formatDate(new Date(displayYear, displayMonth, selectedDay), "dddd, MMMM d");
    }

    readonly property string selectedDayRelative: selectedDay > 0 ? CalendarDates.relativeDay(new Date(displayYear, displayMonth, selectedDay), baseDate) : ""

    readonly property string selectedDayHoliday: cells.find(cell => cell.day === selectedDay)?.holiday ?? ""

    ParallelAnimation {
        id: monthSlide
        NumberAnimation {
            target: monthGrid
            property: "x"
            from: root.slideDirection * Theme.space.xl
            to: 0
            duration: Theme.motion.normal
            easing.type: Theme.motion.easeStandard
        }
        NumberAnimation {
            targets: [monthGrid, monthTitle]
            property: "opacity"
            from: 0
            to: 1
            duration: Theme.motion.normal
            easing.type: Theme.motion.easeStandard
        }
    }

    ColumnLayout {
        id: col
        width: parent.width
        spacing: Theme.space.lg

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.space.sm

            Row {
                id: monthTitle
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                spacing: Theme.space.sm

                Text {
                    anchors.baseline: yearLabel.baseline
                    text: root.monthName
                    color: Theme.text.primary
                    font.family: Theme.font.ui
                    font.pixelSize: Theme.type.display.size
                    font.weight: Theme.type.display.weight
                }
                Text {
                    id: yearLabel
                    text: root.displayYear
                    color: Theme.text.tertiary
                    font.family: Theme.font.ui
                    font.pixelSize: Theme.type.display.size
                    font.weight: Theme.type.body.weight
                }
            }

            Row {
                spacing: Theme.space.xxs

                Chevron {
                    glyph: PhosphorIcons.caretLeft
                    onTriggered: root.shiftMonth(-1)
                }
                Chevron {
                    dot: true
                    enabled: root.monthOffset !== 0 || root.selectedDay !== root.baseDate.getDate()
                    onTriggered: root.reset()
                }
                Chevron {
                    glyph: PhosphorIcons.caretRight
                    onTriggered: root.shiftMonth(1)
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: root.headerGap

            Row {
                Layout.fillWidth: true

                Repeater {
                    model: root.weekdayLabels
                    delegate: Text {
                        required property string modelData
                        required property int index
                        width: root.dayCellWidth
                        height: root.headerRowHeight
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        text: modelData
                        color: weekdayHover.hovered ? Theme.text.primary : CalendarDates.isWeekendColumn(root.weekStart, index) ? Theme.text.tertiary : Theme.text.secondary
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.caption.size
                        font.letterSpacing: 1
                        font.weight: Theme.type.label.weight

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.motion.fast
                            }
                        }
                    }
                }

                HoverHandler {
                    id: weekdayHover
                    cursorShape: Qt.PointingHandCursor
                }
                TapHandler {
                    onTapped: SettingsService.weekStart = root.weekStart === 1 ? 0 : 1
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: monthGrid.height
                clip: true

                SizeMotion on Layout.preferredHeight {}

                Grid {
                    id: monthGrid
                    columns: 7
                    rowSpacing: 0
                    columnSpacing: 0

                    Repeater {
                        model: root.cells
                        delegate: Item {
                            id: dayCell
                            required property var modelData
                            required property int index

                            width: root.dayCellWidth
                            height: root.dayCellHeight

                            readonly property bool isCurrentMonth: modelData.day !== 0
                            readonly property bool isToday: modelData.today
                            readonly property bool isWeekend: CalendarDates.isWeekendColumn(root.weekStart, index % 7)
                            readonly property bool isHoliday: modelData.holiday !== ""
                            readonly property bool isSelected: isCurrentMonth && root.selectedDay === modelData.day

                            Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                width: root.dayPillWidth
                                height: root.dayPillHeight
                                radius: Theme.radius.md
                                antialiasing: true
                                color: {
                                    if (dayCell.isToday)
                                        return Theme.accent;
                                    if (dayCell.isSelected)
                                        return Theme.fill.strong;
                                    if (dayHover.hovered && dayCell.isCurrentMonth)
                                        return Theme.fill.hover;
                                    return Theme.withAlpha(Theme.fill.hover, 0);
                                }

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.motion.fast
                                    }
                                }

                                Text {
                                    anchors.centerIn: parent
                                    anchors.verticalCenterOffset: dayCell.isHoliday ? -1 : 0
                                    text: dayCell.isCurrentMonth ? dayCell.modelData.day : ""
                                    color: dayCell.isToday ? Theme.accentText : dayCell.isWeekend ? Theme.text.secondary : Theme.text.primary
                                    font.family: Theme.font.ui
                                    font.pixelSize: Theme.type.body.size
                                    font.weight: dayCell.isToday ? Theme.type.title.weight : Theme.type.body.weight
                                }

                                Rectangle {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: root.dayMarkerInset
                                    width: root.dayMarkerWidth
                                    height: root.dayMarkerHeight
                                    radius: height / 2
                                    color: dayCell.isToday ? Theme.accentText : Theme.accent
                                    visible: dayCell.isHoliday && dayCell.isCurrentMonth
                                    antialiasing: true
                                }
                            }

                            HoverHandler {
                                id: dayHover
                                enabled: dayCell.isCurrentMonth
                                cursorShape: Qt.PointingHandCursor
                            }
                            TapHandler {
                                enabled: dayCell.isCurrentMonth
                                onTapped: root.selectedDay = dayCell.modelData.day
                            }
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.topMargin: -col.spacing
            Layout.preferredHeight: root.selectedDay > 0 ? details.implicitHeight + col.spacing : 0
            clip: true

            SizeMotion on Layout.preferredHeight {}

            ColumnLayout {
                id: details
                y: col.spacing
                width: parent.width
                opacity: root.selectedDay > 0 ? 1 : 0
                spacing: Theme.space.xs

                ContentFade on opacity {}

                transform: Translate {
                    y: (1 - details.opacity) * -Theme.motion.nudge
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: Theme.space.xs
                    spacing: Theme.space.md

                    Text {
                        Layout.fillWidth: true
                        text: root.selectedDayDetail
                        color: Theme.text.primary
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.body.size
                        font.weight: Theme.type.title.weight
                        elide: Text.ElideRight
                    }

                    Text {
                        text: root.selectedDayRelative
                        color: Theme.text.tertiary
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.caption.size
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: root.selectedDayHoliday.length > 0
                    text: root.selectedDayHoliday
                    color: Theme.accent
                    font.family: Theme.font.ui
                    font.pixelSize: Theme.type.caption.size
                    font.weight: Theme.type.label.weight
                }
            }
        }
    }

    component Chevron: Rectangle {
        id: chev

        property string glyph
        property bool dot: false
        readonly property color tint: !chev.enabled ? Theme.text.tertiary : chevHover.hovered ? Theme.text.primary : Theme.text.secondary
        signal triggered

        width: 26
        height: 26
        radius: width / 2
        color: chevHover.hovered && chev.enabled ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

        Behavior on color {
            ColorAnimation {
                duration: Theme.motion.fast
            }
        }

        Text {
            anchors.centerIn: parent
            visible: !chev.dot
            text: chev.glyph
            color: chev.tint
            font.family: Theme.font.icon
            font.pixelSize: Theme.icon.xs

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }
        }

        Rectangle {
            anchors.centerIn: parent
            visible: chev.dot
            width: 6
            height: 6
            radius: width / 2
            color: chev.tint
            antialiasing: true

            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }
        }

        HoverHandler {
            id: chevHover
            cursorShape: chev.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
        TapHandler {
            onTapped: chev.triggered()
        }
    }
}
