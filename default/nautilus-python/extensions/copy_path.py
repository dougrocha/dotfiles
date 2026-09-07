import shutil

from gi import require_version

require_version("Nautilus", "4.1")

from gi.repository import GObject, Gio, Nautilus


class CopyPathAction(GObject.GObject, Nautilus.MenuProvider):
    def _clipboard_command(self):
        wl_copy = shutil.which("wl-copy")
        if wl_copy:
            return [wl_copy]

        xclip = shutil.which("xclip")
        if xclip:
            return [xclip, "-selection", "clipboard"]

        return None

    def _selected_paths(self, files):
        paths = []
        for file in files:
            location = file.get_location()
            path = location.get_path() if location else None
            if path and path not in paths:
                paths.append(path)
        return paths

    def _copy_paths(self, _menu, paths):
        command = self._clipboard_command()
        if not command:
            return
        process = Gio.Subprocess.new(command, Gio.SubprocessFlags.STDIN_PIPE)
        process.communicate_utf8("\n".join(paths), None)

    def get_file_items(self, *args):
        files = args[0] if len(args) == 1 else args[1]
        paths = self._selected_paths(files)
        if not paths or not self._clipboard_command():
            return []

        label = "Copy Path" if len(paths) == 1 else "Copy Paths"
        item = Nautilus.MenuItem(
            name="CopyPathNautilus::copy_path",
            label=label,
        )
        item.connect("activate", self._copy_paths, paths)
        return [item]
