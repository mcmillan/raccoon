import requests
from typing import Any, Tuple

API_ROOT = 'https://api.raccoon.pinyapple.com'


class ApiException(BaseException):
    pass


def get_collections() -> Tuple[list[dict], dict]:
    return _handle_response(
        requests.get(_url_for('/collections'))
    )


def _handle_response(response: requests.Response) -> Tuple[Any, dict]:
    if response.status_code != 200:
        raise ApiException(
            f'Non-200 response code received from API: {response.status_code}'
        )

    json = response.json()

    return (json['data'], json['meta'])


def _url_for(endpoint: str) -> str:
    return API_ROOT + endpoint
