import re
from dataclasses import dataclass
from enum import Enum
from functools import cached_property, lru_cache
from pathlib import Path


class InstallResultType(Enum):
    MULTIPLE_BLOCKS_FOUND = "multiple_blocks_found"
    ALREADY_EXISTS = "already_exists"
    REPLACED = "replaced"
    PREVIEW = "preview"
    INSTALLED = "installed"


@dataclass(frozen=True)
class InstallResult:
    """Result of installing a fenced block."""
    
    type: InstallResultType
    block_text: str
    block_content: str
    existing_block_text: str | None = None
    config_name: str = "config"
    target_path: Path | None = None
    edit_flag_name: str = "--edit"


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


def install_block(
    fence: CodeFence,
    source: Path,
    target_path: Path,
    existing_content: str,
    replace: bool = False,
    edit: bool = True,
    config_name: str = "config",
    edit_flag_name: str = "--edit",
) -> InstallResult:
    """Install a fenced block into a configuration file.

    Args:
        fence: CodeFence to identify the block
        source: Path to source file containing the block
        target_path: Path to target configuration file
        existing_content: Current content of the target file
        replace: Whether to replace existing block
        edit: Whether to actually edit the file (False = preview only)
        config_name: Name of config file for error messages
        edit_flag_name: Name of edit flag for prompt messages
        
    Returns:
        InstallResult indicating the outcome of the installation
        
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
            if edit:
                _ = existing_blocks[0].replace(block.content, target_path)
                return InstallResult(
                    type=InstallResultType.REPLACED,
                    block_text=block.text,
                    block_content=block.content,
                    existing_block_text=existing_blocks[0].text,
                    config_name=config_name,
                    target_path=target_path,
                    edit_flag_name=edit_flag_name,
                )
            else:
                # Preview mode with replace - show what would be replaced
                return InstallResult(
                    type=InstallResultType.PREVIEW,
                    block_text=block.text,
                    block_content=block.content,
                    existing_block_text=existing_blocks[0].text,
                    config_name=config_name,
                    target_path=target_path,
                    edit_flag_name=edit_flag_name,
                )
        return InstallResult(
            type=InstallResultType.ALREADY_EXISTS,
            block_text=block.text,
            block_content=block.content,
            existing_block_text=existing_blocks[0].text,
            config_name=config_name,
            target_path=target_path,
            edit_flag_name=edit_flag_name,
        )

    if not edit:
        return InstallResult(
            type=InstallResultType.PREVIEW,
            block_text=block.text,
            block_content=block.content,
            config_name=config_name,
            target_path=target_path,
            edit_flag_name=edit_flag_name,
        )

    block.append_to(target_path)
    return InstallResult(
        type=InstallResultType.INSTALLED,
        block_text=block.text,
        block_content=block.content,
        config_name=config_name,
        target_path=target_path,
        edit_flag_name=edit_flag_name,
    )
