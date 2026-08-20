import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Constants
import qs.Services

Item {
    id: root

    implicitWidth: 322
    implicitHeight: col.implicitHeight

    property int monthOffset: 0
    property int selectedDay: 0
    property var baseDate: new Date()

    // 1 = Monday, 0 = Sunday.
    readonly property int weekStart: SettingsService.weekStart
    readonly property int weekColumnWidth: 26
    readonly property int rowCount: cells.length / 7

    readonly property var weekdayLabels: {
        const base = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"];
        const labels = [];
        for (let i = 0; i < 7; i++)
            labels.push(base[(root.weekStart + i) % 7]);
        return labels;
    }

    // Colour weekends by weekday, not by position.
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

    // Anonymous Gregorian algorithm — returns a Date for Easter Sunday.
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

    // ISO-8601: anchor on the week's Thursday to handle year boundaries.
    function isoWeek(date) {
        const target = new Date(date.getFullYear(), date.getMonth(), date.getDate());
        target.setDate(target.getDate() + 3 - ((target.getDay() + 6) % 7));

        const firstThursday = new Date(target.getFullYear(), 0, 4);
        firstThursday.setDate(firstThursday.getDate() + 3 - ((firstThursday.getDay() + 6) % 7));

        return 1 + Math.round((target.getTime() - firstThursday.getTime()) / (7 * 86400000));
    }

    // Number a row by its Thursday; a Sunday-start row spans two ISO weeks.
    readonly property int thursdayColumn: (4 - weekStart + 7) % 7

    function weekNumberForRow(row) {
        const cell = cells[row * 7 + thursdayColumn];
        return cell ? isoWeek(cell.date) : "";
    }

    // `today` comes in as an argument so the binding re-runs when reset() refreshes it.
    function buildCells(year, month, today) {
        const cells = [];
        const firstDay = new Date(year, month, 1);
        const offset = (firstDay.getDay() - root.weekStart + 7) % 7;
        const daysInMonth = new Date(year, month + 1, 0).getDate();
        const todayDay = (today.getFullYear() === year && today.getMonth() === month) ? today.getDate() : -1;
        const easter = easterDate(year);

        // Padding cells carry their real date for the week-number column.
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
        spacing: 12

        // Header
        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                spacing: 2

                Text {
                    text: root.monthName.toUpperCase()
                    color: Colors.on_surface
                    font.family: Fonts.font
                    font.pixelSize: Fonts.h4
                    font.weight: Font.DemiBold
                    font.letterSpacing: 2
                }
                Text {
                    text: root.displayYear
                    color: Colors.on_surface_variant
                    font.family: Fonts.font
                    font.pixelSize: Fonts.p
                }
            }

            Item {
                Layout.fillWidth: true
            }

            Row {
                spacing: 8

                Chevron {
                    text: "‹"
                    onTriggered: {
                        root.monthOffset--;
                        root.selectedDay = root.monthOffset === 0 ? root.baseDate.getDate() : 0;
                    }
                }
                Chevron {
                    text: "•"
                    isToday: true
                    font.pixelSize: Fonts.h2
                    onTriggered: root.reset()
                }
                Chevron {
                    text: "›"
                    onTriggered: {
                        root.monthOffset++;
                        root.selectedDay = root.monthOffset === 0 ? root.baseDate.getDate() : 0;
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Colors.outline_variant
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 0

            // ISO week numbers, aligned to the day rows.
            Item {
                Layout.alignment: Qt.AlignTop
                implicitWidth: root.weekColumnWidth
                implicitHeight: weekColumn.implicitHeight

                Column {
                    id: weekColumn
                    spacing: 2

                    // Header doubles as week-start toggle; hovering previews the target day.
                    Item {
                        width: root.weekColumnWidth
                        height: 32

                        Rectangle {
                            anchors.top: parent.top
                            width: root.weekColumnWidth
                            height: 22
                            radius: Theme.blockRadius
                            color: weekStartHover.hovered ? Colors.surface_container_high : "transparent"

                            Behavior on color {
                                ColorAnimation {
                                    duration: Theme.animations.fast
                                }
                            }

                            Text {
                                anchors.centerIn: parent
                                text: weekStartHover.hovered ? (root.weekStart === 1 ? "SU" : "MO") : "W"
                                color: weekStartHover.hovered ? Colors.primary : Colors.outline
                                font.family: Fonts.font
                                font.pixelSize: Fonts.caption
                                font.letterSpacing: 1
                                font.weight: Font.DemiBold

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Theme.animations.fast
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
                    }

                    Repeater {
                        model: root.rowCount

                        delegate: Item {
                            required property int index

                            width: root.weekColumnWidth
                            height: 40

                            Text {
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: -4
                                text: root.weekNumberForRow(parent.index)
                                color: Colors.outline
                                font.family: Fonts.font
                                font.pixelSize: Fonts.caption
                                font.weight: Font.Light
                            }
                        }
                    }
                }

                TextMetrics {
                    id: weekNumberMetrics
                    text: "52"
                    font.family: Fonts.font
                    font.pixelSize: Fonts.caption
                    font.weight: Font.Light
                }

                TextMetrics {
                    id: dayNumberMetrics
                    text: "30"
                    font.family: Fonts.font
                    font.pixelSize: Fonts.p
                    font.weight: Font.Light
                }

                // Centred between the widest week and day numbers.
                Rectangle {
                    readonly property real weekEdge: (root.weekColumnWidth + weekNumberMetrics.width) / 2
                    readonly property real dayEdge: root.weekColumnWidth + (gridArea.width / 7 - dayNumberMetrics.width) / 2

                    x: Math.round((weekEdge + dayEdge) / 2)
                    y: 34
                    width: 1
                    height: weekColumn.implicitHeight - y
                    color: Colors.outline_variant
                }
            }

            ColumnLayout {
                id: gridArea

                Layout.fillWidth: true
                spacing: 12

                // Weekday headers — first column follows the week-start setting
                Row {
                    Layout.fillWidth: true

                    Repeater {
                        model: root.weekdayLabels
                        delegate: Item {
                            required property string modelData
                            required property int index
                            width: gridArea.width / 7
                            height: 22
                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: root.isWeekendColumn(index) ? Colors.tertiary : Colors.on_surface_variant
                                font.family: Fonts.font
                                font.pixelSize: Fonts.small
                                font.letterSpacing: 1
                                opacity: 0.8
                            }
                        }
                    }
                }

                // Day grid
                Grid {
                    columns: 7
                    rowSpacing: 2
                    columnSpacing: 0
                    Layout.fillWidth: true

                    Repeater {
                        model: root.cells
                        delegate: Item {
                            id: dayCell
                            required property var modelData
                            required property int index

                            width: gridArea.width / 7
                            height: 40

                            readonly property bool isCurrentMonth: modelData.day !== 0
                            readonly property bool isToday: modelData.today
                            readonly property bool isWeekend: root.isWeekendColumn(index % 7)
                            readonly property bool isHoliday: modelData.holiday !== ""
                            readonly property bool isSelected: isCurrentMonth && root.selectedDay === modelData.day

                            Rectangle {
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: -4
                                width: 32
                                height: 28
                                radius: Theme.blockRadius
                                color: Colors.primary
                                visible: dayCell.isToday
                                antialiasing: true
                            }
                            Rectangle {
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: -4
                                width: 32
                                height: 28
                                radius: Theme.blockRadius
                                color: Qt.rgba(Colors.on_surface.r, Colors.on_surface.g, Colors.on_surface.b, 0.08)
                                visible: dayMouse.containsMouse && !dayCell.isToday && dayCell.isCurrentMonth
                                antialiasing: true
                            }
                            Rectangle {
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: -4
                                width: 32
                                height: 28
                                radius: Theme.blockRadius
                                color: "transparent"
                                border.color: Colors.primary
                                border.width: 1
                                visible: dayCell.isSelected && !dayCell.isToday
                                antialiasing: true
                            }
                            Text {
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: -4
                                text: modelData.day === 0 ? "" : modelData.day
                                color: {
                                    if (dayCell.isToday)
                                        return Colors.on_primary;
                                    if (!dayCell.isCurrentMonth)
                                        return Colors.outline;
                                    if (dayCell.isWeekend || dayCell.isHoliday)
                                        return Colors.tertiary;
                                    return Colors.on_surface;
                                }
                                opacity: dayCell.isCurrentMonth ? 1.0 : 0.35
                                font.family: Fonts.font
                                font.pixelSize: Fonts.p
                                font.weight: dayCell.isToday ? Font.Medium : Font.Light
                            }
                            Rectangle {
                                width: 4
                                height: 4
                                radius: 2
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 4
                                color: Colors.tertiary
                                visible: dayCell.isHoliday && dayCell.isCurrentMonth
                                antialiasing: true
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

        // Selected day detail
        ColumnLayout {
            Layout.fillWidth: true
            opacity: root.selectedDay > 0 ? 1 : 0
            visible: opacity > 0
            spacing: 8

            Behavior on opacity {
                NumberAnimation {
                    duration: Theme.animations.normal
                    easing.type: Easing.OutCubic
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Colors.outline_variant
            }

            Text {
                Layout.fillWidth: true
                Layout.topMargin: 2
                text: root.selectedDayDetail.toUpperCase()
                color: Colors.on_surface_variant
                font.family: Fonts.font
                font.pixelSize: Fonts.small
                font.letterSpacing: 1
            }

            Text {
                Layout.fillWidth: true
                visible: root.selectedDayHoliday.length > 0
                text: root.selectedDayHoliday.toUpperCase()
                color: Colors.tertiary
                font.family: Fonts.font
                font.pixelSize: Fonts.small
                font.letterSpacing: 1
                font.weight: Font.DemiBold
            }
        }
    }

    // Boxed so the glyph is not the click target.
    component Chevron: Text {
        id: chev
        property bool isToday: false
        width: 28
        height: 28
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: chevHover.hovered ? (isToday ? Colors.primary : Colors.on_surface) : Colors.on_surface_variant
        font.family: Fonts.font
        font.pixelSize: Fonts.h3
        signal triggered
        Behavior on color {
            ColorAnimation {
                duration: Theme.animations.fast
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
