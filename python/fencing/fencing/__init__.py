import re
from dataclasses import dataclass
from functools import cached_property, lru_cache
from pathlib import Path


class Change:
    """Represents a change to be applied to a file.
    
    This is a command pattern - the change is computed in memory,
    and apply() persists it to disk.
    """

    def __init__(self, target_path: Path, old_content: str, new_content: str, block_text: str | None = None):
        self.target_path = target_path
        self.old_content = old_content
        self.new_content = new_content
        self.block_text = block_text  # The block that was added/replaced, for pretty printing

    def apply(self) -> None:
        """Persist the change to disk."""
        self.target_path.write_text(self.new_content)

    def describe(self) -> str:
        """Return a description of what this change would do."""
        if self.old_content == "":
            return f"Create {self.target_path}"
        elif self.old_content == self.new_content:
            return f"No change to {self.target_path}"
        else:
            return f"Update {self.target_path}"

    def pretty_diff(self) -> str:
        """Return a pretty-printed representation of what changed."""
        if self.block_text:
            return self.block_text
        # Fallback: show the diff if block_text not available
        if self.old_content == "":
            return self.new_content
        # Simple diff: show what was added
        if len(self.new_content) > len(self.old_content):
            return self.new_content[len(self.old_content):].lstrip("\n")
        return self.new_content


@dataclass(frozen=True)
class FencedBlock:
    content_location: tuple[int, int]
    block_location: tuple[int, int]
    content: str
    text: str
    source_path: Path | None = None

    def append_to(self, path: Path):
        """
        Write the block to the bottom of the file at path
        """
        with path.open("a") as f:
            _ = f.write("\n" + self.text)

    def replace(self, content: str, source: Path | str):
        if isinstance(source, Path):
            file_content = source.read_text()
        else:
            file_content = source

        prefix = file_content[0 : self.content_location[0]]
        postfix = file_content[self.content_location[1] :]

        new_file_content = prefix + content + postfix

        if isinstance(source, Path):
            _ = source.write_text(new_file_content)

        return new_file_content


@dataclass(frozen=True)
class CodeFence:
    start: str
    end: str

    @cached_property
    def start_pattern(self):
        return re.compile(self.start)

    @cached_property
    def end_pattern(self):
        return re.compile(self.end)

    @property
    def is_symettric(self):
        return self.start == self.end

    @lru_cache
    def _find_matches(self, pattern: re.Pattern[str], content: str):
        """
        currently just re.finditer; here in case this changes later.

        this method also handles the caching.
        """
        return list(pattern.finditer(content))

    def _find_starts(self, content: str):
        matches = self._find_matches(self.start_pattern, content)

        if self.is_symettric:
            # if start and end are the same, the starts the first match, then every second match
            return matches[::2]

        # otherwise, the starts are all the matches
        return matches

    def _find_ends(self, content: str):
        matches = self._find_matches(self.end_pattern, content)
        if self.is_symettric:
            # if start and end are the same, the ends are every second match (skipping the first)
            return matches[1::2]
        return self.start_pattern.finditer(content)

    def find_blocks(self, content: str, source_path: Path | None = None):
        starts = self._find_starts(content)
        ends = self._find_ends(content)
        # TODO: handle missing end blocks
        # atleast the last end could be omitted
        startends = zip(starts, ends)

        return [
            FencedBlock(
                content_location=(smatch.end(0), ematch.start(0)),
                block_location=(smatch.start(0), ematch.end(0)),
                text=content[smatch.start(0) : ematch.end(0)],
                content=content[smatch.end(0) : ematch.start(0)],
                source_path=source_path,
            )
            for smatch, ematch in startends
        ]


def copy_block(
    fence: CodeFence,
    source: Path,
    target_path: Path,
    existing_content: str,
    replace: bool = False,
    config_name: str = "config",
) -> Change | None:
    """Copy a fenced block into a target file.

    Args:
        fence: CodeFence to identify the block
        source: Path to source file containing the block
        target_path: Path to target configuration file
        existing_content: Current content of the target file
        replace: Whether to replace existing block if found
        config_name: Name of config file for error messages

    Returns:
        Change object if a change is needed, None if already installed and replace=False

    Raises:
        ValueError: If multiple blocks matching the fence are found
    """
    block = fence.find_blocks(source.read_text())[0]
    existing_blocks = fence.find_blocks(existing_content)
    # expect zero or one existing_blocks
    if len(existing_blocks) > 1:
        existing_texts = "\n...".join((block.text for block in existing_blocks))
        raise ValueError(
            f"Your {config_name} has two or more existing blocks matching the {fence}, I don't know what to do here"
        )

    if existing_blocks:
        if replace:
            # Compute new content by replacing the existing block
            prefix = existing_content[0 : existing_blocks[0].content_location[0]]
            postfix = existing_content[existing_blocks[0].content_location[1] :]
            new_content = prefix + block.content + postfix
            return Change(target_path, existing_content, new_content, block.text)
        return None  # Already exists and not replacing

    # Compute new content by appending the block
    new_content = existing_content + "\n" + block.text if existing_content else block.text
    return Change(target_path, existing_content, new_content, block.text)
