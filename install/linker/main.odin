// link -- symlinks dotfiles into $HOME, driven by install/links.
//
// The manifest is an allow list. An entry links as-is, so a directory becomes
// one symlink; a trailing "/*" links each child instead. See install/links.
package main

import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"

Platform :: enum {
	Linux,
	Darwin,
}

Platforms :: bit_set[Platform]

ALL :: Platforms{.Linux, .Darwin}

Entry :: struct {
	rel:       string, // path under the source root, e.g. ".config/nvim"
	children:  bool, // written with a trailing "/*"
	platforms: Platforms,
}

Options :: struct {
	manifest: string,
	root:     string,
	target:   string,
	platform: Platform,
	prune:    bool,
	dry_run:  bool,
	force:    bool,
}

Stats :: struct {
	linked:    int,
	unchanged: int,
	replaced:  int,
	pruned:    int,
	skipped:   int,
	errors:    int,
}

opts: Options
stats: Stats

USAGE :: `link -- deploy dotfiles as symlinks

usage: link [options]

options:
  -m, --manifest PATH   manifest to read (default: <dotfiles>/install/links)
  -s, --source PATH     source root (default: <dotfiles>/home)
  -t, --target PATH     destination root (default: $HOME)
  -p, --platform NAME   force "linux" or "darwin" instead of detecting
  -P, --prune           remove symlinks into the repo that are no longer listed
  -n, --dry-run         report what would change without touching anything
  -f, --force           move a conflicting real file aside to <name>.bak
  -h, --help            show this message

<dotfiles> comes from $DOTFILES_DIR, or the grandparent of this executable.`

main :: proc() {
	if !parse_args() do os.exit(2)

	entries, ok := parse_manifest(opts.manifest)
	if !ok do os.exit(1)

	// Every path the manifest could manage on any platform, so that prune can
	// still clean a Linux-only entry off a Mac.
	universe: map[string]bool
	wanted: map[string]bool
	defer delete(universe)
	defer delete(wanted)

	for e in entries {
		active := opts.platform in e.platforms
		for rel in expand(e) {
			universe[rel] = true
			if active do wanted[rel] = true
		}
	}

	for e in entries {
		if opts.platform not_in e.platforms do continue
		apply(e)
	}

	if opts.prune do prune(universe, wanted)

	report()
	if stats.errors > 0 || stats.skipped > 0 do os.exit(1)
}

// -- arguments ---------------------------------------------------------------

parse_args :: proc() -> bool {
	dotfiles := default_dotfiles_dir()

	opts = Options {
		manifest = join({dotfiles, "install", "links"}),
		root     = join({dotfiles, "home"}),
		target   = os.get_env("HOME", context.allocator),
		platform = host_platform(),
	}

	args := os.args[1:]
	for i := 0; i < len(args); i += 1 {
		arg := args[i]

		// Accepts both "--flag value" and "--flag=value".
		next :: proc(args: []string, i: ^int, flag: string) -> (string, bool) {
			arg := args[i^]
			if eq := strings.index_byte(arg, '='); eq >= 0 {
				return arg[eq + 1:], true
			}
			if i^ + 1 >= len(args) {
				fmt.eprintfln("link: %s needs a value", flag)
				return "", false
			}
			i^ += 1
			return args[i^], true
		}

		name := arg
		if eq := strings.index_byte(arg, '='); eq >= 0 do name = arg[:eq]

		switch name {
		case "-h", "--help":
			fmt.println(USAGE)
			os.exit(0)
		case "-m", "--manifest":
			opts.manifest = next(args, &i, name) or_return
		case "-s", "--source":
			opts.root = next(args, &i, name) or_return
		case "-t", "--target":
			opts.target = next(args, &i, name) or_return
		case "-p", "--platform":
			value := next(args, &i, name) or_return
			switch value {
			case "linux":
				opts.platform = .Linux
			case "darwin", "macos":
				opts.platform = .Darwin
			case:
				fmt.eprintfln("link: unknown platform %q (want linux or darwin)", value)
				return false
			}
		case "-P", "--prune":
			opts.prune = true
		case "-n", "--dry-run":
			opts.dry_run = true
		case "-f", "--force":
			opts.force = true
		case:
			fmt.eprintfln("link: unknown option %q (try --help)", arg)
			return false
		}
	}

	if opts.target == "" {
		fmt.eprintln("link: $HOME is unset and no --target was given")
		return false
	}
	return true
}

