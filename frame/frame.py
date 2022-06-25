import api
from renderer import render_error, render_collections
from models import Collections
from inky.auto import auto as inky

if __name__ == "__main__":
    display = inky()

    try:
        data, meta = api.get_collections()
        collections = Collections.from_dicts(data, meta["updated_at"])
        image = render_collections(collections)
    except BaseException as error:
        image = render_error(error)

    display.set_image(image)

    display.show()
