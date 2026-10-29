.pragma library

const weekdayNames = ["SU", "MO", "TU", "WE", "TH", "FR", "SA"];
const dayLength = 86400000;

function weekdayLabels(weekStart) {
    const labels = [];
    for (let i = 0; i < 7; i++)
        labels.push(weekdayNames[(weekStart + i) % 7]);
    return labels;
}

function isWeekendColumn(weekStart, column) {
    const weekday = (weekStart + column) % 7;
    return weekday === 0 || weekday === 6;
}

function buildCells(year, month, today, weekStart) {
    const cells = [];
    const firstDay = new Date(year, month, 1);
    const offset = (firstDay.getDay() - weekStart + 7) % 7;
    const daysInMonth = new Date(year, month + 1, 0).getDate();
    const todayDay = (today.getFullYear() === year && today.getMonth() === month) ? today.getDate() : -1;
    const easter = easterDate(year);

    for (let i = 0; i < offset; i++)
        cells.push(blankCell(new Date(year, month, 1 - (offset - i))));
    for (let d = 1; d <= daysInMonth; d++)
        cells.push({
            day: d,
            today: d === todayDay,
            holiday: usHoliday(year, month, d, easter),
            date: new Date(year, month, d)
        });
    while (cells.length % 7 !== 0) {
        const previous = cells[cells.length - 1].date;
        cells.push(blankCell(new Date(previous.getFullYear(), previous.getMonth(), previous.getDate() + 1)));
    }
    return cells;
}

function relativeDay(date, today) {
    const start = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    const days = Math.round((date.getTime() - start.getTime()) / dayLength);
    if (days === 0)
        return "Today";
    if (days === 1)
        return "Tomorrow";
    if (days === -1)
        return "Yesterday";
    return days > 0 ? "In " + days + " days" : -days + " days ago";
}

function blankCell(date) {
    return {
        day: 0,
        today: false,
        holiday: "",
        date: date
    };
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
    return new Date(year, month, day).getTime() === easter.getTime() ? "Easter Sunday" : "";
}
