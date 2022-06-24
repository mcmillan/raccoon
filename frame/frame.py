import api
from renderer import render_error, render_collections
from models import Collections

if __name__ == '__main__':
    try:
        data, meta = api.get_collections()
        collections = Collections.from_dicts(data, meta['updated_at'])
        image = render_collections(collections)
    except BaseException as error:
        image = render_error(error)

    image.show()