host_platform :: proc() -> Platform {
	when ODIN_OS == .Darwin {
		return .Darwin
	} else {
		return .Linux
	}
}

// $DOTFILES_DIR when set, otherwise install/linker/<exe> -> ../..
default_dotfiles_dir :: proc() -> string {
	if dir := os.get_env("DOTFILES_DIR", context.allocator); dir != "" {
		return dir
	}
	exe := os.args[0]
	if abs, err := filepath.abs(exe, context.allocator); err == nil {
		return filepath.dir(filepath.dir(filepath.dir(abs)))
	}
	return "."
}

// -- manifest ----------------------------------------------------------------

parse_manifest :: proc(path: string) -> (entries: [dynamic]Entry, ok: bool) {
	data, err := os.read_entire_file(path, context.allocator)
	if err != nil {
		fmt.eprintfln("link: cannot read manifest %s: %v", path, err)
		return nil, false
	}

	ok = true
	section := ALL

	for raw, index in strings.split_lines(string(data)) {
		line := index + 1

		text := raw
		if hash := strings.index_byte(text, '#'); hash >= 0 do text = text[:hash]
		text = strings.trim_space(text)
		if text == "" do continue

		if strings.has_prefix(text, "[") && strings.has_suffix(text, "]") {
			parsed, valid := parse_section(text[1:len(text) - 1])
			if !valid {
				fmt.eprintfln("%s:%d: unknown section %s", path, line, text)
				ok = false
				continue
			}
			section = parsed
			continue
		}

		if strings.has_prefix(text, "/") {
			fmt.eprintfln("%s:%d: entries are relative to the source root, drop the leading /", path, line)
			ok = false
			continue
		}

		children := strings.has_suffix(text, "/*")
		rel := strings.trim_suffix(text, "/*")
		rel = strings.trim_suffix(rel, "/")
		if rel == "" {
			fmt.eprintfln("%s:%d: empty entry", path, line)
			ok = false
			continue
		}

		append(&entries, Entry{rel = rel, children = children, platforms = section})
	}

	return entries, ok
}

parse_section :: proc(body: string) -> (Platforms, bool) {
	result: Platforms
	for part in strings.split(body, ",") {
		switch strings.trim_space(part) {
		case "all":
			result |= ALL
		case "linux":
			result |= {.Linux}
		case "darwin", "macos":
			result |= {.Darwin}
		case:
			return {}, false
		}
	}
	return result, result != {}
}

// The target-relative paths an entry resolves to: itself, or its children.
expand :: proc(e: Entry) -> []string {
	if !e.children {
		out := make([]string, 1)
		out[0] = e.rel
		return out
	}

	src := join({opts.root, e.rel})
	names, ok := dir_names(src)
	if !ok do return nil

	out := make([dynamic]string, 0, len(names))
	for name in names {
		append(&out, join({e.rel, name}))
	}
	return out[:]
}

// -- linking -----------------------------------------------------------------

apply :: proc(e: Entry) {
	src := join({opts.root, e.rel})

	if !path_exists(src) {
		fmt.eprintfln("link: %s is listed but missing from %s", e.rel, opts.root)
		stats.errors += 1
		return
	}

	if !e.children {
		link_one(src, join({opts.target, e.rel}))
		return
	}

	// "/*": the directory stays real so other tools can write into it.
	dst_dir := join({opts.target, e.rel})
	if !ensure_dir(dst_dir) do return

	names, ok := dir_names(src)
	if !ok {
		fmt.eprintfln("link: cannot read %s", src)
		stats.errors += 1
		return
	}
	for name in names {
		link_one(join({src, name}), join({dst_dir, name}))
	}
}

