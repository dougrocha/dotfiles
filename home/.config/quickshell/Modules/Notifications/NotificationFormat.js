.pragma library

function relativeTime(timestamp) {
    const mins = Math.floor((Date.now() - timestamp) / 60000);
    if (mins < 1)
        return "now";
    if (mins < 60)
        return mins + "m";
    const hours = Math.floor(mins / 60);
    if (hours < 24)
        return hours + "h";
    return Math.floor(hours / 24) + "d";
}

function shortUrl(url) {
    const match = url.match(/^[a-z]+:\/\/(?:www\.)?([^\/?#]+)([^?#]*)/i);
    if (!match)
        return url;
    const path = match[2].replace(/\/$/, "");
    return match[1] + (path.length > 24 ? path.slice(0, 23) + "…" : path);
}

function styledBody(text, linkColor) {
    const anchors = [];
    const linked = text.replace(/<a\s[^>]*>.*?<\/a>|<[^>]+>/gi, tag => {
        anchors.push(tag);
        return "\u0000" + (anchors.length - 1) + "\u0000";
    }).replace(/\bhttps?:\/\/[^\s<>"']*[^\s<>"'.,;:!?)\]]/gi, url => `<a href="${url}">${shortUrl(url)}</a>`).replace(/\u0000(\d+)\u0000/g, (_, index) => anchors[index]);
    return linked.replace(/<a\s+href="([^"]*)"[^>]*>(.*?)<\/a>/gi, `<a href="$1"><font color="${linkColor}">$2</font></a>`);
}

function openBodyLink(link) {
    const scheme = String(link).split(":", 1)[0].toLowerCase();
    if (scheme === "http" || scheme === "https" || scheme === "mailto")
        Qt.openUrlExternally(link);
}
