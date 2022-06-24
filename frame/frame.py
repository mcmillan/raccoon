import api
from models import Collections


if __name__ == '__main__':
    data, meta = api.get_collections()
    collections = Collections.from_dicts(data)

    print(collections.next)
