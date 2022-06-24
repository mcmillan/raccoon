import requests
import arrow
from typing import Any, Tuple
import config


class ApiException(BaseException):
    pass


def get_collections() -> Tuple[list[dict], dict]:
    return _handle_response(
        requests.get(_url_for('/collections'))
    )


def _handle_response(response: requests.Response) -> Tuple[Any, dict]:
    def parse_datetimes(json_object: dict) -> dict:
        for (key, value) in json_object.items():
            try:
                json_object[key] = arrow.get(value)
            except:
                pass

        return json_object

    if response.status_code != 200:
        raise ApiException(
            f'Non-200 response code received from API: {response.status_code}'
        )

    json = response.json(object_hook=parse_datetimes)

    return (json['data'], json['meta'])


def _url_for(endpoint: str) -> str:
    return config.API_ROOT + endpoint
