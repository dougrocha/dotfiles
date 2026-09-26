import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Constants
import qs.Services

Item {
    id: root

    implicitWidth: dayCellWidth * 7
    implicitHeight: col.implicitHeight

    property int monthOffset: 0
    property int selectedDay: 0
    property var baseDate: new Date()
    property int slideDirection: 0

    readonly property int weekStart: SettingsService.weekStart
    readonly property int rowCount: cells.length / 7

    readonly property int dayCellWidth: 40
    readonly property int dayCellHeight: 34
    readonly property int dayPillWidth: 32
    readonly property int dayPillHeight: 28
    readonly property int dayMarkerWidth: 12
    readonly property int dayMarkerHeight: 2
    readonly property int dayMarkerInset: 3
    readonly property int headerRowHeight: 20
    readonly property int headerGap: Theme.space.md

    readonly property var weekdayLabels: {
        const base = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"];
        const labels = [];
        for (let i = 0; i < 7; i++)
            labels.push(base[(root.weekStart + i) % 7]);
        return labels;
    }

    function isWeekendColumn(column) {
        const weekday = (root.weekStart + column) % 7;
        return weekday === 0 || weekday === 6;
    }

    readonly property int displayYear: {
        const d = new Date(baseDate.getFullYear(), baseDate.getMonth() + monthOffset, 1);
        return d.getFullYear();
    }
    readonly property int displayMonth: {
        const d = new Date(baseDate.getFullYear(), baseDate.getMonth() + monthOffset, 1);
        return d.getMonth();
    }
    readonly property string monthName: Qt.formatDate(new Date(displayYear, displayMonth, 1), "MMMM")
    readonly property var cells: buildCells(displayYear, displayMonth, baseDate)

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

    function easterDate(year) {
        const a = year % 19;
        const b = Math.floor(year / 100);
        const c = year % 100;
        const d = Math.floor(b / 4);
        const e = b % 4;
        const f = Math.floor((b + 8) / 25);
        const g = Math.floor((b - f + 1) / 3);
        const h = (19 * a + b - d - g + 15) % 30;
        const i = Math.floor(c / 4);
        const k = c % 4;
        const l = (32 + 2 * e + 2 * i - h - k) % 7;
        const mm = Math.floor((a + 11 * h + 22 * l) / 451);
        const month = Math.floor((h + l - 7 * mm + 114) / 31);
        const day = ((h + l - 7 * mm + 114) % 31) + 1;
        return new Date(year, month - 1, day);
    }

    function nthWeekday(year, month, weekday, n) {
        const first = new Date(year, month, 1);
        const offset = (weekday - first.getDay() + 7) % 7;
        return 1 + offset + (n - 1) * 7;
    }

    function lastWeekday(year, month, weekday) {
        const last = new Date(year, month + 1, 0);
        return last.getDate() - ((last.getDay() - weekday + 7) % 7);
    }

    function usHoliday(year, month, day, easter) {
        if (month === 0 && day === 1)
            return "New Year's Day";
        if (month === 6 && day === 4)
            return "Independence Day";
        if (month === 10 && day === 11)
            return "Veterans Day";
        if (month === 11 && day === 25)
            return "Christmas Day";
        if (year >= 2021 && month === 5 && day === 19)
            return "Juneteenth";
        if (month === 0 && day === nthWeekday(year, 0, 1, 3))
            return "MLK Day";
        if (month === 1 && day === nthWeekday(year, 1, 1, 3))
            return "Presidents' Day";
        if (month === 4 && day === lastWeekday(year, 4, 1))
            return "Memorial Day";
        if (month === 8 && day === nthWeekday(year, 8, 1, 1))
            return "Labor Day";
        if (month === 9 && day === nthWeekday(year, 9, 1, 2))
            return "Columbus Day";
        if (month === 10 && day === nthWeekday(year, 10, 4, 4))
            return "Thanksgiving";
        const offset = Math.round((new Date(year, month, day).getTime() - easter.getTime()) / 86400000);
        if (offset === 0)
            return "Easter Sunday";
        return "";
    }

    function buildCells(year, month, today) {
        const cells = [];
        const firstDay = new Date(year, month, 1);
        const offset = (firstDay.getDay() - root.weekStart + 7) % 7;
        const daysInMonth = new Date(year, month + 1, 0).getDate();
        const todayDay = (today.getFullYear() === year && today.getMonth() === month) ? today.getDate() : -1;
        const easter = easterDate(year);

        for (let i = 0; i < offset; i++)
            cells.push({
                day: 0,
                today: false,
                holiday: "",
                date: new Date(year, month, 1 - (offset - i))
            });
        for (let d = 1; d <= daysInMonth; d++)
            cells.push({
                day: d,
                today: d === todayDay,
                holiday: usHoliday(year, month, d, easter),
                date: new Date(year, month, d)
            });
        while (cells.length % 7 !== 0) {
            const previous = cells[cells.length - 1].date;
            cells.push({
                day: 0,
                today: false,
                holiday: "",
                date: new Date(previous.getFullYear(), previous.getMonth(), previous.getDate() + 1)
            });
        }
        return cells;
    }

    readonly property string selectedDayDetail: {
        if (selectedDay <= 0)
            return "";
        return Qt.formatDate(new Date(displayYear, displayMonth, selectedDay), "dddd, MMMM d");
    }

    readonly property string selectedDayRelative: {
        if (selectedDay <= 0)
            return "";
        const today = new Date(baseDate.getFullYear(), baseDate.getMonth(), baseDate.getDate());
        const days = Math.round((new Date(displayYear, displayMonth, selectedDay).getTime() - today.getTime()) / 86400000);
        if (days === 0)
            return "Today";
        if (days === 1)
            return "Tomorrow";
        if (days === -1)
            return "Yesterday";
        return days > 0 ? "In " + days + " days" : -days + " days ago";
    }

    readonly property string selectedDayHoliday: {
        if (selectedDay <= 0)
            return "";
        for (let i = 0; i < cells.length; i++)
            if (cells[i].day === selectedDay)
                return cells[i].holiday;
        return "";
    }

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

            Item {
                Layout.fillWidth: true
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
                        color: weekdayHover.hovered ? Theme.text.primary : root.isWeekendColumn(index) ? Theme.text.tertiary : Theme.text.secondary
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
                            readonly property bool isWeekend: root.isWeekendColumn(index % 7)
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

        ColumnLayout {
            Layout.fillWidth: true
            opacity: root.selectedDay > 0 ? 1 : 0
            visible: opacity > 0
            spacing: Theme.space.xs

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.motion.normal
                    easing.type: Theme.motion.easeStandard
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                Layout.bottomMargin: Theme.space.sm
                color: Theme.stroke.hairline
            }

            RowLayout {
                Layout.fillWidth: true
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
