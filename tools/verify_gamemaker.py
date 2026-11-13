"""Static GM1.4 resource/content checks; this does not compile or execute GML."""
from pathlib import Path
import configparser
import re
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]


def verify():
    manifest = ET.parse(ROOT / "RTSTemplate.project.gmx").getroot()
    scripts = [node.text for node in manifest.findall(".//script")]
    assert len(scripts) == len(set(scripts)), "Duplicate script registration"
    for name in scripts:
        assert (ROOT / name.replace(chr(92), "/")).is_file(), f"Missing script: {name}"
    for kind, suffix in [("object", ".object.gmx"), ("room", ".room.gmx"), ("sprite", ".sprite.gmx")]:
        for node in manifest.findall(f".//{kind}"):
            path = ROOT / (node.text.replace(chr(92), "/") + suffix)
            assert path.is_file(), f"Missing resource: {path}"
            resource = ET.parse(path).getroot()
            if kind == "object":
                events = [(ev.get("eventtype"), ev.get("enumb")) for ev in resource.findall("events/event")]
                assert len(events) == len(set(events)), f"Duplicate event: {path}"
    included = manifest.find("datafiles")
    assert int(included.get("number")) == len(included.findall("datafile")), "Included file count mismatch"
    for node in included.findall("datafile"):
        assert (ROOT / "datafiles" / node.findtext("filename")).is_file(), "Missing included file"
    registered = {Path(name.replace(chr(92), "/")).stem for name in scripts}
    source = {}
    for path in (ROOT / "scripts").glob("rts_*.gml"):
        assert path.stem in registered, f"Unregistered RTS script: {path}"
        # Strip comments and strings before checking resource calls/delimiters.
        text = re.sub(r'/\*.*?\*/|//[^\n]*|"[^"\n]*"', '', path.read_text(), flags=re.S)
        source[path.stem] = text
        for call in re.findall(r'\b(rts_\w+)\s*\(', text):
            assert call in registered, f"Unregistered call: {call} in {path}"
        stack = []
        for char in text:
            if char in "([{":
                stack.append(char)
            elif char in ")]}":
                assert stack and stack.pop() == {")": "(", "]": "[", "}": "{"}[char], f"Unbalanced GML: {path}"
        assert not stack, f"Unclosed GML delimiter: {path}"
    resolver = (ROOT / "scripts/rts_template_resolve.gml").read_text()
    traits = set(re.findall(r'case "([^"]+)"', resolver))
    definitions = {}
    for path in (ROOT / "datafiles").glob("core_*.ini"):
        data = configparser.ConfigParser()
        data.read(path)
        key = data["unit"]["id"]
        assert key not in definitions, f"Duplicate definition ID: {key}"
        count = data.getint("unit", "template_count")
        declared = [data["templates"][str(i)] for i in range(count)]
        assert len(declared) == len(set(declared)), f"Duplicate trait: {key}"
        assert set(declared) <= traits, f"Unknown trait: {key}"
        assert "health" in declared, f"Missing health trait: {key}"
        assert data.getfloat("stats", "hp") > 0
        definitions[key] = data
    for key, data in definitions.items():
        product = data.get("production", "product", fallback="")
        assert not product or product in definitions, f"Unknown product: {key} -> {product}"
    print(f"PASS: {len(scripts)} registered scripts, GMX resource/event integrity, "
          f"{len(source)} RTS script delimiters/calls, {len(definitions)} packaged definitions")
    print("Compiler/runtime behavior must be checked in GameMaker Studio 1.4.")


if __name__ == "__main__":
    verify()
