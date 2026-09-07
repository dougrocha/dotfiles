import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Constants
import qs.Services

Item {
    id: root

    implicitWidth: weekColumnWidth + gutterWidth + dayCellWidth * 7
    implicitHeight: col.implicitHeight

    property int monthOffset: 0
    property int selectedDay: 0
    property var baseDate: new Date()

    readonly property int weekStart: SettingsService.weekStart
    readonly property int rowCount: cells.length / 7

    readonly property int weekColumnWidth: 26
    readonly property int gutterWidth: 14
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
        monthOffset = 0;
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

    function isoWeek(date) {
        const target = new Date(date.getFullYear(), date.getMonth(), date.getDate());
        target.setDate(target.getDate() + 3 - ((target.getDay() + 6) % 7));

        const firstThursday = new Date(target.getFullYear(), 0, 4);
        firstThursday.setDate(firstThursday.getDate() + 3 - ((firstThursday.getDay() + 6) % 7));

        return 1 + Math.round((target.getTime() - firstThursday.getTime()) / (7 * 86400000));
    }

    readonly property int thursdayColumn: (4 - weekStart + 7) % 7

    function weekNumberForRow(row) {
        const cell = cells[row * 7 + thursdayColumn];
        return cell ? isoWeek(cell.date) : "";
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
        return Qt.formatDate(new Date(displayYear, displayMonth, selectedDay), "dddd, MMMM d yyyy");
    }

    readonly property string selectedDayHoliday: {
        if (selectedDay <= 0)
            return "";
        for (let i = 0; i < cells.length; i++)
            if (cells[i].day === selectedDay)
                return cells[i].holiday;
        return "";
    }

    ColumnLayout {
        id: col
        width: parent.width
        spacing: Theme.space.lg

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: Theme.space.xxs

                Text {
                    text: root.monthName.toUpperCase()
                    color: Theme.text.primary
                    font.family: Theme.font.ui
                    font.pixelSize: Theme.type.display.size
                    font.weight: Font.Medium
                    font.letterSpacing: 2
                }
                Text {
                    text: root.displayYear
                    color: Theme.text.secondary
                    font.family: Theme.font.ui
                    font.pixelSize: Theme.type.body.size
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Row {
                spacing: 0

                Chevron {
                    glyph: "‹"
                    onTriggered: {
                        root.monthOffset--;
                        root.selectedDay = root.monthOffset === 0 ? root.baseDate.getDate() : 0;
                    }
                }
                Chevron {
                    dot: true
                    onTriggered: root.reset()
                }
                Chevron {
                    glyph: "›"
                    onTriggered: {
                        root.monthOffset++;
                        root.selectedDay = root.monthOffset === 0 ? root.baseDate.getDate() : 0;
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Theme.stroke.hairline
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            ColumnLayout {
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: root.weekColumnWidth
                spacing: root.headerGap

                Rectangle {
                    Layout.preferredWidth: root.weekColumnWidth
                    Layout.preferredHeight: root.headerRowHeight
                    radius: Theme.radius.md
                    color: weekStartHover.hovered ? Theme.fill.hover : Theme.withAlpha(Theme.fill.hover, 0)

                    Behavior on color {
                        ColorAnimation {
                            duration: Theme.motion.fast
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: weekStartHover.hovered ? (root.weekStart === 1 ? "SU" : "MO") : "W"
                        color: weekStartHover.hovered ? Theme.accent : Theme.text.tertiary
                        font.family: Theme.font.ui
                        font.pixelSize: Theme.type.caption.size
                        font.letterSpacing: 1
                        font.weight: Font.Medium

                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.motion.fast
                            }
                        }
                    }

                    HoverHandler {
                        id: weekStartHover
                        cursorShape: Qt.PointingHandCursor
                    }
                    TapHandler {
                        onTapped: SettingsService.weekStart = root.weekStart === 1 ? 0 : 1
                    }
                }

                Column {
                    Repeater {
                        model: root.rowCount

                        delegate: Item {
                            required property int index

                            width: root.weekColumnWidth
                            height: root.dayCellHeight

                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                y: Math.round((root.dayPillHeight - height) / 2)
                                text: root.weekNumberForRow(parent.index)
                                color: Theme.text.tertiary
                                font.family: Theme.font.ui
                                font.pixelSize: Theme.type.caption.size
                                font.weight: Font.Normal
                            }
                        }
                    }
                }
            }

            Item {
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: root.gutterWidth
                Layout.preferredHeight: root.headerRowHeight + root.headerGap + root.rowCount * root.dayCellHeight

                Rectangle {
                    x: Math.round((root.gutterWidth - width) / 2)
                    y: root.headerRowHeight + root.headerGap
                    width: 1
                    height: (root.rowCount - 1) * root.dayCellHeight + root.dayPillHeight
                    color: Theme.stroke.hairline
                }
            }

            ColumnLayout {
                id: gridArea

                Layout.fillWidth: true
                spacing: root.headerGap

                Row {
                    Layout.fillWidth: true

                    Repeater {
                        model: root.weekdayLabels
                        delegate: Item {
                            required property string modelData
                            required property int index
                            width: root.dayCellWidth
                            height: root.headerRowHeight
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: root.isWeekendColumn(index) ? Theme.text.tertiary : Theme.text.secondary
                                font.family: Theme.font.ui
                                font.pixelSize: Theme.type.caption.size
                                font.letterSpacing: 1
                                font.weight: Font.Medium
                            }
                        }
                    }
                }

                Grid {
                    columns: 7
                    rowSpacing: 0
                    columnSpacing: 0
                    Layout.fillWidth: true

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

                            Item {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.top: parent.top
                                width: root.dayPillWidth
                                height: root.dayPillHeight

                                Rectangle {
                                    anchors.fill: parent
                                    radius: Theme.radius.md
                                    color: Theme.fill.selectedSolid
                                    visible: dayCell.isToday
                                    antialiasing: true
                                }
                                Rectangle {
                                    anchors.fill: parent
                                    radius: Theme.radius.md
                                    color: Theme.fill.hover
                                    visible: dayMouse.containsMouse && !dayCell.isToday && dayCell.isCurrentMonth
                                    antialiasing: true
                                }
                                Rectangle {
                                    anchors.fill: parent
                                    radius: Theme.radius.md
                                    color: "transparent"
                                    border.color: Theme.fill.selectedSolid
                                    border.width: 1
                                    visible: dayCell.isSelected && !dayCell.isToday
                                    antialiasing: true
                                }
                                Text {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.verticalCenterOffset: -2
                                    text: dayCell.modelData.day === 0 ? "" : dayCell.modelData.day
                                    color: {
                                        if (dayCell.isToday)
                                            return Theme.accentText;
                                        if (!dayCell.isCurrentMonth)
                                            return Theme.text.tertiary;
                                        if (dayCell.isWeekend || dayCell.isHoliday)
                                            return Theme.text.tertiary;
                                        return Theme.text.primary;
                                    }
                                    opacity: dayCell.isCurrentMonth ? 1.0 : 0.35
                                    font.family: Theme.font.ui
                                    font.pixelSize: Theme.type.body.size
                                    font.weight: dayCell.isToday ? Font.Medium : Font.Normal
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

                            MouseArea {
                                id: dayMouse
                                anchors.fill: parent
                                hoverEnabled: dayCell.isCurrentMonth
                                enabled: dayCell.isCurrentMonth
                                cursorShape: dayCell.isCurrentMonth ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: root.selectedDay = dayCell.modelData.day
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
            spacing: Theme.space.md

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.motion.normal
                    easing.type: Theme.motion.easeStandard
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.stroke.hairline
            }

            Text {
                Layout.fillWidth: true
                text: root.selectedDayDetail.toUpperCase()
                color: Theme.text.secondary
                font.family: Theme.font.ui
                font.pixelSize: Theme.type.body.size
                font.letterSpacing: 1
            }

            Text {
                Layout.fillWidth: true
                visible: root.selectedDayHoliday.length > 0
                text: root.selectedDayHoliday.toUpperCase()
                color: Theme.accent
                font.family: Theme.font.ui
                font.pixelSize: Theme.type.body.size
                font.letterSpacing: 1
                font.weight: Font.Medium
            }
        }
    }

    component Chevron: Item {
        id: chev

        property string glyph
        property bool dot: false
        property int dotSize: 6
        property int dotOffset: 1
        readonly property color tint: chevHover.hovered ? Theme.accent : Theme.text.primary
        signal triggered

        width: 24
        height: 24

        Text {
            anchors.fill: parent
            visible: !chev.dot
            text: chev.glyph
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: chev.tint
            font.family: Theme.font.ui
            font.pixelSize: Theme.type.display.size
            Behavior on color {
                ColorAnimation {
                    duration: Theme.motion.fast
                }
            }
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: chev.dotOffset
            visible: chev.dot
            width: chev.dotSize
            height: chev.dotSize
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
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: chev.triggered()
        }
    }
}
