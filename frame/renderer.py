import math
from pathlib import Path
import textwrap
from typing import Tuple
from PIL import Image, ImageDraw, ImageFont
from functools import reduce
import colors
from models import Collections


def __load_font(name: str, size: int) -> ImageFont.FreeTypeFont:
    path = str(Path(__file__).parent / "fonts" / name)
    return ImageFont.truetype(path, size)


SIZE = (600, 448)
FONT_HEADING = __load_font("IBMPlexSans-Bold.ttf", 36)
FONT_BODY = __load_font("IBMPlexSans-Regular.ttf", 24)
FONT_WARNING = __load_font("IBMPlexSans-Bold.ttf", 15)
GUTTER = 30
WARNING_SIZE = 40


def render_collections(collections: Collections) -> Image.Image:
    (image, draw) = __create_canvas()
    segment_count = len(collections.all)
    warning_offset = WARNING_SIZE / segment_count if collections.stale else 0
    segment_size = math.ceil(SIZE[1] / segment_count) - warning_offset

    for index, collection in enumerate(collections.all):
        background_y = segment_size * index
        center_y = background_y + (segment_size / 2)

        draw.rectangle(
            xy=(0, background_y, SIZE[0], background_y + segment_size),
            fill=collection.background_color,
        )

        draw.text(
            xy=(GUTTER, center_y),
            text=collection.colour,
            font=FONT_HEADING,
            fill=collection.text_color,
            anchor="lm",
        )

        draw.text(
            xy=(SIZE[0] - GUTTER, center_y),
            text=collection.date.humanize(granularity="day"),
            font=FONT_BODY,
            fill=collection.text_color,
            anchor="rm",
        )

    if collections.stale:
        background_y = segment_size * segment_count
        center_x = SIZE[0] / 2
        center_y = background_y + (WARNING_SIZE / 2)

        draw.rectangle(
            xy=(0, background_y, SIZE[0], background_y + WARNING_SIZE), fill=colors.RED
        )

        draw.line(
            xy=(0, background_y, SIZE[0], background_y), width=1, fill=colors.WHITE
        )

        draw.text(
            xy=(center_x, center_y),
            text=f"Data might be stale. Last updated at {collections.updated_at.format()}",
            fill=colors.WHITE,
            font=FONT_WARNING,
            anchor="mm",
        )

    return image


def render_error(exception: BaseException) -> Image.Image:
    (image, draw) = __create_canvas(colors.RED)

    draw.text(
        xy=(GUTTER, GUTTER),
        text=exception.__class__.__name__,
        fill=colors.WHITE,
        font=FONT_HEADING,
    )

    draw.text(
        xy=(GUTTER, GUTTER + 60),
        text="\n".join(textwrap.wrap(exception.args[0], 24)),
        fill=colors.WHITE,
        font=FONT_BODY,
    )

    return image


def __create_canvas(
    background_color: Tuple[int, int, int] = colors.WHITE
) -> Tuple[Image.Image, ImageDraw.ImageDraw]:
    image = Image.new("RGB", SIZE, background_color)
    draw = ImageDraw.Draw(image)
    return (image, draw)
