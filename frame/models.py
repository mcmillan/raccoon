import arrow
from typing import Tuple
from dataclasses import dataclass
from functools import reduce
import colors


@dataclass
class Collection:
    id: str
    colour: str
    date: arrow.Arrow

    @property
    def background_color(self) -> Tuple[int, int, int]:
        match self.id:
            case "green":
                return colors.GREEN
            case "brown":
                return colors.ORANGE
            case "blue":
                return colors.BLUE
            case _:
                return colors.BLACK

    @property
    def text_color(self) -> Tuple[int, int, int]:
        return colors.WHITE


class Collections:
    updated_at: arrow.Arrow
    __collections: list[Collection]

    @classmethod
    def from_dicts(cls, dicts: list[dict], updated_at: arrow.Arrow):
        return cls(list(map(lambda dict: Collection(**dict), dicts)), updated_at)

    def __init__(self, collections: list[Collection], updated_at: arrow.Arrow):
        self.updated_at = updated_at
        self.__collections = collections
        self.__collections.sort(key=lambda c: c.date)

    @property
    def all(self) -> list[Collection]:
        return self.__collections

    @property
    def next(self) -> list[Collection]:
        def reduce_handler(acc: list[Collection], collection: Collection) -> list[Collection]:
            if len(acc) == 0 or acc[-1].date == collection.date:
                acc.append(collection)
            return acc

        return reduce(reduce_handler, self.__collections, list())

    @property
    def stale(self) -> bool:
        return self.updated_at < arrow.utcnow().shift(hours=-12)
