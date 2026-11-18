#!/usr/bin/env python3
"""List the project's Codex roles or print one brief for a text-only handoff."""
import argparse
from pathlib import Path
import tomllib


def project_roles():
    directory = Path(__file__).resolve().parents[1] / ".codex"
    with (directory / "config.toml").open("rb") as file:
        catalog = tomllib.load(file)["agents"]

    roles = {}
    for name, entry in catalog.items():
        if not isinstance(entry, dict) or "config_file" not in entry:
            continue
        with (directory / entry["config_file"]).open("rb") as file:
            config = tomllib.load(file)
        description = entry["description"].strip()
        instructions = config["developer_instructions"].strip()
        if not description or not instructions:
            raise ValueError(f"{name} 的职责或交接指令为空")
        roles[name] = (description, instructions)
    if not roles:
        raise ValueError("项目尚未登记岗位")
    return roles


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    try:
        roles = project_roles()
    except (KeyError, OSError, ValueError) as error:
        parser.error(str(error))
    parser.add_argument("--brief", choices=roles, help="打印指定岗位的完整交接指令")
    args = parser.parse_args()
    if args.brief:
        description, instructions = roles[args.brief]
        print(f"{args.brief} · {description}\n\n{instructions}")
    else:
        for name, (description, _) in roles.items():
            print(f"{name:<17} {description}")


if __name__ == "__main__":
    main()
