import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { readFile } from "node:fs/promises";

export default function (pi: ExtensionAPI) {
  pi.registerCommand("status", {
    description: "Show current NixOS install phase and pending user actions",
    handler: async (_args, ctx) => {
      try {
        const phase = await readFile(`${ctx.cwd}/PHASE.md`, "utf-8");
        // Print as plain text so user can scroll in terminal
        console.log("\n" + "=".repeat(60));
        console.log(phase);
        console.log("=".repeat(60) + "\n");
        ctx.ui.notify("Phase printed to terminal — scroll up to read", "info");
      } catch {
        ctx.ui.notify("No PHASE.md found in cwd", "warning");
      }
    },
  });

  pi.registerCommand("phase", {
    description: "Alias for /status",
    handler: async (_args, ctx) => {
      // Delegate to status command logic by reading the file directly
      try {
        const phase = await readFile(`${ctx.cwd}/PHASE.md`, "utf-8");
        console.log("\n" + "=".repeat(60));
        console.log(phase);
        console.log("=".repeat(60) + "\n");
      } catch {
        ctx.ui.notify("No PHASE.md found", "warning");
      }
    },
  });

  pi.on("session_start", async (_event, ctx) => {
    ctx.ui.setStatus("nixos-install", "Phase: DISK PREP");
  });
}
