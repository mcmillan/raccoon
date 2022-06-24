import os


class MissingEnvironmentVariableException(BaseException):
    pass


def __get_env_var_or_crash(key: str) -> str:
    value = os.getenv(key)

    if not value:
        raise MissingEnvironmentVariableException(
            f'Environment variable "{key}" not set'
        )

    return value


API_ROOT = __get_env_var_or_crash("API_ROOT")