link_one :: proc(src, dst: string) {
	info, err := os.lstat(dst, context.allocator)

	if err == nil {
		defer os.file_info_delete(info, context.allocator)

		if info.type == .Symlink {
			current, rerr := os.read_link(dst, context.allocator)
			if rerr == nil {
				if resolve(dst, current) == src {
					stats.unchanged += 1
					return
				}
				// Someone else's link needs --force.
				if is_within(resolve(dst, current), opts.root) {
					if !remove_path(dst) do return
					if create(src, dst) do stats.replaced += 1
					return
				}
			}
		}

		// These two lose nothing, so they do not need --force.
		if info.type == .Directory && is_reclaimable_dir(dst) {
			fmt.printfln("  reclaim %s (contents are already links into the repo)", display(dst))
			if !remove_tree(dst) do return
			if create(src, dst) do stats.replaced += 1
			return
		}

		if info.type == .Regular && same_contents(src, dst) {
			if !remove_path(dst) do return
			if create(src, dst) do stats.replaced += 1
			return
		}

		if !opts.force {
			fmt.eprintfln("link: %s already exists and is not ours (use --force)", display(dst))
			stats.skipped += 1
			return
		}

		backup := strings.concatenate({dst, ".bak"})
		if opts.dry_run {
			fmt.printfln("  would back up %s -> %s", display(dst), display(backup))
		} else if rerr := os.rename(dst, backup); rerr != nil {
			fmt.eprintfln("link: cannot back up %s: %v", display(dst), rerr)
			stats.errors += 1
			return
		} else {
			fmt.printfln("  backed up %s -> %s", display(dst), display(backup))
		}
		if create(src, dst) do stats.replaced += 1
		return
	}

	if !ensure_dir(filepath.dir(dst)) do return
	if create(src, dst) do stats.linked += 1
}

create :: proc(src, dst: string) -> bool {
	if opts.dry_run {
		fmt.printfln("  link %s -> %s", display(dst), src)
		return true
	}
	if err := os.symlink(src, dst); err != nil {
		fmt.eprintfln("link: cannot link %s: %v", display(dst), err)
		stats.errors += 1
		return false
	}
	fmt.printfln("  link %s -> %s", display(dst), src)
	return true
}

// -- prune -------------------------------------------------------------------

// Remove links into the repo that the manifest no longer claims.
prune :: proc(universe, wanted: map[string]bool) {
	dirs: map[string]bool
	defer delete(dirs)

	for rel in universe {
		dirs[filepath.dir(join({opts.target, rel}))] = true
	}

	for dir in dirs {
		names, ok := dir_names(dir)
		if !ok do continue

		for name in names {
			path := join({dir, name})

			info, err := os.lstat(path, context.allocator)
			if err != nil do continue
			defer os.file_info_delete(info, context.allocator)

			// Ours only if it is a link into the repo, or a tree of them.
			tree := false
			switch info.type {
			case .Symlink:
				current, rerr := os.read_link(path, context.allocator)
				if rerr != nil do continue
				if !is_within(resolve(path, current), opts.root) do continue
			case .Directory:
				// ~/.config/ghostty and ~/.local are structure, not units we own.
				if contains_managed_path(universe, opts.target, path) do continue
				if !is_prunable_dir(path) do continue
				tree = true
			case .Regular, .Undetermined, .Named_Pipe, .Socket, .Character_Device, .Block_Device:
				continue
			}

			rel, relerr := filepath.rel(opts.target, path, context.allocator)
			if relerr != nil do continue
			if wanted[rel] do continue

			removed := tree ? remove_tree(path) : remove_path(path)
			if removed {
				fmt.printfln("  %s %s", opts.dry_run ? "would prune" : "pruned", display(path))
				stats.pruned += 1
			}
		}
	}
}

// -- helpers -----------------------------------------------------------------

// filepath.join and filepath.clean return an allocator error that cannot fail here.
join :: proc(elems: []string) -> string {
	joined, _ := filepath.join(elems, context.allocator)
	return joined
}

clean :: proc(path: string) -> string {
	cleaned, _ := filepath.clean(path, context.allocator)
	return cleaned
}

is_within :: proc(path, root: string) -> bool {
	prefix := strings.concatenate({strings.trim_suffix(clean(root), "/"), "/"})
	defer delete(prefix)
	return strings.has_prefix(clean(path), prefix)
}

// A symlink's stored value, made absolute relative to the link's own directory.
resolve :: proc(link, value: string) -> string {
	if filepath.is_abs(value) do return clean(value)
	return clean(join({filepath.dir(link), value}))
}

dir_names :: proc(path: string) -> ([]string, bool) {
	f, err := os.open(path)
	if err != nil do return nil, false
	defer os.close(f)

	infos, rerr := os.read_directory(f, -1, context.allocator)
	if rerr != nil do return nil, false

	out := make([dynamic]string, 0, len(infos))
	for info in infos {
		append(&out, strings.clone(info.name))
	}
	os.file_info_slice_delete(infos, context.allocator)
	return out[:], true
}

