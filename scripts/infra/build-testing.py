#!/usr/bin/env python3

# Replaces `{{testing}}` in stdin with markdown tables of `source/testing.yml`, one per demo repository.
# Requires the `pyyaml` Python package (`python3-yaml` via apt).

import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent.parent

RENDERERS = {"mobile": ("M", "Mobile"), "forward_plus": ("F", "Forward+")}
MARKS = {"ok": "✅", "performance": "⏱️", "visual": "👁️", "partial": "⚠️", "crash": "❌"}
UNTESTED = "❔"
PLATFORMS = ["linuxbsd", "windows", "macos"]
TARGETS = [f"desktop-{platform}-{backend}" for platform in PLATFORMS for backend in ["wgpu", "dawn"]] + [
    f"web-{platform}-{browser}" for browser in ["chromium", "firefox"] for platform in PLATFORMS
] + ["web-macos-safari"]

testing = yaml.safe_load((ROOT / "source/testing.yml").read_text())
demos = testing["demos"]


def escape(text):
    return text.replace("|", "\\|").replace("\n", " ")


def render_table(projects):
    notes = []
    rows = [
        "| Demo | " + " | ".join(target.replace("-", "<br>") for target in TARGETS) + " |",
        "|---|" + "---|" * len(TARGETS),
    ]
    for demo, runs in projects.items():
        runs = runs or {}
        cells = []
        for target in TARGETS:
            run = runs.get(target) or {}
            parts = []
            for renderer, (letter, label) in RENDERERS.items():
                result = run.get(renderer)
                if result is None or result.get("status") is None:
                    parts.append(f"{letter} {UNTESTED}")
                    continue
                part = f"{letter} {MARKS[result['status']]}"
                if result.get("note"):
                    notes.append(f"{demo} ({target}, {label}): {escape(result['note'])}")
                    part += f"<sup>{len(notes)}</sup>"
                parts.append(part)

            cells.append(" · ".join(parts))

        rows.append(f"| {escape(demo)} | " + " | ".join(cells) + " |")

    footnotes = "\n".join(f"{i}. {note}" for i, note in enumerate(notes, 1))
    return "\n".join(rows) + ("\n\n" + footnotes if footnotes else "")


def render():
    if not demos:
        return "No test results yet."

    sections = [
        "M is Mobile, F is Forward+. "
        f"✅ OK, ⏱️ Performance, 👁️ Visual, ⚠️ Partial, ❌ Crash, {UNTESTED} Needs testing."
    ]
    for repo, projects in demos.items():
        config = ROOT / "source/demos" / f"{repo}.yml"
        if not config.is_file():
            sys.exit(f"Error: {repo} has no source/demos/{repo}.yml")
        url = yaml.safe_load(config.read_text())["url"]
        sections.append(f"### [{repo}]({url})\n\n" + render_table(projects))
    return "\n\n".join(sections)


sys.stdout.write(sys.stdin.read().replace("{{testing}}", render()))
