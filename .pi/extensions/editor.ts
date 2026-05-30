import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { readFile, writeFile } from "node:fs/promises";
import { Type } from "typebox";

const SESSION_FILES: { path: string; description: string }[] = [
  { path: "/home/nixos/PHASE.md", description: "Current install phase & pending commands" },
  { path: "/home/nixos/TODO.md", description: "Full task list for this reinstall" },
  { path: "/home/nixos/nixos-config/flake.nix", description: "Top-level flake" },
  { path: "/home/nixos/nixos-config/modules/hosts/laptop/default.nix", description: "Framework host config" },
  { path: "/home/nixos/nixos-config/modules/hosts/laptop/hardware-configuration.nix", description: "Hardware probe" },
  { path: "/home/nixos/nixos-config/modules/system/btrfs-laptop.nix", description: "Btrfs subvolume layout" },
  { path: "/home/nixos/nixos-config/modules/users/stephan.nix", description: "User definition" },
  { path: "/home/nixos/nixos-config/modules/desktop/gnome.nix", description: "GNOME desktop module" },
  { path: "/home/nixos/nixos-config/modules/desktop/niri.nix", description: "Niri compositor module" },
  { path: "/home/nixos/home-manager/flake.nix", description: "Standalone home-manager flake" },
  { path: "/home/nixos/home-manager/home.nix", description: "Main home-manager config" },
];

export default function (pi: ExtensionAPI) {
  pi.registerCommand("editor", {
    description: "Show session file browser, or edit a file inside pi",
    handler: async (args, ctx) => {
      const arg = args.trim();

      // No args → show interactive file browser
      if (!arg) {
        let selected = 0;
        const action = await ctx.ui.custom((_tui, theme, _kb, done) => ({
          handleInput(data: string) {
            if (data === "q" || data === "Q" || data === "\x1b" || data === "\r") {
              done({ type: "close" });
              return;
            }
            if (data === "\x1b[A" || data === "k" || data === "K") {
              selected = Math.max(0, selected - 1);
              _tui.requestRender();
              return;
            }
            if (data === "\x1b[B" || data === "j" || data === "J") {
              selected = Math.min(SESSION_FILES.length - 1, selected + 1);
              _tui.requestRender();
              return;
            }
            if (data === "\r" || data === " ") {
              done({ type: "edit", index: selected });
              return;
            }
          },
          render(width: number) {
            const lines: string[] = [];
            lines.push(theme.fg("accent", " Session Files ".padEnd(width, "─")));
            lines.push("");
            for (let i = 0; i < SESSION_FILES.length; i++) {
              const f = SESSION_FILES[i];
              const isSel = i === selected;
              const prefix = isSel ? "› " : "  ";
              const line = `${prefix}${String(i + 1).padStart(2)}. ${f.path}`;
              lines.push(isSel ? theme.bg("selectedBg", theme.fg("accent", line)) : theme.fg("muted", line));
              lines.push(theme.fg("dim", `     ${f.description}`));
            }
            lines.push("");
            lines.push(theme.fg("dim", "↑↓/j/k move • Enter/Space edit • q/Esc close"));
            return lines;
          },
        }));

        if (!action || action.type !== "edit") return;

        const target = SESSION_FILES[action.index];
        let content: string;
        try {
          content = await readFile(target.path, "utf-8");
        } catch (err: any) {
          ctx.ui.notify(`Cannot read ${target.path}: ${err.message}`, "error");
          return;
        }

        const edited = await ctx.ui.editor(`Edit: ${target.path}`, content);
        if (edited === undefined) {
          ctx.ui.notify("Edit cancelled", "info");
          return;
        }

        if (edited !== content) {
          await writeFile(target.path, edited, "utf-8");
          ctx.ui.notify(`Saved ${target.path}`, "success");
        } else {
          ctx.ui.notify("No changes made", "info");
        }
        return;
      }

      // Number argument
      const num = parseInt(arg, 10);
      if (!isNaN(num) && num >= 1 && num <= SESSION_FILES.length) {
        const target = SESSION_FILES[num - 1];
        let content: string;
        try {
          content = await readFile(target.path, "utf-8");
        } catch (err: any) {
          ctx.ui.notify(`Cannot read ${target.path}: ${err.message}`, "error");
          return;
        }
        const edited = await ctx.ui.editor(`Edit: ${target.path}`, content);
        if (edited !== undefined && edited !== content) {
          await writeFile(target.path, edited, "utf-8");
          ctx.ui.notify(`Saved ${target.path}`, "success");
        }
        return;
      }

      // Path argument
      let content: string;
      try {
        content = await readFile(arg, "utf-8");
      } catch (err: any) {
        ctx.ui.notify(`Cannot read ${arg}: ${err.message}`, "error");
        return;
      }
      const edited = await ctx.ui.editor(`Edit: ${arg}`, content);
      if (edited !== undefined && edited !== content) {
        await writeFile(arg, edited, "utf-8");
        ctx.ui.notify(`Saved ${arg}`, "success");
      }
    },
  });
}