ensure_dir :: proc(path: string) -> bool {
	if is_dir(path) do return true
	if opts.dry_run do return true
	if err := os.make_directory_all(path); err != nil {
		fmt.eprintfln("link: cannot create %s: %v", display(path), err)
		stats.errors += 1
		return false
	}
	return true
}

// Finds Stow residue: a tree whose every file is a symlink into the source
// root, left behind when the destination directory already existed.
//
// `links` counts them, because "every file is ours" is vacuously true of a
// tree with no files -- ~/.gem full of empty subdirectories would match.
scan_reclaimable :: proc(path: string) -> (ok: bool, links: int) {
	names, read := dir_names(path)
	if !read do return false, 0

	for name in names {
		child := join({path, name})

		info, err := os.lstat(child, context.allocator)
		if err != nil do return false, 0
		defer os.file_info_delete(info, context.allocator)

		switch info.type {
		case .Symlink:
			value, rerr := os.read_link(child, context.allocator)
			if rerr != nil do return false, 0
			if !is_within(resolve(child, value), opts.root) do return false, 0
			links += 1
		case .Directory:
			nested, found := scan_reclaimable(child)
			if !nested do return false, 0
			links += found
		case .Regular, .Undetermined, .Named_Pipe, .Socket, .Character_Device, .Block_Device:
			return false, 0
		}
	}
	return true, links
}

// True when any manifest entry, on any platform, lives underneath `dir`.
contains_managed_path :: proc(universe: map[string]bool, target, dir: string) -> bool {
	rel, err := filepath.rel(target, dir, context.allocator)
	if err != nil do return true // cannot place it, so do not touch it

	prefix := strings.concatenate({rel, "/"})
	defer delete(prefix)

	for managed in universe {
		if strings.has_prefix(managed, prefix) do return true
	}
	return false
}

// A destination we want anyway. An empty directory is fine to replace.
is_reclaimable_dir :: proc(path: string) -> bool {
	ok, _ := scan_reclaimable(path)
	return ok
}

// Deleting an unlisted path is a stronger claim: prove we created it.
is_prunable_dir :: proc(path: string) -> bool {
	ok, links := scan_reclaimable(path)
	return ok && links > 0
}

same_contents :: proc(a, b: string) -> bool {
	da, aerr := os.read_entire_file(a, context.allocator)
	if aerr != nil do return false
	defer delete(da)

	db, berr := os.read_entire_file(b, context.allocator)
	if berr != nil do return false
	defer delete(db)

	return string(da) == string(db)
}

remove_tree :: proc(path: string) -> bool {
	if opts.dry_run do return true
	if err := os.remove_all(path); err != nil {
		fmt.eprintfln("link: cannot replace %s: %v", display(path), err)
		stats.errors += 1
		return false
	}
	return true
}

remove_path :: proc(path: string) -> bool {
	if opts.dry_run do return true
	if err := os.remove(path); err != nil {
		fmt.eprintfln("link: cannot remove %s: %v", display(path), err)
		stats.errors += 1
		return false
	}
	return true
}

// os.exists follows symlinks, so it calls a dangling link absent.
path_exists :: proc(path: string) -> bool {
	info, err := os.lstat(path, context.allocator)
	if err != nil do return false
	os.file_info_delete(info, context.allocator)
	return true
}

is_dir :: proc(path: string) -> bool {
	info, err := os.stat(path, context.allocator)
	if err != nil do return false
	defer os.file_info_delete(info, context.allocator)
	return info.type == .Directory
}

display :: proc(path: string) -> string {
	if strings.has_prefix(path, opts.target) {
		return strings.concatenate({"~", path[len(opts.target):]})
	}
	return path
}

report :: proc() {
	prefix := opts.dry_run ? "dry run:" : "done:"
	fmt.printf("%s %d linked, %d unchanged", prefix, stats.linked, stats.unchanged)
	if stats.replaced > 0 do fmt.printf(", %d replaced", stats.replaced)
	if stats.pruned > 0 do fmt.printf(", %d pruned", stats.pruned)
	if stats.skipped > 0 do fmt.printf(", %d skipped", stats.skipped)
	if stats.errors > 0 do fmt.printf(", %d failed", stats.errors)
	fmt.println()
}
