import re

from functools import cached_property, lru_cache
from dataclasses import dataclass


@dataclass
class FencedBlock:
    content_location: tuple[int, int]
    block_location: tuple[int, int]
    content: str
    text: str


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

    def find_starts(self, content: str):
        matches = self._find_matches(self.start_pattern, content)

        if self.is_symettric:
            # if start and end are the same, the starts the first match, then every second match
            return matches[::2]
        
        # otherwise, the starts are all the matches
        return matches

            
    def find_ends(self, content: str):
        matches = self._find_matches(self.end_pattern, content)
        if self.is_symettric:
            # if start and end are the same, the ends are every second match (skipping the first)
            return matches[1::2]
        return self.start_pattern.finditer(content)

    def find_blocks(self, content: str):
        starts= self.find_starts(content)
        ends = self.find_ends(content)
        # TODO: handle missing end blocks
        # atleast the last end could be omitted
        startends = zip(starts, ends)

        return [
            FencedBlock(
                content_location=(
                    smatch.end(0),
                    ematch.start(0)
                ),
                block_location=(
                    smatch.start(0),
                    ematch.end(0)
                ),
                text=content[smatch.start(0):ematch.end(0)],
                content=content[smatch.end(0):ematch.start(0)]

            )
            for smatch, ematch in startends
        ]
