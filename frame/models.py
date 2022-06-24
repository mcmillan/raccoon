from dataclasses import dataclass
from datetime import datetime
from functools import reduce


@dataclass
class Collection:
    id: str
    colour: str
    date: datetime


class Collections:
    __collections: list[Collection]

    @classmethod
    def from_dicts(cls, dicts: list[dict]):
        def transform_dict(dict: dict) -> Collection:
            try:
                dict['date'] = datetime.fromisoformat(dict['date'])
            except:
                pass

            return Collection(**dict)

        return cls(list(map(transform_dict, dicts)))

    def __init__(self, collections: list[Collection]):
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