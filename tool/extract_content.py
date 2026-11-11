#!/usr/bin/env python3
"""One-off extraction of dialogue from the legacy Kotlin app into JSON content files.

Reads ConversationManager.kt and VoiceManager.kt under legacy/android-native and writes
assets/content/conversations/en/*.json and assets/content/scripts/en.json.

Run from the repository root:  python3 tool/extract_content.py
The output is committed. Re-run only if the Kotlin source changes before it is deleted.
"""
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "legacy/android-native/app/src/main/java/com/example/baobao"
OUT = ROOT / "assets/content"

STRING = r'"((?:[^"\\]|\\.)*)"'
MOODS = ["happy", "okay", "sad", "anxious", "tired", "intervention"]
VOICE_PREFIX = {
    "happy": "h_happy", "okay": "o_okay", "sad": "s_sad",
    "anxious": "x_anxious", "tired": "t_tired", "intervention": "int",
}
NUDGES = {"joke": "joke", "affirmation": "affirmation", "self-care": "selfCare",
          "claw-machine": "clawMachine", "shop": "shop"}
TARGETS = {"return_to_mood": "@end", "show_resources_screen": "@resources"}


def unescape(s: str) -> str:
    return (s.replace('\\"', '"').replace("\\'", "'").replace("\\n", "\n")
            .replace("\\$", "$").replace("\\\\", "\\"))


def block(text: str, start: int) -> str:
    """Return the parenthesised block that opens at text[start] == '('."""
    depth, i, in_str = 0, start, False
    while i < len(text):
        c = text[i]
        if in_str:
            if c == "\\":
                i += 1
            elif c == '"':
                in_str = False
        elif c == '"':
            in_str = True
        elif c == "(":
            depth += 1
        elif c == ")":
            depth -= 1
            if depth == 0:
                return text[start + 1:i]
        i += 1
    raise ValueError("unbalanced parentheses")


def string_list(text: str, name: str) -> list[str]:
    m = re.search(rf"private val {name} = listOf\(", text)
    return [unescape(s) for s in re.findall(STRING, block(text, m.end() - 1))]


def voice_map(text: str, mood: str) -> dict[str, int]:
    m = re.search(rf"private val {mood}NodeToAudioIndex = mapOf\(", text)
    return {k: int(v) for k, v in re.findall(r'"(\w+)" to (\d+)', block(text, m.end() - 1))}


def tree(conv: str, voice: str, mood: str) -> dict:
    m = re.search(rf"private val {mood}Nodes = mapOf\(", conv)
    body = block(conv, m.end() - 1)
    voices = voice_map(voice, mood)
    nodes = {}
    for nm in re.finditer(r"ConversationNode\(", body):
        b = block(body, nm.end() - 1)
        node_id = re.search(rf"id = {STRING}", b).group(1)
        line = unescape(re.search(rf"baobaoLine = {STRING}", b).group(1))
        opts = block(b, re.search(r"userOptions = listOf\(", b).end() - 1)
        options = []
        for text, nxt, effect in re.findall(rf"UserOption\({STRING}, {STRING}, (-?\d+)\)", opts):
            option = {"text": unescape(text), "next": TARGETS.get(nxt, nxt)}
            if int(effect):
                option["moodEffect"] = int(effect)
            options.append(option)
        node = {"line": line, "voice": f"{VOICE_PREFIX[mood]}_{voices[node_id]:02d}"}
        nudge = re.search(rf"featureNudge = {STRING}", b)
        if nudge:
            node["nudge"] = NUDGES[nudge.group(1)]
        if re.search(r"isLoopPoint = true", b):
            node["closing"] = True
        node["options"] = options
        nodes[node_id] = node
    return {"id": mood, "start": f"{mood}_start", "nodes": nodes}


def pool(conv: str, name: str, prefix: str) -> list[dict]:
    return [{"text": t, "voice": f"{prefix}_{i:02d}"}
            for i, t in enumerate(string_list(conv, name), start=1)]


def main() -> None:
    conv = (SRC / "conversation/ConversationManager.kt").read_text(encoding="utf-8")
    voice = (SRC / "audio/VoiceManager.kt").read_text(encoding="utf-8")

    out = OUT / "conversations/en"
    out.mkdir(parents=True, exist_ok=True)
    total = 0
    for mood in MOODS:
        t = tree(conv, voice, mood)
        total += len(t["nodes"])
        (out / f"{mood}.json").write_text(
            json.dumps(t, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    claw = pool(conv, "clawMachineScripts", "h")
    greetings = pool(conv, "greetingScripts", "g_greetings")
    scripts = {
        "welcome": pool(conv, "signupScripts", "a"),
        "welcomeBack": pool(conv, "loginScripts", "b"),
        "shop": pool(conv, "shopScripts", "c"),
        "settings": pool(conv, "settingsScripts", "d"),
        "selfCare": pool(conv, "selfCareScripts", "e"),
        "affirmations": pool(conv, "dailyAffirmationScripts", "f"),
        "jokes": pool(conv, "jokeScripts", "g"),
        "goodbye": pool(conv, "goodbyeScripts", "i"),
        "greetings": {"morning": greetings[0], "afternoon": greetings[1], "evening": greetings[2]},
        "clawMachine": {"intro": claw[0], "aim": claw[1], "win": claw[2],
                        "miss": claw[3], "again": claw[4]},
    }
    (OUT / "scripts").mkdir(parents=True, exist_ok=True)
    (OUT / "scripts/en.json").write_text(
        json.dumps(scripts, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {total} conversation nodes and {len(scripts)} script pools")


if __name__ == "__main__":
    main()
